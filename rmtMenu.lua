-- by modelleicher
-- menu spec for fakebox 

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
		for _, button in pairs(self.spec_rmtMenu.buttons) do
			if button.isHovered then
				button.state = not button.state;
				if button.indexTable ~= nil then
					button.indexTable[button.indexString] = button.state;
				else
					self.spec_realManualTransmission[button.indexString] = button.state;
				end;
				self:synchMenuInput(button.synchId, button.state);
			end;
		end;
		for _, checkBox in pairs(self.spec_rmtMenu.checkBoxes) do
			if checkBox.isHovered then
				self:updateCheckBox(checkBox, not checkBox.state);
				self:synchMenuInput(checkBox.synchId, checkBox.state);
			end;
		end;
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

function rmtMenu:updateCheckBox(checkBox, state)
	checkBox.state = state;
	if checkBox.indexTable ~= nil then
		checkBox.indexTable[checkBox.indexString] = state;
	else
		self.spec_realManualTransmission[checkBox.indexString] = state;
	end;
	if checkBox.indexStringDefaultVar ~= nil then
		if checkBox.defaultValueOff ~= nil and state == false then
			if checkBox.defaultValueIndexTable ~= nil then
				checkBox.defaultValueIndexTable[checkBox.indexStringDefaultVar] = checkBox.defaultValueOff;
			else
				self.spec_realManualTransmission[checkBox.indexStringDefaultVar] = checkBox.defaultValueOff;
			end;
		elseif checkBox.defaultValueOn ~= nil and state == true then
			if checkBox.defaultValueIndexTable ~= nil then
				checkBox.defaultValueIndexTable[checkBox.indexStringDefaultVar] = checkBox.defaultValueOn;
			else
				self.spec_realManualTransmission[checkBox.indexStringDefaultVar] = checkBox.defaultValueOn;
			end;		
		end;
	end;
end;

function rmtMenu:synchMenuInput(synchId, state, noEventSend)
	synchMenuInputEvent.sendEvent(self, synchId, state, noEventSend);
	print("synchMenuInput: "..tostring(synchId).." "..tostring(state));
	if self.isServer then
		if synchId ~= nil and state ~= nil then
			for _, button in pairs(self.spec_rmtMenu.buttons) do
				if button.synchId == synchId then
					if button.indexTable ~= nil then
						button.indexTable[button.indexString] = state;
					else
						self.spec_realManualTransmission[button.indexString] = state;
					end;
				end;
			end;
			for _, checkBox in pairs(self.spec_rmtMenu.checkBoxes) do 
				if checkBox.synchId == synchId then
					self:updateCheckBox(checkBox, state);
				end;
			end;
		end;
	end;
end;
-- add checkBox function 
-- name = name, text is text shown next to checkBox.. pos and size is self explanatory 
-- indexString is the string value for the table index of the variable that is changing 
-- indexTable in case our variable isn't directly in self.spec_realManualTransmission we can specify the table here 
-- indexStringDefaultVar = we have an optional default variable that we want to set depending on checkbox state 
-- defaultValueOff = the value we want the indexStringDefaultVar to be when the checkbox is selected off 
-- defaultValueOn = the value we want the indexStringDefaultVar to be when the checkbox is selected on 
-- defaultValueIndexTable = if we want to use a particular index Table 
function rmtMenu:addCheckBox(name, text, sizeX, sizeY, posX, posY, indexString, indexTable, indexStringDefaultVar, defaultValueOff, defaultValueOn, defaultValueIndexTable)
	local checkBox = {};
	checkBox.name = name;
	checkBox.text = text;
	checkBox.sizeX = sizeX / g_screenAspectRatio;
	checkBox.sizeY = sizeY;
	checkBox.posX = posX;
	checkBox.posY = posY;
	
	
	checkBox.isHovered = false;	
	checkBox.indexString = indexString;	
	if indexTable ~= nil then
		checkBox.indexTable = indexTable;
	else	
		checkBox.indexTable = self.spec_realManualTransmission;
	end;
	
	if indexStringDefaultVar ~= nil then
		checkBox.indexStringDefaultVar = indexStringDefaultVar;
		if defaultValueOff ~= nil then
			checkBox.defaultValueOff = defaultValueOff;
		end;
		if defaultValueOn ~= nil then
			checkBox.defaultValueOn = defaultValueOn;
		end;
		if defaultValueIndexTable ~= nil then
			checkBox.defaultValueIndexTable = defaultValueIndexTable;
		else
			checkBox.defaultValueIndexTable = self.spec_realManualTransmission;
		end;
	end;
	
	checkBox.indexString = indexString;
	
	checkBox.state = checkBox.indexTable[indexString];
	
	self.spec_rmtMenu.synchIds = self.spec_rmtMenu.synchIds + 1;
	checkBox.synchId = self.spec_rmtMenu.synchIds;

	table.insert(self.spec_rmtMenu.checkBoxes, checkBox);	
end;

