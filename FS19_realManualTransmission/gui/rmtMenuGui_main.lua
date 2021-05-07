rmtMenuGui_main = {};
local modDirectory = g_currentModDirectory

local rmtMenuGui_main_mt = Class(rmtMenuGui_main, YesNoDialog)

rmtMenuGui_main.CONTROLS = {
    GENERAL_CONTAINER = "generalContainer"
}

function rmtMenuGui_main:new(target, custom_mt)
    local self = YesNoDialog:new(target, custom_mt or rmtMenuGui_main_mt)

    self:registerControls(rmtMenuGui_main.CONTROLS)
    self.isServer = g_server ~= nil

    return self
end

function rmtMenuGui_main:loadSettings(vehicle)
    self.vehicle = vehicle;
end;

function rmtMenuGui_main:update(dt)
    rmtMenuGui_main:superClass().update(self, dt)

    if rmtMenuMain_firstTimeRun == nil then
        rmtMenuMain_firstTimeRun = true;
    end
end

function rmtMenuGui_main:onClick_mainSettings(selection)
    self:close()
	local GUI = g_gui:showDialog("rmtMenuGui_mainSettings")
	if GUI ~= nil then
		GUI.target:loadSettings(self.vehicle);
	end;    
end;
function rmtMenuGui_main:onClick_hudSettings(selection)
    self:close()
	local GUI = g_gui:showDialog("rmtMenuGui_hudSettings")
	if GUI ~= nil then
		GUI.target:loadSettings(self.vehicle);
	end;    
end;
function rmtMenuGui_main:onClick_inputSettings(selection)
    self:close()
	local GUI = g_gui:showDialog("rmtMenuGui_inputSettings")
	if GUI ~= nil then
		GUI.target:loadSettings(self.vehicle);
	end;    
end;

function rmtMenuGui_main:onClickBack()
    self:close()
end

function rmtMenuGui_main:loadGUI()
    if g_gui ~= nil then
        if g_gui.guis.rmtMenuGui_main == nil then
            local xmlPath = g_currentModDirectory .. "gui/rmtMenuGui_main.xml"
            if fileExists(xmlPath) then
                local rmtMenuGui_main = rmtMenuGui_main:new(nil, nil)
                g_gui:loadGui(xmlPath, "rmtMenuGui_main", rmtMenuGui_main)
            else
                print("Error: RMT Menu Main GUI could not be loaded. XML File "..g_currentModDirectory.."gui/rmtMenuGui_main.xml not found.")
            end;
        end;
    end;
end;

rmtMenuGui_main.loadGUI()
rmtMenuGui_main.modDirectory = g_currentModDirectory;
