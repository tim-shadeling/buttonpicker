local TEMPLATES = require "widgets/redux/templates"
local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Image = require "widgets/image"
local TextEdit = require "widgets/textedit"

local RemiColorHelperScreen = Class(Screen, function(self, title, hover, buttons, initial_color, include_alpha, return_hex)
	Screen._ctor(self, "RemiColorHelperScreen")

	self.return_hex = return_hex

	self.tint = self:AddChild(TEMPLATES.BackgroundTint())
	self.proot = self:AddChild(TEMPLATES.ScreenRoot())
	
	self.dialog = self.proot:AddChild(TEMPLATES.CurlyWindow(400,450, title, buttons))

	if hover and hover ~= "" then
		local info_hover = self.proot:AddChild(Text(BODYTEXTFONT, 25, "(i)"))
		info_hover:SetPosition(0.5*400+25, 0.5*450+35)
		info_hover:SetColour(UICOLOURS.GOLD_FOCUS)
		info_hover:SetHoverText(hover, {
			font = BODYTEXTFONT,
			wordwrap = true,
			region_w = 665, -- same as on the config screen
			region_h = 50, -- same as on the config screen
		})
		info_hover.hovertext_bg:SetSize(665*1.2, 50*2.25)
		rawset(_G, "info_hover", info_hover)
		self.info_hover = info_hover
	end

	if return_hex then -- initial_color is hex color string, convert to actual color table
		local r, g, b = HexToPercentColor(initial_color)
		initial_color = {r, g, b, 1}
	else
		initial_color = shallowcopy(initial_color)
	end
	initial_color = type(initial_color) == "table" and initial_color or {1,1,1,1}
	for i = 1,4 do initial_color[i] = initial_color[i] or 1 end

	local newcolor = self.proot:AddChild(Image("images/global.xml", "square.tex"))
	newcolor:SetPosition(100,140)
	newcolor:ScaleToSize(200,100)
	newcolor:SetTint(unpack(initial_color))
	newcolor.ep_current_color = initial_color
	self.newcolor = newcolor
	self.newcolor_lbl = self.proot:AddChild(Text(CHATFONT, 25, STRINGS.BUTTONPICKER.NEWCOLOR_LBL_STRING))
	self.newcolor_lbl:SetPosition(100,210)
	local oldcolor = self.proot:AddChild(Image("images/global.xml", "square.tex"))
	oldcolor:SetPosition(-100,140)
	oldcolor:ScaleToSize(200,100)
	oldcolor:SetTint(unpack(initial_color))
	self.oldcolor = oldcolor
	self.oldcolor_lbl = self.proot:AddChild(Text(CHATFONT, 25, STRINGS.BUTTONPICKER.OLDCOLOR_LBL_STRING))
	self.oldcolor_lbl:SetPosition(-100,210)

	self.colorlabels = {}
	self.colorpickers = {}

	self.scroll_info = self.proot:AddChild(Text(CHATFONT, 18, STRINGS.BUTTONPICKER.SCROLL_INFO_STRING))
	self.scroll_info:SetPosition(0, 40)

	local channels = include_alpha and 4 or 3
	for i = 1,channels do
		local color_limit = i == 4 and 100 or 255

		local label = self.proot:AddChild(Text(CHATFONT, 25, STRINGS.BUTTONPICKER.COLOR_NAMES[i]))
		label:SetRegionSize(100,40)
		label:SetHAlign(1)
		label:SetPosition(-150, -50*(i-1))
		self.colorlabels[i] = label

		local colorpicker_bg = self.proot:AddChild(Image())
		colorpicker_bg:SetTexture("images/global_redux.xml", "textbox3_gold_normal.tex")
		colorpicker_bg:ScaleToSize(200, 40)
		colorpicker_bg:SetPosition(100, -50*(i-1))

		local colorpicker = self.proot:AddChild(TextEdit(CHATFONT, 25, ""))
		colorpicker.actualvalue = math.floor(initial_color[i]*color_limit + .5)
		colorpicker:SetString(tostring(colorpicker.actualvalue))
		colorpicker:SetFocusedImage(colorpicker_bg, "images/global_redux.xml", "textbox3_gold_normal.tex", "textbox3_gold_hover.tex", "textbox3_gold_focus.tex" )
		colorpicker:SetRegionSize(180, 40)
		colorpicker:SetAllowNewline(false)
		colorpicker:SetForceEdit(true)
		colorpicker:SetTextLengthLimit(5)
		colorpicker:SetHAlign(1)
		colorpicker:SetCharacterFilter("1234567890")
		colorpicker.OnTextInputted = function()
			local val = tonumber(colorpicker:GetString())
			if val then label:SetColour(1,1,1,1) else label:SetColour(1,0,0,1) end
			val = val or 0
			if val > color_limit then val = color_limit end
			colorpicker:SetString(tostring(val))
			colorpicker.actualvalue = val
			newcolor.ep_current_color[i] = val/color_limit
			newcolor:SetTint(unpack(newcolor.ep_current_color))
		end
		local oldfn = colorpicker.OnControl
		colorpicker.OnControl = function(self, control, down)
			if not down and (control == CONTROL_SCROLLFWD or control == CONTROL_SCROLLBACK) then
				local delta = TheInput:IsKeyDown(KEY_CTRL) and 1 or 10
				self.actualvalue = math.clamp(self.actualvalue + (control == CONTROL_SCROLLFWD and -delta or delta), 0, color_limit)
				self:SetString(tostring(self.actualvalue))
				--self.actualvalue = tonumber(self:GetString()) or self.actualvalue
				newcolor.ep_current_color[i] = self.actualvalue/color_limit
				newcolor:SetTint(unpack(newcolor.ep_current_color))
				return true
			end
			return oldfn and oldfn(self, control, down)
		end
		colorpicker:SetPosition(100, -50*(i-1))
		self.colorpickers[i] = colorpicker
	end
	for i = 1, channels do
		local prev_picker, cur_picker, next_picker = self.colorpickers[i-1], self.colorpickers[i], self.colorpickers[i+1]
		if prev_picker then cur_picker:SetFocusChangeDir(MOVE_UP, prev_picker) end
		if next_picker then 
			cur_picker:SetFocusChangeDir(MOVE_DOWN, next_picker)
		else
			cur_picker:SetFocusChangeDir(MOVE_DOWN, self.dialog.actions)
			self.dialog.actions:SetFocusChangeDir(MOVE_UP, cur_picker)
		end
	end
	
	--local w,h = TheSim:GetScreenSize()
	--self.proot:SetScale(w/RESOLUTION_X) -- h/RESOLUTION_Y
end)

function RemiColorHelperScreen:GetCurrentColor()
	local color = self.newcolor.ep_current_color
	if self.return_hex then
		local colorstr = "#"
		for i = 1,3 do
			local val = string.format("%x", math.floor(color[i]*255 + .5))
			val = string.rep("0", 2-val:len())..val
			colorstr = colorstr..val 
		end
		return colorstr
	end
	return color
end

function RemiColorHelperScreen:OnControl(control, down)
	if RemiColorHelperScreen._base.OnControl(self,control, down) then
		return true
	end

	if not down and control == CONTROL_CANCEL then
		for k,v in pairs(self.colorpickers) do
			if v.editing then
				return v:OnControl(control, down)
			end
		end
		TheFrontEnd:PopScreen()
		return true
	end
end

return RemiColorHelperScreen