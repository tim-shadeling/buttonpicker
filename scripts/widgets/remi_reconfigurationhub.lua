local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local TextEdit = require "widgets/textedit"
local TEMPLATES = require "widgets/redux/templates"

local RemiNewModConfigurationScreen = require "widgets/remi_newmodconfigurationscreen"

-- A very simple listing of mods that added their names (and reconfiguration callbacks) to REMI_RECONFIGURABLE_MODS
local ReconfigurationHub = Class(Screen, function(self)
	Screen._ctor(self, "ReconfigurationHub")

	self.list_items = {}
	for modname, callback in pairs(REMI_RECONFIGURABLE_MODS) do
		local modinfo = KnownModIndex:GetModInfo(modname)
		table.insert(self.list_items, {modname = modname, callback = callback, displayname = modinfo and modinfo.name or modname})
	end
	table.sort(self.list_items, function(a,b) return a.displayname < b.displayname end)
	--
	self.loaded_infoprefabs = {}
	self:LoadModInfoPrefabs()

	self.black = self:AddChild(TEMPLATES.BackgroundTint())
	self.root = self:AddChild(TEMPLATES.ScreenRoot("root"))

	local window_width = 360
	local window_height = 580

	self.bg = self.root:AddChild(TEMPLATES.RectangleWindow(window_width, window_height, STRINGS.BUTTONPICKER.RECFG_TITLE, {{text = "Close", cb = function() self:_Cancel() end}}))
--  self.bg:SetTint(.7,.7,.7,1)
	self.bg:SetBackgroundTint(0,0,0,.8)

	self.horizontal_line = self.root:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
	self.horizontal_line:SetPosition(0, 200)
	self.horizontal_line:SetSize(window_width+10, 3)

	self.search_bar = self.root:AddChild(TextEdit(CHATFONT, 25, "", UICOLOURS.GOLD_CLICKABLE))
	self.search_bar:SetForceEdit(true)
	self.search_bar:SetRegionSize(window_width+10, 30)
	self.search_bar:SetPosition(0, 200 + 16)
	self.search_bar:SetHAlign(ANCHOR_LEFT)
	self.search_bar.prompt_color = {215/255, 210/255, 157/255, .55}
	self.search_bar:SetTextPrompt("Search...", self.search_bar.prompt_color) -- UICOLOURS.GOLD_CLICKABLE but less alpha
	self.search_bar:SetIdleTextColour(UICOLOURS.GOLD_CLICKABLE)
	self.search_bar:SetEditTextColour(UICOLOURS.WHITE)
	self.search_bar:SetEditCursorColour(UICOLOURS.WHITE)

	self.search_bar.OnGainFocus = function(self)
		Widget.OnGainFocus(self)

		if not self.editing then
			self:SetColour(UICOLOURS.GOLD_FOCUS)
			self.prompt:SetColour(UICOLOURS.GOLD_FOCUS)
		end
	end

	self.search_bar.OnLoseFocus = function(self)
		Widget.OnLoseFocus(self)

		if not self.editing then
			self:SetColour(self.idle_text_color)
			self.prompt:SetColour(self.prompt_color)
		end
	end

	self.search_bar.OnTextInputted = function() self:FilterEntries() end
	
	-- erase with a single right click
	local oldoncontrol = self.search_bar.OnControl
	self.search_bar.OnControl = function(self, control, down)
		if control == CONTROL_SECONDARY and not down then
			self:SetString("")
			self.OnTextInputted()
			return true
		end
		return oldoncontrol(self, control, down)
	end

	self:CreateModsScrollList()
end)

function ReconfigurationHub:ReconfigureMod(modname, callback)
	TheFrontEnd:PushScreen(RemiNewModConfigurationScreen(modname, true, function(...)
		callback(...)
		TheFrontEnd:PopScreen() -- return straight to the game
	end))
end

function ReconfigurationHub:UnloadModInfoPrefabs()
	TheSim:UnloadPrefabs(self.loaded_infoprefabs)
	TheSim:UnregisterPrefabs(self.loaded_infoprefabs)
	self.loaded_infoprefabs = {}
end

function ReconfigurationHub:LoadModInfoPrefabs()
	self.loaded_infoprefabs = {}
	for i, data in ipairs(self.list_items) do
		local modname = data.modname
		local info = KnownModIndex:GetModInfo(modname)
		local modinfoassets = {
			Asset("ATLAS", info.icon_atlas),
			Asset("IMAGE", info.iconpath),
		}
		local prefab = Prefab("MODSCREEN_"..modname, nil, modinfoassets, nil)
		RegisterSinglePrefab(prefab)
		table.insert(self.loaded_infoprefabs, prefab.name)
	end
	TheSim:LoadPrefabs(self.loaded_infoprefabs)
end

local function search_match(search, str)
	if string.find( str, search, 1, true ) ~= nil then return true end
	return false
end

function ReconfigurationHub:FilterEntries()
	local query = TrimString(self.search_bar:GetString()):lower()

	local filtered_entries = {}
	if query ~= "" then
		for k,v in pairs(self.list_items) do
			if search_match(query, v.displayname:lower()) then
				table.insert(filtered_entries, v)
			end
		end
	else
		filtered_entries = self.list_items
	end
	self.scroll_list:SetItemsData(filtered_entries)
end

function ReconfigurationHub:CreateModsScrollList()
	local function ScrollWidgetsCtor(context, index)
		local w = Widget("widget-".. index)

		w:SetOnGainFocus(function() self.scroll_list:OnWidgetFocus(w) end)

		w.moditem = w:AddChild(TEMPLATES.ModListItem(function()
			self:ReconfigureMod(w.data.modname, w.data.callback)
		end,
		function() end,
		function() end))

		local opt = w.moditem
		opt.checkbox:Hide()
		opt.setfavorite:Hide()

		-- Get the actual w representing this mod (not the root).
		w.GetModWidget = function(_)
			return opt
		end

		w.focus_forward = opt

		return w
	end

	local function ApplyDataToWidget(context, w, data, index)
		w.data = data
		local opt = w.moditem

		if data then
			opt:Show()

			local modname = data.modname
			local modinfo = KnownModIndex:GetModInfo(modname)
			opt:SetMod(modname, modinfo)
			opt.image:SetTint(unpack(UICOLOURS.WHITE))
		else
			opt:Hide()
		end
	end

	-- And make a scrollable list!
	if self.scroll_list == nil then
		self.scroll_list  = self.root:AddChild(TEMPLATES.ScrollingGrid(
				self.list_items,
				{
					context = {},
					widget_width  = 340,
					widget_height = 90,
					num_visible_rows = 5,
					num_columns	  = 1,
					item_ctor_fn = ScrollWidgetsCtor,
					apply_fn	 = ApplyDataToWidget,
					scrollbar_offset = 10,
					scrollbar_height_offset = -60,
					peek_percent = 0.15, -- may init with few clientmods, but have many servermods.
					allow_bottom_empty_row = true -- it's hidden anyway
				}
			))

		self.scroll_list:SetPosition(0, -55)
	end
end

function ReconfigurationHub:_Cancel()
	self:UnloadModInfoPrefabs()
	TheFrontEnd:PopScreen(self)
end

function ReconfigurationHub:OnControl(control, down)
	if ReconfigurationHub._base.OnControl(self, control, down) then return true end

	if not down then
		if control == CONTROL_CANCEL then
			self:_Cancel()
		end
	end
end

return ReconfigurationHub
