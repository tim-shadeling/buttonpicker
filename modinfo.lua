name = "Configs Extended"
description = "Improves user experience when configurating mods and allows for different types of settings: keybinds, text inputs, color pickers, multiple choices..."
author = "Remi"
version = "0.5"

forumthread = ""

api_version = 10

dst_compatible = true
client_only_mod = true
all_clients_require_mod = false
server_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

local text_edit_hover = [[This is the option's hover text! I've left a fair amount of space here to allow mod makers to describe what kind of input they are expecting from the player.
It would also help a lot to provide an example.

This feature originates from clearlove's Mod Config By Text.]]

local Keys = {
	{description = "F1", data = 282},
	{description = "F2", data = 283},
	{description = "F3", data = 284},
	{description = "1", data = 49},
	{description = "2", data = 50},
	{description = "3", data = 51},
	{description = "Num 1", data = 257},
	{description = "Num 2", data = 258},
	{description = "Num 3", data = 259},
	{description = "Alt", data = 308},
	{description = "Ctrl", data = 306},
	{description = "A", data = 97},
	{description = "B", data = 98},
	{description = "C", data = 99},
    {description = "Mouse 3", data = 1002},
}

local KeysFormat = {
	{description = "F1", data = "KEY_F1"},
	{description = "F2", data = "KEY_F2"},
	{description = "F3", data = "KEY_F3"},
	{description = "1", data = "KEY_1"},
	{description = "2", data = "KEY_2"},
	{description = "3", data = "KEY_3"},
	{description = "Num 1", data = "KEY_KP_1"},
	{description = "Num 2", data = "KEY_KP_2"},
	{description = "Num 3", data = "KEY_KP_3"},
	{description = "Alt", data = "KEY_ALT"},
	{description = "Ctrl", data = "KEY_CTRL"},
	{description = "Shift", data = "KEY_SHIFT"},
	{description = "A", data = "KEY_A"},
	{description = "B", data = "KEY_B"},
	{description = "C", data = "KEY_C"},
    {description = "Mouse 3", data = "MOUSEBUTTON_MIDDLE"},
}

-- Now let's get to the different types of configs.
configuration_options = {
	
	-- Header.
	-- This is a base game feature. You can make a config into a header by giving it exactly one option with an empty description.
	{
		name = "HEADER_EXAMPLE",
		label = "Header Example",
		options = {
			{description = "", data = 1}, -- make sure the data value here matches the default value
		},
		default = 1, -- this is the default value
	},

	-- List.
	-- This is the default type of config.
	{
	    name = "LIST_EXAMPLE",
	    label = "List Example",
	    options = {
	    	{description = "Option A",	data =  1, hover = "Hover text for the option A!"},
	    	{description = "Option B",	data =  2, hover = "Hover text for the option B!"},
	    	{description = "Option C",	data =  3, hover = "Hover text for the option C!"},
	    	{description = "Option D",	data =  4, hover = "Hover text for the option D!"},
	    	{description = "Option E",	data =  5, hover = "Hover text for the option E!"},
	    	{description = "Option F",	data =  6, hover = "Hover text for the option F!"},
	    	{description = "Option G",	data =  7, hover = "Hover text for the option G!"},
	    	{description = "Option H",	data =  8, hover = "Hover text for the option H!"}, -- ←
	    	{description = "Option I",	data =  9, hover = "Hover text for the option I!"},
	    	{description = "Option J",	data = 10, hover = "Hover text for the option J!"},
	    	{description = "Option K",	data = 11, hover = "Hover text for the option K!"},
	    },
	    default = 8, -- make sure there's an option that corresponds to this value
	    hover = "Instead of scrolling through the options, pick from a list!",
	},

	-- Keybind.
	-- In DST it's fairly common that the player is asked to assign a keyboard button to an feature of the mod.
	-- The number of key options is usually very high, more than 40 or 50.
	-- Since scrolling through such a big number of options is a huge pain, the mod will instead let the player choose a key directly -- by simply pressing it.
	--
	-- You make a config into a keybind by adding "is_keybind = true," to its definition, as shown below.
	-- The player is also able to unbind the action, setting the data value to -1. Your mod must be able to handle that case without crashing.
	{
	    name = "KEYBIND_EXAMPLE",
	    label = "Keybind Example",
	    options = Keys, -- it's a good idea to define keybind options and put it in a local variable, that way you won't have to copy-paste the whole table for every keybind config
	    default = 97,
	    hover = "Select a key directly. Feel the difference.",
	    --
	    is_keybind = true, -- this does the magic 
	},
	-- A significant number of mods prefer to have their key data values as strings (defined in constants.lua) instead of the actual codes.
	-- Unbound action is still going to be -1.
	--
	--[[ Choose one format and stick to it. You cannot use both at the same time, one of them will stop working.
	{
	    name = "KEYBIND_EXAMPLE_2",
	    label = "Keybind Example 2",
	    options = KeysFormat,
	    default = "KEY_A",
	    hover = "Select a key directly. Feel the difference.",
	    is_keybind = true,
	},
	--]]

	-- Toggles.
	-- Toggles only contains two options, with one representing true, and the other one - false.
	-- The mod will make your config into a toggle automatically if the options meet the condition above.
	{
	    name = "TOGGLE_EXAMPLE",
	    label = "Toggle Example",
	    options = {
	    	{description = "On", data = true, hover = "Yay!"},
	    	{description = "Off", data = false, hover = "Nay!"},
	    },
	    default = true,
	    hover = "Alternate between 2 options quickly.",
	},

	-- Text inputs.
	-- A pre-determined list of options isn't always enough. What if you need the player to choose a prefab, or multiple prefabs?
	-- Surely you aren't going to list all the prefabs, especially considering their number is constantly increasing.
	--
	-- You make a config into a text input by adding "is_text_config = true," to its definition, as shown below.
	-- Please make sure to include a hover text contatining an explanation of what kind if input you are expecting from the player.
	-- It would also not hurt to provide an example.
	{
	    name = "TEXT_EXAMPLE",
	    label = "Text Input Example",
	    options = {
	    	{description = "Enable the mod!", data = "any text here!"},
	    },
	    default = "any text here!",
	    --
	    hover = text_edit_hover, -- explanation here
	    --
	    is_text_config = true, -- this does the magic
	},	

	-- Color.
	-- It's never bad to let players customize their mods, is it?
	-- Since you cannot list all the possible colors, there's a need to use a specialized color picker.
	-- 
	-- You make a config into a color config by adding either "is_rgb_config = true," or "is_rgba_config = true," to its definition.
	-- The former will only let the player change the Red, Green and Blue color components, while the latter will allow the opacity level to be changed too.
	-- Regardless of which type you use, the actual data value will always be a table of FOUR numbers ranging from 0 to 1.
	{
	    name = "RGB_EXAMPLE",
	    label = "RGB Example",
	    options = {
	    	{description = "Enable the mod!", data = {1,1,1,1}}, -- make sure the data value matches the default
	    },
	    default = {1,1,1,1}, -- even though alpha is unchangeable, the table must still contain it (the 4th number)
	    is_rgb_config = true,
	    hover = "Pick any color!",
	},	
	-- 
	{
	    name = "RGBA_EXAMPLE",
	    label = "RGBA Example",
	    options = {
	    	{description = "Enable the mod!", data = {1,1,1,1}},
	    },
	    default = {1,1,1,1},
	    is_rgba_config = true,
	    hover = "Pick any color and opacity level!",
	},

	-- Multiple choices.
	-- This one is a bit trickier than the others (and it was harder to implement as well).
	--
	-- To allow multiple choices, you need to move all the actual options into "choices" field.
	-- In the options field you need to leave a single option.
	-- The reasoning behind this is to prevent the player from editing the config without this extension enabled!
	{
		-- Nothing special here
		name = "MULTIPLE_CHOICES_EXAMPLE",
		label = "Multiple Choices Example",
		hover = "Pick multiple options at the same time!",
		--

		-- This field will contain the actual options.
		choices = {
			{description = "Option A", data = "AAA", hover = "Hover text for the option A!"}, -- ←
			{description = "Option B", data = "BBB", hover = "Hover text for the option B!"},
			{description = "Option C", data = "CCC", hover = "Hover text for the option C!"}, -- ←
			{description = "Option D", data = "DDD", hover = "Hover text for the option D!"},
			{description = "Option E", data = "EEE", hover = "Hover text for the option E!"}, -- ←
			{description = "Option F", data = "FFF", hover = "Hover text for the option F!"},
			{description = "Option G", data = "GGG", hover = "Hover text for the option G!"},
			{description = "Option H", data = "HHH", hover = "Hover text for the option H!"},
			{description = "Option I", data = "III", hover = "Hover text for the option I!"},
			{description = "Option J", data = "JJJ", hover = "Hover text for the option J!"},
			{description = "Option K", data = "KKK", hover = "Hover text for the option K!"},
		},
		-- The choices are collected into a table.
		-- For each choice that was selected, the table will contain a key-value pair, where the key is that choice's data, and value equals true.
		--
		-- For example, if the player selects "Option D" and "Option I" in the choice list above, the resulting table will look as following:
		-- {["DDD"] = true, ["III"] = true}
		-- And that will be the value returned by GetModConfigData.
		

		-- Put exactly one option here, in which you tell the player to enable the extension first.
		options = {
			{description = "Enable the mod!", data = {["AAA"] = true,["CCC"] = true,["EEE"] = true,}}, -- make sure the data value matches the default
		},
		default = {["AAA"] = true,["CCC"] = true,["EEE"] = true,}, -- make sure all keys have corresponding choices
	},

	-- Sliders.
	-- In the near future. Maybe.
}