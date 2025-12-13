require "util"
require "strings"
local TEMPLATES = require "widgets/redux/templates"
local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Text = require "widgets/text"
local TextEdit = require "widgets/textedit"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local PopupDialogScreen = require "screens/redux/popupdialog"
local ListOptionScreen = require "widgets/remi_listoptionscreen"
local InputDialogScreen = require "screens/redux/inputdialog"
local ColorHelperScreen = require "widgets/remi_colorhelperscreen"
local ListChoiceScreen = require "widgets/remi_listchoicescreen"
local ArrayEditScreen = require "widgets/remi_arrayeditscreen"
local DictionaryEditScreen = require "widgets/remi_dictionaryeditscreen"
--
local ManualSupport = require "remi_manualsupport"

local DISPLAYSTR_MAXCHARS = 30

local function checkdesc(desc)
	return (type(desc) == "string" or type(desc) == "number") and tostring(desc) or "!!! WRONG DESC !!!"
end

local VALID_FONTS = {["opensans"] = true, ["bp100"] = true, ["bp50"] = true, ["buttonfont"] = true, ["spirequal"] = true, ["spirequal_small"] = true, ["spirequal_outline"] = true, ["spirequal_outline_small"] = true, ["stint-ucr"] = true, ["talkingfont"] = true, ["talkingfont_wormwood"] = true, ["talkingfont_tradein"] = true, ["talkingfont_hermit"] = true, ["bellefair"] = true, ["hammerhead"] = true, ["bellefair_outline"] = true, ["stint-small"] = true, ["ptmono"] = true}
local function fontexists(font)
	if font ~= nil and VALID_FONTS[font] then return font end
end

local function custom_not_equal(a,b)
	if type(a) ~= type(b) then return true end
	if type(a) == "table" then
		if table.count(a) ~= table.count(b) then return true end
		--
		for k in pairs(a) do
			if type(a[k]) == "number" and type(b[k]) == "number" then
				if math.abs(a[k] - b[k]) >= 0.001 then
					return true
				end
			else
				if a[k] ~= b[k] then return true end
			end
		end
		return false
	else
		return a ~= b
	end
end

local function custom_equal(a,b)
	return not custom_not_equal(a,b) -- wow
end

local function BreakIntoSections(options)
	local result = {}
	local current_section = result

	for _, opt in pairs(options) do
		if opt.section_start then
			table.insert(result, opt)
			--
			current_section = {}
			opt._section = current_section
		elseif opt.section_end then
			current_section = result
			table.insert(current_section, opt)
		else
			table.insert(current_section, opt)
		end
	end

	return result
end

