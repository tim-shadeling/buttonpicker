local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"

local VALID_FONTS = {["opensans"] = true, ["bp100"] = true, ["bp50"] = true, ["buttonfont"] = true, ["spirequal"] = true, ["spirequal_small"] = true, ["spirequal_outline"] = true, ["spirequal_outline_small"] = true, ["stint-ucr"] = true, ["talkingfont"] = true, ["talkingfont_wormwood"] = true, ["talkingfont_tradein"] = true, ["talkingfont_hermit"] = true, ["bellefair"] = true, ["hammerhead"] = true, ["bellefair_outline"] = true, ["stint-small"] = true, ["ptmono"] = true}
local function fontexists(font)
	if font ~= nil and VALID_FONTS[font] then return font end
end

local ListOptionScreen = Class(Screen, function(self, list_items, title_text, body_text, hover, buttons, keybind_config, font_config)
	Screen._ctor(self, "RemiListOptionScreen")

	self.keybind_config = keybind_config
	self.font_config = font_config

	local scroll_height = 380
	local body_height = 100

	self.black = self:AddChild(TEMPLATES.BackgroundTint())
	self.proot = self:AddChild(TEMPLATES.ScreenRoot())

	self.buttons = buttons or {}
	if not keybind_config then
	table.insert(self.buttons, {
			text=STRINGS.UI.HELP.BACK,
			cb = function()
				self:_Cancel()
			end,
			controller_control = CONTROL_CANCEL,
		})
	end

	local bg_width = 300
	self.dialog = self.proot:AddChild(TEMPLATES.CurlyWindow(bg_width,
			scroll_height + body_height,
			title_text,
			self.buttons,
			nil,
			body_text or "" -- force creation of body to re-use sizing data
		))
	self.dialog.body:SetSize(20)

	if hover and hover ~= "" then
		local info_hover = self.proot:AddChild(Text(BODYTEXTFONT, 25, "(i)"))
		info_hover:SetPosition(0.5*bg_width+25, 0.5*(scroll_height+body_height)+35)
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

	local content_width = 250 -- self.dialog.body:GetRegionSize()
	local item_height = keybind_config and 30 or 40

	local function ScrollWidgetsCtor(context, i)
		local item = Widget("item-"..i)
		item.root = item:AddChild(Widget("root"))
		if not keybind_config then
			local btn = item.root:AddChild(ImageButton("images/global_redux.xml", "blank.tex", "spinner_focus.tex"))
			btn:ForceImageSize(content_width+20,item_height)
			btn:SetText("")
			btn:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
			btn:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
			btn:SetFont(CHATFONT)
			btn:SetTextSize(20)
			btn.text:SetRegionSize(content_width-30,item_height)
			btn.text:SetHAlign(ANCHOR_LEFT)
			item.btn = btn -- item.root:AddChild(TEMPLATES.StandardButton(nil, "", {content_width+20,item_height+10}))
			item.text = item.btn.text

			item.SetOnClick = function(_, onclick)
				item.btn:SetOnClick(onclick)
				if onclick then
					item.btn:Enable()
				else
					item.btn:Disable()
				end
			end

			item.focus_forward = item.btn
		else
			item.text = item.root:AddChild(Text(CHATFONT, 20, "", UICOLOURS.GOLD_UNIMPORTANT))
			item.text:SetRegionSize(content_width-30,item_height)
			item.text:SetHAlign(ANCHOR_LEFT)
			item.SetOnClick = function(_, onclick)
			end

			item.focus_forward = item.text
		end

		item:SetOnGainFocus(function()
			self.scroll_list:OnWidgetFocus(item)
			--
			local data = list_items[item.real_index]
			local hover = data and data.hover and ("\n--\n"..data.hover) or ""
			self.dialog.body:SetString(body_text..hover)
			if self.font_config then self.dialog.body:SetFont(fontexists(data.data) or DEFAULTFONT) end
		end)

		return item
	end
	local function ScrollWidgetApply(context, item, data, index)
		item.real_index = index
		--
		if data then
			item:SetOnClick(data.onclick)
			item.text:SetTruncatedString(data.text, content_width-25, 75, true)
			-- left align
			--local w, h = item.text:GetRegionSize()
			--item.text:SetPosition(-content_width/2 + w/2 + 20, 0, 0)

			if self.font_config then item.text:SetFont(fontexists(data.data) or DEFAULTFONT) end

			item.root:Show()
		else
			item.root:Hide()
		end
	end

	self.scroll_list = self.proot:AddChild(
		TEMPLATES.ScrollingGrid(
			list_items,
			{
				context = {},
				widget_width  = content_width + 40,
				widget_height =  item_height,
				num_visible_rows = math.floor(scroll_height/item_height) - 1,
				num_columns	  = 1,
				item_ctor_fn = ScrollWidgetsCtor,
				apply_fn	 = ScrollWidgetApply,
				scrollbar_height_offset = -60
			}
		))
	self.scroll_list:SetPosition(0, 30)
	self.scroll_list.scissored_root:SetPosition(self.scroll_list.scroll_bar_container:IsVisible() and -25 or 0,0)
	self.scroll_list.scroll_per_click = keybind_config and 5 or 1

	if body_text then
		self.dialog.body:SetPosition(0, 210)
		self.dialog.body:SetRegionSize(content_width+100, body_height)
		self.scroll_list:SetPosition(0, -10)
	end

	self.scroll_list:SetFocusChangeDir(MOVE_DOWN, self.dialog.actions)
	self.scroll_list:SetFocusChangeDir(MOVE_RIGHT, self.dialog.actions)
	self.dialog.actions:SetFocusChangeDir(MOVE_UP, self.scroll_list)

	self.default_focus = self.scroll_list
end)

function ListOptionScreen:OnControl(control, down) 
	if self.keybind_config and control ~= CONTROL_SCROLLBACK and control ~= CONTROL_SCROLLFWD then
		return true -- inputhandler will catch this input and close the screen
	end

	if ListOptionScreen._base.OnControl(self,control, down) then
		return true
	end

	if not down and control == CONTROL_CANCEL then
		self:_Cancel()
		return true
	end
end

function ListOptionScreen:_Cancel()
	TheFrontEnd:PopScreen(self)
end

return ListOptionScreen
