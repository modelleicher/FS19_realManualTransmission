-- by modelleicher
-- all menu-related stuff is in this script

rmtMenu = {};

function rmtMenu.prerequisitesPresent(specializations)
	print("prerequisitesPresent is active");
    return true;
end;


function rmtMenu.registerEventListeners(vehicleType)
	--print("registerEventListeners called");
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", rmtMenu);
	SpecializationUtil.registerEventListener(vehicleType, "onDraw", rmtMenu);
	SpecializationUtil.registerEventListener(vehicleType, "saveToXMLFile", rmtMenu);
	SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", rmtMenu);
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", rmtMenu); -- this one is used to add the actionEvents
end;

-- actionEvent stuffs.. (this one is called each time the vehicle is entered)
function rmtMenu.onRegisterActionEvents(self, isActiveForInput)
	local spec = self.spec_rmtMenu;
	spec.actionEvents = {}; -- needs this. Farmcon Example didn't have this. Doesn't work without this though.. 
	self:clearActionEventsTable(spec.actionEvents); -- not sure if we need to clear the table now that we just created it. I suppose you could create the table in onLoad, then it makes more sense

	-- add the actionEvents if vehicle is ready to have Inputs
	if self:getIsActive() then      
		-- shift up / shift down 
		local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.INTERACT, self, rmtMenu.RMT_MOUSE_BUTTON, true, true, false, true, nil);

	end;

end;

function rmtMenu:RMT_MOUSE_BUTTON(actionName, inputValue)
	if inputValue == 1 then
		self.spec_rmtMenu.mouseHeldDown = true;
		local hud = self.spec_rmtMenu.hud;
		if hud ~= nil and hud.isHovered then
			hud.mouseRelativePositionX = g_lastMousePosX - hud.posX;
			hud.mouseRelativePositionY = g_lastMousePosY - hud.posY;
			hud.isHeld = true;
		end;
	else
		self.spec_rmtMenu.mouseHeldDown = false;
		self.spec_rmtMenu.hud.isHeld = false;
	end;
end;

function rmtMenu:onLoad(savegame)
	self.spec_rmtMenu = {};
	
	local spec = self.spec_rmtMenu;
	
	if spec.hud == nil then
		spec.hud = {};
	end;

end;
function rmtMenu:onPostLoad(savegame)
	if self.hasRMT and savegame ~= nil then
		-- load settings from XML 
		local xmlFile = savegame.xmlFile

		local key1 = savegame.key..".FS19_realManualTransmission.rmtMenu.hudSettings"
		local hud = self.spec_rmtMenu.hud
		if hud ~= nil then
			hud.posX = Utils.getNoNil(getXMLFloat(xmlFile, key1.."#posX"), hud.posX);
			hud.posY = Utils.getNoNil(getXMLFloat(xmlFile, key1.."#posY"), hud.posY);
			
			hud.showHud = Utils.getNoNil(getXMLBool(xmlFile, key1.."#showHud"), hud.showHud);
			hud.showGear = Utils.getNoNil(getXMLBool(xmlFile, key1.."#showGear"), hud.showGear);
			hud.showRange = Utils.getNoNil(getXMLBool(xmlFile, key1.."#showRange"), hud.showRange);
			hud.showReverser = Utils.getNoNil(getXMLBool(xmlFile, key1.."#showReverser"), hud.showReverser);
			hud.showClutch = Utils.getNoNil(getXMLBool(xmlFile, key1.."#showClutch"), hud.showClutch);
			hud.showRpm = Utils.getNoNil(getXMLBool(xmlFile, key1.."#showRpm"), hud.showRpm);
			hud.showHandbrake = Utils.getNoNil(getXMLBool(xmlFile, key1.."#showHandbrake"), hud.showHandbrake);
			hud.showSpeed = Utils.getNoNil(getXMLBool(xmlFile, key1.."#showSpeed"), hud.showSpeed);
			hud.showLoad = Utils.getNoNil(getXMLBool(xmlFile, key1.."#showLoad"), hud.showLoad);
			
		end;
	end;
end;
function rmtMenu:saveToXMLFile(xmlFile, key)
	-- save settings to XML 
	if self.hasRMT then
		-- first, save all the hud settings 
		local key1 = key..".hudSettings";
		local hud = self.spec_rmtMenu.hud;
		if hud ~= nil then
			setXMLFloat(xmlFile, key1.."#posX", hud.posX);
			setXMLFloat(xmlFile, key1.."#posY", hud.posY);
			
			setXMLBool(xmlFile, key1.."#showHud", hud.showHud);
			setXMLBool(xmlFile, key1.."#showGear", hud.showGear);
			setXMLBool(xmlFile, key1.."#showRange", hud.showRange);
			setXMLBool(xmlFile, key1.."#showReverser", hud.showReverser);
			setXMLBool(xmlFile, key1.."#showClutch", hud.showClutch);
			setXMLBool(xmlFile, key1.."#showRpm", hud.showRpm);
			setXMLBool(xmlFile, key1.."#showHandbrake", hud.showHandbrake);
			setXMLBool(xmlFile, key1.."#showSpeed", hud.showSpeed);
			setXMLBool(xmlFile, key1.."#showLoad", hud.showLoad);
			
		end;
	end;
