name = "Convenient Configs"
description = "Imagine scrolling through 40 different options just to set a single keybind."
author = "Remi"
version = "0.4.1"

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
	{description = "Alt", data = 308},
	{description = "Ctrl", data = 306},
	{description = "A", data = 97},
	{description = "B", data = 98},
	{description = "C", data = 99},
    {description = "Mouse 3", data = 1002},
}

local KeysFormat = {
	{description = "Alt", data = "KEY_ALT"},
	{description = "Ctrl", data = "KEY_CTRL"},
	{description = "Shift", data = "KEY_SHIFT"},
	{description = "A", data = "KEY_A"},
	{description = "B", data = "KEY_B"},
	{description = "C", data = "KEY_C"},
    {description = "Mouse 3", data = "MOUSEBUTTON_MIDDLE"},
}

configuration_options =
{
	{
		name = "HEADER_TEST",
		label = "Header Test",
		options = {
			{description = "", data = 1},
		},
		default = 1,
	},

	{
		name = "HEADER_TEST2",
		label = "Another Header Test",
		options = {
			{description = "Some Option", data = 1},
			{description = "Some Option", data = 10},
			{description = "Some Option", data = 100},
			{description = "Some Option", data = 1000},
			{description = "Some Option", data = 10000},
			{description = "Some Option", data = 100000},
		},
		default = 1,
		is_header = true,
	},

	{
	    name = "SCROLLER_TEST",
	    label = "Scroller Test",
	    options = {
	    	{description = "First Option", data = 1, hover = "A"},
	    	{description = "Second Option", data = 2, hover = "B"},
	    	{description = "Third Option", data = 3, hover = "C"},
	    	{description = "Fourth Option", data = 4, hover = "D"},
	    	{description = "Fifth Option", data = 5, hover = "E"},
	    	{description = "Sixth Option", data = 6, hover = "F"},
	    	{description = "Seventh Option", data = 7, hover = "G"},
	    	{description = "Eighth Option", data = 8, hover = "H"},
	    	{description = "Ninth Option", data = 9, hover = "I"},
	    	{description = "Tenth Option", data = 10, hover = "J"},
	    	{description = "Eleventh Option", data = 11, hover = "K"},
	    },
	    default = 8,
	    hover = "Choose from a list.",
	    --is_keybind = true,
	},

	{
	    name = "KEYBIND_TEST",
	    label = "Keybind Test",
	    options = KeysFormat,
	    default = "KEY_A",
	    hover = "Select a key directly. Feel the difference.",
	    is_keybind = true,
	},

	{
	    name = "TOGGLE_TEST",
	    label = "Toggle Test",
	    options = {
	    	{description = "On", data = true, hover = "Yay!"},
	    	{description = "Off", data = false, hover = "Nay!"},
	    },
	    default = true,
	    hover = "Alternate between 2 options quickly.",
	},

	{
	    name = "TEXT_TEST",
	    label = "Text Input Test",
	    options = {
	    	{description = "Enable the mod!", data = "any text here!"},
	    },
	    default = "any text here!",
	    is_text_config = true,
	    hover = text_edit_hover,
	},	

	{
	    name = "RGB_TEST",
	    label = "[NEW] RGB Test",
	    options = {
	    	{description = "Enable the mod!", data = {1,1,1,1}},
	    },
	    default = {1,1,1,1},
	    is_rgb_config = true,
	    hover = "Pick any color!",
	},	

	{
	    name = "RGBA_TEST",
	    label = "[NEW] RGBA Test",
	    options = {
	    	{description = "Enable the mod!", data = {1,1,1,1}},
	    },
	    default = {1,1,1,1},
	    is_rgba_config = true,
	    hover = "Pick any color and opacity level!",
	},
}