local RemiNewModConfigurationScreen = Class(Screen, function(self, modname, client_config, callback)
	Screen._ctor(self, "RemiNewModConfigurationScreen")

	self.modname = modname
	self.client_config = client_config
	self.callback = callback
	local modinfo = KnownModIndex:GetModInfo(modname)
	local is_client_only = modinfo and modinfo.client_only_mod

	if modinfo and modinfo.keys then
		self.format = require "remi_keybinduiformat"
		print("[ConfExt] Special Keybind UI Demo format loaded.")
	else
		local support_table = ManualSupport[self.modname]
		if support_table then
			self.keybinds = support_table.keybinds
			self.format = support_table.format
			print("[ConfExt] Manual support loaded.")
		end
	end

	self.config = KnownModIndex:LoadModConfigurationOptions(modname, client_config)
	self.options = {}
	if self.config and type(self.config) == "table" then
		for i,v in ipairs(self.config) do
			if v.name and v.options and (v.saved ~= nil or v.default ~= nil) and (is_client_only or not v.client or self.client_config) then
				local _value = v.saved
				if _value == nil then _value = v.default end
				-- Calculate this beforehand cus it's used more than once
				local is_keybind = (self.keybinds and self.keybinds[v.name] or v.is_keybind) or (v.options == (modinfo and modinfo.keys))
				--
				local option_data = shallowcopy(v) -- there's a LOT of fields to carry over, just copy lmao
				option_data.value = shallowcopy(_value)
				option_data.initial_value = shallowcopy(_value)
				option_data.is_keybind = is_keybind
				option_data.is_toggle = #v.options == 2 and type(v.options[1].data) == "boolean" and type(v.options[2].data) == "boolean" and v.options[1].data ~= v.options[2].data
				option_data.is_header = #v.options == 1 and v.options[1].description and v.options[1].description:len() == 0
				option_data.label = v.label or v.name
				table.insert(self.options, option_data)

				-- Here if we detect an options that is keybind but has strings as data values, we'll have to use a different format
				if not self.format and is_keybind and v.options[1] and type(v.options[1].data) == "string" then
					self.format = require "remi_commonstringformat"
					print("[ConfExt] Common format loaded.")
				end
			end
		end
	end
	self.split_options = BreakIntoSections(self.options)
	self.started_default = self:IsDefaultSettings()
	self.dirty = false
	self.pre_section_scroll_pos = nil -- if it's a number then it means a section is opened

	self.black = self:AddChild(TEMPLATES.BackgroundTint())
	self.root = self:AddChild(TEMPLATES.ScreenRoot())

	local label_width = 300
	local spinner_width = 225
	local item_width, item_height = label_width + spinner_width + 70, 40

	local buttons = {
		{ text = STRINGS.UI.MODSSCREEN.APPLY,			cb = function() self:Apply() end,				},
		{ text = STRINGS.UI.MODSSCREEN.RESETDEFAULT, 	cb = function() self:ResetToDefaultValues() end,},
		{ text = STRINGS.UI.MODSSCREEN.BACK,		 	cb = function() self:Cancel() end,				},
	}

	self.dialog = self.root:AddChild(TEMPLATES.RectangleWindow(item_width + 60, 580, nil, buttons))

	self.option_header = self.dialog:AddChild(Widget("option_header"))
	self.option_header:SetPosition(0, 270)

	local title_max_w = 420
	local title_max_chars = 70
	local title = self.option_header:AddChild(Text(HEADERFONT, 28, " "..STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX))
	local title_suffix_w = title:GetRegionSize()
	function title:Reset()
		if title_suffix_w < title_max_w then
			self:SetTruncatedString(KnownModIndex:GetModFancyName(modname), title_max_w - title_suffix_w, title_max_chars - 1 - STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX:len(), true)
			self:SetString(self:GetString().." "..STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX)
		else
			-- translation was so long we can't fit any more text
			self:SetTruncatedString(STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX, title_max_w, title_max_chars, true)
		end
		--
		title:SetColour(UICOLOURS.GOLD_SELECTED)
	end
	title:Reset()
	self.title = title

	local option_description = self.option_header:AddChild(Text(CHATFONT, 22))
	option_description:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
	option_description:SetPosition(0,-48)
	option_description:SetRegionSize(item_width+70, 50)
	option_description:SetVAlign(ANCHOR_TOP) -- stop text from jumping around as we scroll
	option_description:EnableWordWrap(true)
	self.option_description = option_description

	local value_description = self.option_header:AddChild(Text(CHATFONT, 22))
	value_description:SetColour(UICOLOURS.GOLD)
	value_description:SetPosition(0,-85)
	value_description:SetRegionSize(item_width+70, 25)
	self.value_description = value_description

	self.optionspanel = self.dialog:InsertWidget(Widget("optionspanel"))
	self.optionspanel:SetPosition(0,-60)

	local section_back_btn = self.optionspanel:AddChild(ImageButton("images/global_redux.xml", "close.tex", "close.tex"))
	section_back_btn:SetOnClick(function()
		self:SetSection()
	end)
	section_back_btn:SetPosition(340, 330)
	section_back_btn:SetScale(.7)
	section_back_btn:SetHoverText(STRINGS.BUTTONPICKER.RETURN)
	section_back_btn:Hide()
	self.section_back_btn = section_back_btn

	local function ScrollWidgetsCtor(context, idx)
		local widget = Widget("option"..idx)
		widget.bg = widget:AddChild(TEMPLATES.ListItemBackground(item_width, item_height))
		local opt = widget:AddChild(ImageButton("images/global_redux.xml", "blank.tex", "spinner_focus.tex"))
		opt:ForceImageSize(spinner_width, item_height)
		opt.text:SetRegionSize(spinner_width-30, item_height)
		opt:SetText("")
		opt:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
		opt:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
		opt:SetFont(CHATFONT)
		opt:SetTextSize(20)
		opt:SetFocusSound()
		opt:SetPosition((item_width/2)-(spinner_width/2)-40, 0)
		opt:SetOnClick(function()
			self:GenericOptionCallback(widget.opt.option, widget.opt)
		end)
		widget.opt = opt

		widget.changed_image = widget:AddChild(Image("images/global_redux.xml", "wardrobe_spinner_bg.tex"))
		widget.changed_image:SetTint(1,1,1,0.3)
		widget.changed_image:SetSize(spinner_width+20, item_height)
		widget.changed_image:SetPosition((item_width/2)-(spinner_width/2)-40+2, 0)
		widget.changed_image:Hide()
		widget.opt.UpdateAppearance = function(button)
			local option = button.option
			if not option then return end

			if custom_not_equal(option.value, option.initial_value) then
				widget.changed_image:Show()
			else
				widget.changed_image:Hide()
			end

			if option._section then
				if not option.displaystr then 
					local section_size = #option._section
					option.displaystr = string.format(STRINGS.BUTTONPICKER.OPENSECTION, section_size, section_size == 1 and "" or "s")
				end
				--
				button:SetText(option.displaystr)
				button:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
				button:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
				button:SetFont(CHATFONT)
			elseif option.is_text_config then -- don't check anything for inputs
				button:SetText(tostring(option.value))
				button:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
				button:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
				button:SetFont(CHATFONT)
			elseif option.is_rgb_config or option.is_rgba_config then
				button:SetText("████")
				button:SetTextColour(unpack(option.value))
				button:SetTextFocusColour(unpack(option.value))
				button:SetFont(CHATFONT)
			elseif option.choices then
				if not option.displaystr and type(option.value) == "table" then
					local descs = ""
					for k,v in ipairs(option.choices) do
						if option.value[v.data] and descs:len() < DISPLAYSTR_MAXCHARS then descs = descs..v.description..", " end
					end
					option.displaystr = descs == "" and "--" or descs:sub(0,-3)
				end
				--
				button:SetText(option.displaystr or "...")
				button:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
				button:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
				button:SetFont(CHATFONT)
			elseif option.is_set_config then
				if not option.displaystr and type(option.value) == "table" then
					local descs = ""
					for k in pairs(option.value) do
						if k ~= "" and descs:len() < DISPLAYSTR_MAXCHARS then descs = descs..k..", " end
					end
					option.displaystr = descs == "" and "--" or descs:sub(0,-3)
				end
				--
				button:SetText(option.displaystr or "...")
				button:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
				button:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
				button:SetFont(CHATFONT)
			elseif option.is_array_config then
				if not option.displaystr and type(option.value) == "table" then
					local descs = ""
					for k,v in ipairs(option.value) do
						if v ~= "" and descs:len() < DISPLAYSTR_MAXCHARS then descs = descs..v..", " end
					end
					option.displaystr = descs == "" and "--" or descs:sub(0,-3)
				end
				--
				button:SetText(option.displaystr or "...")
				button:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
				button:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
				button:SetFont(CHATFONT)
			elseif option.is_dictionary_config then
				if not option.displaystr and type(option.value) == "table" then
					local descs = ""
					for k,v in pairs(option.value) do
						if k ~= "" and v ~= "" and descs:len() < DISPLAYSTR_MAXCHARS then descs = descs..k.." = "..v..", " end
					end
					option.displaystr = descs == "" and "--" or descs:sub(0,-3)
				end
				--
				button:SetText(option.displaystr or "...")
				button:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
				button:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
				button:SetFont(CHATFONT)
			else
				button:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
				button:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
				button:SetFont(CHATFONT)
				--
				for k,v in ipairs(option.options) do
					if custom_equal(v.data, option.value) then
						button:SetText(checkdesc(v.description))
						if option.is_font_config then button:SetFont(fontexists(v.data) or DEFAULTFONT) end
						return
					end
				end
				--
				button:SetText(option.is_keybind and type(option.value) == "number" and option.value <= 0 and STRINGS.UI.CONTROLSSCREEN.INPUTS[6][2] or "!!! "..STRINGS.UI.CONTROLSSCREEN.INVALID_CONTROL.." !!!")
			end
		end

		local revert = widget:AddChild(ImageButton("images/button_icons.xml", "undo.tex", "undo.tex"))
		revert:SetOnClick(
			function()
				local option = widget.opt.option
				option.value = shallowcopy(option.default)
				option.displaystr = nil
				widget.opt:UpdateAppearance()
				self:MakeDirty()
			end)
		revert:SetPosition((item_width/2)-20 , 0)
		revert:SetScale(0.12, 0.12)
		revert:SetHoverText(STRINGS.UI.MODSSCREEN.RESETDEFAULT)
		widget.revert = revert

		local unbind = widget:AddChild(ImageButton("images/global_redux.xml", "close.tex", "close.tex"))
		unbind:SetOnClick(
			function()
				local option = widget.opt.option
				if self.format then
					if self.format[-1] ~= nil then option.value = self.format[-1] else TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative") end
				else
					option.value = -1
				end

				widget.opt:UpdateAppearance()
				self:MakeDirty()
			end)
		unbind:SetPosition((item_width/2)-20 , 0)
		unbind:SetScale(0.6, 0.6)
		unbind:SetHoverText(STRINGS.UI.CONTROLSSCREEN.UNBIND)
		widget.unbind = unbind

		local label = widget:AddChild(Text(CHATFONT, 25, ""))
		label:SetColour(UICOLOURS.GOLD)
		label:SetPosition((-item_width/2)+(label_width/2), 0)
		label:SetRegionSize(label_width, item_height)
		label:SetHAlign(ANCHOR_RIGHT)
		widget.label = label

		widget.ApplyDescription = function()
			local option = widget.opt.option
			if not option then return end

			self.option_description:SetString(option.hover or "")

			for k,v in ipairs(option.options) do
				if custom_equal(v.data, option.value) then
					self.value_description:SetString(v.hover or "")
					if option.is_font_config then self.value_description:SetFont(fontexists(v.data) or DEFAULTFONT) else self.value_description:SetFont(CHATFONT) end
					return
				end
			end
			self.value_description:SetString("")
		end
		widget.opt.ApplyDescription = widget.ApplyDescription

		widget:SetOnGainFocus(function()
			self.options_scroll_list:OnWidgetFocus(widget)
			widget:ApplyDescription()
		end)

		widget.focus_forward = opt
		widget.default_focus = opt
		widget.opt:MoveToFront()
		return widget
	end

	local function ApplyDataToWidget(context, widget, option, idx)
		widget.opt.option = option
		if option then
			local label = (option.label or STRINGS.UI.MODSSCREEN.UNKNOWN_MOD_CONFIG_SETTING)
			if not option.is_header then
				label =  label .. ":"
			end
			widget.real_index = idx
			widget.label:Show()

			if widget.focus then
				widget:ApplyDescription()
			end

			if not option.is_header or option._section then
				widget.bg:Show()
				widget.opt:Show()
				widget.opt:Unselect()
				widget.label:SetSize(25) -- same as LabelSpinner's default.
				widget.label:SetColour(option._section and UICOLOURS.WHITE or UICOLOURS.GOLD)
			else -- header and no section
				widget.bg:Hide()
				widget.opt:Hide()
				widget.opt:Select()
				widget.label:SetSize(30)
				widget.label:SetColour(UICOLOURS.GOLD)
			end

			if option.is_keybind then
				widget.unbind:Show()
			else
				widget.unbind:Hide()
			end

			if option.is_text_config 
			or option.is_rgb_config or option.is_rgba_config 
			or option.choices 
			or option.is_set_config or option.is_array_config or option.is_dictionary_config then
				widget.revert:Show()
			else
				widget.revert:Hide()
			end

			widget.label:SetString(label)
			widget.opt:UpdateAppearance()
		else
			widget.label:Hide()
			widget.opt:Hide()
			widget.opt:Select()
			widget.bg:Hide()
			widget.unbind:Hide()
			widget.revert:Hide()
			widget.changed_image:Hide()
		end
	end

	self.options_scroll_list = self.optionspanel:AddChild(TEMPLATES.ScrollingGrid(
			self.split_options,
			{
				scroll_context = {},
				widget_width  = item_width,
				widget_height = item_height,
				num_visible_rows = 9,
				num_columns = 1,
				peek_percent = 0.22,
				item_ctor_fn = ScrollWidgetsCtor,
				apply_fn = ApplyDataToWidget,
				scrollbar_offset = 20,
				scrollbar_height_offset = -60
			}
		))
	self.options_scroll_list:SetPosition(0,-6)

	-- Top border of the scroll list.
	self.horizontal_line = self.optionspanel:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
	self.horizontal_line:SetPosition(0,self.options_scroll_list.visible_rows/2 * item_height)
	self.horizontal_line:SetSize(item_width+30, 3)

	local search_bar = self.optionspanel:AddChild(TextEdit(CHATFONT, 20, "", UICOLOURS.GOLD_CLICKABLE))
	search_bar:SetForceEdit(true)
	search_bar:SetRegionSize(item_width, 30)
	search_bar:SetPosition(0,self.options_scroll_list.visible_rows/2 * item_height + 14)
	search_bar:SetHAlign(ANCHOR_LEFT)
	search_bar.prompt_color = {215/255, 210/255, 157/255, .55}
	search_bar:SetTextPrompt(STRINGS.BUTTONPICKER.SEARCH, search_bar.prompt_color) -- UICOLOURS.GOLD_CLICKABLE but less alpha
	search_bar:SetIdleTextColour(UICOLOURS.GOLD_CLICKABLE)
	search_bar:SetEditTextColour(UICOLOURS.WHITE)
	search_bar:SetEditCursorColour(UICOLOURS.WHITE)
	--
	search_bar.OnGainFocus = function(self)
		Widget.OnGainFocus(self)

		if not self.editing then
			self:SetColour(UICOLOURS.GOLD_FOCUS)
			self.prompt:SetColour(UICOLOURS.GOLD_FOCUS)
		end
	end
	--
	search_bar.OnLoseFocus = function(self)
		Widget.OnLoseFocus(self)

		if not self.editing then
			self:SetColour(self.idle_text_color)
			self.prompt:SetColour(self.prompt_color)
		end
	end
	--
	search_bar.OnTextInputted = function() self:FilterConfigs() end
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
	self.default_focus = self.options_scroll_list
	self:HookupFocusMoves()
end)


