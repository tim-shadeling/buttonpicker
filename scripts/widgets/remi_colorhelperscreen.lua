local TEMPLATES = require "widgets/redux/templates"
local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local TextEdit = require "widgets/textedit"

local SILLY_VISUAL_CHOICES = {
	{
		bank = "pigman",
		build = "pig_build",
		scale = .15,
		offset = Vector3(0, -25, 0),
		facing = FACING_DOWN,
		anims = {"idle_creepy", "idle_happy", "idle_loop", "idle_scared", "walk_loop"},
		hidelayers = {"hat", "ARM_carry_up"},
		hidesymbols = {},
	},

	{
		bank = "manrabbit",
		build = "manrabbit_build",
		scale = .15,
		offset = Vector3(0, -30, 0),
		facing = FACING_DOWN,
		anims = {"alert_loop", "sleep_loop"},
		hidelayers = {"hat", "ARM_carry", "HAIR_HAT"},
		hidesymbols = {},
	},

	{
		bank = "mandrake",
		build = "mandrake",
		scale = .18,
		offset = Vector3(0, -25, 0),
		facing = FACING_DOWN,
		anims = {"idle_loop"},
		hidelayers = {},
		hidesymbols = {},
	},
}
local silly_visual_data -- determined and altered upon screen creation
local silly_visual_anim -- determined and altered upon screen creation

local function ApplySillyVisual(widget)
	local animstate = widget:GetAnimState()
	animstate:SetBank(silly_visual_data.bank)
	animstate:SetBuild(silly_visual_data.build)
	widget:SetScale(silly_visual_data.scale)
	widget:SetPosition(widget.pos_x + silly_visual_data.offset.x, widget.pos_y + silly_visual_data.offset.y)
	widget:SetFacing(silly_visual_data.facing)
	animstate:PlayAnimation(silly_visual_anim, true)
	for _, layer in pairs(silly_visual_data.hidelayers) do animstate:Hide(layer) end
	for _, symbol in pairs(silly_visual_data.hidesymbols) do animstate:HideSymbol(symbol) end
end

local function rgb_to_hex(color) -- uses range 0 to 1
	local colorstr = "#"
	for i = 1,3 do
		local val = string.format("%x", math.floor(color[i]*255 + .5))
		val = string.rep("0", 2-val:len())..val
		colorstr = colorstr..val 
	end
	return colorstr
end

