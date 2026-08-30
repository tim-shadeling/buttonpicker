-- EN -- line 148
-- ZH -- line 578
-- RU -- line 1015

local languages =
{
	zh = "zh", -- Chinese for Steam
	zhr = "zh", -- Chinese for WeGame
	ch = "zh", -- Chinese mod
	chs = "zh", -- Chinese mod
	sc = "zh", -- simple Chinese
	zht = "zh", -- traditional Chinese for Steam
	chinese = "zh", -- Chinese mod
	tc = "zh", -- traditional Chinese
	cht = "zh", -- Chinese mod
	ru = "ru",
	rus = "ru",
	russian = "ru",
}
local lang = languages[locale] or "en"

local strings = { -- replaces en_zh for strings
	en = {
		MODNAME= "Configs Extended",
		MODDESC = "Improves user experience when configurating mods and allows for different types of settings: keybinds, text inputs, color pickers, multiple choices...",
		KEY_NUM1 = "Num 1",
		KEY_NUM2 = "Num 2",
		KEY_NUM3 = "Num 3",
		KEY_MOUSE3 = "Mouse 3",
		TEXT_EDIT_HOVER = [[This is the option's hover text! I've left a fair amount of space here to allow mod makers to describe what kind of input they are expecting from the player.
It would also help a lot to provide an example.

This feature originates from clearlove's Mod Config By Text.]],
		FILLER_LABEL = "Useless Config #",
		FILLER_HOVER = "How did it break out??",
		YES = "Yes", -- wow
		NO = "No", -- wow
	},

	zh = {
		MODNAME= "配置扩展",
		MODDESC = "在配置Mod时改善用户体验，并允许不同类型的设置: 快捷键绑定，文本输入，颜色选择，多项选择...",
		KEY_NUM1 = "小键盘 1",
		KEY_NUM2 = "小键盘 2",
		KEY_NUM3 = "小键盘 3",
		KEY_MOUSE3 = "鼠标中键",
		TEXT_EDIT_HOVER = [[这是选项的悬停文本！
我在这里留下了相当多的空间，让Mod制作者描述他们希望从玩家那里得到什么样的输入内容。
举个例子也会有很大帮助。

这个功能来源于clearlove的Mod: 文本模组配置]],
		FILLER_LABEL = "无用配置 ",
		FILLER_HOVER = "它是怎么跑出来的？？",
		YES = "是",
		NO = "否",
	},

	ru = {
		MODNAME= "Configs Extended",
		MODDESC = "Упрощает настройку модов и обеспечивает поддержку новых типов настроек: привязки, ввод текста, выбор цвета, выбор нескольких вариантов...",
		KEY_NUM1 = "Num 1",
		KEY_NUM2 = "Num 2",
		KEY_NUM3 = "Num 3",
		KEY_MOUSE3 = "Колесо мыши",
		TEXT_EDIT_HOVER = [[Я оставил для текстовых настроек немного пространства, где можно будет объяснить пользователю, какой ввод от него ожидается.
Хорошей идеей будет предоставить образец.

Функционал взят из мода "Mod Config By Text" от clearlove.]],
		FILLER_LABEL = "Пустышка №",
		FILLER_HOVER = "Как она выбралась??",
		YES = "Да",
		NO = "Нет",
	},
}
local STRINGS = strings[lang]

name = STRINGS.MODNAME
description = STRINGS.MODDESC
author = "Remi, Chinese translation by 冰冰羊"
version = "1.2a"

forumthread = ""

api_version = 10

dst_compatible = true
client_only_mod = true
all_clients_require_mod = false
server_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

local filler_counter = 0
local function Filler(is_end)
	filler_counter = filler_counter + 1
	return {
		name = "FILLER_"..filler_counter,
		label = STRINGS.FILLER_LABEL..filler_counter,
		options = {
			{description = STRINGS.YES, data =   "no"},
			{description =  STRINGS.NO, data =  "yes"},
		},
		default = "no",
		--
		section_end = is_end,
		hover = is_end and STRINGS.FILLER_HOVER or ""
	}
end

local Keys = {
	{description = "F1", data = 282},
	{description = "F2", data = 283},
	{description = "F3", data = 284},
	{description = "1", data = 49},
	{description = "2", data = 50},
	{description = "3", data = 51},
	{description = STRINGS.KEY_NUM1, data = 257},
	{description = STRINGS.KEY_NUM2, data = 258},
	{description = STRINGS.KEY_NUM3, data = 259},
	{description = "Alt", data = 308},
	{description = "Ctrl", data = 306},
	{description = "A", data = 97},
	{description = "B", data = 98},
	{description = "C", data = 99},
	{description = STRINGS.KEY_MOUSE3, data = 1002},
}

local KeysFormat = {
	{description = "F1", data = "KEY_F1"},
	{description = "F2", data = "KEY_F2"},
	{description = "F3", data = "KEY_F3"},
	{description = "1", data = "KEY_1"},
	{description = "2", data = "KEY_2"},
	{description = "3", data = "KEY_3"},
	{description = STRINGS.KEY_NUM1, data = "KEY_KP_1"},
	{description = STRINGS.KEY_NUM2, data = "KEY_KP_2"},
	{description = STRINGS.KEY_NUM3, data = "KEY_KP_3"},
	{description = "Alt", data = "KEY_ALT"},
	{description = "Ctrl", data = "KEY_CTRL"},
	{description = "Shift", data = "KEY_SHIFT"},
	{description = "A", data = "KEY_A"},
	{description = "B", data = "KEY_B"},
	{description = "C", data = "KEY_C"},
	{description = STRINGS.KEY_MOUSE3, data = "MOUSEBUTTON_MIDDLE"},
}

-- Feature of 0.7: sections.
-- Sections can be used to group up multiple configs or break all configs into parts.

-- HOW TO IMPLEMENT:
-- 1. Start a section by adding "section_start = true" to a header.
-- 2. End a section by adding "section_end = true" to a config of any type.
-- NOTE: that config won't be part of the section
-- 2.1. You can close a section with "section_start = true" as well, and it will obviously start another section right after.
-- And that's basically it. All configs between a section start and a section end (or 2 starts) will be grouped up and hidden until the user opens the section.

-- Hopefully this example can help clear things up:
--[[
configuration_options = {
	{some config...},					-- belongs to no section
	{some config...},					-- belongs to no section
	{header, section_start = true}, 	-- START of section 1, this belongs to no section, opens section 1 when clicked
	{some config...},					-- belongs to section 1
	{some config...},					-- belongs to section 1
	{header, section_start = true}, 	-- END of section 1, START of section 2, this belongs to no section, opens section 2 when clicked
	{some config...},					-- belongs to section 2
	{some config, section_end = true},	-- END of section 2, this belongs to NO SECTION
	{some config...},					-- belongs to no section
	{some config, section_end = true},  -- belongs to no section still
	{header, section_start = true}, 	-- section 3 starts, this belongs to no section
	{some config...},					-- belongs to section 3
	{some config...},					-- belongs to section 3
}
--]]

-- You could perhaps make a function like this to add section start points:
local section_counter = 0 -- This counter will ensure all section starting points will have unique names.
local function AddSection(label, hover)
	-- Bump the counter to ensure unique names.
	section_counter = section_counter + 1
	-- Return a fake config table:
	-- There has to be a table for options with at least one option, otherwise the game will ignore the config completely.
	-- Just put empty strings as values, no need to be excessive.
	return {section_start = true, name = "SECTION_"..section_counter, label = label, hover = hover, options = {{description = "", data = ""}}, default = ""}
end

--[[ a version with no comments, for copying I guess

local section_counter = 0
local function AddSection(label, hover)
	section_counter = section_counter + 1
	return {section_start = true, name = "SECTION_"..section_counter, label = label, hover = hover, options = {{description = "", data = ""}}, default = ""}
end

--]]

-- Feature of 0.8: quick presets
-- Quick presets allow modders to change multiple configs in a predetermined way.
-- If a mod has presets defined, the button that resets configs to default will instead open a menu listing all presets.

-- Defining presets is rather easy:
--
-- presets = { -- normally you would do this...
local en_presets = { -- however in this file I have to provide both English and Chinese variants, so I'll do 2 local variables, and assign one of them at the bottom of this file
	{ -- begin a new preset
		name = "All* first", -- give it a name using the "name" field
		hover = "Sets configs to the first option, where possible.", -- explain briefly what the preset does using the "hover" field
		values = { -- provide values using the "values" (duh) field
			["LIST_EXAMPLE"] = 1, -- NAME OF CONFIG = DATA VALUE
			["KEYBIND_EXAMPLE"] = 282,
			["TOGGLE_EXAMPLE_NEW"] = 1, -- PLEASE be very careful and don't supply a value of incorrect type by accident!
		--	["TEXT_EXAMPLE"] = "???", -- this config doesn't have a "first option", so it's not included
		--	["RGB_EXAMPLE"] = "{1,1,1,1}" -- same thing here
		--	["RGBA_EXAMPLE"] = {1,1,1,1}" -- and here
			["MULTIPLE_CHOICES_EXAMPLE"] = {["AAA"] = true}, -- don't forget it's a multiple choices config
		--	["SET_EXAMPLE"] = {}, -- no "first option"
		--	["ARRAY_EXAMPLE"] = {}, -- no "first option"
		--	["DICTIONARY_EXAMPLE"] = {}, -- no "first option"
		--	we'll add fillers in a more clever way rather than listing them one by one, look not too far below
		},
	},

	-- A similar example with no comments:
	{
		name = "All* second", 
		hover = "Sets configs to the second option, where possible.",
		values = {
			["LIST_EXAMPLE"] = 2,
			["KEYBIND_EXAMPLE"] = 283,
			["TOGGLE_EXAMPLE_NEW"] = 0,
			["MULTIPLE_CHOICES_EXAMPLE"] = {["BBB"] = true},
		},
	},

	-- and so on...
}

-- Including fillers to the presets
for i = 1, 5 do -- well, we know there's 5 of them
	en_presets[1].values["FILLER_"..i] = "no"
	en_presets[2].values["FILLER_"..i] = "yes"
end

-- IMPORTANT:
-- 1. Any configs missing in the preset's "values" field will not be affected by the preset.
-- 2. Please be very careful with value types! Supplying a worng-typed value will likely lead to crashes.
-- 3. You do not need to create an "all default" preset. It will be added automatically.
-- 4. RGB configs return a table of FOUR (not three) elements (red, green, blue, and opacity, opacity equals 1).
-- 5. A preset providing a value for a non-existent config should not cause issues.

-- Now let's get to the different types of configs.
local en_configuration_options = {
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
	-- In DST it's fairly common that the player is asked to assign a keyboard button to a feature of the mod.
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
	-- If a list config contaits exactly 2 options, it will be made into a config.
	-- Clicking a toggle will quickly alternate between its options.
	{
		name = "TOGGLE_EXAMPLE_NEW",
		label = "Toggle Example",
		options = {
			{description = "On", data = 1, hover = "Yay!"},
			{description = "Off", data = 0, hover = "Nay!"},
		},
		default = 1,
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
		hover = STRINGS.TEXT_EDIT_HOVER, -- explanation here
		--
		is_text_config = true, -- this does the magic
	},

	-- Sliders.
	-- A type of config designed to help specifically with picking numbers. 
	-- In vanilla, you'd have to create an option for each possible value. Ouch!
	--
	-- To make a slider config you have to use the slider_data field. Supply a table of 2 numbers, which will represent the boundaries.
	-- The user will be able to pick any value between those boundaries.
	--
	-- It is required that both boundaries are numbers, and the left boundary is strictly lesser than the right one.
	{
		name = "CONTINUOUS_SLIDER_EXAMPLE",
		label = "Continuous Slider Example",
		options = {
			{description = "Enable the mod!", data = 3.1415}, -- make sure the data value here matches the default value
		},
		default = 3.1415, -- this is the default value
		--
		hover = "Pick any number within given interval!\nYou can also type the exact value if needed.",
		--
		slider_data = {4, 6}, -- 2 numbers: min value, max value
	},

	-- The interval can also be divided into a number of segments, thus making a discrete slider.
	-- You can do that by adding a third number to the slider_data table, which will represent the size of each segment.
	-- The max count of segments allowed is 500, attempting to create more than that will make the slider continuous.
	{
		name = "DISCRETE_SLIDER_EXAMPLE",
		label = "Discrete Slider Example",
		options = {
			{description = "Enable the mod!", data = 5.5}, -- should snap to 5.46 when opening slider screen
		},
		default = 5.5,
		--
		hover = "Pick a number within given interval!\nThe value will be automatically adjusted to the nearest step.",
		--
		slider_data = {5, 7, 0.23}, -- 3 numbers: min value, max value, step (just like in lua "for" loops hehe)
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

	-- Hex Color.
	-- Returns a hex color string instead of a color table, otherwise it's the same as RGB color config.
	{
		name = "HEX_EXAMPLE",
		label = "Hex Example",
		options = {
			{description = "Enable the mod!", data = "#ffffff"}, -- make sure the data value matches the default
		},
		default = "#ffffff",
		is_hex_config = true,
		hover = "Pick any hex color!",
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

	-- Set.
	-- Contains multiple elemets (all strings). Useful for selecting prefabs.
	{
		-- Nothing special here
		name = "SET_EXAMPLE",
		label = "Set Example",
		hover = "Make a set of your own strings!\n9 lines of instruction at your disposal!\n3\n4\n5\n6\n7\n8\n!! 9 !!",
		--

		-- We're not providing the player with any "choices". They can enter whatever strings they want.
		-- Just add this to let the magic happen:
		is_set_config = true,

		-- With this type of config, the player will be able to make a custom list of strings.
		-- These strings will be gathered into a table as KEYS: {string1 = true, string2 = true, ...}
		-- And that will be the value returned by GetModConfigData.

		-- For example, if a player makes a list that goes like:
			-- true
			-- {}
			-- 3
		-- The final value will be {["true"] = true, ["{}"] = true, ["3"] = true} -- note how all the keys are strings despite looking like values of other types

		-- Put exactly one option here, in which you tell the player to enable the extension first.
		options = {
			{description = "Enable the mod!", data = {["torch"] = true, ["axe"] = true, ["backpack"] = true}}, -- make sure the data value has the same keys as the default, order doesn't matter
		},
		default = {["torch"] = true, ["axe"] = true, ["backpack"] = true},
	},

	-- Array.
	-- Similar to the set, except for the way the strings are collected.
	{
		-- Nothing special here
		name = "ARRAY_EXAMPLE",
		label = "Array Example",
		hover = "Make a string array of your own!\n9 lines of instruction at your disposal!\n3\n4\n5\n6\n7\n8\n!! 9 !!",
		--

		-- Once again, we're not providing the player with any "choices". They can enter whatever strings they want.
		-- Add this to let the magic happen:
		is_array_config = true,

		-- With this type of config, the player will be able to make a custom list of strings.
		-- These strings will be gathered into a table as VALUES not keys: {"string 1", "string 2", and so on}.
		-- And that will be the value returned by GetModConfigData.

		-- For example, if a player makes a list that goes like:
			-- true
			-- {}
			-- 3
		-- The final value will be {"true", "{}", "3"} -- note that all the values are strings despite looking like values of other types

		-- Put exactly one option here, in which you tell the player to enable the extension first.
		options = {
			{description = "Enable the mod!", data = {"torch", "axe", "backpack"}}, -- make sure the data value matches the default, order matters too
		},
		default = {"torch", "axe", "backpack"},
	},

	-- Dictionary.
	-- A combination of previous two types.
	-- In this one, the player is able to set both keys and values alike (they're all strings): {["key1"] = "value1", ["key2"] = "value2", ...}
	{
		-- Nothing special here
		name = "DICTIONARY_EXAMPLE",
		label = "Dictionary Example",
		hover = "Make a dictionary of your own!\n9 lines of instruction at your disposal!\n3\n4\n5\n6\n7\n8\n!! 9 !!",
		--

		-- Yet again, we're not providing the player with any "choices". They can enter whatever strings they want.
		-- Just add this to let the magic happen:
		is_dictionary_config = true,

		-- With this type of config, the player will be able to make a custom list of STRINGS PAIRS.
		-- These pairs will be gathered into a table as follows: {["key1"] = "value1", ["key2"] = "value2", ...}.
		-- And that will be the value returned by GetModConfigData.

		-- For example, if a player makes a list that goes like:
			-- true = 5
			-- {} = {}
			-- 3 = 6
		-- The final value will be {["true"] = "5", ["{}"] = "{}", ["3"] = "6"} -- please once again note that all keys and values are strings

		-- Put exactly one option here, in which you tell the player to enable the extension first.
		options = {
			{description = "Enable the mod!", data = {["1"] = "torch", ["axe"] = "3", ["backpack"] = "2"}}, -- make sure the data value matches the default
		},
		default = {["1"] = "torch", ["axe"] = "3", ["backpack"] = "2"},
	},

	-- Just a tiny showcase of a section
	AddSection("Section Example", "A whole section of settings that don't do anything at all!"),
	Filler(), -- these
	Filler(), -- will be hidden
	Filler(), -- until
	Filler(), -- the header is clicked
	Filler(true),
}

filler_counter = 0 -- Reset the counter so the numbering in the Chinese descriptions also starts from 1 (重置计数器使中文说明的计数也从1开始)





--------------------------------------------------------- 以下部分为中文说明 ---------------------------------------------------------

-- 0.7 版本新增功能：分区。
-- 分区可用于将多个配置项分组，或将所有配置项拆分为多个部分。

-- 实现方法：
-- 1. 在标题中添加"section_start = true"即可开始一个分区。
-- 2. 在任何类型的配置项中添加"section_end = true"即可结束一个分区。
-- 注意：该配置项将不再属于这个分区。
-- 2.1. 您也可以使用"section_start = true"来结束一个分区，显然，它会在之后立即开始另一个分区。
-- 基本就是这样。分区起点和终点（或两个起点）之间的所有配置项将被分组并隐藏，直到用户打开该分区。

-- 希望这个例子能有所帮助：
--[[
configuration_options = {
	{一些配置...},					-- 不属于任何分区
	{一些配置...},					-- 不属于任何分区
	{标题, section_start = true},	-- 分区1开始；此项本身不属于任何分区，点击后展开分区1
	{一些配置...},					-- 属于分区1
	{一些配置...},					-- 属于分区1
	{标题, section_start = true}, 	-- 分区1结束，分区2开始；此项不属于任何分区，点击后展开分区2
	{一些配置...},					-- 属于分区2
	{一些配置, section_end = true},	-- 分区2结束；此项不属于任何分区
	{一些配置...},					-- 不属于任何分区
	{一些配置, section_end = true},  -- 不属于任何分区
	{标题, section_start = true}, 	-- 分区3开始；此项不属于任何分区
	{一些配置...},					-- 属于分区3
	{一些配置...},					-- 属于分区3
}
--]]

-- 或许你可以创建一个类似这样的函数来添加分区起点：
local section_counter = 0 -- 此计数器将确保所有分区的起始点都具有唯一名称。
local function AddSection(label, hover)
	-- 递增计数器以确保名称唯一。
	section_counter = section_counter + 1
	-- 返回一个虚拟配置表：
	-- 对于 options，必须至少有一个选项，否则游戏会完全忽略该配置。
	-- 只需放入空字符串作为值即可，无需写太多内容。
	return {section_start = true, name = "SECTION_"..section_counter, label = label, hover = hover, options = {{description = "", data = ""}}, default = ""}
end

--[[ 这是一个没有注释的版本，大概是为了方便复制吧。

local section_counter = 0
local function AddSection(label, hover)
	section_counter = section_counter + 1
	return {section_start = true, name = "SECTION_"..section_counter, label = label, hover = hover, options = {{description = "", data = ""}}, default = ""}
end

--]]

-- NEW, machine-translated/以下部分为新增内容，由机器翻译。
-- 0.8 版本新增功能：快速预设
-- 快速预设功能允许模组制作者以预定的方式更改多个配置。
-- 如果 MOD 定义了预设，则将配置重置为默认值的按钮将打开一个菜单，列出所有预设。

-- 定义预设并不难：
--
-- presets = { -- 你通常可以这样做
local zh_presets = { -- 但是，在这个文件中我还需要提供一个英文版本，所以我将创建两个局部变量，并在文件末尾使用其中一个。
	{ -- 开始一个新的预设
		name = "一切*到第一", -- 使用 name 字段为其命名
		hover = "尽可能选择第一个选项。", -- 简要说明预设值在 hover 字段中的作用。
		values = { -- 请使用 values 字段提供值。
			["LIST_EXAMPLE"] = 1, -- 配置名称 = 数据值
			["KEYBIND_EXAMPLE"] = 282,
			["TOGGLE_EXAMPLE_NEW"] = 1,
		--	["TEXT_EXAMPLE"] = "???", -- 这个没有“选项 1”。
		--	["RGB_EXAMPLE"] = "{1,1,1,1}" -- 这个没有“选项 1”。
		--	["RGBA_EXAMPLE"] = {1,1,1,1}" -- 这个没有“选项 1”。
			["MULTIPLE_CHOICES_EXAMPLE"] = {["AAA"] = true}, -- 这是一个多项选择题设置
		--	["SET_EXAMPLE"] = {}, -- 这个没有“选项 1”。
		--	["ARRAY_EXAMPLE"] = {}, -- 这个没有“选项 1”。
		--	["DICTIONARY_EXAMPLE"] = {}, -- 这个没有“选项 1”。
		--	我们将以更巧妙的方式添加填充词，而不是逐一列出，请向下看不远。
		},
	},

	-- 一个类似的例子，但没有评论：
	{
		name = "一切*到第二", 
		hover = "尽可能选择第二个选项。",
		values = {
			["LIST_EXAMPLE"] = 2,
			["KEYBIND_EXAMPLE"] = 283,
			["TOGGLE_EXAMPLE_NEW"] = 0,
			["MULTIPLE_CHOICES_EXAMPLE"] = {["BBB"] = true},
		},
	},

	-- 你可以设置任意数量的预设...
}

-- 在预设中包含填充词
for i = 1, 5 do -- 我们已经知道他们有5个。
	zh_presets[1].values["FILLER_"..i] = "no"
	zh_presets[2].values["FILLER_"..i] = "yes"
end

-- 重要提示：
-- 1. 预设的 values 字段中缺失的任何配置都不会受到预设的影响。
-- 2. 请务必注意值类型！提供错误类型的值可能会导致程序崩溃。
-- 3. 您无需创建“全部默认值”预设。它会自动添加。
-- 4. RGB 配置返回一个包含四个元素（而非三个）的表格（红色、绿色、蓝色和不透明度，不透明度等于 1）。
-- 5. 预设为不存在的配置提供值不应导致问题。

-- 现在，让我们了解不同类型的配置。
zh_configuration_options = {
	-- 标题
	-- 这是一个基本的游戏功能。你可以通过给它一个选项和一个空的描述来把一个配置变成一个标题。
	{
		name = "HEADER_EXAMPLE",
		label = "标题示例",
		options = {
			{description = "", data = 1}, -- 请确保此处的data值与默认值匹配
		},
		default = 1, -- 这是默认值
	},

	-- 列表.
	-- 这是默认的配置类型。
	{
		name = "LIST_EXAMPLE",
		label = "列表示例",
		options = {
			{description = "选项A",	data =  1, hover = "选项A的悬停文本！"},
			{description = "选项B",	data =  2, hover = "选项B的悬停文本！"},
			{description = "选项C",	data =  3, hover = "选项C的悬停文本！"},
			{description = "选项D",	data =  4, hover = "选项D的悬停文本！"},
			{description = "选项E",	data =  5, hover = "选项E的悬停文本！"},
			{description = "选项F",	data =  6, hover = "选项F的悬停文本！"},
			{description = "选项G",	data =  7, hover = "选项G的悬停文本！"},
			{description = "选项H",	data =  8, hover = "选项H的悬停文本！"}, -- ←
			{description = "选项I",	data =  9, hover = "选项I的悬停文本！"},
			{description = "选项J",	data = 10, hover = "选项J的悬停文本！"},
			{description = "选项K",	data = 11, hover = "选项K的悬停文本！"},
		},
		default = 8, -- 确保有一个选项对应于该值
		hover = "不要在选项中切换，而是从列表中选择！",
	},

	-- 快捷键绑定
	-- 在DST中，玩家被要求为mod的一个功能分配键盘按钮是相当普遍的。
	-- 快捷键绑定的数量通常非常高，超过40或50个。
	-- 因为切换这么多选项是一件非常痛苦的事情，所以此mod将让玩家直接选择一个键 -- 只需按下它。
	--
	-- 您可以通过在配置的定义中添加 "is_keybind = true" 将其设置为按键绑定，如下所示。
	-- 玩家还可以解除绑定，将data值设置为-1。你的mod必须能够在不崩溃的情况下处理这种情况。
	{
		name = "KEYBIND_EXAMPLE",
		label = "快捷键绑定示例",
		options = Keys, -- 定义按键绑定选项并将其放在局部变量中是一个好主意，这样就不必为每个快捷键配置复制粘贴整个表
		default = 97,
		hover = "直接选择一个按键。感受一下不同。",
		--
		is_keybind = true, -- 这就是魔术
	},
	-- 许多mod更喜欢将其快捷键绑定的data作为字符串（在constants.lua中定义）而不是实际代码。
	-- 解除绑定操作仍将其设置为-1
	--
	--[[ 选择一种格式并坚持使用。不能同时使用这两种格式，其中一种将停止工作。
	{
		name = "KEYBIND_EXAMPLE_2",
		label = "快捷键绑定示例 2",
		options = KeysFormat,
		default = "KEY_A",
		hover = "直接选择一个按键。感受一下不同。",
		is_keybind = true,
	},
	--]]

	-- 开关.
	-- 开关仅包含两个选项
	-- 如果选项满足上述条件，此mod将自动将您的配置转换为开关。
	{
		name = "TOGGLE_EXAMPLE_NEW",
		label = "开关示例",
		options = {
			{description = "开", data = 1, hover = "Yay!"},
			{description = "关", data = 0, hover = "Nay!"},
		},
		default = 1,
		hover = "在两个选项之间快速切换",
	},

	-- 文本输入
	-- 一个预先确定的选项列表并不总是足够的。如果你需要玩家选择一个prefab或多个prefab怎么办？
	-- 当然，你不会列出所有的prefab，特别是考虑到它们的数量在不断增加。
	--
	-- 你可以通过在其定义中添加 "is_text_config = true"，将配置变为文本输入，如下所示。
	-- 请确保包含一个悬停文本，其中包含一个解释，说明你希望从玩家那里得到什么样的输入内容。
	-- 举个例子也无妨。
	{
		name = "TEXT_EXAMPLE",
		label = "文本输入示例",
		options = {
			{description = "请启用此Mod！", data = "填写任何文字在这里！"},
		},
		default = "填写任何文字在这里！",
		--
		hover = STRINGS.TEXT_EDIT_HOVER, -- 此处为解释
		--
		is_text_config = true, -- 这就是魔术
	},

	-- 滑块 -- NEW, machine-translated/以下部分为新增内容，由机器翻译。
	-- 一种专门用于辅助选择数字的配置类型。
	-- 在原版游戏中，您需要为每个可能的值创建一个选项。太麻烦了！
	--
	-- 要创建滑块配置，您需要使用 `slider_data` 字段。提供一个包含两个数字的表格，这两个数字将代表边界。
	-- 用户可以选择这两个边界之间的任何值。
	--
	-- 两个边界都必须是数字，并且左侧边界的值必须小于右侧边界的值。
	{
		name = "CONTINUOUS_SLIDER_EXAMPLE",
		label = "连续滑块示例",
		options = {
			{description = "请启用此Mod！", data = 3.1415}, -- 请确保此处的data值与默认值匹配
		},
		default = 3.1415, -- 这是默认值
		--
		hover = "在给定的区间内任选一个数字！\n如果需要，您也可以输入确切的值。",
		--
		slider_data = {4, 6}, -- 2 个数字：最小值，最大值
	},


	-- 也可以将区间划分成若干段，从而创建一个离散的滑块。
	-- 您可以通过在 slider_data 表中添加第三个数字来实现这一点，该数字将表示每个段的大小。
	-- 允许的最大段数为 500，尝试创建超过此数量的段将使滑块变为连续的。
	{
		name = "DISCRETE_SLIDER_EXAMPLE",
		label = "离散滑块示例",
		options = {
			{description = "请启用此Mod！", data = 5.5}, -- 应该自动更改为 5.46
		},
		default = 5.5,
		--
		hover = "在给定的区间内任选一个数字！\n该值将自动调整到最接近的刻度。",
		--
		slider_data = {5, 7, 0.23}, -- 3 个数字：最小值、最大值、步长（就像 Lua 的“for”循环一样，呵呵）
	},

	-- 颜色.
	-- 让玩家定制他们的mod从来都不是坏事，对吗？
	-- 由于无法列出所有可能的颜色，因此需要使用专门的颜色选择器。
	-- 
	-- 你可以通过在其定义中添加 "is_rgb_config = true" 或 "is_rgba_config = true" 将配置转换为颜色配置。
	-- 前者只允许玩家更改红、绿、蓝颜色占比，而后者将允许更改不透明度级别。
	-- 无论使用哪种类型，实际data值都将始终是一个由0到1之间的四个数字组成的表。
	{
		name = "RGB_EXAMPLE",
		label = "RGB示例",
		options = {
			{description = "请启用此Mod！", data = {1,1,1,1}}, -- 请确保此处的data值与默认值匹配
		},
		default = {1,1,1,1}, -- 即使不透明度是不变的，表也必须包含它（第4个数字）
		is_rgb_config = true,
		hover = "选择任何颜色！",
	},
	-- 
	{
		name = "RGBA_EXAMPLE",
		label = "RGBA示例",
		options = {
			{description = "请启用此Mod！", data = {1,1,1,1}},
		},
		default = {1,1,1,1},
		is_rgba_config = true,
		hover = "选择任何颜色和不透明度级别！",
	},

	-- Hex 颜色. -- NEW, machine-translated/以下部分为新增内容，由机器翻译。
	-- 十六进制颜色示例：与 RGB(A) 颜色配置类似，这种类型也使用颜色选择器。唯一的区别是，十六进制颜色配置返回的是十六进制颜色字符串，而不是颜色表。
	{
		name = "HEX_EXAMPLE",
		label = "Hex示例",
		options = {
			{description = "请启用此Mod！", data = "#ffffff"}, -- 请确保此处的data值与默认值匹配
		},
		default = "#ffffff",
		is_hex_config = true,
		hover = "选择任意十六进制颜色！",
	},


	-- 多项选择
	-- 这一个相比其它的有点棘手（并且它也很难实现）。
	--
	-- 要允许多个选项，你需要将所有实际选项移到 "choices" 中。
	-- 在options中，您需要留下一个选项。
	-- 这背后的原因是为了防止玩家在没有启用此扩展Mod的情况下编辑配置！
	{
		-- 这里没什么特别的
		name = "MULTIPLE_CHOICES_EXAMPLE",
		label = "多项选择示例",
		hover = "同时选择多个选项！",
		--

		-- 该字段将包含实际选项。
		choices = {
			{description = "选项A", data = "AAA", hover = "选项A的悬停文本！"}, -- ←
			{description = "选项B", data = "BBB", hover = "选项B的悬停文本！"},
			{description = "选项C", data = "CCC", hover = "选项C的悬停文本！"}, -- ←
			{description = "选项D", data = "DDD", hover = "选项D的悬停文本！"},
			{description = "选项E", data = "EEE", hover = "选项E的悬停文本！"}, -- ←
			{description = "选项F", data = "FFF", hover = "选项F的悬停文本！"},
			{description = "选项G", data = "GGG", hover = "选项G的悬停文本！"},
			{description = "选项H", data = "HHH", hover = "选项H的悬停文本！"},
			{description = "选项I", data = "III", hover = "选项I的悬停文本！"},
			{description = "选项J", data = "JJJ", hover = "选项J的悬停文本！"},
			{description = "选项K", data = "KKK", hover = "选项K的悬停文本！"},
		},
		-- 这些选项被收集到一个表中。
		-- 对于选择的每个选项，表将包含一个键-值对，其中键是该选项的数据，值等于true。
		--
		-- 例如，如果玩家在上面的选择列表中选择了 "选项D" 和 "选项I" ，结果表将如下所示：
		-- {["DDD"] = true, ["III"] = true}
		-- 这将是GetModConfigData返回的值。


		-- 在这里只放置一个选项，在这个选项中，告诉玩家首先启用扩展。
		options = {
			{description = "请启用此Mod！", data = {["AAA"] = true,["CCC"] = true,["EEE"] = true,}}, -- 请确保此处的data值与默认值匹配
		},
		default = {["AAA"] = true,["CCC"] = true,["EEE"] = true,}, -- 确保所有"键" 都有相应的选择
	},

	-- 键列表
	-- 包含多个元素（均为字符串）。它可以用来选择Prefab
	-- 这些字符串被收集到一个表中作为键： {string1 = true, string2 = true, ...}
	{
		-- 这里没什么特别的
		name = "SET_EXAMPLE",
		label = "键列表示例",
		hover = "列出你自己的键列表。\n有 9 行空间可用于填写说明！\n3\n4\n5\n6\n7\n8\n-- 9 --",
		--

		-- 我们不给玩家提供任何 “选择” 他们可以输入任何他们想要的字符串。
		-- 只需加上这个，让奇迹发生：
		is_set_config = true,

		-- 通过这种配置方式，玩家可以创建自定义字符串列表。
		-- 这些字符串将作为键被收集到一个表中： {string1 = true, string2 = true, ...}
		-- 这就是 GetModConfigData 返回的值。

		-- 例如，如果一个玩家列出如下清单:
			-- true
			-- {}
			-- 3
		-- 最终值将是 {["true"] = true, ["{}"] = true, ["3"] = true} -- 请注意，尽管看起来像是其它类型的值，但所有的键都是字符串。

		-- 在这里只放一个选项，告诉玩家先启用配置扩展模组
		options = {
			{description = "请启用此Mod！", data = {["torch"] = true, ["axe"] = true, ["backpack"] = true}}, -- 请确保这与默认值相同。
		},
		default = {["torch"] = true, ["axe"] = true, ["backpack"] = true},
	},

	-- 值列表
	-- 它与前一种类型类似，但是…
	-- 这些字符串被收集到一个表中作为值： {"string1", "string2", ...}, 而且它们也是按顺序排列的
	{
		-- 这里没什么特别的
		name = "ARRAY_EXAMPLE",
		label = "值列表示例",
		hover = "创建你自己的字符串列表。\n有 9 行空间可用于填写说明！\n3\n4\n5\n6\n7\n8\n-- 9 --",
		--

		-- 我们不给玩家提供任何 “选择” 他们可以输入任何他们想要的字符串。
		-- 只需加上这个，让奇迹发生：
		is_array_config = true,

		-- 通过这种配置方式，玩家可以创建自定义字符串列表。
		-- 这些字符串将被收集到一个表中，作为值而不是键： {"string 1", "string 2", ...}
		-- 这就是 GetModConfigData 返回的值。

		-- 例如，如果一个玩家列出如下清单:
			-- true
			-- {}
			-- 3
		-- 最终值将是 {"true", "{}", "3"} -- 请注意，尽管它们看起来像是其它类型的值，但所有值都是字符串。

		-- 在这里只放一个选项，告诉玩家先启用配置扩展模组
		options = {
			{description = "请启用此Mod！", data = {"torch", "axe", "backpack"}}, -- 请确保这与默认值相同。
		},
		default = {"torch", "axe", "backpack"},
	},

	-- 键值对列表
	-- 前两种类型的结合。
	-- 在这个版本中，玩家可以输入自定义键和值: {["key1"] = "value1", ["key2"] = "value2", ...}, 它们都是字符串
	{
		-- 这里没什么特别的
		name = "DICTIONARY_EXAMPLE",
		label = "键值对列表示例",
		hover = "创建您自己的键值对列表！\n有 9 行空间可用于填写说明！\n3\n4\n5\n6\n7\n8\n-- 9 --",
		--

		-- 我们不给玩家提供任何 “选择” 他们可以输入任何他们想要的字符串。
		-- 只需加上这个，让奇迹发生：
		is_dictionary_config = true,

		-- 通过这种配置，玩家可以创建自定义的字符串键值对列表。
		-- 这些字符串键值对将按如下方式整理成表： {["key1"] = "value1", ["key2"] = "value2", ...}
		-- 这就是 GetModConfigData 返回的值。

		-- 例如，如果一个玩家列出如下清单:
			-- true = 5
			-- {} = {}
			-- 3 = 6
		-- 最终值将是 {["true"] = "5", ["{}"] = "{}", ["3"] = "6"} -- 请注意，尽管它们看起来像是其它类型的值，但所有键和值都是字符串。

		-- 在这里只放一个选项，告诉玩家先启用配置扩展模组
		options = {
			{description = "请启用此Mod！", data = {["1"] = "torch", ["axe"] = "3", ["backpack"] = "2"}}, -- 它们都是字符串
		},
		default = {["1"] = "torch", ["axe"] = "3", ["backpack"] = "2"},
	},

	-- 一个关于分区的小示例
	AddSection("分区示例", "一个没有任何作用的设置分区！"),
	Filler(), -- 这些将会被隐藏，直到点击标题时
	Filler(), -- 这些将会被隐藏，直到点击标题时
	Filler(), -- 这些将会被隐藏，直到点击标题时
	Filler(), -- 这些将会被隐藏，直到点击标题时
	Filler(true),
}

filler_counter = 0 -- Reset the counter so the numbering in the Russian descriptions also starts from 1 (сбросим счётчик, чтобы пустышки в русском варианте тоже нумеровались с 1)





--------------------------------------------------------- Русский вариант ---------------------------------------------------------

-- Ключевое нововведение версии 0.7 - разделы.
-- Разделы позволяют собрать несколько настроек вместе или разбить их список на смысловые части.

-- Использование:
-- 1. Начните раздел путём добавления "section_start = true" к определению настройки типа заголовка.
-- 2. Завершите раздел, добавив "section_end = true" к определению настройки любого типа.
-- Важно: настройка, на которой завершается раздел, не будет сама входить в этот раздел. 
-- 2.1. Можно также звершить раздел, просто начав новый - с помощью "section_start = true".
-- Собственно, это всё. Все настройки, входящие в разделы, будут скрыты, пока пользователь не раскроет нужный раздел. Таким образом обеспечивается аккуратный вид списка настроек.

-- Небольшой пример для ясности:
--[[
configuration_options = {
	{какая-то настройка...},					-- не входит ни в один раздел
	{какая-то настройка...},					-- не входит ни в один раздел
	{заголовок, section_start = true}, 			-- НАЧАЛО раздела 1, сам заголовок в раздел не входит, при нажатии открывает раздел 1
	{какая-то настройка...},					-- входит в раздел 1
	{какая-то настройка...},					-- входит в раздел 1
	{заголовок, section_start = true}, 			-- НАЧАЛО раздела 2, сам заголовок в раздел не входит, при нажатии открывает раздел 2
	{какая-то настройка...},					-- входит в раздел 2
	{какая-то настройка, section_end = true},	-- КОНЕЦ раздела 2, сама настройка не входит ни в один раздел
	{какая-то настройка...},					-- не входит ни в один раздел
	{какая-то настройка, section_end = true},  	-- не входит ни в один раздел, всё ещё
	{заголовок, section_start = true}, 			-- НАЧАЛО раздела 3, сам заголовок в раздел не входит, при нажатии открывает раздел 3
	{какая-то настройка...},					-- входит в раздел 3
	{какая-то настройка...},					-- входит в раздел 3
}
--]]

-- Как вариант, можно создать специализированную функцию для добавления разделов:
local section_counter = 0 -- Счетчик для имен раздела, все настройки должны иметь уникальные внутренние имена, включая заголовки.
local function AddSection(label, hover)
	-- Счетчик повышается на 1.
	section_counter = section_counter + 1
	-- Функция должна вернуть таблицу с определением настройки вида заголовка.
	-- Поле options должно быть таблицей с ровно одним вариантом выбора, без него игра не "увидит" заголовок.
	-- В варианте выбора лучше использовать пустые строки, ничего изобретать не нужно.
	return {section_start = true, name = "SECTION_"..section_counter, label = label, hover = hover, options = {{description = "", data = ""}}, default = ""}
end

--[[ Тот же пример без комментариев, для копирования:

local section_counter = 0
local function AddSection(label, hover)
	section_counter = section_counter + 1
	return {section_start = true, name = "SECTION_"..section_counter, label = label, hover = hover, options = {{description = "", data = ""}}, default = ""}
end

--]]

-- Ключевое нововведение версии 0.8 - быстрые пресеты
-- Быстрые пресеты предоставляют пользователю готовые конфигурации для модов, которые можно будет применить в 1 клик.
-- Если у мода опредлены быстрые пресеты, то кнопка возвращения настроек к исходным значениям будет открывать список всех пресетов.

-- Определить пресет вовсе не сложно:
--
-- presets = { -- нужно использовать глобальную переменную presets...
local ru_presets = { -- однако конкретно в этом файле мне нужно привести варианты для нескольких языков, так что сейчас я использую вспомогательную переменную, а в конце файла сделаю выбор на основе языка
	{ -- начинаем новый пресет
		name = "Везде* первое", -- название указывается в поле "name"
		hover = "Назначает настройкам первый вариант, где возможно.", -- краткое описание сути пресета в поле "hover"
		values = { -- в поле "values" перечислены все настройки, которые пресет изменяет, и значения, которые будут назначены этим настройкам
			["LIST_EXAMPLE"] = 1, -- ВНУТРЕННЕЕ ИМЯ НАСТРОЙКИ = ЦЕЛЕВОЕ ЗНАЧЕНИЕ
			["KEYBIND_EXAMPLE"] = 282,
			["TOGGLE_EXAMPLE_NEW"] = 1, -- очень прошу следить за типами значений (число, строка, таблица...) в пресетах и самих настройках - они должны совпадать!
		--	["TEXT_EXAMPLE"] = "???", -- для текстового ввода не существует "первого варианта выбора", так что он в пресет не включается
		--	["RGB_EXAMPLE"] = "{1,1,1,1}" -- то же самое с выбором цвета
		--	["RGBA_EXAMPLE"] = {1,1,1,1}" -- тоже выбор цвета
			["MULTIPLE_CHOICES_EXAMPLE"] = {["AAA"] = true}, -- опять следим за типом значения: это настройка типа выбора нескольких вариантов и она ожидает *таблицу*
		--	["SET_EXAMPLE"] = {}, -- нет "первого варианта"
		--	["ARRAY_EXAMPLE"] = {}, -- нет "первого варианта"
		--	["DICTIONARY_EXAMPLE"] = {}, -- нет "первого варианта"
		--	настройки-пустышки добавляются посредством цикла, см. 20 строк ниже
		},
	},

	-- Похожий пример без комментариев:
	{
		name = "Везде* второе", 
		hover = "Назначает настройкам второй вариант, где возможно.",
		values = {
			["LIST_EXAMPLE"] = 2,
			["KEYBIND_EXAMPLE"] = 283,
			["TOGGLE_EXAMPLE_NEW"] = 0,
			["MULTIPLE_CHOICES_EXAMPLE"] = {["BBB"] = true},
		},
	},

	-- и так далее...
}

-- Добавление пустышек:
for i = 1, 5 do -- точно известно, что их 5
	ru_presets[1].values["FILLER_"..i] = "no"
	ru_presets[2].values["FILLER_"..i] = "yes"
end

-- ВАЖНО:
-- 1. Пресет изменяет только те настройки, которые в нём перечислены. Остальные настройки не будут затронуты.
-- 2. Снова обращаю внимание на типы значений! Если настройка получит через пресет значение неверного типа (напр. ожидалось число, получена строка), ошибки неизбежны.
-- 3. Нет необходимости определять пресет для возращения настроек к исходным значениям - он создается автоматически.
-- 4. Настройки типа выбора цвета всегда возвращают таблицу из четырех чисел: и RGB, и RGBA. В случае RGB непрозрачность (четвертое число) должна равняться 1. 
-- 5. Если в пресете перечислены несуществующие настройки, ошибок быть не должно.

-- Переходим к различным типам настроек, в том числе новым.
local ru_configuration_options = {
	-- Заголовок.
	-- Заголовки существуют в базовой игре. Чтобы создать заголовок, нужно определить настройку с одним вариантом выбора, у которого description равен пустой строке.
	{
		name = "HEADER_EXAMPLE",
		label = "Заголовок",
		options = {
			{description = "", data = 1}, -- значение у единственного варианта выбора должно совпадать с исходным значением
		},
		default = 1, -- исходное значение
	},

	-- Классический список.
	-- Самый привычный и часто встречаемый тип настроек.
	{
		name = "LIST_EXAMPLE",
		label = "Классический список",
		options = {
			{description = "Вариант A",	data =  1, hover = "Пояснение для варианта A!"},
			{description = "Вариант B",	data =  2, hover = "Пояснение для варианта B!"},
			{description = "Вариант C",	data =  3, hover = "Пояснение для варианта C!"},
			{description = "Вариант D",	data =  4, hover = "Пояснение для варианта D!"},
			{description = "Вариант E",	data =  5, hover = "Пояснение для варианта E!"},
			{description = "Вариант F",	data =  6, hover = "Пояснение для варианта F!"},
			{description = "Вариант G",	data =  7, hover = "Пояснение для варианта G!"},
			{description = "Вариант H",	data =  8, hover = "Пояснение для варианта H!"}, -- ←
			{description = "Вариант I",	data =  9, hover = "Пояснение для варианта I!"},
			{description = "Вариант J",	data = 10, hover = "Пояснение для варианта J!"},
			{description = "Вариант K",	data = 11, hover = "Пояснение для варианта K!"},
		},
		default = 8, -- обязательно должен быть вариант выбора с этим значением
		hover = "Вместо долгого перебора сделайте выбор из списка!",
	},

	-- Привязка кнопки.
	-- В игре довольно часто бывает, что игроку нужно назначить кнопку для какого-либо действия из мода.
	-- Вариантов выбора кнопки может быть очень много; и 40, и 50, и больше.
	-- Перебирать такое огромное число вариантов - ужасная идея, так что мод предоставляет возможность выбрать кнопку, просто нажав её.
	--
	-- Чтобы установить настройке тип привязки кнопки, нужно добавить "is_keybind = true,".
	-- Пользователь также может убрать привязку, setting the data value to -1. Your mod must be able to handle that case without crashing.
	{
		name = "KEYBIND_EXAMPLE",
		label = "Привязка кнопки",
		options = Keys, -- хорошей идеей будет сохранить список кнопок в локальную переменную, как в этом файле, в этом случае не придется его копировать каждый раз
		default = 97,
		hover = "Выберите кнопку одним нажатем. Просто и быстро.",
		--
		is_keybind = true, -- волшебная фраза
	},
	-- Существует довольно много модов, которые предпочитают использовать названия кнопок из constants.lua вместо числовых значений.
	-- Важно: если пользователь уберет привяку, то значение настройки все равно будет -1.
	--
	--[[ Можно выбрать любой из двух форматов, но недопустимо использовать сразу оба: будет работать только один.
	{
		name = "KEYBIND_EXAMPLE_2",
		label = "Привязка кнопки 2",
		options = KeysFormat,
		default = "KEY_A",
		hover = "Выберите кнопку одним нажатем. Просто и быстро.",
		is_keybind = true,
	},
	--]]

	-- Переключатель.
	-- Классический список ровно с двумя вариантами выбора будет оформлен в виде переключаеля.
	-- По нажатии настройка быстро переключается с одного варианта на другой.
	{
		name = "TOGGLE_EXAMPLE_NEW",
		label = "Переключатель",
		options = {
			{description =  "Вкл.", data = 1, hover = "Да!"},
			{description = "Выкл.", data = 0, hover = "Нет!"},
		},
		default = 1,
		hover = "Быстро переключайтесь между двумя вариантами.",
	},

	-- Ввод текста.
	-- Иногда списка с фиксированными вариантами недостаточно. Что если игроку, например, нужно выбрать префаб?
	-- Все префабы перечислять нецелесообразно: их очень много и с каждым обновлением становится только больше.
	--
	-- Чтобы создать настройку со вводом текста, нужно добавить в её определение "is_text_config = true,".
	-- В поле "hover" следует разъяснить пользователю, какого вида ввод от него ожидается.
	-- Не помешает и привести образец.
	{
		name = "TEXT_EXAMPLE",
		label = "Текстовый ввод",
		options = {
			{description = "Включите мод!", data = "можно вписать любой текст!"},
		},
		default = "можно вписать любой текст!",
		--
		hover = STRINGS.TEXT_EDIT_HOVER, -- вот здесь указания для игрока
		--
		is_text_config = true, -- волшебная фраза
	},

	-- Ползунки.
	-- Этот тип настроек предназначен для удобной работы с числовыми данными. 
	-- В базовой игре пришлось бы писать определение для каждого возможного варианта. От 1 до 100 по строке кода, ура...
	--
	-- Ползунки опираются на поле "slider_data". Его значением должна быть таблица из двух чисел, обозначающих допустимые границы значения.
	-- Пользователь сможет выбрать любое число между установленными границами.
	--
	-- Границы должны быть числами, причем первое число должно быть меньше второго.
	{
		name = "CONTINUOUS_SLIDER_EXAMPLE",
		label = "Плавный ползунок", -- "непрерывный"" не совсем корректно, длина шага в этом случае 0.0001
		options = {
			{description = "Включите мод!", data = 3.1415}, -- убедитесь, что значение здесь совпадает с исходным
		},
		default = 3.1415, -- это исходное значение
		--
		hover = "Выберите любое число в заданном интервале!\nМожно вписать точное значение вручную.",
		--
		slider_data = {4, 6}, -- 2 числа: левая граница, правая граница
	},

	-- Интервал можно разделить на определённое количество шагов, там самым получая дискретный ползунок.
	-- Для этого в таблицу для поля "slider_data" нужно добавить третье число, обозначающее длину шага.
	-- Максимальное количество отрезков - 500. Если выйдет больше, мод автоматически вернется к плавному ползунку.
	{
		name = "DISCRETE_SLIDER_EXAMPLE",
		label = "Дискретный ползунок",
		options = {
			{description = "Включите мод!", data = 5.5}, -- подстроится и станет 5.46
		},
		default = 5.5,
		--
		hover = "Выберите любое число в заданном интервале!\nВыбранное значение подстраивается под длину шага.",
		--
		slider_data = {5, 7, 0.23}, -- 3 числа: левая граница, правая граница, длина шага (прямо как в циклах for)
	},

	-- Выбор цвета.
	-- Немного кастомизации не повредит.
	-- Все цвета перечислить невозможно, так что мод предоставляет специальный инструмент для подбора цвета.
	-- 
	-- Цветовая настройка создается путем добавления "is_rgb_config = true," или "is_rgba_config = true,".
	-- В первом случае игрок сможет изменять цветовые компоненты (красный, зелёный, синий), во втором добавляется возможность изменять уровень прозрачности.
	-- Итоговым значением настройки в обоих случаях будет таблица из *четырёх* чисел в интервале [0, 1].
	{
		name = "RGB_EXAMPLE",
		label = "Выбор цвета",
		options = {
			{description = "Включите мод!", data = {1,1,1,1}}, -- убедитесь, что значение здесь совпадает с исходным
		},
		default = {1,1,1,1}, -- хоть прозрачность изменять нельзя, в таблице все равно должно быть *четыре* числа (последнее равно 1)
		is_rgb_config = true,
		hover = "Выберите произвольный цвет!",
	},
	-- 
	{
		name = "RGBA_EXAMPLE",
		label = "Выбор цвета и прозрачности",
		options = {
			{description = "Включите мод!", data = {1,1,1,1}},
		},
		default = {1,1,1,1},
		is_rgba_config = true,
		hover = "Выберите произвольный цвет и уровень прозрачности!",
	},

	-- Цвет формата HEX.
	-- Тот же стандартный выбор цвета с одним отличием: итоговым значением является не таблица из 4 чисел, а строка цвета формата HEX.
	{
		name = "HEX_EXAMPLE",
		label = "Выбор цвета HEX",
		options = {
			{description = "Включите мод!", data = "#ffffff"}, -- убедитесь, что значение здесь совпадает с исходным
		},
		default = "#ffffff", -- это исходное значение
		is_hex_config = true,
		hover = "Выберите произвольный цвет!\nО формате пусть думает автор мода.",
	},

	-- Выбор нескольких вариантов.
	-- Этот тип настроек немного сложнее предыдущих (и реализовать его поддержку тоже было немного тяжелее).
	--
	-- Для множественного выбора нужно поместить все варианты в поле "choices".
	-- При этом в поле "options" нужно оставить один вариант, соответствующий исходному значению (без него игра не "увидит" настройку).
	-- Это также не даст игроку работать со множественным выбором, когда этот мод выключен.
	{
		-- Здесь ничего особенного
		name = "MULTIPLE_CHOICES_EXAMPLE",
		label = "Выбор нескольских вариантов",
		hover = "Зачем выбирать что-то одно, когда можно сразу много?",
		--

		-- В этом поле собраны настоящие варианты выбора.
		choices = {
			{description = "Вариант A", data = "AAA", hover = "Пояснение для варианта A!"}, -- ←
			{description = "Вариант B", data = "BBB", hover = "Пояснение для варианта B!"},
			{description = "Вариант C", data = "CCC", hover = "Пояснение для варианта C!"}, -- ←
			{description = "Вариант D", data = "DDD", hover = "Пояснение для варианта D!"},
			{description = "Вариант E", data = "EEE", hover = "Пояснение для варианта E!"}, -- ←
			{description = "Вариант F", data = "FFF", hover = "Пояснение для варианта F!"},
			{description = "Вариант G", data = "GGG", hover = "Пояснение для варианта G!"},
			{description = "Вариант H", data = "HHH", hover = "Пояснение для варианта H!"},
			{description = "Вариант I", data = "III", hover = "Пояснение для варианта I!"},
			{description = "Вариант J", data = "JJJ", hover = "Пояснение для варианта J!"},
			{description = "Вариант K", data = "KKK", hover = "Пояснение для варианта K!"},
		},
		-- Выбранные варианты будут собраны в таблицу.
		-- Для каждого выбранного варианта в таблице будет пара "ключ-значение", где ключом станет внутреннее значение (поле "data"), а значением - логическая истина (true).
		--
		-- Например, если игрок выберет "Вариант D" и "Вариант I" из списка выше, итоговая таблица будет выглядеть так:
		-- {["DDD"] = true, ["III"] = true}
		-- Такая таблица и будет возвращена функцией GetModConfigData.


		-- В поле "options" нужно поместить ровно один вариант, в котором игроку будет сказано включить этот мод.
		options = {
			{description = "Включите мод!", data = {["AAA"] = true,["CCC"] = true,["EEE"] = true,}}, -- убедитесь, что значение здесь совпадает с исходным
		},
		default = {["AAA"] = true,["CCC"] = true,["EEE"] = true,}, -- а ещё убедитесь, что здесь у каждого ключа есть соответствующий вариант в поле "choices"
	},

	-- Множество.
	-- Позволяет указать несколько строк. Полезно, например, при выборе префабов.
	{
		-- Здесь ничего особенного
		name = "SET_EXAMPLE",
		label = "Множество",
		hover = "Создайте своё множество!\nДля инструкций выделено целых 9 строк!\n3\n4\n5\n6\n7\n8\n!! 9 !!",
		--

		-- Для создания множества необходимо добавить следующую фразу:
		is_set_config = true,

		-- Настройка типа множества не предоставляет вариантов выбора. Игрок может ввести любое количество произвольных строк.
		-- Все введённые строки собираются в таблицу как ключи: {строка1 = true, строка2 = true, ...}
		-- Эта таблица и будет возвращена функцией GetModConfigData.

		-- Например, пусть ввод игрока имеет вид:
			-- true
			-- {}
			-- 3
		-- В этом случае итоговая таблица будет такой: {["true"] = true, ["{}"] = true, ["3"] = true} -- важно отметить, что все ключи строковые, хоть и похожи на другие типы

		-- В поле "options" нужно поместить ровно один вариант, в котором игроку будет сказано включить этот мод.
		options = {
			{description = "Включите мод!", data = {["факел"] = true, ["топор"] = true, ["рюкзак"] = true}}, -- убедитесь, что значение здесь совпадает с исходным
		},
		default = {["факел"] = true, ["топор"] = true, ["рюкзак"] = true}, -- это исходное значение
	},

	-- Массив.
	-- Массивы схожи со множествами, но их данные собираются в таблицу совершенно другим образом.
	{
		-- Здесь ничего особенного
		name = "ARRAY_EXAMPLE",
		label = "Массив",
		hover = "Создайте свой массив!\nДля инструкций выделено целых 9 строк!\n3\n4\n5\n6\n7\n8\n!! 9 !!",
		--

		-- Для создания массива необходимо добавить следующую фразу:
		is_array_config = true,

		-- Настройка типа массива тоже не предоставляет вариантов выбора. Игрок может ввести любое количество произвольных строк.
		-- Все введённые строки будут собраны в таблицу как значения (а не ключи, как в случае множества): {"строка1", "строка2", ...}.
		-- Эта таблица и будет возвращена функцией GetModConfigData.

		-- Например, пусть ввод игрока имеет вид:
			-- true
			-- {}
			-- 3
		-- В этом случае итоговая таблица будет такой: {"true", "{}", "3"} -- важно отметить, что все значения строковые, хоть и похожи на другие типы

		-- В поле "options" нужно поместить ровно один вариант, в котором игроку будет сказано включить этот мод.
		options = {
			{description = "Включите мод!", data = {"факел", "топор", "рюкзак"}}, -- убедитесь, что значение здесь совпадает с исходным, порядок имеет значение
		},
		default = {"факел", "топор", "рюкзак"}, -- это исходное значение
	},

	-- Словарь.
	-- Комбинация множества и массива.
	{
		-- Nothing special here
		name = "DICTIONARY_EXAMPLE",
		label = "Словарь",
		hover = "Создайте свой словарь!\nДля инструкций выделено целых 9 строк!\n3\n4\n5\n6\n7\n8\n!! 9 !!",
		--

		-- Для создания словаря необходимо добавить следующую фразу:
		is_dictionary_config = true,

		-- Словарь позволяет игроку указывать как ключи, так и значения.
		-- Пары "ключ-значение" будут собраны в таблицу следующим образом: {["ключ1"] = "значение1", ["ключ2"] = "значение2", ...}.
		-- And that will be the value returned by GetModConfigData.

		-- Например, пусть ввод игрока имеет вид:
			-- true = 5
			-- {} = {}
			-- 3 = 6
		-- В этом случае итоговая таблица будет такой: {["true"] = "5", ["{}"] = "{}", ["3"] = "6"} -- в очередной раз обращаю внимание, что все ключи и все значения строковые

		-- В поле "options" нужно поместить ровно один вариант, в котором игроку будет сказано включить этот мод.
		options = {
			{description = "Включите мод!", data = {["1"] = "факел", ["топор"] = "3", ["рюкзак"] = "2"}}, -- убедитесь, что значение здесь совпадает с исходным
		},
		default = {["1"] = "факел", ["топор"] = "3", ["рюкзак"] = "2"}, -- это исходное значение
	},

	-- Небольшой образец раздела:
	AddSection("Заголовок раздела", "Пачка настроек, которые ни на что не влияют!"),
	Filler(), -- эти *четыре* пустышки
	Filler(), -- будут скрыты
	Filler(), -- пока игрок
	Filler(), -- не нажмет на заголовок раздела
	Filler(true),
}

local configuration_options_choice = {
	en = en_configuration_options,
	zh = zh_configuration_options,
	ru = ru_configuration_options,
}
configuration_options = configuration_options_choice[lang]

local presets_choice = {
	en = en_presets,
	zh = zh_presets,
	ru = ru_presets,
}
presets = presets_choice[lang]