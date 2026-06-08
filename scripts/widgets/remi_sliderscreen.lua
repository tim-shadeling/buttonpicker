local Screen = require "widgets/screen"
local Text = require "widgets/text"
local TextEdit = require "widgets/textedit"
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"

local slider_length = 500
local default_precision = 4

local function adjust(cur, min, step)
	cur = cur - min + step*0.5
	return cur - cur%step + min
end

local function round(num, precision)
	-- return math.floor(num/precision + 0.5) * precision -- don't trust floating-point calculations, actually faced issues like typing 2.3 into the textbox produces 2.29 somehow
	return tonumber(string.format("%."..precision.."f", num))
end

local SliderScreen = Class(Screen, function(self, title_text, body_text, buttons, slider_data, current_value)
	Screen._ctor(self, "RemiSliderScreen")

	-- option value limits
	self.option_min, self.option_max, self.option_step = unpack(slider_data)

	-- safety checks
	if not (type(self.option_min) == "number" and type(self.option_max) == "number" and self.option_min < self.option_max) or not (type(self.option_step) == "number" and self.option_step > 0 or type(self.option_step) == "nil") then
		self.bad = true
		self.option_cur = current_value
	else
		self.option_cur = self.option_step and adjust(current_value, self.option_min, self.option_step) or math.clamp(current_value, self.option_min, self.option_max)
		self.option_cur = round(self.option_cur, default_precision)
	
		self.step_pct = self.option_step and self.option_step/(self.option_max - self.option_min)
		if self.step_pct and self.step_pct < 1/500 then -- disallow creation of more than 500 steps, and make it continuous
			self.option_step = nil
			self.step_pct = nil
		end
	end

	-- position marker limits
	self.marker_min, self.marker_max, self.marker_step = -slider_length*.5, slider_length*.5, self.step_pct and self.step_pct*slider_length

	-- slider limits in actual screen coords, filled during slider creation
	self.slider_min, self.slider_max, self.slider_step = 0, 0, nil

	self.black = self:AddChild(TEMPLATES.BackgroundTint())
	self.proot = self:AddChild(TEMPLATES.ScreenRoot())

	self.buttons = buttons or {}
	table.insert(self.buttons, {
		text=STRINGS.UI.HELP.BACK,
		cb = function()
			self:_Cancel()
		end,
		controller_control = CONTROL_CANCEL,
	})

	local bg_width = 570
	local body_height = 220
	self.dialog = self.proot:AddChild(TEMPLATES.CurlyWindow(bg_width, body_height,
		title_text,
		self.buttons,
		nil,
		body_text or "" -- force creation of body to re-use sizing data
	))
	self.dialog.body:SetSize(20)
	self.dialog.body:SetPosition(0, 80)
	self.dialog.body:SetRegionSize(bg_width+50, 40)

	if self.bad then
		self.dialog.body:SetString(STRINGS.BUTTONPICKER.BAD_SLIDER_DATA.."\n"..tostring(self.option_min)..", "..tostring(self.option_max)..", "..tostring(self.option_step))
		return
	end

	-- when using continuous slider, the exact value needed can be typed into a textbox
	local value_display
	if self.option_step == nil then
		value_display = self.proot:AddChild(TextEdit(CHATFONT, 25, "", UICOLOURS.GOLD_CLICKABLE))
		value_display:SetForceEdit(true)
		value_display:SetRegionSize(slider_length*0.75, 30)
		value_display:SetIdleTextColour(UICOLOURS.GOLD_CLICKABLE)
		value_display:SetEditTextColour(UICOLOURS.WHITE)
		value_display:SetEditCursorColour(UICOLOURS.WHITE)
		value_display:SetCharacterFilter("-1234567890.")
		value_display.OnTextInputted = function() self:TryUpdateSliderFromTextbox() end
		--
		local oldfn = value_display.SetEditing
		value_display.SetEditing = function(widget, editing)
			oldfn(widget, editing)
			if editing then 
				self.slider_clickbox:Disable() 
			else 
				self.slider_clickbox:Enable() 
				if widget:GetString() == "" then
					widget:SetString(string.format("%."..default_precision.."f", self.option_cur))
					widget:SetColour(UICOLOURS.WHITE)
					widget:SetEditTextColour(UICOLOURS.WHITE)
				end
			end
		end
	else -- otherwise it's just a label
		value_display = self.proot:AddChild(Text(CHATFONT, 25, "", UICOLOURS.WHITE))
		value_display:SetRegionSize(slider_length*0.5, 30)
	end	
	value_display:SetPosition(0, -35)
	value_display:SetHAlign(ANCHOR_MIDDLE)
	value_display:SetString(self.option_step and self.option_cur or string.format("%."..default_precision.."f", self.option_cur))
	value_display.last_safe_string = value_display:GetString()
	self.value_display = value_display

	self:MakeSlider()

	self.default_focus = self.slider
end)