local function search_match(search, str)
	if string.find( str, search, 1, true ) ~= nil then return true end
	return false
end

function RemiNewModConfigurationScreen:FilterConfigs()
	local query = TrimString(self.search_bar:GetString()):lower()

	local filtered_configs = {}
	if query ~= "" then
		for k,v in pairs(self.options) do
			if search_match(query, v.label:lower()) then
				table.insert(filtered_configs, v)
			end
		end		
	else
		filtered_configs = self.split_options
	end
	--
	self.title:Reset()
	self.section_back_btn:Hide()
	self.options_scroll_list:SetItemsData(filtered_configs)
	self.options_scroll_list:ScrollToScrollPos(1)
	self.pre_section_scroll_pos = nil
end

function RemiNewModConfigurationScreen:SetSection(option, option_button)
	if option == nil then
		self.title:Reset()
		self.section_back_btn:Hide()
		self.options_scroll_list:SetItemsData(self.split_options)	
		self.options_scroll_list:ScrollToScrollPos(self.pre_section_scroll_pos)	
		self.pre_section_scroll_pos = nil
	else
		if next(option._section) == nil then 
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative")
			return 
		end
		--
		self.title:SetColour(UICOLOURS.WHITE)
		self.title:SetString(option.label)
		self.section_back_btn:Show()
		self.pre_section_scroll_pos = self.options_scroll_list.current_scroll_pos
		self.options_scroll_list:SetItemsData(option._section)
		self.options_scroll_list:ScrollToScrollPos(1)
	end
