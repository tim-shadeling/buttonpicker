local lang = GLOBAL.LanguageTranslator.defaultlang or "en"
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
}

if languages[lang] ~= nil then
    lang = languages[lang]
else
    lang = "en"
end

local strings = {
    en = {
        EDIT_KEY = "Key...",
        EDIT_TEXT = "Your text here...",
        EDIT_VALUE = "Value...",
        EMPTY = "- empty -",
        MOVEDOWN = "Move Down",
        MOVEUP = "Move Up",
        NEWENTRY = "New Entry",
        PRESS_A_BUTTON = "Press a button from the list below!",
        REMOVE = "Remove",
        SEARCH = "Search...",
        UNDOREMOVE = "Undo",
        VALUESTR = "Value:",
    },
    zh = {
        EDIT_KEY = "键...",
        EDIT_TEXT = "在此输入文本...",
        EDIT_VALUE = "值...",
        EMPTY = "- 空 -",
        MOVEDOWN = "向下移动",
        MOVEUP = "向上移动",
        NEWENTRY = "新建条目",
        PRESS_A_BUTTON = "从下面的列表中按一个按钮！",
        REMOVE = "删除",
        SEARCH = "搜索...",
        UNDOREMOVE = "撤销",
        VALUESTR = "选项值",
    },
}

GLOBAL.STRINGS.BUTTONPICKER = strings[lang]