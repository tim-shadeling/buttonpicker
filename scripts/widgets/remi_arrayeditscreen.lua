local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local TextEdit = require "widgets/textedit"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"

local ArrayEditScreen = Class(Screen, function(self, list_items, title_text, body_text, buttons, spacing, nohelpbutton, is_keylist)
	Screen._ctor(self, "RemiArrayEditScreen")

	self.list_items = list_items
	self.items_amount = #list_items
	self.is_keylist = is_keylist

	local scroll_height = 200
	local body_height = 0
	if body_text then
		body_height = 100
	end

	self.black = self:AddChild(TEMPLATES.BackgroundTint())
	self.proot = self:AddChild(TEMPLATES.ScreenRoot())

	self.buttons = buttons or {}

	if not nohelpbutton then
		table.insert(self.buttons, {
			text=STRINGS.UI.HELP.BACK,
			cb = function()
				self:_Cancel()
			end,
			controller_control = CONTROL_CANCEL,
		})
	end
	self.dialog = self.proot:AddChild(TEMPLATES.CurlyWindow(460, scroll_height*2 + body_height,
			title_text,
			self.buttons,
			spacing,
			body_text or "" -- force creation of body to re-use sizing data
		))
	local content_width = 450 -- self.dialog.body:GetRegionSize()

	self.oncontrol_fn, self.gethelptext_fn = TEMPLATES.ControllerFunctionsFromButtons(self.buttons)
	if TheInput:ControllerAttached() then
		self.dialog.actions:Hide()
	end

	local item_height = 40

	local function MoveUp(item, move)
		local cur_entry = list_items[item.real_index]
		local prev_entry = list_items[item.real_index - 1]
		if prev_entry then
			cur_entry.text, prev_entry.text = prev_entry.text, cur_entry.text
			cur_entry.removed, prev_entry.removed = prev_entry.removed, cur_entry.removed
		end

		if move then self.scroll_list:GetNextWidget(MOVE_UP) end
		self.scroll_list:RefreshView()
	end

	local function MoveDown(item, move)
		local cur_entry = list_items[item.real_index]
		local next_entry = list_items[item.real_index + 1]
		if next_entry then
			cur_entry.text, next_entry.text = next_entry.text, cur_entry.text
			cur_entry.removed, next_entry.removed = next_entry.removed, cur_entry.removed
		end

		if move then self.scroll_list:GetNextWidget(MOVE_DOWN) end
		self.scroll_list:RefreshView()
	end

	local function ScrollWidgetsCtor(context, i)
		local item = Widget("item-"..i)
		item.root = item:AddChild(Widget("root"))
		item.removed_root = item:AddChild(Widget("removed_root"))
		item.mutual_root = item:AddChild(Widget("mutual_root"))

		local edit_text_width = content_width*0.70
		local edit_text_offset = content_width*0.30/2

		local numberlbl = item.mutual_root:AddChild(Text(CHATFONT, 25, ""))
		numberlbl:SetPosition(-content_width/2+5, 0)
		numberlbl:SetRegionSize(60, item_height)
		numberlbl:SetHAlign(ANCHOR_RIGHT)
		item.numberlbl = numberlbl

		local edit_text_bg = item.root:AddChild(Image("images/global_redux.xml", "textbox3_gold_normal.tex"))
		edit_text_bg:ScaleToSize(edit_text_width+10, item_height)
		edit_text_bg:SetPosition(-edit_text_offset+40, 0)
		item.edit_text_bg = edit_text_bg

		local edit_text = item.root:AddChild(TextEdit(CHATFONT, 20, ""))
		edit_text:SetColour(UICOLOURS.BLACK)
		edit_text:SetRegionSize(edit_text_width-20, item_height)
		edit_text:SetPosition(-edit_text_offset+40, 0)
		edit_text:SetHAlign(ANCHOR_LEFT)
		edit_text:SetFocusedImage(item.edit_text_bg, "images/global_redux.xml", "textbox3_gold_normal.tex", "textbox3_gold_hover.tex", "textbox3_gold_focus.tex" )
		edit_text:SetTextLengthLimit(200)
		edit_text:SetForceEdit(true)
		edit_text:SetTextPrompt("Your text here...", {0,0,0,.35})
		function edit_text.OnTextInputted(down)
			if list_items[item.real_index] then list_items[item.real_index].text = edit_text:GetString() end
		end
		item.edit_text = edit_text

		local moveupbtn = item.mutual_root:AddChild(ImageButton("images/ui.xml", "arrow2_up.tex", "arrow2_up_over.tex", nil, "arrow2_up_down.tex", nil, {.4,.4,.4}))
		moveupbtn:SetHoverText("Move Up")
		moveupbtn:SetPosition(150, 0)
		moveupbtn:SetOnClick(function()
			MoveUp(item, true)
		end)
		item.moveupbtn = moveupbtn
		local movedownbtn = item.mutual_root:AddChild(ImageButton("images/ui.xml", "arrow2_down.tex", "arrow2_down_over.tex", nil, "arrow2_down_down.tex", nil, {.4,.4,.4}))
		movedownbtn:SetHoverText("Move Down")
		movedownbtn:SetPosition(180, 0)
		movedownbtn:SetOnClick(function()
			MoveDown(item, true)
		end)
		item.movedownbtn = movedownbtn

		local removebtn = item.root:AddChild(ImageButton(CRAFTING_ATLAS, "pinslot_unpin_button.tex", "pinslot_unpin_button.tex"))
		removebtn:SetScale(.4,.4)
		removebtn:SetPosition(210,0)
		removebtn:SetHoverText("Remove")
		removebtn:SetOnClick(function()
			list_items[item.real_index].removed = true
			self.scroll_list:RefreshView()
		end)
		item.removebtn = removebtn

		local removedlbl = item.removed_root:AddChild(Text(CHATFONT, 20, ""))
		removedlbl:SetRegionSize(edit_text_width-20, item_height)
		removedlbl:SetPosition(-edit_text_offset+40, 0)
		removedlbl:SetHAlign(ANCHOR_LEFT)
		item.removedlbl = removedlbl

		local undoremovebtn = item.removed_root:AddChild(ImageButton("images/button_icons.xml", "undo.tex", "undo.tex"))
		undoremovebtn:SetScale(.15,.15)
		undoremovebtn:SetPosition(210,0)
		undoremovebtn:SetHoverText("Undo")
		undoremovebtn:SetOnClick(function()
			list_items[item.real_index].removed = nil
			self.scroll_list:RefreshView()
		end)
		item.undoremovebtn = undoremovebtn

		item.focus_forward = item.edit_text

		item:SetOnGainFocus(function()
			self.scroll_list:OnWidgetFocus(item)
			--[[
			local hover = list_items[item.real_index]
			hover = hover and hover.hover or ""
			self.dialog.body:SetString(hover)
			--]]
		end)

		return item
	end
	local function ScrollWidgetsCtor_KeyList(context, i)
		local item = Widget("item-"..i)
		item.root = item:AddChild(Widget("root"))
		item.removed_root = item:AddChild(Widget("removed_root"))
--		item.mutual_root = item:AddChild(Widget("mutual_root"))

		local edit_text_width = content_width*0.90
		local edit_text_offset = content_width*0.10/2

--		local numberlbl = item.mutual_root:AddChild(Text(CHATFONT, 25, ""))
--		numberlbl:SetPosition(-content_width/2+5, 0)
--		numberlbl:SetRegionSize(60, item_height)
--		numberlbl:SetHAlign(ANCHOR_RIGHT)
--		item.numberlbl = numberlbl

		local edit_text_bg = item.root:AddChild(Image("images/global_redux.xml", "textbox3_gold_normal.tex"))
		edit_text_bg:ScaleToSize(edit_text_width+10, item_height)
		edit_text_bg:SetPosition(-edit_text_offset+5, 0)
		item.edit_text_bg = edit_text_bg

		local edit_text = item.root:AddChild(TextEdit(CHATFONT, 20, ""))
		edit_text:SetColour(UICOLOURS.BLACK)
		edit_text:SetRegionSize(edit_text_width-20, item_height)
		edit_text:SetPosition(-edit_text_offset+5, 0)
		edit_text:SetHAlign(ANCHOR_LEFT)
		edit_text:SetFocusedImage(item.edit_text_bg, "images/global_redux.xml", "textbox3_gold_normal.tex", "textbox3_gold_hover.tex", "textbox3_gold_focus.tex" )
		edit_text:SetTextLengthLimit(200)
		edit_text:SetForceEdit(true)
		edit_text:SetTextPrompt("Your text here...", {0,0,0,.35})
		function edit_text.OnTextInputted(down)
			if list_items[item.real_index] then list_items[item.real_index].text = edit_text:GetString() end
		end
		item.edit_text = edit_text

--		local moveupbtn = item.mutual_root:AddChild(ImageButton("images/ui.xml", "arrow2_up.tex", "arrow2_up_over.tex", nil, "arrow2_up_down.tex", nil, {.4,.4,.4}))
--		moveupbtn:SetHoverText("Move Up")
--		moveupbtn:SetPosition(150, 0)
--		moveupbtn:SetOnClick(function()
--			MoveUp(item, true)
--		end)
--		item.moveupbtn = moveupbtn
--		local movedownbtn = item.mutual_root:AddChild(ImageButton("images/ui.xml", "arrow2_down.tex", "arrow2_down_over.tex", nil, "arrow2_down_down.tex", nil, {.4,.4,.4}))
--		movedownbtn:SetHoverText("Move Down")
--		movedownbtn:SetPosition(180, 0)
--		movedownbtn:SetOnClick(function()
--			MoveDown(item, true)
--		end)
--		item.movedownbtn = movedownbtn

		local removebtn = item.root:AddChild(ImageButton(CRAFTING_ATLAS, "pinslot_unpin_button.tex", "pinslot_unpin_button.tex"))
		removebtn:SetScale(.4,.4)
		removebtn:SetPosition(210,0)
		removebtn:SetHoverText("Remove")
		removebtn:SetOnClick(function()
			list_items[item.real_index].removed = true
			self.scroll_list:RefreshView()
		end)
		item.removebtn = removebtn

		local removedlbl = item.removed_root:AddChild(Text(CHATFONT, 20, ""))
		removedlbl:SetRegionSize(edit_text_width-20, item_height)
		removedlbl:SetPosition(-edit_text_offset+5, 0)
		removedlbl:SetHAlign(ANCHOR_LEFT)
		item.removedlbl = removedlbl

		local undoremovebtn = item.removed_root:AddChild(ImageButton("images/button_icons.xml", "undo.tex", "undo.tex"))
		undoremovebtn:SetScale(.15,.15)
		undoremovebtn:SetPosition(210,0)
		undoremovebtn:SetHoverText("Undo")
		undoremovebtn:SetOnClick(function()
			list_items[item.real_index].removed = nil
			self.scroll_list:RefreshView()
		end)
		item.undoremovebtn = undoremovebtn

		item.focus_forward = item.edit_text

		item:SetOnGainFocus(function()
			self.scroll_list:OnWidgetFocus(item)
			--[[
			local hover = list_items[item.real_index]
			hover = hover and hover.hover or ""
			self.dialog.body:SetString(hover)
			--]]
		end)

		return item
	end

	local function ScrollWidgetApply(context, item, data, index)
		item.real_index = data and data.index or index
		--
		if data then
			item.data = data.data
			--
			if data.removed then
				item.root:Hide()
				item.removed_root:Show()
			else
				item.root:Show()
				item.removed_root:Hide()
			end

			item.edit_text:SetString(data.text)
			if data.text == "" then
				item.removedlbl:SetString("- empty -")
				item.removedlbl:SetColour(1,.4,.4,1)
			else
				item.removedlbl:SetString(data.text)
				item.removedlbl:SetColour(1,1,1,1)
			end

			item.mutual_root:Show()
			item.numberlbl:SetString(data.index..".")
		else
			item.root:Hide()
			item.removed_root:Hide()
			item.mutual_root:Hide()
		end
	end
	local function ScrollWidgetApply_KeyList(context, item, data, index)
		item.real_index = data and data.index or index
		--
		if data then
			item.data = data.data
			--
			if data.removed then
				item.root:Hide()
				item.removed_root:Show()
			else
				item.root:Show()
				item.removed_root:Hide()
			end

			item.edit_text:SetString(data.text)
			if data.text == "" then
				item.removedlbl:SetString("- empty -")
				item.removedlbl:SetColour(1,.4,.4,1)
			else
				item.removedlbl:SetString(data.text)
				item.removedlbl:SetColour(1,1,1,1)
			end

--			item.mutual_root:Show()
--			item.numberlbl:SetString(data.index..".")
		else
			item.root:Hide()
			item.removed_root:Hide()
--			item.mutual_root:Hide()
		end
	end

	self.scroll_list = self.proot:AddChild(
		TEMPLATES.ScrollingGrid(
			list_items,
			{
				context = {},
				widget_width  = content_width + 40,
				widget_height =  item_height,
				num_visible_rows = math.floor(scroll_height/item_height),
				num_columns	  = 1,
				item_ctor_fn = is_keylist and ScrollWidgetsCtor_KeyList or ScrollWidgetsCtor,
				apply_fn	 = is_keylist and ScrollWidgetApply_KeyList or ScrollWidgetApply,
				scrollbar_height_offset = -60
			}
		))
	local scroll_y = -80
	self.scroll_list:SetPosition(0, scroll_y)

	if not is_keylist then
	local old_onfocusmove = self.scroll_list.OnFocusMove
		function self.scroll_list:OnFocusMove(dir, down)
			if TheInput:IsKeyDown(KEY_CTRL) and (dir == MOVE_UP or dir == MOVE_DOWN) then
				local focused_item = self.widgets_to_update[self.focused_widget_index]
				if focused_item and focused_item.focus then
					if dir == MOVE_UP then MoveUp(focused_item) else MoveDown(focused_item) end
				end
			end
	
			return old_onfocusmove(self, dir, down)
		end
	end

	if body_text then
		local body = self.dialog.body
		body:SetSize(20)
		body:SetPosition(0, 160)
		body:SetRegionSize(content_width+80, 180)
		body:EnableWordWrap(true)
		--body:SetVAlign(ANCHOR_MIDDLE)
		--body:SetHAlign(ANCHOR_LEFT)
	end

	self.horizontal_line = self.proot:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
	self.horizontal_line:SetPosition(0, scroll_y+scroll_height/2+5)
	self.horizontal_line:SetSize(content_width, 3)

	local search_bar = self.proot:AddChild(TextEdit(CHATFONT, 25, "", UICOLOURS.GOLD_CLICKABLE))
	search_bar:SetForceEdit(true)
	search_bar:SetRegionSize(content_width*0.9, 30)
	search_bar:SetPosition(-content_width*0.05, scroll_y+scroll_height/2+20)
	search_bar:SetHAlign(ANCHOR_LEFT)
	search_bar.prompt_color = {215/255, 210/255, 157/255, .55}
	search_bar:SetTextPrompt("Search...", search_bar.prompt_color) -- UICOLOURS.GOLD_CLICKABLE but less alpha
	search_bar:SetIdleTextColour(UICOLOURS.GOLD_CLICKABLE)
	search_bar:SetEditTextColour(UICOLOURS.WHITE)
	search_bar:SetEditCursorColour(UICOLOURS.WHITE)

	search_bar.OnGainFocus = function(self)
		Widget.OnGainFocus(self)

		if not self.editing then
			self:SetColour(UICOLOURS.GOLD_FOCUS)
			self.prompt:SetColour(UICOLOURS.GOLD_FOCUS)
		end
	end

	search_bar.OnLoseFocus = function(self)
		Widget.OnLoseFocus(self)

		if not self.editing then
			self:SetColour(self.idle_text_color)
			self.prompt:SetColour(self.prompt_color)
		end
	end

	search_bar.OnTextInputted = function() self:FilterEntries() end
	
	-- erase with a single right click
	local oldoncontrol = search_bar.OnControl
	search_bar.OnControl = function(self, control, down)
		if control == CONTROL_SECONDARY and not down then
			self:SetString("")
			self.OnTextInputted()
			return true
		end
		return oldoncontrol(self, control, down)
	end

	self.search_bar = search_bar

	local newentrybtn = self.proot:AddChild(ImageButton("images/global_redux.xml", "checkbox_normal.tex", "checkbox_normal.tex"))
	newentrybtn:SetPosition(210, scroll_y+scroll_height/2+20)
	newentrybtn:ForceImageSize(item_height*1.5, item_height*1.5)
	newentrybtn:SetText("+")
	newentrybtn.image:SetHoverText("New Entry")
	newentrybtn:SetTextColour(UICOLOURS.GREY)
	newentrybtn:SetTextFocusColour(UICOLOURS.WHITE)
	newentrybtn:SetImageNormalColour(1,1,1,.7)
	newentrybtn:SetImageFocusColour(1,1,1,1)
	newentrybtn:SetFont(HEADERFONT)
	newentrybtn:SetTextSize(25)
	newentrybtn:SetOnClick(function()
		self.items_amount = self.items_amount + 1
		table.insert(list_items, {text = "", index = self.items_amount})
		self.scroll_list:SetItemsData(list_items)
		self.scroll_list.end_pos = math.ceil(self.scroll_list.end_pos)
		self.scroll_list:Scroll(self.items_amount)
	end)
	self.newentrybtn = newentrybtn

	self.scroll_list:SetFocusChangeDir(MOVE_DOWN, self.dialog.actions)
	self.scroll_list:SetFocusChangeDir(MOVE_RIGHT, self.dialog.actions)
	self.dialog.actions:SetFocusChangeDir(MOVE_UP, self.scroll_list)

	self.default_focus = self.scroll_list
end)

