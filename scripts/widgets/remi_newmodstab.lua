local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local NewModConfigurationScreen = require "widgets/remi_newmodconfigurationscreen"

local function NewModsTab(ModsTab)
	function ModsTab:ConfigureSelectedMod(modname)
		TheFrontEnd:PushScreen(NewModConfigurationScreen(self.currentmodname))
	end
end

return NewModsTab