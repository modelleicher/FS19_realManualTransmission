rmtMenuMainGui = {};
local modDirectory = g_currentModDirectory

local rmtMenuMainGui_mt = Class(rmtMenuMainGui, YesNoDialog)

rmtMenuMainGui.CONTROLS = {
    GENERAL_CONTAINER = "generalContainer",
    CLUTCHSETTINGBUTTON = "clutchSettingButton"

}
function rmtMenuMainGui:new(target, custom_mt)
    local self = YesNoDialog:new(target, custom_mt or rmtMenuMainGui_mt)

    self:registerControls(rmtMenuMainGui.CONTROLS)
    self.isServer = g_server ~= nil

    return self
end

function rmtMenuMainGui:loadSettings(vehicle)
    self.vehicle = vehicle;
end;

function rmtMenuMainGui:update(dt)
    rmtMenuMainGui:superClass().update(self, dt)

    if rmtMenuMain_firstTimeRun == nil then
        self.clutchSettingButton:setTexts({"Manual", "Automatic", "Low-RPM", "Auto+Low-RPM"}) 
        rmtMenuMain_firstTimeRun = true;
    end
end


function rmtMenuMainGui:onClickButton_clutchSetting(selection)

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

function rmtMenuMainGui:onClickOk()
    self:close()

end

function rmtMenuMainGui:onClickBack(forceBack, usedMenuButton)
    self:close()
end


function rmtMenuMainGui:loadGUI()
    if g_gui ~= nil and g_gui.guis.rmtMenuMainGui == nil then
        local xmlPath = g_currentModDirectory .. "rmtMenuMainGui.xml"
        if fileExists(xmlPath) then
            local rmtMenuMainGui = rmtMenuMainGui:new(nil, nil)
            g_gui:loadGui(xmlPath, "rmtMenuMainGui", rmtMenuMainGui)
        else
            print("Error: RMT Menu Main GUI could not be loaded. XML File "..g_currentModDirectory.."rmtMenuMainGui.xml not found.")
        end;
    end
end

rmtMenuMainGui.loadGUI()
rmtMenuMainGui.modDirectory = g_currentModDirectory;