-- the same as the checkBox version 
function rmtMenu:addButton(name, text, sizeX, sizeY, posX, posY, indexString, indexTable)
	
	local button = {};
	button.name = name;
	button.text = text;
	button.sizeX = sizeX / g_screenAspectRatio;
	button.sizeY = sizeY;
	button.posX = posX;
	button.posY = posY;
	
	button.state = false;
	button.isHovered = false;
	button.isActive = false;
	if indexTable ~= nil then
		button.indexTable = indexTable;
	end;
	

	self.spec_rmtMenu.synchIds = self.spec_rmtMenu.synchIds + 1;
	checkBox.synchId = self.spec_rmtMenu.synchIds;	

	button.indexString = indexString;
	table.insert(self.spec_rmtMenu.buttons, button);
end;

function rmtMenu:onLoad(savegame)
	self.addCheckBox = rmtMenu.addCheckBox;
	self.addButton = rmtMenu.addButton;
	self.synchMenuInput = rmtMenu.synchMenuInput;
	self.updateCheckBox = rmtMenu.updateCheckBox;
	
	self.spec_rmtMenu = {};
	
	local spec = self.spec_rmtMenu;
	
	spec.buttons = {};
	spec.checkBoxes = {};
	
	if spec.hud == nil then
		spec.hud = {};
	end;

	spec.synchIds = 0;
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
			if hud.showGear and fb.gears ~= nil then
				if fb.neutral then
					renderText(x, y, 0.02, "Gear: N");
				else
					renderText(x, y, 0.02, "Gear: "..tostring(fb.gears[fb.currentGear].name));	
				end;
				y =  y + addY;
			end;
			if hud.showRange then
				local rangeString = "Range: "
				local hasRange = false;
				if fb.rangeSet1 ~= nil then	
					rangeString = rangeString.." "..tostring(fb.rangeSet1.ranges[fb.currentRange1].name);
					hasRange = true;
				end;
				if fb.rangeSet2 ~= nil then
					rangeString = rangeString.." "..tostring(fb.rangeSet2.ranges[fb.currentRange2].name);
					hasRange = true;
				end;
				if fb.rangeSet3 ~= nil then
					rangeString = rangeString.." "..tostring(fb.rangeSet3.ranges[fb.currentRange3].name);
					hasRange = true;
				end;
				if hasRange then
					renderText(x, y, 0.02, rangeString);		
					y = y + addY;
				end;
			end;
			if hud.showReverser then
				if fb.reverser ~= nil then
					local revString = "Reverser: "
					if fb.reverser.isForward then
						revString = revString.."F";
						if not fb.reverser.wantForward then
							revString = revString.." ->R";
						end;
					else	
						revString = revString.."R";
						if fb.reverser.wantForward then
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
				renderText(x, y, 0.02, "RPM: "..tostring(math.floor(self.spec_motorized.motor.equalizedMotorRpm)));
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
		
		
		if spec.isOn then
		
			
			
			local mouseX = g_lastMousePosX;
			local mouseY = g_lastMousePosY;
			
			renderOverlay(g_currentMission.rmtMenu.background, 0.2, 0.2, 0.6, 0.6);
			setTextAlignment(RenderText.ALIGN_CENTER)
			setTextBold(true)
			renderText(0.5, 0.77, 0.03, "Transmission Settings");
			--renderOverlay(g_currentMission.rmtMenu.button_active, 0.7, 0.2, 0.05, 0.05);
			--print(g_currentMission.rmtMenu.background);
			
			for _, button in pairs(spec.buttons) do
				
				-- check if we hover the button 
				if mouseX > button.posX and mouseX < (button.posX+button.sizeX) and mouseY > button.posY and mouseY < (button.posY+button.sizeY) then
					button.isHovered = true;
					renderOverlay(g_currentMission.rmtMenu.button_hover, button.posX, button.posY, button.sizeX, button.sizeY);
				else	
					button.isHovered = false;
				end;
				
				if button.isActive then
					renderOverlay(g_currentMission.rmtMenu.button_normal, button.posX, button.posY, button.sizeX, button.sizeY);
				else
					renderOverlay(g_currentMission.rmtMenu.button_active, button.posX, button.posY, button.sizeX, button.sizeY);
				end;
				
				if button.text ~= nil and button.text ~= "" then
					
				end;
				
			
			end;
			
			setTextAlignment(RenderText.ALIGN_LEFT)
			for _, checkBox in pairs(spec.checkBoxes) do
			
				-- check if we hover the button 
				if mouseX > checkBox.posX and mouseX < (checkBox.posX+checkBox.sizeX) and mouseY > checkBox.posY and mouseY < (checkBox.posY+checkBox.sizeY) then
					checkBox.isHovered = true;
					--print("is hovered");
				else	
					checkBox.isHovered = false;
				end;
				
				checkBox.state = checkBox.indexTable[checkBox.indexString];
				if checkBox.state then
					renderOverlay(g_currentMission.rmtMenu.checkbox_checked, checkBox.posX, checkBox.posY, checkBox.sizeX, checkBox.sizeY);
				else
					renderOverlay(g_currentMission.rmtMenu.checkbox_unchecked, checkBox.posX, checkBox.posY, checkBox.sizeX, checkBox.sizeY);
				end;
					
				
				if checkBox.text ~= nil and checkBox.text ~= "" then
					renderText(checkBox.posX+checkBox.sizeX, checkBox.posY+(checkBox.sizeY*0.25), checkBox.sizeY * 0.4, checkBox.text);
				end;
				
			end;
		
		end;
	
	end;
end;




















