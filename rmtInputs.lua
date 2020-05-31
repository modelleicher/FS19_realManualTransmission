-- by modelleicher
-- all input-related stuff is in this script

rmtInputs = {};

function rmtInputs.prerequisitesPresent(specializations)
    return true;
end;


function rmtInputs.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", rmtInputs); -- this one is used to add the actionEvents
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", rmtInputs); -- this one is used to add the actionEvents	
end;

function rmtInputs:onLoad(savegame)
	self.addRmtActionEvent = rmtInputs.addRmtActionEvent;
end;

-- actionEvent stuffs.. (this one is called each time the vehicle is entered)
function rmtInputs.onRegisterActionEvents(self, isActiveForInput, isActiveForInputIgnoreSelection)
	local spec = self.spec_realManualTransmission;
	spec.actionEvents = {}; -- needs this. Farmcon Example didn't have this. Doesn't work without this though.. 
	self:clearActionEventsTable(spec.actionEvents); -- not sure if we need to clear the table now that we just created it. I suppose you could create the table in onLoad, then it makes more sense

	-- add the actionEvents if vehicle is ready to have Inputs
	if isActiveForInputIgnoreSelection then
		-- non-specific keybindings, we want to use those even in vehicles without RMT 
		self:addRmtActionEvent("BUTTON_SINGLE_ACTION", "RMT_TOGGLE_ONOFF", "RMT_TOGGLE_ONOFF")	
		
		-- RMT specific keybindings, only add when vehicle has RMT 
		if self.hasRMT then
			
			-- all the basic inputs we add always 
			-- non-synchronized Inputs: 
			local actions = {"RMT_OPEN_MENU"}
			for i = 1, #actions do
				self:addRmtActionEvent("BUTTON_SINGLE_ACTION", actions[i], actions[i])
			end;	
			
			-- synchronized Inputs 
			-- basic ones 
			local actions = {"RMT_HANDBRAKE"}
			for i = 1, #actions do
				self:addRmtActionEvent("BUTTON_SINGLE_ACTION", actions[i], actions[i])
			end;	

			-- direct gear buttons
			if self.spec_rmtClassicTransmission.gears ~= nil then
				local actions = {"RMT_SHIFT_UP", "RMT_SHIFT_DOWN", "RMT_NEUTRAL", "RMT_SELECT_GEAR_1", "RMT_SELECT_GEAR_2", "RMT_SELECT_GEAR_3", "RMT_SELECT_GEAR_4", "RMT_SELECT_GEAR_5", "RMT_SELECT_GEAR_6", "RMT_SELECT_GEAR_7", "RMT_SELECT_GEAR_8"}
				for i = 1, #actions do
					self:addRmtActionEvent("BUTTON_DOUBLE_ACTION", actions[i], "UIP_SYNCH_GEARS")
				end;			
			end;			

			-- Reverser Buttons (only add them if we have a reverser)
			if self.spec_rmtReverser ~= nil then
				local actions = {"RMT_FORWARD", "RMT_REVERSE", "RMT_TOGGLE_REVERSER"}
				for i = 1, #actions do
					self:addRmtActionEvent("BUTTON_SINGLE_ACTION", actions[i], "UIP_SYNCH_REVERSER")
				end;
			end;		

			-- hand throttle 
			self:addRmtActionEvent("PRESSED_OR_AXIS", "RMT_HANDTHROTTLE_UP", "RMT_HANDTHROTTLE");
			self:addRmtActionEvent("PRESSED_OR_AXIS", "RMT_HANDTHROTTLE_DOWN", "RMT_HANDTHROTTLE");
			self:addRmtActionEvent("PRESSED_OR_AXIS", "RMT_HANDTHROTTLE_AXIS", "RMT_HANDTHROTTLE");

			-- Range up / range down 
			if self.spec_rmtClassicTransmission.rangeSet1 ~= nil then
				self:addRmtActionEvent("BUTTON_SINGLE_ACTION", "RMT_RANGE_UP1", "UIP_SYNCH_RANGES");
				self:addRmtActionEvent("BUTTON_SINGLE_ACTION", "RMT_RANGE_DOWN1", "UIP_SYNCH_RANGES");
				self:addRmtActionEvent("BUTTON_SINGLE_ACTION", "RMT_RANGE_TOGGLE1", "UIP_SYNCH_RANGES");

				self:addRmtActionEvent("BUTTON_DOUBLE_ACTION", "RMT_RANGE_DIRECT_1", "UIP_SYNCH_RANGES");
				self:addRmtActionEvent("BUTTON_DOUBLE_ACTION", "RMT_RANGE_DIRECT_2", "UIP_SYNCH_RANGES");
				self:addRmtActionEvent("BUTTON_DOUBLE_ACTION", "RMT_RANGE_DIRECT_3", "UIP_SYNCH_RANGES");
				self:addRmtActionEvent("BUTTON_DOUBLE_ACTION", "RMT_RANGE_DIRECT_4", "UIP_SYNCH_RANGES");
				self:addRmtActionEvent("BUTTON_DOUBLE_ACTION", "RMT_RANGE_DIRECT_5", "UIP_SYNCH_RANGES");
				self:addRmtActionEvent("BUTTON_DOUBLE_ACTION", "RMT_RANGE_DIRECT_6", "UIP_SYNCH_RANGES");																	
			end; 
			if self.spec_rmtClassicTransmission.rangeSet2 ~= nil then
				self:addRmtActionEvent("BUTTON_SINGLE_ACTION", "RMT_RANGE_UP2", "UIP_SYNCH_RANGES");
				self:addRmtActionEvent("BUTTON_SINGLE_ACTION", "RMT_RANGE_DOWN2", "UIP_SYNCH_RANGES");			
			end;
			if self.spec_rmtClassicTransmission.rangeSet3 ~= nil then
				self:addRmtActionEvent("BUTTON_SINGLE_ACTION", "RMT_RANGE_UP3", "UIP_SYNCH_RANGES");
				self:addRmtActionEvent("BUTTON_SINGLE_ACTION", "RMT_RANGE_DOWN3", "UIP_SYNCH_RANGES");
				self:addRmtActionEvent("BUTTON_SINGLE_ACTION", "RMT_RANGE_TOGGLE3", "UIP_SYNCH_RANGES");			
			end;
		
			-- clutch axis 
			self:addRmtActionEvent("PRESSED_OR_AXIS", "RMT_AXIS_CLUTCH", "actionEventClutch");
			self:addRmtActionEvent("BUTTON_DOUBLE_ACTION", "RMT_CLUTCH_BUTTON", "RMT_CLUTCH_BUTTON");
	
		end;
	end;
