local Formats = {
	alphabet = {},
	alphabet_nu = {},
	constnames = {},
	constnames_nu = {},
	shortnames = {},
	shortnames_nu = {},
	false_unbind = {},
	nu = {},
}
----------------------------------------------------------------------------------------------------------
--[[ Alphabet Format
{
	[KEY_A] = "A",
	[KEY_B] = "B",
	...
	[KEY_Z] = "Z",
	[-1] = "", -- if unbinding is supported
}
--]] 

for i = 1, 26 do
	local input = KEY_A + i - 1
	local ch = string.char(input)
	Formats.alphabet[input] = ch:upper()
	Formats.alphabet_nu[input] = ch:upper()
end
Formats.alphabet[-1] = ""
----------------------------------------------------------------------------------------------------------
--[[ Constant Names Format
{
	[KEY_A] = "KEY_A",
	[KEY_B] = "KEY_B",
	... -- and same goes for all other keys defined in constants.lua
	[-1] = false, -- if unbinding is supported
}
Short version doesn't have the "KEY_" part, making it basically an expanded version of Alphabet Format.
--]] 

local keylist = { "TAB", "KP_0", "KP_1", "KP_2", "KP_3", "KP_4", "KP_5", "KP_6", "KP_7", "KP_8", "KP_9", "KP_PERIOD", "KP_DIVIDE", "KP_MULTIPLY", "KP_MINUS", "KP_PLUS", "KP_ENTER", "KP_EQUALS", 
"MINUS", "EQUALS", "SPACE", "ENTER", "ESCAPE", "HOME", "INSERT", "DELETE", "END", "PAUSE", "PRINT", "CAPSLOCK", "SCROLLOCK", "RSHIFT", "LSHIFT", "RCTRL", "LCTRL", "RALT", "LALT", "LSUPER", "RSUPER", 
"ALT", "CTRL", "SHIFT", "BACKSPACE", "PERIOD", "SLASH", "SEMICOLON", "LEFTBRACKET", "BACKSLASH", "RIGHTBRACKET", "TILDE", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", 
"P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "UP", "DOWN", "RIGHT", "LEFT", "PAGEUP", "PAGEDOWN", 
"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
for i = 1, #keylist do
	local key = "KEY_"..keylist[i]
    Formats.constnames[_G[key]] = key
    Formats.constnames_nu[_G[key]] = key
    Formats.shortnames[_G[key]] = keylist[i]
    Formats.shortnames_nu[_G[key]] = keylist[i]
end
Formats.constnames[-1] = false
Formats.shortnames[-1] = false
----------------------------------------------------------------------------------------------------------
-- For mods that use false as null binds.

Formats.false_unbind[-1] = false
setmetatable(Formats.false_unbind, {__index = function(t,k) return k end})
----------------------------------------------------------------------------------------------------------
-- Format that prevents unbinding but doesn't change anything else

setmetatable(Formats.nu, {__index = function(t,k) return k > 0 and k or nil end})
----------------------------------------------------------------------------------------------------------
local ManualSupport = {}
local function AddManualSupport(modname, format_name, ...) -- name of the mod, name of format table, then names of all options that should be treated as keybinds
	local keybinds = {}
	for k,v in pairs{...} do keybinds[v] = true end
	ManualSupport[modname] = {keybinds = keybinds, format = Formats[format_name]}
end

AddManualSupport("workshop-2976382468",	nil,					"keybind") -- Bone Helm Shadow Toggle, makes my wicker days way more bearable
AddManualSupport("workshop-351325790",	"alphabet",				"KEYBOARDTOGGLEKEY", "GEOMETRYTOGGLEKEY", "SNAPGRIDKEY") -- Geometric Placement, one of the mods of all time
AddManualSupport("workshop-352373173",	"alphabet_nu",			"KEYBOARDTOGGLEKEY") -- Gesture Wheel, should be basegame ngl
AddManualSupport("workshop-1603516353",	nil,					"change_pickup", "change_meat", "blacklist_key", "whitelist_key") -- Pick-up Filters, this mod is so based btw
AddManualSupport("workshop-2302837868",	"constnames_nu",		"keychagemode") -- Snapping Tills, has an interesting way to set up keybind options
AddManualSupport("workshop-1608191708",	"constnames",			"action_queue_key", "turf_grid_key", "auto_collect_key", "endless_deploy_key", "last_recipe_key") -- ActionQueue Reborn, a somewhat cheaty masterpiece 
AddManualSupport("workshop-2325441848",	"constnames",			"action_queue_key", "turf_grid_key", "auto_collect_key", "endless_deploy_key", "last_recipe_key") -- ActionQueue RB2
AddManualSupport("workshop-2873533916",	"constnames",			"action_queue_key", "turf_grid_key", "auto_collect_key", "endless_deploy_key", "last_recipe_key") -- ActionQueue RB3 
AddManualSupport("workshop-2525858933",	nil,					"ping_key", "whisper_key") -- Environment Pinger, my most fav mod :O
AddManualSupport("workshop-714735102",	nil,					"KEY_TOGGLE_MOD_WAYPOINT", "KEY_TOGGLE_MOD_WAYPOINT_INDICATORS") -- Waypoint, a great example to study
-- 0.1
AddManualSupport("workshop-2895442474", nil,					"recall", "commune", "useotherelixir", "usehealthelixir", -- wendigo							-- Character Keybinds, the only other character keybind mod I am willing to accept
																"sing", "sing1", "sing2", "sing3", "sing4", "sing5", "sing6", "sing7", -- loud woman
																"uselighter", "useember", "useemberwheel", "ember1", "ember2", "ember3", "ember4", "ember5", -- table fork
																"fuel", "tophat", "usebook", "usebookwheel", "spell1", "spell2", "spell3", "spell4", -- ew
																"backstep", "heal", "revive", "backtrek", -- wandus
																"souldrop", "souldodge", -- imp guy
																"dumbbell", -- fat and dumb forgor name
																"actionqueue", "movementpredict", "jumphole", "rescue", -- misc
																"leftclick", "rightclick", "leftrightclick") -- mapping
-- The fat list begins here
AddManualSupport("workshop-2683677179", "false_unbind",			"whisper_key", "announce_all_key", "announce_under_mouse_key", "announce_under_mouse_key_mod", -- Quick Announcements, nice work on the configs
																"distance_keybind_add", "distance_keybind_subtract")

AddManualSupport("workshop-2975147092", "constnames",			"CANE", "WEAPON", "LIGHTSOURCE", "RANGED", "ARMOR", "ARMORHAT", "ARMORBODY", "AXE", "PICKAXE", -- DST Helper, oof!
																"HAMMER", "SHOVEL", "PITCHFORK", "SCYTHE", "STAFF", "FOOD", "HEALINGFOOD", "DROPKEY", "MEAT_PRIORITIZATION_MODE", 
																"SORT_INVENTORY", "SORT_CHEST", "TOGGLE_TELEPOOF", "TOGGLE_SORTING_CONTAINER", "TOGGLE_AUTO_EQUIP", 
																"TOGGLE_AUTO_EQUIP_CANE", "CONFIRM_TO_EAT", "PICKUP_FILTER", "ATTACK_FILTER")

AddManualSupport("workshop-1704104804", "nu",					"DROP_WORTOX_SOUL") -- Wortox Quick Heal, I remember using it a lot
AddManualSupport("workshop-1903101575", "constnames",			"key_rejoin") -- Auto Join, personally I don't care for pubs though
AddManualSupport("workshop-2896126381", "nu",					"GOP_TMIP_TOGGLE_KEY") -- Too Many Items Revisited, haven't gotten to use that one
AddManualSupport("workshop-1900530222", "alphabet_nu",			"KEY") -- Sharing target with followers, aka "the aggro mod"
AddManualSupport("workshop-1835465557", "constnames",			"key_action", "key_push") -- Keep Following, very annoying
AddManualSupport("workshop-2043109179", "shortnames_nu",		"summonkey", "commandkey") -- Abigail Keybinds, nothing to say on this one tbh
AddManualSupport("workshop-1969627724", "alphabet_nu",			"KEYBOARDTOGGLEKEY") -- Super Gesture, those super emotes are way too loud
AddManualSupport("workshop-1322200744", "constnames",			"shortcut_key", "shortcut_key_2") -- Animal Tracker, hmmmm, cheaty but I like
AddManualSupport("workshop-2305130719", nil,					"keyregister", "keyhud") -- Farming Helper, if only I cared for gardening.
AddManualSupport("workshop-2179516140", "constnames",			"announce_ents_bind", "instant_special_bind") -- Item Ability Cooldown Timer, oh the things you have to do just to make a translation for modinfo...
AddManualSupport("workshop-1984734819", "constnames",			"CANE","WEAPON", "LIGHTSOURCE", "RANGED", "ARMOR", "ARMORHAT", "ARMORBODY", "AXE", "PICKAXE", -- Equipment Control, aww man here we go again!
																"HAMMER", "SHOVEL", "PITCHFORK", "SCYTHE", "STAFF", "FOOD", "HEALINGFOOD", "DROPKEY", "MEAT_PRIORITIZATION_MODE", 
																"SORT_INVENTORY", "SORT_CHEST", "TOGGLE_TELEPOOF", "TOGGLE_SORTING_CONTAINER", "TOGGLE_AUTO_EQUIP", 
																"TOGGLE_AUTO_EQUIP_CANE", "CONFIRM_TO_EAT", "PICKUP_FILTER", "ATTACK_FILTER")

AddManualSupport("workshop-2525856394", nil,					"hideButton") -- Burning Timer, is it that hard to count 30 seconds for ropes?
AddManualSupport("workshop-1853696644", "constnames",			"m_vol_minus", "m_vol_plus") -- Synthwave Boss Rush Music, no thanks.

return ManualSupport