end

function RemiNewModConfigurationScreen:GenericOptionCallback(option, option_button)
	if option._section then
		self:SetSection(option, option_button)
	elseif option.is_keybind then
		self:SetBind(option, option_button)
	elseif option.is_set_config then
		self:EditSet(option, option_button)
	elseif option.is_array_config then
		self:EditArray(option, option_button)
	elseif option.is_dictionary_config then
		self:EditDictionary(option, option_button)
	elseif option.choices then
		self:SetMultipleChoices(option, option_button)
	elseif option.is_rgb_config or option.is_rgba_config then
		self:SetColor(option, option_button)
	elseif option.is_text_config then
		self:SetInput(option, option_button)
	elseif option.is_toggle then
		self:AlternateOption(option, option_button)
	else
		self:SetOption(option, option_button)
	end
end

function RemiNewModConfigurationScreen:EditSet(option, option_button)
	local popup
	local buttons = {
		{text = STRINGS.UI.MODSSCREEN.APPLY, cb = function() local descs, data = popup:CollectData(); self:OnComplexDataSet(option, option_button, descs, data); TheFrontEnd:PopScreen() end},
		-- {text = STRINGS.UI.MODSSCREEN.BACK, cb = function() TheFrontEnd:PopScreen() end}, -- "back" button is gonna be added automatically
	}

	local list_options = {}
	for k in pairs(option.value) do table.insert(list_options, {text = k}) end
	table.sort(list_options, function(a, b) return a.text < b.text end) -- first sort
	for i,v in pairs(list_options) do v.index = i end -- THEN add indexes

	popup = ArrayEditScreen(list_options, option.label, option.hover or "--", buttons, true, option.restricted)
	TheFrontEnd:PushScreen(popup)