end;
	
function rmtMenu:onDraw() 

	local spec = self.spec_rmtMenu;
	
	if self.hasRMT and self.rmtIsOn then
		-- vehicle hud 
		if spec.hud ~= nil and spec.hud.showHud then
			local hud = spec.hud;
			local fb = self.spec_realManualTransmission;
			
			local y = hud.posY + 0.005;
			local x = hud.posX + 0.005;
			local addY = 0.02;
			
			setTextAlignment(RenderText.ALIGN_LEFT)
			
			if hud.showHandbrake then
				if fb.handBrake then
					renderText(x, y, 0.02, "Handbrake: ON");
				else
					renderText(x, y, 0.02, "Handbrake: OFF");
				end;
				y = y + addY;
			end;
			if hud.showGear then
				local spec = self.spec_rmtClassicTransmission;
				if spec.neutral then
					renderText(x, y, 0.02, "Gear: N");
				else
					renderText(x, y, 0.02, "Gear: "..tostring(spec.gears[spec.currentGear].name));	
				end;
				y =  y + addY;
			end;
			if hud.showRange then
				local spec = self.spec_rmtClassicTransmission;
				local rangeString = "Range: "
				local hasRange = false;
				if spec.rangeSet1 ~= nil then	
					rangeString = rangeString.." "..tostring(spec.rangeSet1.ranges[spec.currentRange1].name);
					hasRange = true;
				end;
				if spec.rangeSet2 ~= nil then
					rangeString = rangeString.." "..tostring(spec.rangeSet2.ranges[spec.currentRange2].name);
					hasRange = true;
				end;
				if spec.rangeSet3 ~= nil then
					rangeString = rangeString.." "..tostring(spec.rangeSet3.ranges[spec.currentRange3].name);
					hasRange = true;
				end;
				if hasRange then
					renderText(x, y, 0.02, rangeString);		
					y = y + addY;
				end;
			end;
			if hud.showReverser then
				if self.spec_rmtReverser ~= nil then
					local spec = self.spec_rmtReverser; 
					local revString = "Reverser: "
					if spec.isForward then
						revString = revString.."F";
						if not spec.wantForward then
							revString = revString.." ->R";
						end;
					else	
						revString = revString.."R";
						if spec.wantForward then
							revString = revString.." ->F";
						end;
					end;
					renderText(x, y, 0.02, revString);
					y = y + addY;
				end;
			end;
			if hud.showClutch then
				local clutchPercent = math.min(fb.clutchPercentManual, fb.clutchPercentAuto);
				renderText(x, y, 0.02, "Clutch: "..tostring(math.floor(clutchPercent*100)).."%");
				y = y + addY;
			end;
			if hud.showRpm then
				if self.isServer then
					renderText(x, y, 0.02, "RPM: "..tostring(math.floor(self.spec_realManualTransmission.lastRealRpm)));
				else
					renderText(x, y, 0.02, "RPM: "..tostring(math.floor(self.spec_motorized.motor.equalizedMotorRpm)));
				end;
				y = y + addY;
			end;
			if hud.showLoad then
				renderText(x, y, 0.02, "Load: "..tostring(math.floor(self.spec_motorized.smoothedLoadPercentage*100)).."%");
				y = y + addY;
			end;			
			if hud.showSpeed then
				renderText(x, y, 0.02, "Kmh: "..tostring(math.floor(fb.currentWantedSpeed*10)*0.1));
				y = y + addY;
			end;
			
			renderOverlay(g_currentMission.rmtMenu.background, hud.posX, hud.posY, hud.sizeX, y-hud.posY+0.01);
			
			if spec.isOn then
				-- check if the mouse is hovered over the HUD
				if g_lastMousePosX > hud.posX and g_lastMousePosX < (hud.posX+hud.sizeX) and g_lastMousePosY > hud.posY and g_lastMousePosY < (hud.posY+(y-hud.posY+0.01)) then
					hud.isHovered = true;
				else
					hud.isHovered = false;
				end;
				
				-- the hud is "held down" by the mouse so it needs to move along with the mouse position 
				if hud.isHeld then
				
					hud.posX = g_lastMousePosX - hud.mouseRelativePositionX;
					hud.posY = g_lastMousePosY - hud.mouseRelativePositionY;
				
				end;
			
			end;
		
		end;
	
	end;
end;




