end;

function rmtInputs:addRmtActionEvent(type, inputAction, func, showHud)
	local spec = self.spec_realManualTransmission
	local _, actionEventId = nil;
	if type == "BUTTON_SINGLE_ACTION" then
		_ , actionEventId = self:addActionEvent(spec.actionEvents, InputAction[inputAction], self, rmtInputs[func], false, true, false, true);
	elseif type == "BUTTON_DOUBLE_ACTION" then
		_ , actionEventId = self:addActionEvent(spec.actionEvents, InputAction[inputAction], self, rmtInputs[func], true, true, false, true);
	elseif type == "PRESSED_OR_AXIS" then
		_ , actionEventId = self:addActionEvent(spec.actionEvents, InputAction[inputAction], self, rmtInputs[func], false, false, true, true);
	end;
	if not showHud then
		g_inputBinding:setActionEventTextVisibility(actionEventId, false)
	end;
end;

function rmtInputs:RMT_OPEN_MENU()
	if self.spec_rmtMenu ~= nil then
		self.spec_rmtMenu.isOn = not self.spec_rmtMenu.isOn;
		g_inputBinding:setShowMouseCursor(self.spec_rmtMenu.isOn)
		self.spec_enterable.cameras[self.spec_enterable.camIndex].isActivated = not self.spec_rmtMenu.isOn;
	end;
end;

-- Handbrake button 
function rmtInputs:RMT_HANDBRAKE(force, noEventSend)
	self:setHandBrake(not self.spec_realManualTransmission.handBrake)
end;

function rmtInputs:UIP_SYNCH_REVERSER(actionName, inputValue)
	--print("UIP_SYNCH_REVERSER called");
	if self.spec_rmtReverser ~= nil then
		print("UIP_SYNCH_REVERSER - reverser not nil");
		if actionName == "RMT_FORWARD" then
			self:selectReverser(true);
		elseif actionName == "RMT_REVERSE" then
			self:selectReverser(false);
		elseif actionName == "RMT_TOGGLE_REVERSER" then
			self:selectReverser(not self.spec_rmtReverser.isForward);
		end;
	end;
end;

-- clutch button 
function rmtInputs:RMT_CLUTCH_BUTTON(actionName, inputValue)
	self:processClutchInput(inputValue);
end;


-- direct gear selection 
function rmtInputs:UIP_SYNCH_GEARS(actionName, inputValue)
	local spec = self.spec_rmtClassicTransmission;
	local rmt = self.spec_realManualTransmission;
	local gearValue = 0; -- always start with 0 to not get nil errors in event 
	local sequentialDir = 0; 
	
	
	local stringEndNumber = tonumber(actionName:sub(actionName:len())) -- convert the actionName string to a gear number 
	if stringEndNumber ~= nil then
		gearValue = stringEndNumber;
		if inputValue == 0 and rmt.buttonReleaseNeutral then -- if actionName is neutral or we released the gear-button, go neutral 
			gearValue = -1;
		end;	
	end;

	if inputValue > 0.5 then
		if actionName == "RMT_SHIFT_UP" then -- take care of the sequential shift buttons 
			sequentialDir = 1;
		elseif actionName == "RMT_SHIFT_DOWN" then
			sequentialDir = -1;
		elseif actionName == "RMT_NEUTRAL" then 
			gearValue = -1;
		end;
	end;


	--print("UIP_SYNCH_GEARS: actionName: "..tostring(actionName).." gearValue:"..tostring(gearValue).." sequentialDir:"..tostring(sequentialDir));
	
	if gearValue ~= 0 or sequentialDir ~= 0 then -- only continue if something changed 
	
		if rmt.switchGearRangeMapping then -- take care of range/gear mapping swap here because its client-side 
			self:processRangeInputs(sequentialDir, 1, gearValue);
		else
			self:processGearInputs(gearValue, sequentialDir);
		end;
	
	end;
