local TEMPLATES = require "widgets/redux/templates"
local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Image = require "widgets/image"
local TextEdit = require "widgets/textedit"

local COLOR_NAMES = {"Red:", "Green:", "Blue:", "Alpha:"}

local ColorHelperScreen = Class(Screen, function(self, title, buttons, initial_color, include_alpha)
	Screen._ctor(self, "ColorHelperScreen")
	self.tint = self:AddChild(TEMPLATES.BackgroundTint())
	
	self.root = self:AddChild(Widget("root"))
	self.root:SetVAnchor(0)
	self.root:SetHAnchor(0)

	self.dialog = self.root:AddChild(TEMPLATES.CurlyWindow(600,450, title, buttons, nil, "Hello! This is a color demo!\nChange the RGB(A) values below and find your perfect color!\n\n██████████"))
	local text = self.dialog.body
	text:SetPosition(0,140)
	text:SetFont(TALKINGFONT)
	text:SetSize(30)
	initial_color = type(initial_color) == "table" and initial_color or {1,1,1,1}
	for i = 1,4 do initial_color[i] = initial_color[i] or 1 end
	text.ep_current_color = initial_color
	text:SetColour(unpack(initial_color))

	self.colorlabels = {}
	self.colorpickers = {}

	self.scroll_info = self.root:AddChild(Text(CHATFONT, 18, "(textboxes are scrollable)"))
	self.scroll_info:SetPosition(0, 40)

	local channels = include_alpha and 4 or 3
	for i = 1,channels do
		local label = self.root:AddChild(Text(CHATFONT, 25, COLOR_NAMES[i]))
		label:SetRegionSize(100,40)
		label:SetHAlign(1)
		label:SetPosition(-150, -50*(i-1))
		self.colorlabels[i] = label

		local colorpicker_bg = self.root:AddChild(Image())
		colorpicker_bg:SetTexture("images/global_redux.xml", "textbox3_gold_normal.tex")
		colorpicker_bg:ScaleToSize(200, 40)
		colorpicker_bg:SetPosition(100, -50*(i-1))

		local colorpicker = self.root:AddChild(TextEdit(CHATFONT, 25, tostring(initial_color[i])))
		colorpicker.actualvalue = initial_color[i]
		colorpicker:SetFocusedImage(colorpicker_bg, "images/global_redux.xml", "textbox3_gold_normal.tex", "textbox3_gold_hover.tex", "textbox3_gold_focus.tex" )
		colorpicker:SetRegionSize(180, 40)
		colorpicker:SetAllowNewline(false)
		colorpicker:SetForceEdit(true)
		colorpicker:SetTextLengthLimit(5)
		colorpicker:SetHAlign(1)
		colorpicker:SetCharacterFilter("1234567890.")
		colorpicker.OnTextInputted = function()
			local val = tonumber(colorpicker:GetString())
			if val then label:SetColour(1,1,1,1) else label:SetColour(1,0,0,1) end
			val = val or 0
			if val > 1 then
				val = 1
				colorpicker:SetString("1")
			end
			colorpicker.actualvalue = val
			text.ep_current_color[i] = val
			text:SetColour(unpack(text.ep_current_color))
		end
		local oldfn = colorpicker.OnControl
		colorpicker.OnControl = function(self, control, down)
			if not down and (control == CONTROL_SCROLLFWD or control == CONTROL_SCROLLBACK) then
				self.actualvalue = math.clamp(self.actualvalue + (control == CONTROL_SCROLLFWD and -.02 or .02), 0, 1)
				self:SetString(tostring(self.actualvalue))
				text.ep_current_color[i] = self.actualvalue
				text:SetColour(unpack(text.ep_current_color))
				return true
			end
			return oldfn and oldfn(self, control, down)
		end
		colorpicker:SetPosition(100, -50*(i-1))
		self.colorpickers[i] = colorpicker
	end

	local onclick = function() TheFrontEnd:PopScreen() end
	--self.backbtn = self.root:AddChild(TEMPLATES.StandardButton(onclick, "Back", {200,40}))
	--self.backbtn:SetPosition(0,-200)

	local w,h = TheSim:GetScreenSize()
	self.root:SetScale(w/RESOLUTION_X, h/RESOLUTION_Y)
end)

function ColorHelperScreen:GetCurrentColor()
	return self.dialog.body.ep_current_color
end

return ColorHelperScreen