end

function RemiNewModConfigurationScreen:EditArray(option, option_button)
	local popup
	local buttons = {
		{text = STRINGS.UI.MODSSCREEN.APPLY, cb = function() local descs, data = popup:CollectData(); self:OnComplexDataSet(option, option_button, descs, data); TheFrontEnd:PopScreen() end},
		-- {text = STRINGS.UI.MODSSCREEN.BACK, cb = function() TheFrontEnd:PopScreen() end}, -- "back" button is gonna be added automatically
	}

	local list_options = {}
	for k,v in ipairs(option.value) do
		list_options[k] = {text = v, index = k}
	end

	popup = ArrayEditScreen(list_options, option.label, option.hover or "--", buttons, false, option.restricted)
	TheFrontEnd:PushScreen(popup)
end

function RemiNewModConfigurationScreen:EditDictionary(option, option_button)
	local popup
	local buttons = {
		{text = STRINGS.UI.MODSSCREEN.APPLY, cb = function() local descs, data = popup:CollectData(); self:OnComplexDataSet(option, option_button, descs, data); TheFrontEnd:PopScreen() end},
		-- {text = STRINGS.UI.MODSSCREEN.BACK, cb = function() TheFrontEnd:PopScreen() end}, -- "back" button is gonna be added automatically
	}

	local list_options = {}
	for k,v in pairs(option.value) do table.insert(list_options, {key = k, value = v}) end
	table.sort(list_options, function(a, b) return a.key < b.key end) -- first sort
	for i,v in pairs(list_options) do v.index = i end -- THEN add indexes

	popup = DictionaryEditScreen(list_options, option.label, option.hover or "--", buttons, option.restricted)
	TheFrontEnd:PushScreen(popup)