function SliderScreen:MakeSlider()
	local decor_nudge = 10
	local label_nudge = -25
	local textsize = 20

	self.slider = self.proot:AddChild(Widget("slider"))
	self.slider:SetPosition(0, 15)

	self.slider_left_decor = self.slider:AddChild(Image("images/ui.xml", "crafting_inventory_arrow_r_hl.tex"))
	self.slider_left_decor:SetPosition(self.marker_min - decor_nudge, 0)
	self.slider_left_decor:SetScale(0.4)

	self.slider_left_label = self.slider:AddChild(Text(CHATFONT, textsize, round(self.option_min, default_precision)))
	self.slider_left_label:SetPosition(self.marker_min, label_nudge)

	self.slider_right_decor = self.slider:AddChild(Image("images/ui.xml", "crafting_inventory_arrow_l_hl.tex"))
	self.slider_right_decor:SetPosition(self.marker_max + decor_nudge, 0)
	self.slider_right_decor:SetScale(0.4)

	self.slider_right_label = self.slider:AddChild(Text(CHATFONT, textsize, round(self.option_max, default_precision)))
	self.slider_right_label:SetPosition(self.marker_max, label_nudge)

	self.slider_line = self.slider:AddChild(Image("images/global.xml", "square.tex"))
	self.slider_line:SetTint(.3,.3,.3, 1)
	self.slider_line:SetSize(slider_length, 4)

	-- add notches representing steps 
	if self.marker_step and self.step_pct > 1/50 then -- no notches starting from 50 steps!
		self.notches = {}
		--
		local i = 0
		local pos = self.marker_min
		while pos <= self.marker_max+0.1 do -- slider length is 400, max amount of steps is 200, so min step length is 2
			local notch = self.slider:AddChild(Image("images/global.xml", "square.tex"))
			notch:SetSize(3, 8)
			notch:SetPosition(pos, 0)
			--
			i = i + 1
			pos = self.marker_min + i * self.marker_step
			--
			self.notches[i] = notch
		end

		local tint = math.clamp((35 - i)/30, 0.3, 1) -- peaks at 1 at 5 notches, goes down to 0.3 at 26 notches (also 0.5 at 20)
		for k,v in pairs(self.notches) do v:SetTint(tint, tint, tint, 1) end
	end

