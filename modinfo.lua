local function en_zh(en, zh)
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
	local lang = languages[locale] or en
    return lang == "zh" and zh or en
end

name = en_zh("Configs Extended","配置扩展")
description = en_zh(
	"Improves user experience when configurating mods and allows for different types of settings: keybinds, text inputs, color pickers, multiple choices...",
	"在配置Mod时改善用户体验，并允许不同类型的设置: 快捷键绑定，文本输入，颜色选择，多项选择...")
author = "Remi"
version = "0.6.1"

forumthread = ""

api_version = 10

dst_compatible = true
client_only_mod = true
all_clients_require_mod = false
server_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

local text_edit_hover = en_zh([[This is the option's hover text! I've left a fair amount of space here to allow mod makers to describe what kind of input they are expecting from the player.
It would also help a lot to provide an example.

This feature originates from clearlove's Mod Config By Text.]],

[[这是选项的悬停文本！
我在这里留下了相当多的空间，让Mod制作者描述他们希望从玩家那里得到什么样的输入内容。
举个例子也会有很大帮助。

这个功能来源于clearlove的Mod: 文本模组配置]]
)

local Keys = {
	{description = "F1", data = 282},
	{description = "F2", data = 283},
	{description = "F3", data = 284},
	{description = "1", data = 49},
	{description = "2", data = 50},
	{description = "3", data = 51},
	{description = en_zh("Num 1","小键盘 1"), data = 257},
	{description = en_zh("Num 2","小键盘 2"), data = 258},
	{description = en_zh("Num 3","小键盘 3"), data = 259},
	{description = "Alt", data = 308},
	{description = "Ctrl", data = 306},
	{description = "A", data = 97},
	{description = "B", data = 98},
	{description = "C", data = 99},
    {description = en_zh("Mouse 3","鼠标中键"), data = 1002},
}

local KeysFormat = {
	{description = "F1", data = "KEY_F1"},
	{description = "F2", data = "KEY_F2"},
	{description = "F3", data = "KEY_F3"},
	{description = "1", data = "KEY_1"},
	{description = "2", data = "KEY_2"},
	{description = "3", data = "KEY_3"},
	{description = en_zh("Num 1","小键盘 1"), data = "KEY_KP_1"},
	{description = en_zh("Num 2","小键盘 2"), data = "KEY_KP_2"},
	{description = en_zh("Num 3","小键盘 3"), data = "KEY_KP_3"},
	{description = "Alt", data = "KEY_ALT"},
	{description = "Ctrl", data = "KEY_CTRL"},
	{description = "Shift", data = "KEY_SHIFT"},
	{description = "A", data = "KEY_A"},
	{description = "B", data = "KEY_B"},
	{description = "C", data = "KEY_C"},
    {description = en_zh("Mouse 3","鼠标中键"), data = "MOUSEBUTTON_MIDDLE"},
}

-- Now let's get to the different types of configs.
en_configuration_options = {

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

	-- Set.
	-- Contains multiple elemets (all strings). Useful for selecting prefabs.
	-- The strings are collected into a table as keys: {string1 = true, string2 = true, ...}
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
		-- And that will the value returned by GetModConfigData.

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
	-- Kinda similar to the set, except...
	-- the strings are collected into a table as values: {"string1", "string2", ...}, and they're also ordered,
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
		-- And that will the value returned by GetModConfigData.

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
		-- And that will the value returned by GetModConfigData.

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
}


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
	-- 开关仅包含两个选项，一个为true，另一个则为false
	-- 如果选项满足上述条件，此mod将自动将您的配置转换为开关。
	{
		name = "TOGGLE_EXAMPLE",
		label = "开关示例",
		options = {
			{description = "开", data = true, hover = "Yay!"},
			{description = "关", data = false, hover = "Nay!"},
		},
		default = true,
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
		hover = text_edit_hover, -- 此处为解释
		--
		is_text_config = true, -- 这就是魔术
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
}


configuration_options = en_zh(en_configuration_options, zh_configuration_options)