end

function RemiNewModConfigurationScreen:SetMultipleChoices(option, option_button)
	local popup
	local buttons = {
		{text = STRINGS.UI.MODSSCREEN.APPLY, cb = function() local descs, data = popup:CollectData(); self:OnComplexDataSet(option, option_button, descs, data); TheFrontEnd:PopScreen() end},
		-- {text = STRINGS.UI.MODSSCREEN.BACK, cb = function() TheFrontEnd:PopScreen() end}, -- "back" button is gonna be added automatically
	}

	local list_options = {}
	local max_item_index = 0
	for k,v in ipairs(option.choices) do
		list_options[k] = {text = k..".\t"..checkdesc(v.description), description = v.description, hover = v.hover, data = v.data, onclick = function() end}
		max_item_index = k
	end

	popup = ListChoiceScreen(list_options, option.label, "", option.hover, buttons, option.value)
	TheFrontEnd:PushScreen(popup)
end

function RemiNewModConfigurationScreen:OnComplexDataSet(option, option_button, descs, data)
	option.displaystr = descs
	option.value = data
	TheFrontEnd:GetSound():PlaySound("meta4/winona_remote/click", nil, .3)
	self:MakeDirty()
	option_button:UpdateAppearance()
	option_button:ApplyDescription()
end

function RemiNewModConfigurationScreen:SetColor(option, option_button)
	local popup
	local buttons = {
		{text = STRINGS.UI.MODSSCREEN.APPLY, cb = function() self:OnColorSet(option, option_button, popup:GetCurrentColor()); TheFrontEnd:PopScreen() end},
		{text = STRINGS.UI.MODSSCREEN.BACK, cb = function() TheFrontEnd:PopScreen() end},
	}

	popup = ColorHelperScreen(option.label, option.hover, buttons, option.value, option.is_rgba_config)
	TheFrontEnd:PushScreen(popup)
end

function RemiNewModConfigurationScreen:OnColorSet(option, option_button, color)
	option.value = color
	TheFrontEnd:GetSound():PlaySound("terraria1/skins/life_crystal", nil, .3)
	self:MakeDirty()
	option_button:UpdateAppearance()
	option_button:ApplyDescription()
end

function RemiNewModConfigurationScreen:SetInput(option, option_button)
	local popup
	local buttons = {
		{text = STRINGS.UI.MODSSCREEN.APPLY, cb = function() self:OnInputSet(option, option_button, popup:GetActualString()); TheFrontEnd:PopScreen() end},
		{text = STRINGS.UI.MODSSCREEN.BACK, cb = function() TheFrontEnd:PopScreen() end},
	}
	popup = InputDialogScreen(option.label, buttons, true, true)
	popup:OverrideText(tostring(option.value))

	-- Background curly window
	popup.bg:SetSize(600, 400)

	-- Text edit line
	popup.edit_text:SetPosition(40,-110,0)
	popup.edit_text_bg:SetPosition(40,-110,0)

	-- Add a little label before text edit
	popup.edit_text_label = popup.proot:AddChild(Text(CHATFONT, 25, STRINGS.BUTTONPICKER.VALUESTR, UICOLOURS.WHITE))
	popup.edit_text_label:SetPosition(-240,-110,0)

	-- Add hover as body text
	popup.body = popup.proot:AddChild(Text(CHATFONT, 20, option.hover or "--", UICOLOURS.WHITE))
	popup.body:EnableWordWrap(true)
	popup.body:SetPosition(0, 70)
	popup.body:SetRegionSize(630,280)
	--popup.body:SetVAlign(ANCHOR_MIDDLE)
	--popup.body:SetHAlign(ANCHOR_LEFT)

	TheFrontEnd:PushScreen(popup)
	--popup.edit_text:SetEditing(true)