local RemiColorHelperScreen = Class(Screen, function(self, title, hover, buttons, initial_color, include_alpha, return_hex)
	Screen._ctor(self, "RemiColorHelperScreen")
	--
	silly_visual_data = SILLY_VISUAL_CHOICES[math.random(1, #SILLY_VISUAL_CHOICES)]
	silly_visual_anim = silly_visual_data.anims[math.random(1, #silly_visual_data.anims)]

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
		self.info_hover = info_hover
	end

	self.current_color = initial_color
	if return_hex then -- initial_color is hex color string, convert to actual color table
		local r, g, b = HexToPercentColor(self.current_color)
		self.current_color = {r, g, b, 1}
	else
		self.current_color = shallowcopy(self.current_color)
	end
	-- let's make sure the color table is correct
	self.current_color = type(self.current_color) == "table" and self.current_color or {1,1,1,1}
	for i = 1,4 do 
		local v = self.current_color[i]
		if not (type(v) == "number" and v >= 0 and v <= 1) then self.current_color[i] = 1 end
	end
	if not include_alpha then self.current_color[4] = 1 end

	if include_alpha then
		local new_silly_visual = self.proot:AddChild(UIAnim())
		new_silly_visual.pos_x, new_silly_visual.pos_y = 100, 140
		new_silly_visual:SetPosition(new_silly_visual.pos_x, new_silly_visual.pos_y)
		ApplySillyVisual(new_silly_visual)
		self.new_silly_visual = new_silly_visual
	end

	local newcolor = self.proot:AddChild(Image("images/global.xml", "square.tex"))
	newcolor:SetPosition(100,140)
	newcolor:ScaleToSize(200,100)
	newcolor:SetTint(unpack(self.current_color))
	self.newcolor = newcolor
	self.newcolor_lbl = self.proot:AddChild(Text(CHATFONT, 25, STRINGS.BUTTONPICKER.NEWCOLOR_LBL_STRING))
	self.newcolor_lbl:SetPosition(100,210)

	if include_alpha then
		local old_silly_visual = self.proot:AddChild(UIAnim())
		old_silly_visual.pos_x, old_silly_visual.pos_y = -100, 140
		old_silly_visual:SetPosition(old_silly_visual.pos_x, old_silly_visual.pos_y)
		ApplySillyVisual(old_silly_visual)
		self.old_silly_visual = old_silly_visual
	end

	local oldcolor = self.proot:AddChild(Image("images/global.xml", "square.tex"))
	oldcolor:SetPosition(-100,140)
	oldcolor:ScaleToSize(200,100)
	oldcolor:SetTint(unpack(self.current_color))
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
		label:SetRegionSize(150,40)
		label:SetHAlign(1)
		label:SetPosition(-135, -50*(i-1))
		self.colorlabels[i] = label

		local colorpicker_bg = self.proot:AddChild(Image())
		colorpicker_bg:SetTexture("images/global_redux.xml", "textbox3_gold_normal.tex")
		colorpicker_bg:ScaleToSize(200, 40)
		colorpicker_bg:SetPosition(100, -50*(i-1))

		local colorpicker = self.proot:AddChild(TextEdit(CHATFONT, 25, ""))
		colorpicker.actualvalue = math.floor(self.current_color[i]*color_limit + .5)
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
			if val then 
				if val > color_limit then val = color_limit end
				colorpicker:SetString(tostring(val))
				colorpicker.actualvalue = val
				self.current_color[i] = val/color_limit
				self:UpdateColorPreview()
				self:UpdateHexField()
				--
				label:SetColour(UICOLOURS.WHITE) 
			else 
				label:SetColour(UICOLOURS.RED) 
			end
		end
		local oldfn = colorpicker.OnControl
		colorpicker.OnControl = function(widget, control, down)
			if not down and (control == CONTROL_SCROLLFWD or control == CONTROL_SCROLLBACK) then
				local delta = TheInput:IsKeyDown(KEY_CTRL) and 1 or 10
				widget.actualvalue = math.clamp(widget.actualvalue + (control == CONTROL_SCROLLFWD and -delta or delta), 0, color_limit)
				widget:SetString(tostring(widget.actualvalue))
				--widget.actualvalue = tonumber(widget:GetString()) or self.actualvalue
				self.current_color[i] = widget.actualvalue/color_limit
				self:UpdateColorPreview()
				self:UpdateHexField()
				return true
			end
			return oldfn and oldfn(widget, control, down)
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

	-- hex field for rgb and hex pickers
	if not include_alpha then
		local hexlabel = self.proot:AddChild(Text(CHATFONT, 25, STRINGS.BUTTONPICKER.HEX))
		hexlabel:SetRegionSize(100,40)
		hexlabel:SetHAlign(1)
		hexlabel:SetPosition(-150, -150)
		self.hexlabel = hexlabel

		local hexfield_bg = self.proot:AddChild(Image())
		hexfield_bg:SetTexture("images/global_redux.xml", "textbox3_gold_normal.tex")
		hexfield_bg:ScaleToSize(200, 40)
		hexfield_bg:SetPosition(100, -150)
		self.hexfield_bg = hexfield_bg

		local hexfield = self.proot:AddChild(TextEdit(CHATFONT, 25, ""))
		hexfield.actualvalue = return_hex and initial_color or rgb_to_hex(self.current_color)
		hexfield:SetString(hexfield.actualvalue)
		hexfield:SetFocusedImage(hexfield_bg, "images/global_redux.xml", "textbox3_gold_normal.tex", "textbox3_gold_hover.tex", "textbox3_gold_focus.tex" )
		hexfield:SetRegionSize(180, 40)
		hexfield:SetAllowNewline(false)
		hexfield:SetForceEdit(true)
		hexfield:SetTextLengthLimit(7)
		hexfield:SetHAlign(1)
		hexfield:SetCharacterFilter("#1234567890AaBbCcDdEeFf")
		hexfield.OnTextInputted = function()
			local valid = hexfield:GetString():match("#?[0-9a-fA-F]*")
			if valid then 
				valid = valid..string.rep("0", 6-valid:gsub("#", ""):len()) -- the string might be valid but incomplete
				local r, g, b = HexToRGB(valid)
				for k,v in pairs{r, g, b} do
					self.colorpickers[k].actualvalue = v
					self.colorpickers[k]:SetString(v)
					self.current_color[k] = v/255
				end
				self:UpdateColorPreview()
				--
				for i = 1, channels do self.colorlabels[i]:SetColour(UICOLOURS.WHITE) end
				hexlabel:SetColour(UICOLOURS.WHITE) 
			else 
				hexlabel:SetColour(UICOLOURS.RED) 
			end
		end
		hexfield:SetPosition(100, -150)
		self.hexfield = hexfield
	end
end)

function RemiColorHelperScreen:UpdateColorPreview()
	self.newcolor:SetTint(unpack(self.current_color))
end

function RemiColorHelperScreen:UpdateHexField()
	if self.hexfield == nil then return end
	--
	self.hexfield:SetString(rgb_to_hex(self.current_color))
	self.hexlabel:SetColour(UICOLOURS.WHITE)
end

function RemiColorHelperScreen:GetCurrentColor()
	local color = self.current_color
	return self.return_hex and rgb_to_hex(color) or color
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