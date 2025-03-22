-- Basically the usual mod config screen but with some minor changes.
require "util"
require "strings"
local Image = require "widgets/image"
local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local ImageButton = require "widgets/imagebutton"
local PopupDialogScreen = require "screens/redux/popupdialog"
local TextListPopup = require "screens/redux/textlistpopup"
local InputDialogScreen = require "screens/redux/inputdialog"
local ManualSupport = require "remi_manualsupport"
local ColorHelperScreen = require "widgets/remi_colorhelperscreen"

local function checkdesc(desc)
	return (type(desc) == "string" or type(desc) == "number") and tostring(desc) or "!!! WRONG DESC !!!"
end

local function custom_not_equal(a,b)
	if type(a) ~= type(b) then return true end
	if type(a) == "table" then -- COLOR TABLE {R, G, B, A}
		for i = 1,4 do
			if math.abs(a[i] - b[i]) >= 0.001 then
				return true
			end
		end
		return false
	else
		return a ~= b
	end
end

local chinese = LanguageTranslator.defaultlang or "en"
chinese = chinese == "zh" or chinese == "zht"

local VALUESTR = chinese and "选项值" or "Value:" 

local NewModConfigurationScreen = Class(Screen, function(self, modname, client_config)
	Screen._ctor(self, "NewModConfigurationScreen")

	self.custombuttons = {}

	self.modname = modname
	self.client_config = client_config
	local is_client_only = KnownModIndex:GetModInfo(modname) and KnownModIndex:GetModInfo(modname).client_only_mod

	self.config = KnownModIndex:LoadModConfigurationOptions(modname)
	self.options = {}
	local subtable = ManualSupport[self.modname]
	if subtable then
		self.keybinds = subtable.keybinds
		self.format = subtable.format
	end

	if self.config and type(self.config) == "table" then
		for i,v in ipairs(self.config) do
			if v.name and v.options and (v.saved ~= nil or v.default ~= nil) and (is_client_only or not v.client or self.client_config) then
				local _value = v.saved
				if _value == nil then _value = v.default end
				table.insert(self.options, {name = v.name, label = v.label, options = v.options, default = v.default, value = shallowcopy(_value), initial_value = shallowcopy(_value), hover = v.hover,
					is_header = v.is_header,
					is_text_config = v.is_text_config,
					is_rgb_config = v.is_rgb_config,
					is_rgba_config = v.is_rgba_config,
					is_keybind = self.keybinds and self.keybinds[v.name] or v.is_keybind,
					is_toggle = #v.options == 2 and type(v.options[1].data) == "boolean" and type(v.options[2].data) == "boolean" and v.options[1].data ~= v.options[2].data}
				)

				-- Here if we detect an options that is keybind but has strings as data values, we'll have to use a different format
				if not self.format and v.is_keybind and v.options[1] and type(v.options[1].data) == "string" then
					self.format = require "remi_commonstringformat"
					print("[ConvConf] Common format loaded.")
				end
			end
		end
	end

	self.started_default = self:IsDefaultSettings()

	self.black = self:AddChild(TEMPLATES.BackgroundTint())
	self.root = self:AddChild(TEMPLATES.ScreenRoot())

	local label_width = 300
	local spinner_width = 225
	local item_width, item_height = label_width + spinner_width + 70, 40

	local buttons = {
		{ text = STRINGS.UI.MODSSCREEN.APPLY,			cb = function() self:Apply() end,				},
		{ text = STRINGS.UI.MODSSCREEN.RESETDEFAULT, 	cb = function() self:ResetToDefaultValues() end, },
		{ text = STRINGS.UI.MODSSCREEN.BACK,		 	cb = function() self:Cancel() end,			   },
	}

	self.dialog = self.root:AddChild(TEMPLATES.RectangleWindow(item_width + 60, 580, nil, buttons))

	self.option_header = self.dialog:AddChild(Widget("option_header"))
	self.option_header:SetPosition(0, 270)

	local title_max_w = 420
	local title_max_chars = 70
	local title = self.option_header:AddChild(Text(HEADERFONT, 28, " "..STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX))
	local title_suffix_w = title:GetRegionSize()
	title:SetColour(UICOLOURS.GOLD_SELECTED)
	if title_suffix_w < title_max_w then
		title:SetTruncatedString(KnownModIndex:GetModFancyName(modname), title_max_w - title_suffix_w, title_max_chars - 1 - STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX:len(), true)
		title:SetString(title:GetString().." "..STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX)
	else
		-- translation was so long we can't fit any more text
		title:SetTruncatedString(STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX, title_max_w, title_max_chars, true)
	end

	self.option_description = self.option_header:AddChild(Text(CHATFONT, 22))
	self.option_description:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
	self.option_description:SetPosition(0,-48)
	self.option_description:SetRegionSize(item_width+70, 50)
	self.option_description:SetVAlign(ANCHOR_TOP) -- stop text from jumping around as we scroll
	self.option_description:EnableWordWrap(true)

	self.value_description = self.option_header:AddChild(Text(CHATFONT, 22))
	self.value_description:SetColour(UICOLOURS.GOLD)
	self.value_description:SetPosition(0,-85)
	self.value_description:SetRegionSize(item_width+70, 25)

	self.optionspanel = self.dialog:InsertWidget(Widget("optionspanel"))
	self.optionspanel:SetPosition(0,-60)

	self.dirty = false

	self.optionwidgets = {}

	local function ScrollWidgetsCtor(context, idx)
		local widget = Widget("option"..idx)
		widget.bg = widget:AddChild(TEMPLATES.ListItemBackground(item_width, item_height))
		widget.opt = widget:AddChild(ImageButton("images/global_redux.xml", "blank.tex", "spinner_focus.tex"))
		widget.opt:ForceImageSize(spinner_width, item_height)
		widget.opt.text:SetRegionSize(spinner_width-30, item_height)
		widget.opt:SetText("")
		widget.opt:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
		widget.opt:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
		widget.opt:SetFont(CHATFONT)
		widget.opt:SetTextSize(25)
		widget.opt:SetFocusSound()
		widget.opt:SetPosition((item_width/2)-(spinner_width/2)-40, 0)
		widget.opt:SetOnClick(function()
			self:GenericOptionCallback(widget.real_index, widget.opt)
		end)
		widget.changed_image = widget:AddChild(Image("images/global_redux.xml", "wardrobe_spinner_bg.tex"))
		widget.changed_image:SetTint(1,1,1,0.3)
		widget.changed_image:SetSize(spinner_width, item_height)
		widget.changed_image:SetPosition((item_width/2)-(spinner_width/2)-40+2, 0)
		widget.changed_image:Hide()
		widget.opt.UpdateAppearance = function(button)
			local option = self.options[widget.real_index]
			if not option then return end

			if custom_not_equal(option.value, option.initial_value) then
				widget.changed_image:Show()
			else
				widget.changed_image:Hide()
			end

			if option.is_text_config then -- don't check anything for inputs
				button:SetText(tostring(option.value))
				button:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
				button:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
			elseif option.is_rgb_config or option.is_rgba_config then
				button:SetText("████")
				button:SetTextColour(unpack(option.value))
				button:SetTextFocusColour(unpack(option.value))
			else
				for k,v in ipairs(option.options) do
					if v.data == option.value then
						button:SetText(checkdesc(v.description))
						return
					end
				end
				button:SetText(option.is_keybind and type(option.value) == "number" and option.value <= 0 and STRINGS.UI.CONTROLSSCREEN.INPUTS[6][2] or "!!! "..STRINGS.UI.CONTROLSSCREEN.INVALID_CONTROL.." !!!")
				button:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
				button:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
			end
		end

		widget.revert = widget:AddChild(ImageButton("images/button_icons.xml", "undo.tex", "undo.tex"))
		widget.revert:SetOnClick(
			function()
				local option = self.options[widget.real_index]
				if not option then return end
				option.value = shallowcopy(option.default)

				widget.opt:UpdateAppearance()
				self:MakeDirty()
			end)
		widget.revert:SetPosition((item_width/2)-20 , 0)
		widget.revert:SetScale(0.12, 0.12)
		widget.revert:SetHoverText(STRINGS.UI.MODSSCREEN.RESETDEFAULT)

		widget.unbind = widget:AddChild(ImageButton("images/global_redux.xml", "close.tex", "close.tex"))
		widget.unbind:SetOnClick(
			function()
				local option = self.options[widget.real_index]
				if not option then return end
				if self.format then
					if self.format[-1] ~= nil then option.value = self.format[-1] else TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative") end
				else
					option.value = -1
				end

				widget.opt:UpdateAppearance()
				self:MakeDirty()
			end)
		widget.unbind:SetPosition((item_width/2)-20 , 0)
		widget.unbind:SetScale(0.6, 0.6)
		widget.unbind:SetHoverText(STRINGS.UI.CONTROLSSCREEN.UNBIND)

		widget.label = widget:AddChild(Text(CHATFONT, 25, ""))
		widget.label:SetColour(UICOLOURS.GOLD)
		widget.label:SetPosition((-item_width/2)+(label_width/2), 0)
		widget.label:SetRegionSize( label_width, item_height )
		widget.label:SetHAlign( ANCHOR_RIGHT )

		widget.ApplyDescription = function()
			local option = widget.opt.data and widget.opt.data.option.hover or ""
			--local value = widget.opt.data and widget.opt.data.spin_options_hover[widget.opt.data.selected_value] or ""
			self.option_description:SetString(option)
			--self.value_description:SetString(value)

			option = self.options[widget.real_index]
			if not option then return end
			for k,v in ipairs(option.options) do
				if v.data == option.value then
					self.value_description:SetString(v.hover or "")
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

		widget.focus_forward = widget.opt
		widget.default_focus = widget.opt
		widget.opt:MoveToFront()
		table.insert(self.custombuttons, widget.opt)
		return widget
	end

	local function ApplyDataToWidget(context, widget, data, idx)		
		widget.opt.data = data
		if data then
			local label = (data.option.label or data.option.name or STRINGS.UI.MODSSCREEN.UNKNOWN_MOD_CONFIG_SETTING)
			if not data.is_header then
				label =  label .. ":"
			end
			widget.real_index = idx
			widget.label:Show()

			if widget.focus then
				widget:ApplyDescription()
			end	

			if data.is_header then
			    widget.bg:Hide()
			    widget.opt:Hide()
			    widget.opt:Select()
			    widget.label:SetSize(30)
			else
			    widget.bg:Show()
			    widget.opt:Show()
			    widget.opt:Unselect()
			    widget.label:SetSize(25) -- same as LabelSpinner's default.
			end

			if data.is_keybind then
				widget.unbind:Show()
			else
				widget.unbind:Hide()
			end

			if data.is_text_config or data.is_rgb_config or data.is_rgba_config then
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
		end
	end

	for idx,option_item in ipairs(self.options) do
		--local spin_options = {} --{{text="default"..tostring(idx), data="default"},{text="2", data="2"}, }
		local spin_options_hover = {}
		for _,v in ipairs(option_item.options) do
		    --table.insert(spin_options, {text=v.description, data=v.data})
		    spin_options_hover[v.data] = v.hover
		end

		--[[
		local initial_value = option_item.value
		if initial_value == nil then
			initial_value = option_item.default
		end
		--]]

		local data = {
			is_header = option_item.is_header or #option_item.options == 1 and option_item.options[1].description and option_item.options[1].description:len() == 0,
			is_keybind = option_item.is_keybind,
			is_text_config = option_item.is_text_config,
			is_rgb_config = option_item.is_rgb_config,
			is_rgba_config = option_item.is_rgba_config,
			--spin_options = spin_options,
			spin_options_hover = spin_options_hover,
			option = option_item,
			--initial_value = initial_value,
			--selected_value = initial_value,
		}
		table.insert(self.optionwidgets, data)
	end

	self.options_scroll_list = self.optionspanel:AddChild(TEMPLATES.ScrollingGrid(
			self.optionwidgets,
			{
				scroll_context = {
				},
				widget_width  = item_width,
				widget_height = item_height,
				num_visible_rows = 11,
				num_columns = 1,
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
    self.horizontal_line:SetSize(item_width+30, 5)

	self.default_focus = self.options_scroll_list
	self:HookupFocusMoves()
end)

function NewModConfigurationScreen:GenericOptionCallback(option_idx, option_button)
	--print("NewModConfigurationScreen:GenericOptionCallback",option_idx, option_button)
	local option = self.options[option_idx]
	if not option or option.is_header then return end

	if option.is_keybind then
		self:SetBind(option, option_button)
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

function NewModConfigurationScreen:SetColor(option, option_button)
	local popup
	local buttons = {
		{text = STRINGS.UI.MODSSCREEN.APPLY, cb = function() self:OnColorSet(option, option_button, popup:GetCurrentColor()); TheFrontEnd:PopScreen() end},
		{text = STRINGS.UI.MODSSCREEN.BACK, cb = function() TheFrontEnd:PopScreen() end},
	}

	popup = ColorHelperScreen(option.label, buttons, option.value, option.is_rgba_config)
	TheFrontEnd:PushScreen(popup)
end

function NewModConfigurationScreen:OnColorSet(option, option_button, color)
	option.value = color
	TheFrontEnd:GetSound():PlaySound("terraria1/skins/life_crystal", nil, .3)
	self:MakeDirty()
	option_button:UpdateAppearance()
	option_button:ApplyDescription()
end

function NewModConfigurationScreen:SetInput(option, option_button)
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
	popup.edit_text_label = popup.proot:AddChild(Text(CHATFONT, 25, VALUESTR, UICOLOURS.WHITE))
	popup.edit_text_label:SetPosition(-240,-110,0)

	-- Add hover as body text
	popup.body = popup.proot:AddChild(Text(CHATFONT, 22, option.hover or "--", UICOLOURS.WHITE))
    popup.body:EnableWordWrap(true)
    popup.body:SetPosition(0, 70)
    popup.body:SetRegionSize(600,280)
    popup.body:SetVAlign(ANCHOR_MIDDLE)

    TheFrontEnd:PushScreen(popup)
	--popup.edit_text:SetEditing(true)
end

function NewModConfigurationScreen:OnInputSet(option, option_button, input)
	option.value = input
	TheFrontEnd:GetSound():PlaySound("meta4/winona_remote/click", nil, .15)
	self:MakeDirty()
	option_button:UpdateAppearance()
	option_button:ApplyDescription()
end

function NewModConfigurationScreen:AlternateOption(option, option_button)
	option.value = not option.value
	--TheFrontEnd:GetSound():PlaySound(option.value and "meta4/winona_battery/battery_level_7_f19" or "meta4/winona_battery/battery_level_1_f19", nil, .3)
	TheFrontEnd:GetSound():PlaySound(option.value and "meta4/wires_minigame/wire_connect" or "meta4/wires_minigame/wire_disconnect", nil, .75)
	self:MakeDirty()
	option_button:UpdateAppearance()
	option_button:ApplyDescription()
end

function NewModConfigurationScreen:SetOption(option, option_button)
	--print("NewModConfigurationScreen:SetOption",option, option_button)
	local function apply(value)
		option.value = value
		self:MakeDirty()
		TheFrontEnd:PopScreen()
		option_button:UpdateAppearance()
		option_button:ApplyDescription()
	end

	local list_options = {}
	local hovers = {}
	local default_option = "???"
	for k,v in ipairs(option.options) do
		list_options[k] = {text = k..".\t"..checkdesc(v.description), hover = v.hover, onclick = function() apply(v.data) end}
		if v.data == option.default then default_option = checkdesc(v.description) end
	end

	local popup = TextListPopup(list_options, option.label or option.name, string.format(STRINGS.UI.CONTROLSSCREEN.DEFAULT_CONTROL_TEXT, default_option))
	for k,v in ipairs(popup.scroll_list.widgets_to_update) do
		local oldfn = v.btn.OnGainFocus
		v.btn.OnGainFocus = function(...)
			oldfn(...) 
			local text = v.btn.text:GetString()
			text = tonumber(text:match("^[0-9]+"))
			if text and list_options[text] then 
				popup.dialog.body:SetString(string.format(STRINGS.UI.CONTROLSSCREEN.DEFAULT_CONTROL_TEXT, default_option).."\n"..(list_options[text].hover or "")) 
			end
		end
	end
	-- popup.scroll_list.scroll_per_click = math.min(2, popup.scroll_list.items_per_view)

	TheFrontEnd:PushScreen(popup)
end

function NewModConfigurationScreen:SetBind(option, option_button)
	--print("NewModConfigurationScreen:SetBind",option, option_button)

	--local loc_text = STRINGS.UI.CONTROLSSCREEN.INPUTS[1][option.value] or "Missing key"
	local valid_options = {--[[{text = "Esc to cancel."},{text = "Backspace to remove bind."}]]}
	local default_key = "???"
	for k,v in ipairs(option.options) do
		if type(v.data) == "number" and v.data > 0 or type(v.data) ~= "number" then table.insert(valid_options, {text = checkdesc(v.description)}) end
		if v.data == option.default then default_key = checkdesc(v.description) end
	end

	local popup = TextListPopup(valid_options, option.label or option.name, STRINGS.UI.CONTROLSSCREEN.CONTROL_SELECT.."\n"..string.format(STRINGS.UI.CONTROLSSCREEN.DEFAULT_CONTROL_TEXT, default_key), {}, nil, true)
	popup.scroll_list.scroll_per_click = math.min(5, popup.scroll_list.items_per_view)

	local oldoncontrol = popup.OnControl
	popup.OnControl = function(popup, control, down) if control == CONTROL_SCROLLBACK or control == CONTROL_SCROLLFWD then return oldoncontrol(popup, control, down) else return true end end
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

function NewModConfigurationScreen:IsValidInputForOption(input, option)
	if not input then return end
	if input == KEY_ESCAPE then return input end

	if self.format then input = self.format[input] end
	for k,v in ipairs(option.options) do
		if input == v.data then return input end
	end
end

function NewModConfigurationScreen:GetValidatedInput(input, option)
	return self:IsValidInputForOption(input, option) or self:IsValidInputForOption(GetGenericCtrlShiftAlt(input), option)
end

function NewModConfigurationScreen:OnBindSet(option, option_button, input)
	--print("NewModConfigurationScreen:OnBindSet",option, option_button, input)

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
			TheFrontEnd:GetSound():PlaySound("meta4/winona_remote/click", nil, .15)
			option_button:UpdateAppearance()
			option_button:ApplyDescription()
			self:MakeDirty()
		end

		self.is_mapping = false
	end	
end

function NewModConfigurationScreen:ResetToDefaultValues()
	local function reset()
		for i,v in ipairs(self.optionwidgets) do 
			self.options[i].value = shallowcopy(self.options[i].default)
			--v.selected_value = self.options[i].default
		end
		--self.options_scroll_list:RefreshView()
		for k,v in ipairs(self.custombuttons) do v:UpdateAppearance() end
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

function NewModConfigurationScreen:CollectSettings()
	local settings = nil
	for i,v in ipairs(self.options) do
		if not settings then settings = {} end
		table.insert(settings, {name=v.name, label = v.label, options=v.options, default=v.default, saved=v.value})
	end
	return settings
end

function NewModConfigurationScreen:Apply()
	if self:IsDirty() then
		local settings = self:CollectSettings()
		KnownModIndex:SaveConfigurationOptions(function()
			self:MakeDirty(false)
		    TheFrontEnd:PopScreen()
		end, self.modname, settings, self.client_config)
	else
		self:MakeDirty(false)
	    TheFrontEnd:PopScreen()
	end
end

function NewModConfigurationScreen:ConfirmRevert(callback)
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

function NewModConfigurationScreen:Cancel()
	if self:IsDirty() and not (self.started_default and self:IsDefaultSettings()) then
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

function NewModConfigurationScreen:MakeDirty(dirty)
	if dirty ~= nil then
		self.dirty = dirty
	else
		self.dirty = true
	end
end

function NewModConfigurationScreen:IsDirty()
	return self.dirty
end

function NewModConfigurationScreen:IsDefaultSettings()
	local alldefault = true
	for i,v in ipairs(self.options) do
		-- print(options[i].value, options[i].default)
		if custom_not_equal(self.options[i].value, self.options[i].default) then
			alldefault = false
			break
		end
	end
	return alldefault
end

function NewModConfigurationScreen:OnControl(control, down)
    if NewModConfigurationScreen._base.OnControl(self, control, down) then return true end

    if not down then
	    if control == CONTROL_CANCEL then
			self:Cancel()
            return true

	    elseif control == CONTROL_MENU_START and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
            self:Apply()
            return true

        elseif control == CONTROL_MENU_BACK and TheInput:ControllerAttached() then
			self:ResetToDefaultValues()
			return true
        end
	end
end

function NewModConfigurationScreen:HookupFocusMoves()

end

function NewModConfigurationScreen:GetHelpText()
	return ""
end

return NewModConfigurationScreen