--	self.position_marker = self.slider:AddChild(ImageButton("images/global_redux.xml", "scrollbar_handle.tex"))
--	self.position_marker.scale_on_focus = false
--	self.position_marker.move_on_click = false
--	self.position_marker.show_stuff = true
--	self.position_marker:SetScale(0.3, 0.3, 1)
--	self.position_marker:SetOnDown(function()
--		TheFrontEnd:LockFocus(true)
--	end)
--	self.position_marker:SetWhileDown(function()
--		self:DoDragSlide()
--	end)
--	self.position_marker:SetOnClick(function()
--		TheFrontEnd:LockFocus(false)
--	end)
--	self.position_marker.OnLoseFocus = function() end
--	self.position_marker.ResetPreClickPosition = function() end -- no thanks!

	self.position_marker = self.slider:AddChild(Image("images/global_redux.xml", "scrollbar_handle.tex"))
	self.position_marker:SetScale(0.3, 0.3, 1)

	-- get actual coords for leftmost and rightmost marker positions
	self.position_marker:SetPosition(-slider_length/2, 0)
	local markerpos = self.position_marker:GetWorldPosition()
	self.slider_min = markerpos.x
	self.position_marker:SetPosition(slider_length/2, 0)
	markerpos = self.position_marker:GetWorldPosition()
	self.slider_max = markerpos.x
	self.slider_step = self.step_pct and self.step_pct*(self.slider_max - self.slider_min)

	-- move the marker according to current value, option_cur is already adjusted
	local pct = math.clamp((self.option_cur - self.option_min)/(self.option_max - self.option_min), 0, 1)
	self.position_marker:SetPosition(slider_length*(pct-0.5), 0)

	-- invisible rectangle that does all the magic yay
	self.slider_clickbox = self.slider:AddChild(ImageButton("images/global.xml", "square.tex"))
	self.slider_clickbox.image:ScaleToSize(slider_length+2*decor_nudge, 32)
	self.slider_clickbox.image:SetTint(1,1,1,0)
	self.slider_clickbox.scale_on_focus = false
	self.slider_clickbox.move_on_click = false
	self.slider_clickbox:SetOnDown(function()
		TheFrontEnd:LockFocus(true)
	end)
	self.slider_clickbox:SetWhileDown(function()
		self:DoDragSlide()
	end)
	self.slider_clickbox:SetOnClick(function()
		TheFrontEnd:LockFocus(false)
	end)
end

function SliderScreen:GetSliderValue() -- not the actual option value
	local pos = self.slider_step and adjust(TheFrontEnd.lastx, self.slider_min, self.slider_step) or TheFrontEnd.lastx
	return math.clamp((pos - self.slider_min)/(self.slider_max - self.slider_min), 0, 1)
end

function SliderScreen:DoDragSlide()
	local slider_value = self:GetSliderValue()
	self.position_marker:SetPosition(slider_length*(slider_value-0.5), 0)
	self:UpdateOptionValueFromSlider(slider_value)
end

function SliderScreen:UpdateOptionValueFromSlider(slider_value) -- the actual option value
	self.option_cur = round(self.option_min + slider_value * (self.option_max - self.option_min), default_precision)
	self.value_display:SetString(self.option_step and self.option_cur or string.format("%."..default_precision.."f", self.option_cur))
end

function SliderScreen:GetCurrentValue()
	return self.option_cur
end

function SliderScreen:TryUpdateSliderFromTextbox()
	local newvalue = tonumber(self.value_display:GetString())
	if newvalue ~= nil then
		local processed_value = round(math.clamp(newvalue, self.option_min, self.option_max), default_precision)
		local pct = (processed_value - self.option_min)/(self.option_max - self.option_min)
		self.position_marker:SetPosition(slider_length*(pct-0.5), 0)
		self.option_cur = processed_value
		--
		self.value_display:SetColour(UICOLOURS.WHITE)
		self.value_display:SetEditTextColour(UICOLOURS.WHITE)
	else
		self.value_display:SetColour(UICOLOURS.RED)
		self.value_display:SetEditTextColour(UICOLOURS.RED)
	end
end

function SliderScreen:OnControl(control, down)
	if SliderScreen._base.OnControl(self,control, down) then
		return true
	end

	if not down and control == CONTROL_CANCEL then
		self:_Cancel()
		return true
	end
end

function SliderScreen:_Cancel()
	TheFrontEnd:PopScreen(self)
end

return SliderScreen
