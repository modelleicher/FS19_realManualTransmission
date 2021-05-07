-- GUI Lua for RMT, specifically Hud Settings
-- by modelleicher
-- 03.05.2021 

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
    BUTTON_XPOS = "button_xPos", 
    BUTTON_YPOS = "button_yPos", 
    BUTTON_SHOWBACKGROUND = "button_showBackground",                              
}

function rmtMenuGui_hudSettings:new(target, custom_mt)
    local self = YesNoDialog:new(target, custom_mt or rmtMenuGui_hudSettings_mt)

    self:registerControls(rmtMenuGui_hudSettings.CONTROLS)
    self.isServer = g_server ~= nil

    return self
end

function rmtMenuGui_hudSettings:loadSettings(vehicle)
    self.vehicle = vehicle

    -- create hudSettings gui table;
    self.vehicle.rmt_gt_hudSettings = {}
end;

function rmtMenuGui_hudSettings:update(dt)
    rmtMenuGui_hudSettings:superClass().update(self, dt)

    -- running a first-time-run only in update because onCreate did not have proper access to self for some reason
    local gt = self.vehicle.rmt_gt_hudSettings;

    if gt.firstTimeRun == nil then

        -- set texts -> avaiable selection including l10n text first
        self.button_showHud:setTexts({g_i18n:getText("gui_showHud").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showHud").." "..g_i18n:getText("gui_off")})
        self.button_showGear:setTexts({g_i18n:getText("gui_showGear").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showGear").." "..g_i18n:getText("gui_off")})
        self.button_showRange:setTexts({g_i18n:getText("gui_showRange").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showRange").." "..g_i18n:getText("gui_off")})
        self.button_showReverser:setTexts({g_i18n:getText("gui_showReverser").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showReverser").." "..g_i18n:getText("gui_off")})
        self.button_showClutch:setTexts({g_i18n:getText("gui_showClutch").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showClutch").." "..g_i18n:getText("gui_off")})
        self.button_showRpm:setTexts({g_i18n:getText("gui_showRpm").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showRpm").." "..g_i18n:getText("gui_off")})
        self.button_showHandbrake:setTexts({g_i18n:getText("gui_showHandbrake").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showHandbrake").." "..g_i18n:getText("gui_off")})
        self.button_showSpeed:setTexts({g_i18n:getText("gui_showSpeed").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showSpeed").." "..g_i18n:getText("gui_off")})
        self.button_showLoad:setTexts({g_i18n:getText("gui_showLoad").." "..g_i18n:getText("gui_on"), g_i18n:getText("gui_showLoad").." "..g_i18n:getText("gui_off")})

        -- now set the current state of the button depending on which state the setting is in
        if self.vehicle.spec_rmtMenu ~= nil then
            local hud = self.vehicle.spec_rmtMenu.hud;

            if not hud.showHud then
                self.button_showHud:setState(2);
            end;
            if not hud.showGear then
                self.button_showGear:setState(2);
            end;
            if not hud.showRange then
                self.button_showRange:setState(2);
            end;
            if not hud.showReverser then
                self.button_showReverser:setState(2);
            end;
            if not hud.showClutch then
                self.button_showClutch:setState(2);
            end;
            if not hud.showRpm then
                self.button_showRpm:setState(2);
            end;
            if not hud.showHandbrake then
                self.button_showHandbrake:setState(2);
            end;
            if not hud.showSpeed then
                self.button_showSpeed:setState(2);
            end;
            if not hud.showLoad then
                self.button_showLoad:setState(2);
            end;

            if hud.showBackground then
                self.button_showBackground:setState(2);
            end;

            -- more direct access to hud for later use
            self.hudAccess = hud;

            -- set the X and Y Pos Buttons Text
            self.button_xPos:setTexts({"", (math.floor(self.hudAccess.posX * 100) / 100), ""})
            self.button_yPos:setTexts({"", (math.floor(self.hudAccess.posY * 100) / 100), ""})    
            self.button_xPos:setState(2);       
            self.button_yPos:setState(2);    
        end;

        gt.firstTimeRun = true
    end
end
function rmtMenuGui_hudSettings:onClickButton_xPos(state)
    if self.hudAccess ~= nil then
        if state == 3 then
            self.hudAccess.posX = math.floor((self.hudAccess.posX + 0.01) * 100) / 100;
            self.button_xPos:setTexts({"", self.hudAccess.posX, ""});
            self.button_xPos:setState(2);
        end;
        if state == 1 then
            self.hudAccess.posX = math.floor((self.hudAccess.posX - 0.01) * 100) / 100;
            self.button_xPos:setTexts({"", self.hudAccess.posX, ""});
            self.button_xPos:setState(2);
        end;
    end;
end
function rmtMenuGui_hudSettings:onClickButton_yPos(state)
    if self.hudAccess ~= nil then
        if state == 3 then
            self.hudAccess.posY = math.floor((self.hudAccess.posY + 0.01) * 100) / 100;
            self.button_yPos:setTexts({"", self.hudAccess.posY, ""});
            self.button_yPos:setState(2);
        end;
        if state == 1 then
            self.hudAccess.posY = math.floor((self.hudAccess.posY - 0.01) * 100) / 100;
            self.button_yPos:setTexts({"", self.hudAccess.posY, ""});
            self.button_yPos:setState(2);
        end;
    end;
end

-- all the buttons
function rmtMenuGui_hudSettings:onClickButton_showBackground(state)
    if self.hudAccess ~= nil then
        if state == 1 then
            self.hudAccess.showBackground = false;
        else
            self.hudAccess.showBackground = true;
        end;
    end;
end
function rmtMenuGui_hudSettings:onClickButton_showHud(state)
    if self.hudAccess ~= nil then
        if state == 1 then
            self.hudAccess.showHud = true;
        else
            self.hudAccess.showHud = false;
        end;
    end;
end
function rmtMenuGui_hudSettings:onClickButton_showGear(state)
    if self.hudAccess ~= nil then
        if state == 1 then
            self.hudAccess.showGear = true;
        else
            self.hudAccess.showGear = false;
        end;
    end; 
end
function rmtMenuGui_hudSettings:onClickButton_showRange(state)
    if self.hudAccess ~= nil then
        if state == 1 then
            self.hudAccess.showRange = true;
        else
            self.hudAccess.showRange = false;
        end;
    end;  
end
function rmtMenuGui_hudSettings:onClickButton_showReverser(state)
    if self.hudAccess ~= nil then
        if state == 1 then
            self.hudAccess.showReverser = true;
        else
            self.hudAccess.showReverser = false;
        end;
    end;  
end
function rmtMenuGui_hudSettings:onClickButton_showClutch(state)
    if self.hudAccess ~= nil then
        if state == 1 then
            self.hudAccess.showClutch = true;
        else
            self.hudAccess.showClutch = false;
        end;
    end;   
end
function rmtMenuGui_hudSettings:onClickButton_showRpm(state)
    if self.hudAccess ~= nil then
        if state == 1 then
            self.hudAccess.showRpm = true;
        else
            self.hudAccess.showRpm = false;
        end;
    end;   
end
function rmtMenuGui_hudSettings:onClickButton_showHandbrake(state)
    if self.hudAccess ~= nil then
        if state == 1 then
            self.hudAccess.showHandbrake = true;
        else
            self.hudAccess.showHandbrake = false;
        end;
    end;     
end
function rmtMenuGui_hudSettings:onClickButton_showSpeed(state)
    if self.hudAccess ~= nil then
        if state == 1 then
            self.hudAccess.showSpeed = true;
        else
            self.hudAccess.showSpeed = false;
        end;
    end;    
end
function rmtMenuGui_hudSettings:onClickButton_showLoad(state)
    if self.hudAccess ~= nil then
        if state == 1 then
            self.hudAccess.showLoad = true;
        else
            self.hudAccess.showLoad = false;
        end;
    end;  
end

-- return and ok buttons
function rmtMenuGui_hudSettings:onClickBack()
    self:close()
    local GUI = g_gui:showDialog("rmtMenuGui_main")
	if GUI ~= nil then
		GUI.target:loadSettings(self.vehicle)
	end     
end

function rmtMenuGui_hudSettings:onClickOk()
    self:close()  
end

-- load the GUI itself
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