function ArrayEditScreen:OnControl(control, down)
	if ArrayEditScreen._base.OnControl(self,control, down) then
		return true
	end

	return self.oncontrol_fn(control, down)
end

function ArrayEditScreen:GetHelpText()
	return self.gethelptext_fn()
end

function ArrayEditScreen:_Cancel()
	TheFrontEnd:PopScreen(self)
end

local function search_match(search, str)
	if string.find( str, search, 1, true ) ~= nil then return true end
	return false
end

function ArrayEditScreen:FilterEntries()
	local query = TrimString(self.search_bar:GetString()):lower()

	local filtered_entries = {}
	if query ~= "" then
		for k,v in pairs(self.list_items) do
			if search_match(query, v.text:lower()) then
				table.insert(filtered_entries, v)
			end
		end
	else
		filtered_entries = self.list_items
	end
	self.scroll_list:SetItemsData(filtered_entries)
end

function ArrayEditScreen:CollectData()
	local descs, data = "", {}
	for k,v in ipairs(self.list_items) do
		if not v.removed then
			if self.is_keylist then data[v.text] = true else table.insert(data, v.text) end
			if v.text ~= "" and descs:len() < 30 then descs = descs..v.text..", " end
		end
	end
	return descs == "" and "--" or descs:sub(0,-3), data
end

return ArrayEditScreen
