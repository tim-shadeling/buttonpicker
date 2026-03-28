_G = GLOBAL
require = _G.require
-- Strings:
STRINGS = _G.STRINGS
modimport("scripts/strings")
-- Config screen replacement
AddClassPostConstruct("widgets/redux/modstab", require "widgets/remi_newmodstab")

-- The new feature of 0.9: Reconfiguration Hub
-- Starting with Vault Navigator, I've been exploring the possibility to change a mod's confings on the go, without having to rejoin the server or restart the game.
-- I've added the feature to quite a few mods: each one of them would have a slash command that opened the mod config screen. Any changes made would be applied right away.
-- Eventually, the slash commands became too many to remember them all, which is why I decided to create a unified interface.

-- How this works: 
-- 1. I'll create a table to gather info:
_G.REMI_RECONFIGURABLE_MODS = {}

-- 2. Other mods will add their "Reconfigure" functions to the table, using their internal mod names as keys.
-- Here's am example on how a mod would do this:
--[[

local function Reconfigure(settigs)
	-- a function that does the whole job of applying the config changes
	-- look up examples in my other mods: Vault Navigator, Bestest Spell Casting, Auto-Refuel Stuff, Brightshade Timer & Warning, and more
end

AddGamePostInit(function() -- it absolutely has to be inside a game post init to ensure all mods have been loaded
	local mods = GLOBAL.rawget(GLOBAL, "REMI_RECONFIGURABLE_MODS") -- use rawget to avoid crashes in case the table didn't exist for some reason
	if mods then mods[modname] = Reconfigure end -- key is modname (built-in variable, you don't need to define it), value is your reconfiguration function
end)

--]]

-- 3. In game, the user will be able to access the reconfiguration hub by either running /recfg (or /cfg).
-- Reconfiguration hub lists all mods that have added their functions to REMI_RECONFIGURABLE_MODS.
-- Clicking on a mod entry will summon it's configuration screen, where the user will be able to make any changes necessary.
-- Once the "Apply" button is hit, the config changes will (should) take place immediately.

-- Here is the slash command by the way.
local ReconfigurationHub = require "widgets/remi_reconfigurationhub"
_G.AddUserCommand("recfg", {
	aliases = {"cfg"},
	prettyname = STRINGS.BUTTONPICKER.RECFG_NAME,
	desc = STRINGS.BUTTONPICKER.RECFG_DESC,
	permission = _G.COMMAND_PERMISSION.USER,
	slash = true,
	usermenu = false,
	servermenu = false,
	params = {},
	vote = false,
	localfn = function()
		TheFrontEnd:PushScreen(ReconfigurationHub()) -- TheFrontEnd:PushScreen(require "widgets/remi_reconfigurationhub"())
	end,
})

-------------------------------------------------------
-- NEW, machine-translated/以下部分为新增内容，由机器翻译。--
-------------------------------------------------------
-- 0.9 版本新增功能：重新配置中心
-- 从 Vault Navigator 开始，我一直在探索如何在不重新加入服务器或重启游戏的情况下，随时更改 MOD 的配置。
-- 我已经为许多 MOD 添加了此功能：每个 MOD 都有一个斜杠命令，用于打开 MOD 配置界面。所做的任何更改都会立即生效。
-- 最终，斜杠命令的数量过多，难以全部记住，因此我决定创建一个统一的界面。
-- 工作原理：

-- 1. 我将创建一个表格来收集信息：
_G.REMI_RECONFIGURABLE_MODS = {}

-- 2. 其他 MOD 将使用其内部 MOD 名称作为键，将其“重新配置”功能添加到该表格中。
-- 以下是一个 MOD 如何实现此功能的示例：
--[[

local function Reconfigure(settigs)
	-- 一个执行所有配置更改的函数
	-- 可在我的其他 MOD 中查找示例：Vault Navigator、Bestest Spell Casting、Auto-Refuel Stuff、Brightshade Timer & Warning 等
end

AddGamePostInit(function() -- 必须放在游戏初始化函数中，以确保所有 MOD 都已加载
	local mods = GLOBAL.rawget(GLOBAL, "REMI_RECONFIGURABLE_MODS") -- 使用 rawget 可以避免因某些原因导致表不存在而崩溃
	if mods then mods[modname] = Reconfigure end -- 键是 modname（内置变量，无需定义），值是您的重新配置函数
end)

--]]

-- 3. 在游戏中，用户可以您可以通过运行 `/recfg`（或 `/cfg`）命令访问重配置中心。
-- 重配置中心列出了所有已将其功能添加到 `REMI_RECONFIGURABLE_MODS` 的模块。
-- 点击模块条目将打开其配置界面，用户可以在此进行必要的更改。
-- 点击“应用”按钮后，配置更改将（应该）立即生效。