local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"

local ListChoiceScreen = Class(Screen, function(self, list_items, title_text, body_text, hover, buttons, current_choice)
	Screen._ctor(self, "RemiListChoiceScreen")

	self.current_choice = shallowcopy(current_choice)
	self.current_selected = table.count(self.current_choice)
	self.max_selected = table.count(list_items)

	local scroll_height = 380
	local body_height = 100

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

	local bg_width = 300
	self.dialog = self.proot:AddChild(TEMPLATES.CurlyWindow(bg_width, scroll_height + body_height,
		title_text,
		self.buttons,
		nil,
		body_text or "" -- force creation of body to re-use sizing data
	))
	self.dialog.body:SetSize(20)

	if hover then
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
	local item_height = 30
	local do_items_have_buttons = false
	for i,item in ipairs(list_items) do
		if item.onclick then
			do_items_have_buttons = true
			item_height = 40
			break
		end
	end

	local function ScrollWidgetsCtor(context, i)
		local item = Widget("item-"..i)
		item.root = item:AddChild(Widget("root"))
		if do_items_have_buttons then
			local active_image = item.root:AddChild(Image("images/global_redux.xml", "wardrobe_spinner_bg.tex"))
			active_image:SetTint(1,1,1,0.3)
			active_image:SetSize(content_width+40, item_height)
			active_image:SetPosition(2.5, 0)
			active_image:Hide()
			item.active_image = active_image

			local btn = item.root:AddChild(ImageButton("images/global_redux.xml", "blank.tex", "spinner_focus.tex"))
			btn:ForceImageSize(content_width+20,item_height)
			btn:SetText("")
			btn:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
			btn:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
			btn:SetFont(CHATFONT)
			btn:SetTextSize(20)
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

			item.SetOnClick = function(_, onclick)
			end

			item.focus_forward = item.text
		end

		item:SetOnGainFocus(function()
			self.scroll_list:OnWidgetFocus(item)
			--
			local hover = list_items[item.real_index]
			hover = hover and hover.hover or ""
			self.dialog.body:SetString(hover)
		end)

		return item
	end
	local function ScrollWidgetApply(context, item, data, index)
		item.real_index = index
		--
		if data then
			item.data = data.data
			--
			item:SetOnClick(function()
				if self.current_choice[item.data] then
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/toggle_off")
					self.current_choice[item.data] = nil
					item.active_image:Hide()

					self.current_selected = self.current_selected - 1
					if self.current_selected ~= self.max_selected then
						self.select_all.active_image:Hide()
					end
				else
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/toggle_on")
					self.current_choice[item.data] = true
					item.active_image:Show()

					self.current_selected = self.current_selected + 1
					if self.current_selected == self.max_selected then
						self.select_all.active_image:Show()
					end
				end

			end)
			item.text:SetTruncatedString(data.text, content_width-25, 75, true)
			-- left align
			local w, h = item.text:GetRegionSize()
			item.text:SetPosition(-content_width/2 + w/2 + 20, 0, 0)

			item.root:Show()

			if self.current_choice[item.data] then
				item.active_image:Show()
			else
				item.active_image:Hide()
			end
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
				num_columns   = 1,
				item_ctor_fn = ScrollWidgetsCtor,
				apply_fn	 = ScrollWidgetApply,
				scrollbar_height_offset = -60
			}
		))
	self.scroll_list:SetPosition(0, 30)
	local list_offset = self.scroll_list.scroll_bar_container:IsVisible() and -25 or 0
	self.scroll_list.scissored_root:SetPosition(list_offset,0)

	if body_text then
		self.dialog.body:SetPosition(0, 230)
		self.dialog.body:SetRegionSize(content_width+100, 25)
		self.scroll_list:SetPosition(0, -10)
	end

	self.select_all = self.proot:AddChild(Widget("select_all"))
	local active_image = self.select_all:AddChild(Image("images/global_redux.xml", "wardrobe_spinner_bg.tex"))
	active_image:SetTint(1,1,1,0.3)
	active_image:SetSize(content_width+40, item_height)
	active_image:SetPosition(2.5, 0)
	if self.current_selected ~= self.max_selected then active_image:Hide() end
	self.select_all.active_image = active_image

	local btn = self.select_all:AddChild(ImageButton("images/global_redux.xml", "blank.tex", "spinner_focus.tex"))
	btn:ForceImageSize(content_width+20,item_height)
	btn:SetText("--  "..STRINGS.UI.PURCHASEPACKSCREEN.FILTER_ALL.."   --")
	btn:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
	btn:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
	btn:SetFont(CHATFONT)
	btn:SetTextSize(20)
	self.select_all.btn = btn

	self.select_all:SetPosition(list_offset, scroll_height/2-5)
	self.select_all.btn:SetOnGainFocus(function()
		self.dialog.body:SetString("")
	end)
	self.select_all.btn:SetOnClick(function()
		if self.current_selected == self.max_selected then -- deselect all
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/toggle_off")
			self.current_choice = {}
			self.current_selected = 0
			self.select_all.active_image:Hide()
			for k,v in pairs(self.scroll_list.widgets_to_update) do
				v.active_image:Hide()
			end
		else -- select all
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/toggle_on")
			for k,v in pairs(self.scroll_list.items) do
				self.current_choice[v.data] = true
			end
			self.current_selected = self.max_selected
			self.select_all.active_image:Show()
			for k,v in pairs(self.scroll_list.widgets_to_update) do
				v.active_image:Show()
			end
		end
	end)

	self.scroll_list:SetFocusChangeDir(MOVE_DOWN, self.dialog.actions)
	self.scroll_list:SetFocusChangeDir(MOVE_RIGHT, self.dialog.actions)
	self.dialog.actions:SetFocusChangeDir(MOVE_UP, self.scroll_list)

	self.default_focus = self.scroll_list
end)

function ListChoiceScreen:OnControl(control, down)
	if ListChoiceScreen._base.OnControl(self,control, down) then
		return true
	end

	if not down and control == CONTROL_CANCEL then
		self:_Cancel()
		return true
	end
end

function ListChoiceScreen:_Cancel()
	TheFrontEnd:PopScreen(self)
end

function ListChoiceScreen:CollectData()
	local descs = ""
	for k,v in ipairs(self.scroll_list.items) do
		if descs:len() >= 30 then break end
		if self.current_choice[v.data] then
			descs = descs..v.description..", "
		end
	end
	return descs == "" and "--" or descs:sub(0,-3), self.current_choice
end

return ListChoiceScreen
