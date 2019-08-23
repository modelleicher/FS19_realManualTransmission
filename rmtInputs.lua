-- by modelleicher

rmtInputs = {};

function rmtInputs.prerequisitesPresent(specializations)
    return true;
end;


function rmtInputs.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", rmtInputs); -- this one is used to add the actionEvents
end;

-- actionEvent stuffs.. (this one is called each time the vehicle is entered)
function rmtInputs.onRegisterActionEvents(self, isActiveForInput, isActiveForInputIgnoreSelection)
	local spec = self.spec_realManualTransmission;
	spec.actionEvents = {}; -- needs this. Farmcon Example didn't have this. Doesn't work without this though.. 
	self:clearActionEventsTable(spec.actionEvents); -- not sure if we need to clear the table now that we just created it. I suppose you could create the table in onLoad, then it makes more sense

	-- add the actionEvents if vehicle is ready to have Inputs
	if isActiveForInputIgnoreSelection then
		-- non-specific keybindings, we want to use those even in vehicles without RMT 
		local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_TOGGLE_ONOFF, self, rmtInputs.RMT_TOGGLE_ONOFF, false, true, false, true, nil);
		g_inputBinding:setActionEventTextVisibility(actionEventId, false)	
		
		-- RMT specific keybindings, only add when vehicle has RMT 
		if self.hasRMT then
			
			-- all the basic inputs we add always 
			-- non-synchronized Inputs: 
			local actions = {"RMT_OPEN_MENU"}
			for i = 1, #actions do
				local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction[tostring(actions[i])], self, rmtInputs[tostring(actions[i])], false, true, false, true, nil);
				g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			end;	
			
			-- synchronized Inputs 
			-- basic ones 
			local actions = {"RMT_HANDBRAKE"}
			for i = 1, #actions do
				local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction[tostring(actions[i])], self, rmtInputs[tostring(actions[i])], false, true, false, true, nil);
				g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			end;	

			-- direct gear buttons
			if spec.gears ~= nil then
				local actions = {"RMT_SHIFT_UP", "RMT_SHIFT_DOWN", "RMT_NEUTRAL", "RMT_SELECT_GEAR_1", "RMT_SELECT_GEAR_2", "RMT_SELECT_GEAR_3", "RMT_SELECT_GEAR_4", "RMT_SELECT_GEAR_5", "RMT_SELECT_GEAR_6", "RMT_SELECT_GEAR_7", "RMT_SELECT_GEAR_8"}
				for i = 1, #actions do
					local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction[tostring(actions[i])], self, rmtInputs.UIP_SYNCH_GEARS, true, true, false, true, nil);
					g_inputBinding:setActionEventTextVisibility(actionEventId, false)
				end;			
			end;			

			-- Reverser Buttons (only add them if we have a reverser)
			if spec.reverser ~= nil then
				local actions = {"RMT_FORWARD", "RMT_REVERSE", "RMT_TOGGLE_REVERSER"}
				for i = 1, #actions do
					local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction[tostring(actions[i])], self, rmtInputs.UIP_SYNCH_REVERSER, false, true, false, true, nil);
					g_inputBinding:setActionEventTextVisibility(actionEventId, false)
				end;
			end;		

			-- hand throttle 
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_HANDTHROTTLE_UP, self, rmtInputs.RMT_HANDTHROTTLE, false, false, true, true, nil);
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_HANDTHROTTLE_DOWN, self, rmtInputs.RMT_HANDTHROTTLE, false, false, true, true, nil);
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_HANDTHROTTLE_AXIS, self, rmtInputs.RMT_HANDTHROTTLE, false, false, true, true, nil);
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			
			-- Range up / range down 
			if spec.rangeSet1 ~= nil then
				local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_RANGE_UP1, self, rmtInputs.UIP_SYNCH_RANGES, false, true, false, true, nil);
				g_inputBinding:setActionEventTextVisibility(actionEventId, false)
				local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_RANGE_DOWN1, self, rmtInputs.UIP_SYNCH_RANGES, false, true, false, true, nil);
				g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			end;
			if spec.rangeSet2 ~= nil then
				local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_RANGE_UP2, self, rmtInputs.UIP_SYNCH_RANGES, false, true, false, true, nil);
				g_inputBinding:setActionEventTextVisibility(actionEventId, false)
				local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_RANGE_DOWN2, self, rmtInputs.UIP_SYNCH_RANGES, false, true, false, true, nil);
				g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			end;
			if spec.rangeSet3 ~= nil then
				local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_RANGE_UP3, self, rmtInputs.UIP_SYNCH_RANGES, false, true, false, true, nil);
				g_inputBinding:setActionEventTextVisibility(actionEventId, false)
				local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_RANGE_DOWN3, self, rmtInputs.UIP_SYNCH_RANGES, false, true, false, true, nil);	
				g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			end;
		
			-- clutch axis 
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_AXIS_CLUTCH, self, rmtInputs.actionEventClutch, false, false, true, true)
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_CLUTCH_BUTTON, self, rmtInputs.RMT_CLUTCH_BUTTON, true, true, false, true, nil);
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)			

	
		end;
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
	if self.spec_realManualTransmission.reverser ~= nil then
		--print("UIP_SYNCH_REVERSER - reverser not nil");
		if actionName == "RMT_FORWARD" then
			self:selectReverser(true);
		elseif actionName == "RMT_REVERSE" then
			self:selectReverser(false);
		elseif actionName == "RMT_TOGGLE_REVERSER" then
			self:selectReverser(not self.spec_realManualTransmission.reverser.isForward);
		end;
	end;
end;

-- clutch button 
function rmtInputs:RMT_CLUTCH_BUTTON(actionName, inputValue)
	self:processClutchInput(inputValue);
end;


-- direct gear selection 
function rmtInputs:UIP_SYNCH_GEARS(actionName, inputValue)
	local spec = self.spec_realManualTransmission;
	local gearValue = 0; -- always start with 0 to not get nil errors in event 
	local sequentialDir = 0; 
	
	
	local stringEndNumber = tonumber(actionName:sub(actionName:len())) -- convert the actionName string to a gear number 
	if stringEndNumber ~= nil then
		gearValue = stringEndNumber;
		if inputValue == 0 and spec.buttonReleaseNeutral then -- if actionName is neutral or we released the gear-button, go neutral 
			gearValue = -1;
		end;	
	end;

	if inputValue == 1 then
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
	
		if spec.switchGearRangeMapping then -- take care of range/gear mapping swap here because its client-side 
			self:processRangeInputs(sequentialDir, 1, gearValue);
		else
			self:processGearInputs(gearValue, sequentialDir);
		end;
	
	end;
end;

function rmtInputs:UIP_SYNCH_RANGES(actionName, inputValue)
	--print("UIP_SYNCH_RANGES "..tostring(actionName).." - "..tostring(inputValue));
	local spec = self.spec_realManualTransmission;
	local dir = 0;
	local index = 1;
	if inputValue == 1 then
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
		end;
	end;
	
	if dir ~= 0 then -- only continue if something changed 
		--print("UIP_SYNCH_RANGES dir: "..tostring(dir).." index:"..tostring(index));
		if not spec.switchGearRangeMapping then
			self:processRangeInputs(dir, index, 0);
		else
			self:processGearInputs(0, dir);
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


