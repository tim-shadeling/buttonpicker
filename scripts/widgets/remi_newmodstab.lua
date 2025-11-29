local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local NewModConfigurationScreen = require "widgets/remi_newmodconfigurationscreen"

local function NewModsTab(ModsTab)
	function ModsTab:ConfigureSelectedMod()
		if self.modconfigable then
			-- ModConfigurationScreen has different behavior for server (a save -- dammit I missed this part!
			-- slot) and client (frontend mods). 
			local is_clientonly_config = not self.settings.is_configuring_server
			--print(is_clientonly_config)
			TheFrontEnd:PushScreen(NewModConfigurationScreen(self.currentmodname, is_clientonly_config))
		end
	end
end

return NewModsTab