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
local lang = _G.LanguageTranslator.defaultlang or "en"
lang = languages[lang] or "en"

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
		-- color picker
		COLOR_NAMES = {"Red:", "Green:", "Blue:", "Alpha:"},
		NEWCOLOR_LBL_STRING = "New:",
		OLDCOLOR_LBL_STRING = "Old:",
		SCROLL_INFO_STRING = "(RGBA textboxes are scrollable)",
		-- 0.7
		OPENSECTION = "-- Open --",
		COLLAPSESECTION = ">> Collapse <<", -- 0.9.1 
		RETURN = "Return (Esc)",
		-- 0.8
		RESETTODEFAULT = "Reset to default",
		RESETTODEFAULT_HOVER = "Reverts all configs to their default values, just as expected.",
		QUICKPRESETS = "Quick Presets",
		-- 0.9
		RECFG_NAME = "Reconfigure Mods",
		RECFG_LAST = "Reconfigure Last Mod",
		RECFG_TITLE = "Reconfigurable Mods",
		RECFG_DESC = "Some mods can be reconfigured without having to restart the game.",
		-- 1.1
		BAD_SLIDER_DATA = "Unable to modify slider with invalid parameters:",
		HEX = "HEX:",
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
		VALUESTR = "选项值:",
		-- 颜色选择
		COLOR_NAMES = {"红:", "绿:", "蓝:", "不透明度:"},
		NEWCOLOR_LBL_STRING = "新:",
		OLDCOLOR_LBL_STRING = "旧:",
		SCROLL_INFO_STRING = "(RGB文本框是可滚动的)",
		-- 0.7
		OPENSECTION = "-- 打开 --",
		COLLAPSESECTION = ">> 隐藏 <<", -- 0.9.1 
		RETURN = "返回 (Esc)",
		-- 0.8
		RESETTODEFAULT = "重置为默认值", -- new, machine-translated
		RESETTODEFAULT_HOVER = "将所有配置恢复为默认值。", -- new, machine-translated
		QUICKPRESETS = "快速预设", -- new, machine-translated
		-- 0.9
		RECFG_NAME = "重新配置MOD", -- new, machine-translated
		RECFG_LAST = "重新配置最后一个MOD", -- new, machine-translated
		RECFG_TITLE = "可重构MOD", -- new, machine-translated
		RECFG_DESC = "部分MOD无需重启游戏即可重新配置。", -- new, machine-translated
		-- 1.1
		BAD_SLIDER_DATA = "参数无效，无法修改滑块：",
		HEX = "HEX:",
	},

	ru = { -- avoid long phrases to make sure everything fits - нужно писать кратко чтобы текст вмещался в боксы
		EDIT_KEY = "Ключ...",
		EDIT_TEXT = "Текст...",
		EDIT_VALUE = "Значение...",
		EMPTY = "- пусто -",
		MOVEDOWN = "Сдвиг вниз",
		MOVEUP = "Сдвиг вверх",
		NEWENTRY = "Новая запись",
		PRESS_A_BUTTON = "Нажмите кнопку из списка:",
		REMOVE = "Убрать",
		SEARCH = "Найти...",
		UNDOREMOVE = "Отмена",
		VALUESTR = "Текст:",
		-- color picker
		COLOR_NAMES = {"Красный:", "Зелёный:", "Синий:", "Непрозрачность:"},
		NEWCOLOR_LBL_STRING = "Стало:",
		OLDCOLOR_LBL_STRING = "Было:",
		SCROLL_INFO_STRING = "(цветовые поля можно прокручивать)",
		-- 0.7
		OPENSECTION = "-- Раскрыть --",
		COLLAPSESECTION = ">> Свернуть <<", -- 0.9.1 
		RETURN = "Назад (Esc)",
		-- 0.8
		RESETTODEFAULT = "По умолчанию",
		RESETTODEFAULT_HOVER = "Возвращает всё к исходным значениям.",
		QUICKPRESETS = "Пресеты",
		-- 0.9
		RECFG_NAME = "Настроить моды",
		RECFG_LAST = "Настроить последний мод",
		RECFG_TITLE = "Поддерживаемые моды",
		RECFG_DESC = "Некоторые моды можно настроить в любой момент.",
		-- 1.1
		BAD_SLIDER_DATA = "Некорректные параметры слайдера:",
		HEX = "HEX:",
	}
}

STRINGS.BUTTONPICKER = strings[lang]