end;

function rmtInputs:UIP_SYNCH_RANGES(actionName, inputValue)
	--print("UIP_SYNCH_RANGES "..tostring(actionName).." - "..tostring(inputValue));
	local spec = self.spec_rmtClassicTransmission;
	local rmt = self.spec_realManualTransmission;
	local dir = 0;
	local index = 1;
	local force = nil;
	if inputValue > 0.5 then
		if actionName == "RMT_RANGE_UP1" then
			dir = 1;
		elseif actionName == "RMT_RANGE_DOWN1" then
			dir = -1;
		elseif actionName == "RMT_RANGE_UP2" then
			dir = 1;
			index = 2;
		elseif actionName == "RMT_RANGE_DOWN2" then
			dir = -1;
			index = 2;
		elseif actionName == "RMT_RANGE_UP3" then
			dir = 1;
			index = 3;
		elseif actionName == "RMT_RANGE_DOWN3" then
			dir = -1;
			index = 3;
		elseif actionName == "RMT_RANGE_TOGGLE1" then
			if spec.currentRange1 ~= nil and spec.currentRange1 < spec.rangeSet1.numberOfRanges then
				dir = spec.rangeSet1.numberOfRanges;
				index = 1;
			elseif spec.currentRange1 == spec.rangeSet1.numberOfRanges then
				dir = -spec.rangeSet1.numberOfRanges;
				index = 1;
			end;
		elseif actionName == "RMT_RANGE_TOGGLE2" then
			if spec.currentRange2 == 1 then
				dir = spec.rangeSet2.numberOfRanges;
				index = 2;
			elseif spec.currentRange2 == spec.rangeSet2.numberOfRanges then
				dir = -spec.rangeSet2.numberOfRanges;
				index = 2;
			end;		
		elseif actionName == "RMT_RANGE_TOGGLE3" then
			if spec.currentRange3 == 1 then
				dir = spec.rangeSet2.numberOfRanges;
				index = 3;
			elseif spec.currentRange3 == spec.rangeSet3.numberOfRanges then
				dir = -spec.rangeSet3.numberOfRanges;
				index = 3;
			end;	
		elseif actionName == "RMT_RANGE_DIRECT_1" then
			force = 1;
			index = 1;
		elseif actionName == "RMT_RANGE_DIRECT_2" then
			force = 2;
			index = 1;	
		elseif actionName == "RMT_RANGE_DIRECT_3" then
			force = 3;
			index = 1;	
		elseif actionName == "RMT_RANGE_DIRECT_4" then
			force = 4;
			index = 1;	
		elseif actionName == "RMT_RANGE_DIRECT_5" then
			force = 5;
			index = 1;	
		elseif actionName == "RMT_RANGE_DIRECT_6" then
			force = 6;
			index = 1;	
		end;										
	end;
	
	if dir ~= 0 or force ~= nil then -- only continue if something changed 
		--print("UIP_SYNCH_RANGES dir: "..tostring(dir).." index:"..tostring(index));
		if not rmt.switchGearRangeMapping then
			self:processRangeInputs(dir, index, force);
		else
			self:processGearInputs(force, dir);
		end;
	end;
end;


-- Clutch Pedal Action Input (inverse of input value since pressed = 0, not pressed = 1);
function rmtInputs:actionEventClutch(actionName, inputValue, callbackState, isAnalog)
	self.spec_realManualTransmission.clutchPercentManual = 1 - inputValue;
end;

-- hand throttle.. not an ideal way of doing it, performancewise..  I think.
function rmtInputs:RMT_HANDTHROTTLE(actionName, inputValue)	
	local spec = self.spec_realManualTransmission;
	spec.handThrottleDown = false;
	spec.handThrottleUp = false;	
	if actionName == "RMT_HANDTHROTTLE_AXIS" then
		spec.handThrottlePercent = inputValue;
	elseif actionName == "RMT_HANDTHROTTLE_UP" and inputValue == 1 then
		spec.handThrottleUp = true; 
	elseif actionName == "RMT_HANDTHROTTLE_DOWN" and inputValue == 1 then
		spec.handThrottleDown = true;
	end;
end;

-- button to toggle RMT on or off
function rmtInputs:RMT_TOGGLE_ONOFF(actionName, inputValue)
	self:processToggleOnOff(nil, true);
end;


