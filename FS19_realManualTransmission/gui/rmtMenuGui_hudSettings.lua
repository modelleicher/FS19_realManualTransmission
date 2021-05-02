rmtMenuGui_hudSettings = {};
local modDirectory = g_currentModDirectory

local rmtMenuGui_hudSettings_mt = Class(rmtMenuGui_hudSettings, YesNoDialog)



rmtMenuGui_hudSettings.CONTROLS = {
    GENERAL_CONTAINER = "generalContainer",
    BUTTON_SHOWHUD = "button_showHud",
    BUTTON_SHOWGEAR = "button_showGear",    
    BUTTON_SHOWRANGE = "button_showRange",      
    BUTTON_SHOWREVERSER = "button_showReverser",     
    BUTTON_SHOWCLUTCH = "button_showClutch",      
    BUTTON_SHOWRPM = "button_showRpm",
    BUTTON_SHOWHANDBRAKE = "button_showHandbrake",
    BUTTON_SHOWSPEED = "button_showSpeed",
    BUTTON_SHOWLOAD = "button_showLoad",                           
}

function rmtMenuGui_hudSettings:new(target, custom_mt)
    local self = YesNoDialog:new(target, custom_mt or rmtMenuGui_hudSettings_mt)

    self:registerControls(rmtMenuGui_hudSettings.CONTROLS)
    self.isServer = g_server ~= nil

    return self
end

function rmtMenuGui_hudSettings:loadSettings(vehicle)
    self.vehicle = vehicle;
end;

function rmtMenuGui_hudSettings:update(dt)
    rmtMenuGui_hudSettings:superClass().update(self, dt)

    if rmtMenuGui_hudSettings_firstTimeRun == nil then
        
        self.button_showHud:setTexts({g_i18n:getText("gui_showHud").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showHud").." "..g_i18n:getText("gui_off")});
        self.button_showGear:setTexts({g_i18n:getText("gui_showGear").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showGear").." "..g_i18n:getText("gui_off")});
        self.button_showRange:setTexts({g_i18n:getText("gui_showRange").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showRange").." "..g_i18n:getText("gui_off")}); 
        self.button_showReverser:setTexts({g_i18n:getText("gui_showReverser").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showReverser").." "..g_i18n:getText("gui_off")}); 
        self.button_showClutch:setTexts({g_i18n:getText("gui_showClutch").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showClutch").." "..g_i18n:getText("gui_off")}); 
        self.button_showRpm:setTexts({g_i18n:getText("gui_showRpm").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showRpm").." "..g_i18n:getText("gui_off")}); 
        self.button_showHandbrake:setTexts({g_i18n:getText("gui_showHandbrake").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showHandbrake").." "..g_i18n:getText("gui_off")}); 
        self.button_showSpeed:setTexts({g_i18n:getText("gui_showSpeed").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showSpeed").." "..g_i18n:getText("gui_off")}); 
        self.button_showLoad:setTexts({g_i18n:getText("gui_showLoad").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showLoad").." "..g_i18n:getText("gui_off")});

        rmtMenuGui_hudSettings_firstTimeRun = true;
    end
end

function rmtMenuGui_hudSettings:onClickBack()
    self:close()
    local GUI = g_gui:showDialog("rmtMenuGui_main")
	if GUI ~= nil then
		GUI.target:loadSettings(self.vehicle);
	end;     
end

function rmtMenuGui_hudSettings:onClickOk()
    self:close()  
end

function rmtMenuGui_hudSettings:loadGUI()
    if g_gui ~= nil then
        if g_gui.guis.rmtMenuGui_hudSettings == nil then
            local xmlPath = g_currentModDirectory .. "gui/rmtMenuGui_hudSettings.xml"
            if fileExists(xmlPath) then
                local rmtMenuGui_hudSettings = rmtMenuGui_hudSettings:new(nil, nil)
                g_gui:loadGui(xmlPath, "rmtMenuGui_hudSettings", rmtMenuGui_hudSettings)
            else
                print("Error: RMT Menu Settings GUI could not be loaded. XML File "..g_currentModDirectory.."gui/rmtMenuGui_hudSettings.xml not found.")
            end;
        end;  
    end;
end;

rmtMenuGui_hudSettings.loadGUI()
rmtMenuGui_hudSettings.modDirectory = g_currentModDirectory;