end

function RemiNewModConfigurationScreen:OnInputSet(option, option_button, input)
	option.value = input
	TheFrontEnd:GetSound():PlaySound("meta4/winona_remote/click", nil, .3)
	self:MakeDirty()
	option_button:UpdateAppearance()
	option_button:ApplyDescription()
end

function RemiNewModConfigurationScreen:AlternateOption(option, option_button)
	option.value = not option.value
	TheFrontEnd:GetSound():PlaySound(option.value and "meta4/wires_minigame/wire_connect" or "meta4/wires_minigame/wire_disconnect", nil, .75)
	self:MakeDirty()
	option_button:UpdateAppearance()
	option_button:ApplyDescription()
end

function RemiNewModConfigurationScreen:SetOption(option, option_button)
	--print("RemiNewModConfigurationScreen:SetOption",option, option_button)
	local function apply(value)
		option.value = value
		TheFrontEnd:GetSound():PlaySound("meta4/winona_remote/click", nil, .3)
		self:MakeDirty()
		TheFrontEnd:PopScreen()
		option_button:UpdateAppearance()
		option_button:ApplyDescription()
	end

	local list_options = {}
	local default_option = "???"
	local amount_options = 0
	for k,v in ipairs(option.options) do
		list_options[k] = {text = k..".\t"..checkdesc(v.description), hover = v.hover, onclick = function() apply(v.data) end, data = v.data}
		if custom_equal(v.data, option.default) then default_option = checkdesc(v.description) end
		amount_options = amount_options + 1 -- k
	end

	local popup = ListOptionScreen(list_options, option.label, string.format(STRINGS.UI.CONTROLSSCREEN.DEFAULT_CONTROL_TEXT, default_option), option.hover, nil, false, option.is_font_config)
	popup.scroll_list.scroll_per_click = math.clamp(1+math.floor(amount_options/30), 1, 5)
	TheFrontEnd:PushScreen(popup)
end

function RemiNewModConfigurationScreen:SetBind(option, option_button)
	--print("RemiNewModConfigurationScreen:SetBind",option, option_button)

	--local loc_text = STRINGS.UI.CONTROLSSCREEN.INPUTS[1][option.value] or "Missing key"
	local valid_options = {--[[{text = "Esc to cancel."},{text = "Backspace to remove bind."}]]}
	local default_key = "???"
	for k,v in ipairs(option.options) do
		if type(v.data) == "number" and v.data > 0 or type(v.data) ~= "number" then table.insert(valid_options, {text = "-\t"..checkdesc(v.description)}) end
		if custom_equal(v.data, option.default) then default_key = checkdesc(v.description) end
	end

	local popup = ListOptionScreen(valid_options, option.label, STRINGS.BUTTONPICKER.PRESS_A_BUTTON.."\n"..string.format(STRINGS.UI.CONTROLSSCREEN.DEFAULT_CONTROL_TEXT, default_key), option.hover, nil, true, false)
	TheFrontEnd:PushScreen(popup)

	self.inst:DoTaskInTime(FRAMES, function()
		self.inputhandlers = {
			TheInput:AddKeyHandler(function(key, down)
				if not down then self:OnBindSet(option, option_button, key) end
			end),

			TheInput:AddMouseButtonHandler(function(key, down, x, y)
				if not down then self:OnBindSet(option, option_button, key) end
			end),
		}
	end)

	self.is_mapping = true
end

local function GetGenericCtrlShiftAlt(input)
	if input == KEY_LCTRL or input == KEY_RCTRL then return KEY_CTRL end
	if input == KEY_LSHIFT or input == KEY_RSHIFT then return KEY_SHIFT end
	if input == KEY_LALT or input == KEY_RALT then return KEY_ALT end
end

function RemiNewModConfigurationScreen:IsValidInputForOption(input, option)
	if not input then return end
	if input == KEY_ESCAPE then return input end

	if self.format then input = self.format[input] end
	for k,v in ipairs(option.options) do
		if input == v.data then return input end
	end
end

