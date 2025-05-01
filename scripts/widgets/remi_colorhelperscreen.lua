local TEMPLATES = require "widgets/redux/templates"
local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Image = require "widgets/image"
local TextEdit = require "widgets/textedit"

local lang = LanguageTranslator.defaultlang or "en"
local languages =
{
    zh = "zh", -- Chinese for Steam
    zhr = "zh", -- Chinese for WeGame
    ch = "zh", -- Chinese mod
    chs = "zh", -- Chinese mod
    sc = "zh", -- simple Chinese
    zht = "zh", -- traditional Chinese for Steam
	tc = "zh", -- traditional Chinese
	cht = "zh", -- Chinese mod
}

if languages[lang] ~= nil then
    lang = languages[lang]
else
    lang = "en"
end

local chinese = lang == "zh"

local COLOR_NAMES = chinese and {"红:", "绿:", "蓝:", "不透明度:"} or {"Red:", "Green:", "Blue:", "Alpha:"}
local NEWCOLOR_LBL_STRING = chinese and "新:" or "New:"
local OLDCOLOR_LBL_STRING = chinese and "旧:" or "Old:"
local SCROLL_INFO_STRING = chinese and "(文本框是可滚动的)" or "(textboxes are scrollable)"

local RemiColorHelperScreen = Class(Screen, function(self, title, buttons, initial_color, include_alpha)
	Screen._ctor(self, "RemiColorHelperScreen")
	self.tint = self:AddChild(TEMPLATES.BackgroundTint())

	self.root = self:AddChild(Widget("root"))
	self.root:SetVAnchor(0)
	self.root:SetHAnchor(0)

	self.dialog = self.root:AddChild(TEMPLATES.CurlyWindow(400,450, title, buttons))

	initial_color = shallowcopy(initial_color)
	initial_color = type(initial_color) == "table" and initial_color or {1,1,1,1}
	for i = 1,4 do initial_color[i] = initial_color[i] or 1 end

	local newcolor = self.root:AddChild(Image("images/global.xml", "square.tex"))
	newcolor:SetPosition(100,140)
	newcolor:ScaleToSize(200,100)
	newcolor:SetTint(unpack(initial_color))
	newcolor.ep_current_color = initial_color
	self.newcolor = newcolor
	self.newcolor_lbl = self.root:AddChild(Text(CHATFONT, 25, NEWCOLOR_LBL_STRING))
	self.newcolor_lbl:SetPosition(100,210)
	local oldcolor = self.root:AddChild(Image("images/global.xml", "square.tex"))
	oldcolor:SetPosition(-100,140)
	oldcolor:ScaleToSize(200,100)
	oldcolor:SetTint(unpack(initial_color))
	self.oldcolor = oldcolor
	self.oldcolor_lbl = self.root:AddChild(Text(CHATFONT, 25, OLDCOLOR_LBL_STRING))
	self.oldcolor_lbl:SetPosition(-100,210)

	self.colorlabels = {}
	self.colorpickers = {}

	self.scroll_info = self.root:AddChild(Text(CHATFONT, 18, SCROLL_INFO_STRING))
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
				while val > 1 do val = val/10 end
				colorpicker:SetString(tostring(val))
			end
			colorpicker.actualvalue = val
			newcolor.ep_current_color[i] = val
			newcolor:SetTint(unpack(newcolor.ep_current_color))
		end
		local oldfn = colorpicker.OnControl
		colorpicker.OnControl = function(self, control, down)
			if not down and (control == CONTROL_SCROLLFWD or control == CONTROL_SCROLLBACK) then
				self.actualvalue = math.clamp(self.actualvalue + (control == CONTROL_SCROLLFWD and -.02 or .02), 0, 1)
				self:SetString(tostring(self.actualvalue))
				self.actualvalue = tonumber(self.actualvalue) or self.actualvalue
				newcolor.ep_current_color[i] = self.actualvalue
				newcolor:SetTint(unpack(newcolor.ep_current_color))
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

function RemiColorHelperScreen:GetCurrentColor()
	return self.newcolor.ep_current_color
end

local oldfn = RemiColorHelperScreen.OnControl
function RemiColorHelperScreen:OnControl(control, down)
	if not down and control == CONTROL_CANCEL then
		for k,v in pairs(self.colorpickers) do
			if v.editing then
				return v:OnControl(control, down)
			end
		end
		TheFrontEnd:PopScreen()
		return true
	end
	return oldfn(self, control, down)
end

return RemiColorHelperScreen