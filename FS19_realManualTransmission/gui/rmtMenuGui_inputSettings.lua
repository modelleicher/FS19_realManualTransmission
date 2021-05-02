rmtMenuGui_inputSettings = {};
local modDirectory = g_currentModDirectory

local rmtMenuGui_inputSettings_mt = Class(rmtMenuGui_inputSettings, YesNoDialog)

rmtMenuGui_inputSettings.CONTROLS = {
    GENERAL_CONTAINER = "generalContainer"
}

function rmtMenuGui_inputSettings:new(target, custom_mt)
    local self = YesNoDialog:new(target, custom_mt or rmtMenuGui_inputSettings_mt)

    self:registerControls(rmtMenuGui_inputSettings.CONTROLS)
    self.isServer = g_server ~= nil

    return self
end

function rmtMenuGui_inputSettings:loadSettings(vehicle)
    self.vehicle = vehicle;
end;

function rmtMenuGui_inputSettings:update(dt)
    rmtMenuGui_inputSettings:superClass().update(self, dt)

    if rmtMenuMain_firstTimeRun == nil then
        rmtMenuMain_firstTimeRun = true;
    end
end

function rmtMenuGui_inputSettings:onClickBack()
    self:close()
    local GUI = g_gui:showDialog("rmtMenuGui_main")
	if GUI ~= nil then
		GUI.target:loadSettings(self.vehicle);
	end;     
end

function rmtMenuGui_inputSettings:onClickOk()
    self:close()
end

function rmtMenuGui_inputSettings:loadGUI()
    if g_gui ~= nil then
        if g_gui.guis.rmtMenuGui_inputSettings == nil then
            local xmlPath = g_currentModDirectory .. "gui/rmtMenuGui_inputSettings.xml"
            if fileExists(xmlPath) then
                local rmtMenuGui_inputSettings = rmtMenuGui_inputSettings:new(nil, nil)
                g_gui:loadGui(xmlPath, "rmtMenuGui_inputSettings", rmtMenuGui_inputSettings)
            else
                print("Error: RMT Menu Settings GUI could not be loaded. XML File "..g_currentModDirectory.."gui/rmtMenuGui_inputSettings.xml not found.")
            end;
        end;  
    end;
end;

rmtMenuGui_inputSettings.loadGUI()
rmtMenuGui_inputSettings.modDirectory = g_currentModDirectory;