function RemiNewModConfigurationScreen:GetValidatedInput(input, option)
	return self:IsValidInputForOption(input, option) or self:IsValidInputForOption(GetGenericCtrlShiftAlt(input), option)
end

function RemiNewModConfigurationScreen:OnBindSet(option, option_button, input)
	--print("RemiNewModConfigurationScreen:OnBindSet",option, option_button, input)

	--print("initial input:", input)
	local valid_input = self:GetValidatedInput(input, option)

	if self.is_mapping and valid_input then
		if valid_input ~= 0xFFFFFFFF then
			TheFrontEnd:PopScreen()
		end

		for k,v in ipairs(self.inputhandlers) do v:Remove() end
		self.inputhandlers = {}

		if valid_input ~= KEY_ESCAPE then
			option.value = valid_input
			TheFrontEnd:GetSound():PlaySound("meta4/winona_remote/click", nil, .3)
			option_button:UpdateAppearance()
			option_button:ApplyDescription()
			self:MakeDirty()
		end

		self.is_mapping = false
	end
end

function RemiNewModConfigurationScreen:ResetToDefaultValues()
	local function reset()
		for i,v in ipairs(self.options) do
			v.value = shallowcopy(v.default)
			v.displaystr = nil
			--v.selected_value = v.default
		end
		--self.options_scroll_list:RefreshView()
		for k,v in ipairs(self.options_scroll_list.widgets_to_update) do v.opt:UpdateAppearance() end
		self.value_description:SetString("")
	end

	if not self:IsDefaultSettings() then
		self:ConfirmRevert(function()
			TheFrontEnd:PopScreen()
			self:MakeDirty()
			reset()
		end)
	end
end

function RemiNewModConfigurationScreen:CollectSettings()
	local settings = nil
	local keyed_settings = {}
	for i,v in pairs(self.options) do
		if not settings then settings = {} end
		table.insert(settings, {name=v.name, label = v.label, options=v.options, default=v.default, saved=v.value})
		keyed_settings[v.name] = v.value
	end
	return settings, keyed_settings
end

function RemiNewModConfigurationScreen:Apply()
	if self:IsDirty() then
		local settings, keyed_settings = self:CollectSettings()
		KnownModIndex:SaveConfigurationOptions(function()
			self:MakeDirty(false)
			if self.callback then self.callback(keyed_settings) end -- new: send config data immediately
			TheFrontEnd:PopScreen()
		end, self.modname, settings, self.client_config)
	else
		self:MakeDirty(false)
		TheFrontEnd:PopScreen()
	end
end

function RemiNewModConfigurationScreen:ConfirmRevert(callback)
	TheFrontEnd:PushScreen(
		PopupDialogScreen( STRINGS.UI.MODSSCREEN.BACKTITLE, STRINGS.UI.MODSSCREEN.BACKBODY,
		  {
		  	{
		  		text = STRINGS.UI.MODSSCREEN.YES,
		  		cb = callback or function() TheFrontEnd:PopScreen() end
			},
			{
				text = STRINGS.UI.MODSSCREEN.NO,
				cb = function()
					TheFrontEnd:PopScreen()
				end
			}
		  }
		)
	)
end

function RemiNewModConfigurationScreen:Cancel()
	if self.pre_section_scroll_pos then
		self:SetSection()
	elseif self:IsDirty() and not (self.started_default and self:IsDefaultSettings()) then
		self:ConfirmRevert(function()
			self:MakeDirty(false)
			TheFrontEnd:PopScreen()
			TheFrontEnd:PopScreen()
		end)
	else
		self:MakeDirty(false)
		TheFrontEnd:PopScreen()
	end
end

function RemiNewModConfigurationScreen:MakeDirty(dirty)
	if dirty ~= nil then
		self.dirty = dirty
	else
		self.dirty = true
	end
end

function RemiNewModConfigurationScreen:IsDirty()
	return self.dirty
end

function RemiNewModConfigurationScreen:IsDefaultSettings()
	local alldefault = true
	for i,v in ipairs(self.options) do
		if custom_not_equal(self.options[i].value, self.options[i].default) then
			alldefault = false
			break
		end
	end
	return alldefault
end

function RemiNewModConfigurationScreen:OnControl(control, down)
	if RemiNewModConfigurationScreen._base.OnControl(self, control, down) then return true end

	if not down then
		if control == CONTROL_CANCEL then
			if self.pre_section_scroll_pos then self:SetSection() else self:Cancel() end
			return true
		end
	end
end

function RemiNewModConfigurationScreen:HookupFocusMoves()
	-- in the distant future?
end

return RemiNewModConfigurationScreen
