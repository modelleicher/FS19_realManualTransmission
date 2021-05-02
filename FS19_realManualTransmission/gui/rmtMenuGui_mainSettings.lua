rmtMenuGui_mainSettings = {};
local modDirectory = g_currentModDirectory

local rmtMenuGui_mainSettings_mt = Class(rmtMenuGui_mainSettings, YesNoDialog)

rmtMenuGui_mainSettings.CONTROLS = {
    GENERAL_CONTAINER = "generalContainer",
    CLUTCHSETTINGSBUTTON = "clutchSettingsButton"
}

function rmtMenuGui_mainSettings:new(target, custom_mt)
    local self = YesNoDialog:new(target, custom_mt or rmtMenuGui_mainSettings_mt)

    self:registerControls(rmtMenuGui_mainSettings.CONTROLS)
    self.isServer = g_server ~= nil

    return self
end

function rmtMenuGui_mainSettings:loadSettings(vehicle)
    self.vehicle = vehicle;
end;

function rmtMenuGui_mainSettings:update(dt)
    rmtMenuGui_mainSettings:superClass().update(self, dt)

    if rmtMenuGui_mainSettings_firstTimeRun == nil then
        self.clutchSettingsButton:setTexts({"Manual", "Automatic", "Low-RPM", "Auto+Low-RPM"}) 
        rmtMenuGui_mainSettings_firstTimeRun = true;
    end
end

function rmtMenuGui_mainSettings:onClickButton_clutchSettings(selection)
 
    local spec = self.vehicle.spec_realManualTransmission;
    if selection == 1 then
        spec.useAutomaticClutch = false;
        spec.automaticClutch.enableOpeningAtLowRPM = false;
    elseif selection == 2 then
        spec.useAutomaticClutch = true;
        spec.automaticClutch.enableOpeningAtLowRPM = false;
    elseif selection == 3 then
        spec.useAutomaticClutch = false;
        spec.automaticClutch.enableOpeningAtLowRPM = true;
    elseif selection == 4 then
        spec.useAutomaticClutch = true;
        spec.automaticClutch.enableOpeningAtLowRPM = true;
    end;

end;

function rmtMenuGui_mainSettings:onClickBack()
    self:close()
    local GUI = g_gui:showDialog("rmtMenuGui_main")
	if GUI ~= nil then
		GUI.target:loadSettings(self.vehicle);
	end;     
end

function rmtMenuGui_mainSettings:onClickOk()
    self:close()  
end

function rmtMenuGui_mainSettings:loadGUI()
    if g_gui ~= nil then
        if g_gui.guis.rmtMenuGui_mainSettings == nil then
            local xmlPath = g_currentModDirectory .. "gui/rmtMenuGui_mainSettings.xml"
            if fileExists(xmlPath) then
                local rmtMenuGui_mainSettings = rmtMenuGui_mainSettings:new(nil, nil)
                g_gui:loadGui(xmlPath, "rmtMenuGui_mainSettings", rmtMenuGui_mainSettings)
            else
                print("Error: RMT Menu Settings GUI could not be loaded. XML File "..g_currentModDirectory.."gui/rmtMenuGui_mainSettings.xml not found.")
            end;
        end;  
    end;
end;

rmtMenuGui_mainSettings.loadGUI()
rmtMenuGui_mainSettings.modDirectory = g_currentModDirectory;