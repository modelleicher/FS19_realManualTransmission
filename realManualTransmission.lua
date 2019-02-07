-- by modelleicher
-- temporary end goal: working manual gearbox with clutch, possibly support for full powershift transmissions.
-- start date: 08.01.2019
-- release Beta on Github date: 03.02.2019

-- Changelog:
-- V 0.4.0.4 ###
	-- fixed hud bug where rangeSet2 and rangeSet3 didn't display 
	-- added new disableRange / disableGear system to disable / lock out certain ranges or gears in certain ranges (to do, add warning messages)
-- V 0.4.0.3 ###
	-- fixed enginebrake when handthrottle is used 
	-- fixed "no brake" bug when engine is stalled 
-- V 0.4.0.2 ###
	-- added Input Mapping to turn RMT on/off per vehicle 
	-- turns itself off automatically when AI is hired 
-- V 0.4.0.1 ###
	-- removed debugPrints I forgot to remove 
	-- added Utils.getNoNil for reverser Settings values 
-- V 0.4.0.0 ###
	-- change in version numbers, we're on Github now!
	-- more smoothing of motorLoad 
	-- changed how we check if engineBrake is in effect 
	-- a few pieces of remaining unneeded code deleted 
	-- let the bugreports roll in.. :( 
-- V 0.0.3.9 ###
	-- added smoothing via table and average values for motorload percentage since smoothing like Giants does it doesn't work if one value is 0
-- V 0.0.3.8 ###
	-- fixed all the stuff I broke when testing the last 2 versions.. 
	-- different variable to calculate engine brake 
-- V 0.0.3.7 ###
	-- added clutch influence on max clutch torque and max acceleration altough this doesn't seem to do much. Seems to make the vel acc spike a little less when clutching slowly 
-- V 0.0.3.6 ###
	-- many versions.. one changelog. Nothing changed. Its all still stupid.. (trying to figure out the RPM and vel acceleration spike bug)
-- V 0.0.3.5 ###
	-- renamed everything realManualTransmission / RMT fully now
	-- XML configs are now realManualTransmission instead of fakeBox
-- V 0.0.3.4 ###
	-- chasing bugs.. 
-- V 0.0.3.3 ###
	-- redone the way final acceleration is calculated, now 50% pedal means 50% rpm and exactly that
	-- fixed the way hand throttle is working (see above)
-- V 0.0.3.2 ### 
	-- fixed rpm spike when clutching in (or at least made it less)
	-- fixed basegameConfigs loading 
	-- redone engine brake, should be way better now 
-- V 0.0.3.1 ###
	-- fixed disableInRangeSetX 
-- V 0.0.3.0 ###
	-- gearRatio is set to 1 when in neutral or clutch fully pressed so it doesn't fake-brake when changing gears 
-- V 0.0.2.9
	-- added hand throttle 
-- V 0.0.2.8 ###
	-- settings and hud position is now saved and loaded in the savegame 
-- V 0.0.2.7 ### 
	-- hud moveable with mouse
	-- basegameConfigs.xml added to add configs for baseGame vehicles.. Its stupid though because sounds are stupid 
	-- no-brake below 1kph bug fixed 
	-- engine-brakeforce calculation updated, still finetuning to do about the base value 
	-- disableInRanges bug fixed where you can stay in a disabled gear when shifting into that range with the gear engaged. Now you get gear -> neutral if you shift into a range this gear is disabled in 
-- V 0.0.2.6 reworked clutch, changed stuff.. I hate this changelog
-- V 0.0.2.0 added GUI/HUD for settings, added Reverser 
-- V 0.0.1.9 fixing ranges, fixing minor things 
-- V 0.0.1.8 adding of automatic clutch for ranges, fixing powershift ranges 
-- V 0.0.1.7 adding of automatic clutch opening at low rpm 
-- V 0.0.1.6 adding of automatic clutch for gearchanges 
-- V 0.0.1.5 bugfixes
-- V 0.0.1.4 major rewrite and future-proofing of gear and range selection
--           and possible gear and range config values 
-- V 0.0.1.3 added removal of all braking if we don't want to brake (still auto-brakes in reverse :( )
-- V 0.0.1.2 minor bugfixes 
-- V 0.0.1.1 added reverse drive
-- V 0.0.1.0 first internal release to testing
-- V 0.0.0.9 initial implementation 

--[[
	<realManualTransmission finalRatio="1" switchGearRangeMapping="true" >
		<gears defaultGear="1" powerShift="false" >
			<gear speed="5.4" name="1" />
			<gear speed="9.0" name="2" />
			<gear speed="13.4" name="3" />
			<gear speed="20.9" name="4" />
			<gear speed="30.7" name="5" />
			<gear speed="50.0" name="6" />
		</gears>
		
		<rangeSet1 powerShift="true" defaultRange="2" hasNeutralPosition="false" >
			<range ratio="0.512" name="I" />
			<range ratio="0.612" name="II" />
			<range ratio="0.72" name="III" />
			<range ratio="1" name="IV" >
				<disableGears gears="1 2" disableType="lock" />
				<disableRangesSet1 ranges="1" disableType="neutral" />
			</range>
		</rangeSet1>
		
		<rangeSet2 powerShift="false" defaultRange="2">
			<range ratio="0.5" name="LO" />
			<range ratio="1" name="HI" />
		</rangeSet2>
		
		<rangeSet3 powerShift="false" defaultRange="2">
			<range ratio="1" name="R" isReverse="true" />
			<range ratio="1" name="V" />
		</rangeSet3>
		
		<reverser type="normal" > <!-- normal or preselect -->
			<ratios forward="1" reverse="1" />
			<settings brakeAggressionBias="1" clutchTime="500" />
		</reverser>	
		
	</realManualTransmission>	
]]



realManualTransmission = {};

function realManualTransmission.prerequisitesPresent(specializations)
    return true;
end;


function realManualTransmission.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", realManualTransmission);
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", realManualTransmission);
	SpecializationUtil.registerEventListener(vehicleType, "saveToXMLFile", realManualTransmission);
	SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", realManualTransmission);
	
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", realManualTransmission); -- this one is used to add the actionEvents
end;

-- actionEvent stuffs.. (this one is called each time the vehicle is entered)
function realManualTransmission.onRegisterActionEvents(self, isActiveForInput)
	local spec = self.spec_realManualTransmission;
	spec.actionEvents = {}; -- needs this. Farmcon Example didn't have this. Doesn't work without this though.. 
	self:clearActionEventsTable(spec.actionEvents); -- not sure if we need to clear the table now that we just created it. I suppose you could create the table in onLoad, then it makes more sense

	-- add the actionEvents if vehicle is ready to have Inputs
	if  self:getIsActive() then
		-- non-specific keybindings, we want to use those even in vehicles without RMT 
		-- Handbrake Button 
		local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_HANDBRAKE, self, realManualTransmission.RMT_HANDBRAKE, false, true, false, true, nil);
		g_inputBinding:setActionEventTextVisibility(actionEventId, false)	

		-- Reverser Buttons 
		local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_FORWARD, self, realManualTransmission.RMT_FORWARD, false, true, false, true, nil);
		g_inputBinding:setActionEventTextVisibility(actionEventId, false)
		local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_REVERSE, self, realManualTransmission.RMT_REVERSE, false, true, false, true, nil);
		g_inputBinding:setActionEventTextVisibility(actionEventId, false)
		local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_TOGGLE_REVERSER, self, realManualTransmission.RMT_TOGGLE_REVERSER, false, true, false, true, nil);
		g_inputBinding:setActionEventTextVisibility(actionEventId, false)		
		
		-- RMT specific keybindings, only add when vehicle has RMT 
		if self.hasRMT then
			-- shift up / shift down 
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_SHIFT_UP, self, realManualTransmission.RMT_SHIFT_UP, false, true, false, true, nil);
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_SHIFT_DOWN, self, realManualTransmission.RMT_SHIFT_DOWN, false, true, false, true, nil);
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			
			-- open menu
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_OPEN_MENU, self, realManualTransmission.RMT_OPEN_MENU, false, true, false, true, nil);
			
			-- toggle RMT on/off 
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_TOGGLE_ONOFF, self, realManualTransmission.RMT_TOGGLE_ONOFF, false, true, false, true, nil);
	
			-- hand throttle 
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_HANDTHROTTLE_UP, self, realManualTransmission.RMT_HANDTHROTTLE, false, false, true, true, nil);
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_HANDTHROTTLE_DOWN, self, realManualTransmission.RMT_HANDTHROTTLE, false, false, true, true, nil);
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_HANDTHROTTLE_AXIS, self, realManualTransmission.RMT_HANDTHROTTLE, false, false, true, true, nil);
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			
			-- Range up / range down 
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_RANGE_UP1, self, realManualTransmission.RMT_RANGE_UP1, false, true, false, true, nil);
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_RANGE_DOWN1, self, realManualTransmission.RMT_RANGE_DOWN1, false, true, false, true, nil);
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_RANGE_UP2, self, realManualTransmission.RMT_RANGE_UP2, false, true, false, true, nil);
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_RANGE_DOWN2, self, realManualTransmission.RMT_RANGE_DOWN2, false, true, false, true, nil);
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_RANGE_UP3, self, realManualTransmission.RMT_RANGE_UP3, false, true, false, true, nil);
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_RANGE_DOWN3, self, realManualTransmission.RMT_RANGE_DOWN3, false, true, false, true, nil);	
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
		
			-- clutch axis 
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_AXIS_CLUTCH, self, realManualTransmission.actionEventClutch, false, false, true, true)
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			-- clutch button 
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_CLUTCH_BUTTON, self, realManualTransmission.RMT_CLUTCH_BUTTON, true, true, false, true)
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			
			-- neutral button 
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_NEUTRAL, self, realManualTransmission.RMT_NEUTRAL, false, true, false, true)
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			
			-- direct gear buttons
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_SELECT_GEAR_1, self, realManualTransmission.RMT_SELECT_GEAR_1, true, true, false, true, nil);	
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)		
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_SELECT_GEAR_2, self, realManualTransmission.RMT_SELECT_GEAR_2, true, true, false, true, nil);	
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_SELECT_GEAR_3, self, realManualTransmission.RMT_SELECT_GEAR_3, true, true, false, true, nil);		
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_SELECT_GEAR_4, self, realManualTransmission.RMT_SELECT_GEAR_4, true, true, false, true, nil);		
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_SELECT_GEAR_5, self, realManualTransmission.RMT_SELECT_GEAR_5, true, true, false, true, nil);		
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_SELECT_GEAR_6, self, realManualTransmission.RMT_SELECT_GEAR_6, true, true, false, true, nil);		
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_SELECT_GEAR_7, self, realManualTransmission.RMT_SELECT_GEAR_7, true, true, false, true, nil);		
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.RMT_SELECT_GEAR_8, self, realManualTransmission.RMT_SELECT_GEAR_8, true, true, false, true, nil);		
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)
		end;
	end;
end;




-- Handbrake button 
function realManualTransmission:RMT_OPEN_MENU()
	if self.spec_rmtMenu ~= nil then
		self.spec_rmtMenu.isOn = not self.spec_rmtMenu.isOn;
		g_inputBinding:setShowMouseCursor(self.spec_rmtMenu.isOn)
		self.spec_enterable.cameras[self.spec_enterable.camIndex].isActivated = not self.spec_rmtMenu.isOn;
	end;
end;

-- Handbrake button 
function realManualTransmission:RMT_HANDBRAKE()
	self.spec_realManualTransmission.handBrake = not self.spec_realManualTransmission.handBrake;
end;
-- Reverser button functions
-- check if we have reverser, then use that
-- if we don't have reverser, check if we have a reverse group, then use that 
-- to do, implement maxSpeed 
function realManualTransmission:RMT_FORWARD()
	if self.spec_realManualTransmission.reverser ~= nil then
		self:selectReverser(true);
	end;
end;
function realManualTransmission:RMT_REVERSE()
	if self.spec_realManualTransmission.reverser ~= nil then
		self:selectReverser(false);
	end;
end;
function realManualTransmission:RMT_TOGGLE_REVERSER()
	if self.spec_realManualTransmission.reverser ~= nil then
		self:selectReverser(not self.spec_realManualTransmission.reverser.isForward);
	end;
end;
-- clutch button 
function realManualTransmission:RMT_CLUTCH_BUTTON(actionName, inputValue)
	local spec = self.spec_realManualTransmission;
	if inputValue == 1 then 
		spec.automaticClutch.wantOpen = true; 
		spec.automaticClutch.timer = spec.automaticClutch.openTime; -- put openTime in timer 
		spec.automaticClutch.timerMax = spec.automaticClutch.timer; -- store the max timer value, we need that later 
		spec.automaticClutch.wantedGear = nil; -- no wanted gear, we just want to open the clutch  
		spec.automaticClutch.preventClosing = true;
	elseif inputValue == 0 then
		if not spec.automaticClutch.openingAtLowRPMTriggered then -- check if we don't hold the clutch open due to minRpm automatic opening already, in that case don't close it again.
			spec.automaticClutch.preventClosing = false;
		end;
	end;
end;

-- direct gear selection 
function realManualTransmission:RMT_SELECT_GEAR_1(actionName, inputValue)
	self:processGearInputs(1, inputValue);
end;
function realManualTransmission:RMT_SELECT_GEAR_2(actionName, inputValue)
	self:processGearInputs(2, inputValue);	
end;
function realManualTransmission:RMT_SELECT_GEAR_3(actionName, inputValue)
	self:processGearInputs(3, inputValue);	
end;
function realManualTransmission:RMT_SELECT_GEAR_4(actionName, inputValue)
	self:processGearInputs(4, inputValue);
end;
function realManualTransmission:RMT_SELECT_GEAR_5(actionName, inputValue)
	self:processGearInputs(5, inputValue);
end;
function realManualTransmission:RMT_SELECT_GEAR_6(actionName, inputValue)
	self:processGearInputs(6, inputValue);	
end;
function realManualTransmission:RMT_SELECT_GEAR_7(actionName, inputValue)
	self:processGearInputs(7, inputValue);	
end;
function realManualTransmission:RMT_SELECT_GEAR_8(actionName, inputValue)
	self:processGearInputs(8, inputValue);	
end;
function realManualTransmission:RMT_NEUTRAL(actionName, inputValue)
	self:processGearInputs(-1, inputValue);	
end;

-- shift up/down and range up/down functions 
function realManualTransmission:RMT_SHIFT_UP()
	if not self.spec_realManualTransmission.switchGearRangeMapping then
		--self:selectGear(self.spec_realManualTransmission.currentGear + 1, inputValue, true);
		self:processGearInputs(nil, nil, true);
	else
		if self.spec_realManualTransmission.rangeSet1 ~= nil then
			self:selectRange(self.spec_realManualTransmission.currentRange1 + 1, 1, inputValue);
		end;
	end;
end;
function realManualTransmission:RMT_SHIFT_DOWN()
	if not self.spec_realManualTransmission.switchGearRangeMapping then
		self:processGearInputs(nil, nil, false);
	else
		if self.spec_realManualTransmission.rangeSet1 ~= nil then
			self:selectRange(self.spec_realManualTransmission.currentRange1 - 1, 1, inputValue);
		end;
	end;
end;
function realManualTransmission:RMT_RANGE_UP1(actionName, inputValue)
	local spec = self.spec_realManualTransmission;
	if not spec.switchGearRangeMapping then
		if spec.rangeSet1 ~= nil then
			self:selectRange(spec.currentRange1 + 1, 1, inputValue);
		end;
	else
		self:processGearInputs(nil, nil, true);
	end;
end;
function realManualTransmission:RMT_RANGE_DOWN1()
	local spec = self.spec_realManualTransmission;
	if not spec.switchGearRangeMapping then
		if spec.rangeSet1 ~= nil then
			self:selectRange(spec.currentRange1 - 1, 1, inputValue);	
		end;
	else
		self:processGearInputs(nil, nil, false);
	end;
end;
function realManualTransmission:RMT_RANGE_UP2(actionName, inputValue)
	local spec = self.spec_realManualTransmission;
	if spec.rangeSet2 ~= nil then
		self:selectRange(spec.currentRange2 + 1, 2, inputValue);
	end;
end;
function realManualTransmission:RMT_RANGE_DOWN2()
	local spec = self.spec_realManualTransmission;
	if spec.rangeSet2 ~= nil then	
		self:selectRange(spec.currentRange2 - 1, 2, inputValue);	
	end;
end;
function realManualTransmission:RMT_RANGE_UP3(actionName, inputValue)
	local spec = self.spec_realManualTransmission;
	if spec.rangeSet3 ~= nil then	
		self:selectRange(spec.currentRange3 + 1, 3, inputValue);
	end;		
end;
function realManualTransmission:RMT_RANGE_DOWN3()
	local spec = self.spec_realManualTransmission;
	if spec.rangeSet3 ~= nil then
		self:selectRange(spec.currentRange3 - 1, 3, inputValue);
	end;
end;
-- Clutch Pedal Action Input (inverse of input value since pressed = 0, not pressed = 1);
function realManualTransmission:actionEventClutch(actionName, inputValue, callbackState, isAnalog)
	self.spec_realManualTransmission.clutchPercentManual = 1 - inputValue;
end;

-- hand throttle.. not an ideal way of doing it, performancewise..  I think.
function realManualTransmission:RMT_HANDTHROTTLE(actionName, inputValue)	
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
function realManualTransmission:RMT_TOGGLE_ONOFF(actionName, inputValue)
	if self.spec_realManualTransmission ~= nil then
		if self.hasRMT then
			self.rmtIsOn = not self.rmtIsOn;
		end;
	end;
end;

-- using tables and average values to smooth stuff 
-- this function adds/fills the initial table with a default value to the given depth 
function realManualTransmission:addSmoothingTable(depth, default)
	local smoothingTable = {}
	for i = 1, depth do
		smoothingTable[i] = default;
	end;
	return smoothingTable; -- return the defailt table 
end;

-- this function returns the average of the given table and optionally adds a new Value to it 
function realManualTransmission:getSmoothingTableAverage(smoothingTable, addedValue)
	if addedValue ~= nil then
		for i = 2, #smoothingTable do -- shift over each value to the previous spot
			smoothingTable[i-1] = smoothingTable[i];
		end;
		smoothingTable[#smoothingTable] = addedValue; -- add new value into last spot 
	end;
	local average = 0;
	for i = 1, #smoothingTable do
		average = average + smoothingTable[i];
	end;
	average = average / #smoothingTable;
	return average;
end;
--
--
function realManualTransmission:onLoad(savegame)

	self.loadGears = realManualTransmission.loadGears;
	self.loadRanges = realManualTransmission.loadRanges;
	self.selectGear = realManualTransmission.selectGear;
	self.selectRange = realManualTransmission.selectRange;
	self.selectReverser = realManualTransmission.selectReverser;
	self.loadFromXML = realManualTransmission.loadFromXML;
	self.processGearInputs = realManualTransmission.processGearInputs;
	self.returnRpmNonClamped = realManualTransmission.returnRpmNonClamped;
	self.addSmoothingTable = realManualTransmission.addSmoothingTable;
	self.getSmoothingTableAverage = realManualTransmission.getSmoothingTableAverage;
	
	self.hasRMT = false;
	self.rmtIsOn = false;
	


	self.spec_realManualTransmission = {};  -- creating the table where all the variables are stored in
	local spec = self.spec_realManualTransmission; -- this looks different to the example on the farmCon video. didn't work the other way though I assume mistake in their presentation

	local xmlFile = self.xmlFile;
	
	-- check if the vehicle has realManualTransmission XML entries
	
	-- self.configFilename 
	-- baseDirectory :: C:/Users/Admin/Documents/My Games/FarmingSimulator2019/mods/FS19_deutzAgroStar661/
	-- customEnvironment = FS19_modname
	
	-- check if this vehicle exists in basegameConfigs 
	local configFile = StringUtil.splitString("/", self.configFileName);
	local baseDirectory = StringUtil.splitString("/", self.baseDirectory);
	local basegameConfigsXML = g_currentMission.rmtGlobals.basegameConfigsXML;
	
	if self.baseDirectory == "" then -- is no mod 
		print(tostring(configFile[#configFile]).." is not a mod!");
		local i = 0;
		while true do
			local check = getXMLString(basegameConfigsXML, "basegameConfigs.realManualTransmission("..i..")#configFile");
			if check == configFile[#configFile] then
				self.hasRMT = true;
				self:loadFromXML(basegameConfigsXML, "basegameConfigs.", i);
				self.rmtIsOn = true;
				print(tostring(configFile[#configFile]).." has realManualTransmission config loaded!");
			elseif check == "" or check == nil then
				break;
			end;
			i = i+1;
		end;
		
	end;
		
	
	if hasXMLProperty(xmlFile, "vehicle.realManualTransmission") then	
		self.hasRMT = true;
		
		-- load from vehicle XML 
		self:loadFromXML(xmlFile, "vehicle.", 0);
		
		self.rmtIsOn = true;
	end;
	
	if self.hasRMT then

		
		-- calculate min and max gear ratio for later calculations 
		local lastRatio = 0;
		for _, gear in pairs(spec.gears) do
			if gear.ratio > lastRatio then	
				lastRatio = gear.ratio;
			end;
		end;
		spec.maxGearRatio = lastRatio;
		for _, gear in pairs(spec.gears) do
			if gear.ratio < lastRatio then
				lastRatio = gear.ratio;
			end;
		end;
		spec.minGearRatio = lastRatio;
		spec.gearRatioRange = spec.maxGearRatio - spec.minGearRatio;
		-- 
		
		-- calculate max speed 
		local ratio = 1;
		if spec.rangeSet1 ~= nil then 
			ratio = ratio * spec.rangeSet1.highestRatio;
		end;
		if spec.rangeSet2 ~= nil then 
			ratio = ratio * spec.rangeSet2.highestRatio;
		end;
		if spec.rangeSet3 ~= nil then 
			ratio = ratio * spec.rangeSet3.highestRatio;
		end;		
		spec.maxSpeedPossible = spec.highestGearSpeed * ratio;
		
		--print("MAX SPEED POSSIBLE: "..tostring(spec.maxSpeedPossible));
		
		
		-- back up gear ratios 
		spec.minForwardGearRatioBackup = self.spec_motorized.motor.minForwardGearRatio;
		spec.maxForwardGearRatioBackup = self.spec_motorized.motor.maxForwardGearRatio;
		
		spec.minBackwardGearRatioBackup = self.spec_motorized.motor.minBackwardGearRatio;
		spec.maxBackwardGearRatioBackup = self.spec_motorized.motor.maxBackwardGearRatio;	
		
		-- back up low brakeforce 
		spec.lowBrakeForceScaleBackup = self.spec_motorized.motor.lowBrakeForceScale;
		self.spec_motorized.motor.lowBrakeForceScale = 0;
		
		-- new smoothing tables 
		spec.loadPercentageSmoothing = self:addSmoothingTable(30, 0);
		
		-- neutral variable 
		spec.neutral = true;
		
		spec.currentGear = spec.defaultGear;
		
		spec.isForward = true;
		
		--
		spec.maxLowBrakeForceScale = 0.60;
		spec.wantedLowBrakeForceScale = 0;
		
		spec.engineBrakeBase = 0.35;
		spec.engineBrakeModifier = 1;
		spec.wantedEngineBrake = 0;
		
		spec.lastWantedAcceleration = 0;

		-- important clutch stuff 
		spec.clutchPercent = 1; -- this is the "actual" clutch percent value
		spec.clutchPercentManual = 1; -- this is the clutch percent value calculated from the clutch pedal 
		spec.clutchPercentAuto = 1; -- this is the clutch percent value calculated from the automatic clutch in auto mode or reverser 
		-- clutchPercent equals to the smaller one (e.g. more open one) of these to. but that way both can be calculated individually without interference and we always have the most open value 
		-- 
		spec.lastClutchPercent2frames = spec.clutchPercent;
		spec.clutchIsClosing = false;
		
		spec.lastActualRatio = 1;
		spec.wantedGearRatio = 0;
		spec.lastGearRatio = 0;
		spec.currentWantedSpeed = 0;
		
		spec.loadPercentage = 0;
		
		spec.lastRealRpm = 850;
		spec.isLowBrakingTimer = 400;
		-- 
		
		
		-- settings stuff 
		spec.buttonReleaseNeutral = true;
		
		self:addCheckBox("buttonReleaseNeutral", "gear button release neutral", 0.05, 0.05, 0.24, 0.58, "buttonReleaseNeutral"); 
	
		spec.switchGearRangeMapping = Utils.getNoNil(spec.switchGearRangeMapping, false);
		self:addCheckBox("switchGearRangeMapping", "switch gear range1 mappings", 0.05, 0.05, 0.24, 0.53, "switchGearRangeMapping"); 
		
		-- 
		spec.useAutomaticClutch = false;
		
		self:addCheckBox("useAutoClutch", "use automatic clutch", 0.05, 0.05, 0.24, 0.68, "useAutomaticClutch"); 
		
		
		
		spec.automaticClutch = {};
		spec.automaticClutch.openTime = 600; --ms
		spec.automaticClutch.closeTimeMax = 3000;
		spec.automaticClutch.closeTimeMin = 500;
		spec.automaticClutch.timer = 0;
		spec.automaticClutch.isOpen = false;
		spec.automaticClutch.wantOpen = false;
		spec.automaticClutch.wantClose = false;
		spec.automaticClutch.preventClosing = false;
		
		spec.automaticClutch.enableOpeningAtLowRPM = false;
		
		self:addCheckBox("enableOpeningAtLowRPM", "enable auto-clutch open at low RPM", 0.05, 0.05, 0.24, 0.63, "enableOpeningAtLowRPM", spec.automaticClutch); 
		
		spec.automaticClutch.openingAtLowRPMTriggered = false;
		spec.automaticClutch.openingAtLowRPMLimit = 950;
		
		--
		
		spec.stallTimer = 500;
		
		-- 
		spec.lastAxisForward = 0;
		
		spec.handBrake = true;
		
		spec.handThrottlePercent = 0;
		spec.handThrottleDown = false;
		spec.handThrottleUp = false;
		
		--
		spec.everyOtherFrame = true;
		--
		spec.debug = false;
		
		
		
		-- VEHICLE HUD 
		local hud = {};
		hud.posX = 0.895;
		hud.posY = 0.22;
		hud.sizeX = 0.1;
		hud.sizeY = 0.02;
		
		hud.showHud = true;
		hud.showGear = true;
		hud.showRange = true;
		hud.showReverser = true;
		hud.showClutch = true;
		hud.showRpm = true;
		hud.showHandbrake = true;
		hud.showSpeed = true;
		hud.showLoad = true;
		
		self.spec_rmtMenu.hud = hud;
			
		self:addCheckBox("showHud", "show hud", 0.04, 0.04, 0.56, 0.72, "showHud", self.spec_rmtMenu.hud); 
		self:addCheckBox("showGear", "show gear", 0.04, 0.04, 0.56, 0.68, "showGear", self.spec_rmtMenu.hud); 
		self:addCheckBox("showRange", "show range", 0.04, 0.04, 0.56, 0.64, "showRange", self.spec_rmtMenu.hud); 
		self:addCheckBox("showReverser", "show reverser", 0.04, 0.04, 0.56, 0.60, "showReverser", self.spec_rmtMenu.hud); 
		self:addCheckBox("showClutch", "show clutch value", 0.04, 0.04, 0.56, 0.56, "showClutch", self.spec_rmtMenu.hud); 
		self:addCheckBox("showRpm", "show RPM", 0.04, 0.04, 0.56, 0.52, "showRpm", self.spec_rmtMenu.hud); 
		self:addCheckBox("showHandbrake", "show Handbrake", 0.04, 0.04, 0.56, 0.48, "showHandbrake", self.spec_rmtMenu.hud); 
		self:addCheckBox("showSpeed", "show wanted speed", 0.04, 0.04, 0.56, 0.44, "showSpeed", self.spec_rmtMenu.hud); 
		self:addCheckBox("showLoad", "show engine load", 0.04, 0.04, 0.56, 0.40, "showLoad", self.spec_rmtMenu.hud); 

		--
		--
		
		
		-- lower low brake force speed limit to prevent automatic braking 
		--self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.1;
		-- raise speed limit to disable automatic braking when reaching speedlimit 
		--self.spec_motorized.motor:setSpeedLimit(100);	
		local oldBrake = self.brake;
		function newBrake(self, brake)
			if not self.hasRMT or not self.rmtIsOn then
				oldBrake(self, brake);
			else
				local spec = self.spec_realManualTransmission;

				-- add engine brake to brake value 
				brake = math.min(1, brake + spec.wantedEngineBrake); 

				-- if handbrake is enabled, brake
				if spec.handBrake then
					brake = 1;
				end;
				
				-- if we have a reverser and the reverser is currently braking, check if the reverser is braking more than we are manually. If so, use the reverser brake value 
				if spec.reverser ~= nil and spec.reverser.lastBrakeForce > 0 then
					brake = math.max(brake, spec.reverser.lastBrakeForce); 
				end;
			
				oldBrake(self, brake);
			end;
		end;
		self.brake = newBrake;		
	end;
end;

function realManualTransmission:onPostLoad(savegame)
	-- load settings from XML 
	if self.hasRMT and savegame ~= nil then
		local xmlFile = savegame.xmlFile
		local spec = self.spec_realManualTransmission;
		
		
		-- load basic settings first 
		local key1 = savegame.key..".FS19_realManualTransmission.realManualTransmission.basicSettings"
		spec.buttonReleaseNeutral = Utils.getNoNil(getXMLBool(xmlFile, key1.."#buttonReleaseNeutral"), spec.buttonReleaseNeutral);
		spec.useAutomaticClutch = Utils.getNoNil(getXMLBool(xmlFile, key1.."#useAutomaticClutch"), spec.useAutomaticClutch);
		spec.automaticClutch.enableOpeningAtLowRPM = Utils.getNoNil(getXMLBool(xmlFile, key1.."#enableOpeningAtLowRPM"), spec.automaticClutch.enableOpeningAtLowRPM);
		self.rmtIsOn = Utils.getNoNil(getXMLBool(xmlFile, key1.."#isOn"), self.rmtIsOn);
	end;
end;

function realManualTransmission:saveToXMLFile(xmlFile, key)
	-- save settings to XML 
	-- save basic settings first 
	if self.hasRMT then
		local spec = self.spec_realManualTransmission;
		local key1 = key..".basicSettings";
		setXMLBool(xmlFile, key1.."#buttonReleaseNeutral", spec.buttonReleaseNeutral);
		setXMLBool(xmlFile, key1.."#useAutomaticClutch", spec.useAutomaticClutch);
		setXMLBool(xmlFile, key1.."#enableOpeningAtLowRPM", spec.automaticClutch.enableOpeningAtLowRPM);
		setXMLBool(xmlFile, key1.."#isOn", self.rmtIsOn);
	end;
end;


function realManualTransmission:loadFromXML(xmlFile, key, i)
		local spec = self.spec_realManualTransmission;
	
		-- first, load gears from XML 
		local gears, numberOfGears, highestSpeed = self:loadGears(xmlFile, key.."realManualTransmission("..i..").gears.gear(");
		spec.gears = gears;
		spec.numberOfGears = numberOfGears;
		spec.defaultGear = Utils.getNoNil(getXMLInt(xmlFile, key.."realManualTransmission("..i..").gears#defaultGear"), 1);
		spec.gearsPowershift = Utils.getNoNil(getXMLBool(xmlFile, key.."realManualTransmission("..i..").gears#powerShift"), false);
		spec.highestGearSpeed = highestSpeed;
		
		-- now load rangeSet 1
		local ranges, numberOfRanges, highestRatio = self:loadRanges(xmlFile, key.."realManualTransmission("..i..").rangeSet1.range(");
		if numberOfRanges ~= nil and numberOfRanges > 0 then
			spec.rangeSet1 = {}
			spec.rangeSet1.ranges = ranges;
			spec.rangeSet1.numberOfRanges = numberOfRanges;
			spec.rangeSet1.defaultRange = Utils.getNoNil(getXMLInt(xmlFile, key.."realManualTransmission("..i..").rangeSet1#defaultRange"));
			spec.rangeSet1.powerShift = Utils.getNoNil(getXMLBool(xmlFile, key.."realManualTransmission("..i..").rangeSet1#powerShift"), false);
			spec.rangeSet1.hasNeutralPosition = Utils.getNoNil(getXMLBool(xmlFile, key.."realManualTransmission("..i..").rangeSet1#hasNeutralPosition"), false);
			spec.rangeSet1.highestRatio = highestRatio;
			spec.hasRangeSet1 = true;
			spec.currentRange1 = spec.rangeSet1.defaultRange;
			print("loaded rangeSet1");
		end;
		
		-- load rangeSet 2
		local ranges, numberOfRanges, highestRatio = self:loadRanges(xmlFile, key.."realManualTransmission("..i..").rangeSet2.range(");
		if numberOfRanges ~= nil and numberOfRanges > 0 then
			spec.rangeSet2 = {};
			spec.rangeSet2.ranges = ranges;
			spec.rangeSet2.numberOfRanges = numberOfRanges;
			spec.rangeSet2.defaultRange = Utils.getNoNil(getXMLInt(xmlFile, key.."realManualTransmission("..i..").rangeSet2#defaultRange"));
			spec.rangeSet2.powerShift = Utils.getNoNil(getXMLBool(xmlFile, key.."realManualTransmission("..i..").rangeSet2#powerShift"), false);
			spec.rangeSet2.hasNeutralPosition = Utils.getNoNil(getXMLBool(xmlFile, key.."realManualTransmission("..i..").rangeSet2#hasNeutralPosition"), false);
			spec.rangeSet2.highestRatio = highestRatio;
			spec.hasRangeSet2 =  true;
			spec.currentRange2 = spec.rangeSet2.defaultRange;
			print("loaded rangeSet2");
		end;
		
		-- load rangeSet 3
		local ranges, numberOfRanges, highestRatio = self:loadRanges(xmlFile, key.."realManualTransmission("..i..").rangeSet3.range(");
		if numberOfRanges ~= nil and numberOfRanges > 0 then
			spec.rangeSet3 = {};
			spec.rangeSet3.ranges = ranges;
			spec.rangeSet3.numberOfRanges = numberOfRanges;
			spec.rangeSet3.defaultRange = Utils.getNoNil(getXMLInt(xmlFile, key.."realManualTransmission("..i..").rangeSet3#defaultRange"));
			spec.rangeSet3.powerShift = Utils.getNoNil(getXMLBool(xmlFile, key.."realManualTransmission("..i..").rangeSet3#powerShift"), false);
			spec.rangeSet3.hasNeutralPosition = Utils.getNoNil(getXMLBool(xmlFile, key.."realManualTransmission("..i..").rangeSet3#hasNeutralPosition"), false);
			spec.rangeSet3.highestRatio = highestRatio;
			spec.hasRangeSet3 = true;
			spec.currentRange3 = spec.rangeSet3.defaultRange;
			print("loaded rangeSet3");
		end;	
		
		-- load reverser 
		local reverserType = getXMLString(xmlFile, key.."realManualTransmission("..i..").reverser#type");
		if reverserType ~= nil and reverserType ~= "" then
			spec.reverser = {};
			spec.reverser.type = reverserType;
			spec.reverser.forwardRatio = getXMLFloat(xmlFile, key.."realManualTransmission("..i..").reverser.ratios#forward");
			spec.reverser.reverseRatio = getXMLFloat(xmlFile, key.."realManualTransmission("..i..").reverser.ratios#reverse");
			spec.reverser.brakeAggressionBias = Utils.getNoNil(getXMLFloat(xmlFile, key.."realManualTransmission("..i..").reverser.settings#brakeAggressionBias"), 1);
			spec.reverser.clutchTime = Utils.getNoNil(getXMLFloat(xmlFile, key.."realManualTransmission.reverser("..i..").settings#clutchTime"), 500);
			
			spec.reverser.isForward = true;
			spec.reverser.wantForward = true;
			spec.reverser.isBraking = false;
			spec.reverser.isClutching = false;
			spec.reverser.lastBrakeForce = 0;
			
		end;
		
		spec.finalRatio = Utils.getNoNil(getXMLFloat(self.xmlFile, key.."realManualTransmission("..i..")#finalRatio"), 1);
		spec.switchGearRangeMapping = Utils.getNoNil(getXMLFloat(self.xmlFile, key.."realManualTransmission("..i..")#switchGearRangeMapping"), false);

end;



function realManualTransmission:loadRanges(xmlFile, key)
	local ranges = {};
	local i = 0;
	local highestRatio = 0;
	while true do
		local range = {};
		-- load ratio (ranges don't use inverse ratio)
		range.ratio = getXMLFloat(xmlFile, key..i..")#ratio")
		if range.ratio == nil then
			break;
		end;
		
		
		-- load name and isReverse, if isReverse is true, this range is a reverse-range
		range.name = getXMLString(xmlFile, key..i..")#name");
		range.isReverse = getXMLBool(xmlFile, key..i..")#isReverse");
		-- load disable gears 
		local disableGears = getXMLString(xmlFile, key..i..").disableGears#gears");
		if disableGears ~= nil and disableGears ~= "" then
			local disableGearsTable = StringUtil.splitString(" ", disableGears);
			range.disableGearsTable = {};
			for _, gear in pairs(disableGearsTable) do
				range.disableGearsTable[gear] = true;
			end;
			range.disableGearsType = Utils.getNoNil(getXMLString(xmlFile, key..i..").disableGears#disableType"));
		else
			range.disableGearsTable = nil;
		end;
		
		-- load disable ranges 
		-- rangeSet1 
		local disableRanges1 = getXMLString(xmlFile, key..i..").disableRangesSet1#ranges");
		if disableRanges1 ~= nil and disableRanges1 ~= "" then
			local disableRanges1Table = StringUtil.splitString(" ", disableRanges1);
			range.disableRanges1Table = {};
			for _, rangeKey in pairs(disableRanges1Table) do
				range.disableRanges1Table[rangeKey] = true;
			end;
			range.disableRanges1Type = Utils.getNoNil(getXMLString(xmlFile, key..i..").disableRangesSet1#disableType"));
		else
			range.disableRanges1Table = nil;
		end;
		-- rangeSet2 
		local disableRanges2 = getXMLString(xmlFile, key..i..").disableRangesSet2#ranges");
		if disableRanges2 ~= nil and disableRanges2 ~= "" then
			local disableRanges2t = StringUtil.splitString(" ", disableRanges2);
			range.disableRanges2Table = {};
			for _, rangeKey in pairs(disableRanges2t) do
				range.disableRanges2Table[rangeKey] = true;
			end;
			range.disableRanges2Type = Utils.getNoNil(getXMLString(xmlFile, key..i..").disableRangesSet2#disableType"));
		else
			range.disableRanges2Table = nil;
		end;		
		-- rangeSet3 
		local disableRanges3 = getXMLString(xmlFile, key..i..").disableRangesSet3#ranges");
		if disableRanges3 ~= nil and disableRanges3 ~= "" then
			local disableRanges3Table = StringUtil.splitString(" ", disableRanges3);
			range.disableRanges3Table = {};
			for _, rangeKey in pairs(disableRanges3Table) do
				range.disableRanges3Table[rangeKey] = true;
			end;
			range.disableRanges3Type = Utils.getNoNil(getXMLString(xmlFile, key..i..").disableRangesSet3#disableType"));
		else
			range.disableRanges3Table = nil;
		end;		
		--
				
		-- also store the highest ratio 
		if range.ratio > highestRatio then
			highestRatio = range.ratio;
		end;
		
		table.insert(ranges, range);
		i = i+1;
	end;
	local numberOfRanges = i;
	return ranges, numberOfRanges, highestRatio;
end;
	
-- load gears function, we give XML-File and XML-File key, so its easier to use seperate config-files later since we just have to change the function-call 
function realManualTransmission:loadGears(xmlFile, key)
	local spec = self.spec_realManualTransmission;
	spec.gearMappings = {};
	local gears = {};
	local highestSpeed = 0;
	local i = 0;
	while true do
		local gear = {};
		-- load ratio or speed 
		gear.ratio = getXMLFloat(xmlFile, key..i..")#ratio")
		gear.speed = getXMLFloat(xmlFile, key..i..")#speed");
		-- we either can have ratio (inverse ratio) or speed, if we have speed in XML convert it to ratio 
		if gear.ratio == nil and gear.speed == nil then
			break;
		end;		
		if gear.ratio == nil and gear.speed ~= nil then
			gear.ratio = 836 / gear.speed; -- conversion for giants calculation 836 constant
		end;
		if gear.speed == nil and gear.ratio ~= nil then 
			gear.speed = 836 / gear.ratio; -- conversion from Ratio to speed
		end;
		
		if gear.speed > highestSpeed then
			highestSpeed = gear.speed;
		end;
		
		
		-- load name and isReverse, if isReverse is true, this gear is a reverse-gear
		gear.name = getXMLString(xmlFile, key..i..")#name");
		gear.isReverse = getXMLBool(xmlFile, key..i..")#isReverse");
		
		-- we can map the gear to a gear-input that is not the number of the gear 
		gear.mappedToGear = Utils.getNoNil(getXMLInt(xmlFile, key..i..")#mappedToGear"), i+1);
		spec.gearMappings[gear.mappedToGear] = i+1;
		
		-- insert gear to gears table 
		table.insert(gears, gear);
		i = i+1;
	end;
	local numberOfGears = i; -- count of all gears 
	
	-- return the gears table and the number of gears 
	return gears, numberOfGears, highestSpeed;
end;

-- process the inputs from the gear buttons, we need this function to easily select range or gears in case its switched around. Its also for future proofing  
function realManualTransmission:processGearInputs(inputIndex, inputValue, isSequentialUp)
	local spec = self.spec_realManualTransmission;
	
	if isSequentialUp == nil then -- we called this via direct selection, so we select the gear or range directly 
		if spec.switchGearRangeMapping then -- if we have gears and ranges switched we want to select the range instead 
			self:selectRange(inputIndex, 1, inputValue);
		else
			self:selectGear(inputIndex, inputValue, inputIndex);
		end;
	end;
	
	if isSequentialUp or isSequentialUp == false then -- we called this via up/down keys e.g. sequential, true means up, false means down (nil means not sequential)
		-- if we want to shift up or down 
		local dir = 1;
		if isSequentialUp == false then
			dir = -1;
		end;
				
		-- just select the gear we want to.. see if we get lockOut back 
		local lockOut = self:selectGear(spec.currentGear - (1*dir), inputValue);
		
		-- if we get locked out of the gear we want to shift in, try to shift down to the next gear and the next
		-- to see if we can shift into the next allowed gear, stop if 1 is reached 
		if lockOut then
			local i = 2;
			while true do
				local curGear = math.min(math.max(1, spec.currentGear - (i*dir)), spec.numberOfGears); -- cur wanted gear is i or 1
				lockOut = self:selectGear(curGear, inputValue); -- try the next gear, return if we are locked out again 
				if lockOut and (curGear == 1 or curGear == spec.numberOfGears) or lockOut == false then -- if we're still locked out but curGear is 1 or max gear, stop looking for gears 
					break;
				end;	
				i = i+1;
			end;
		end;
			
			
	end;	
		
end;

function realManualTransmission:selectRange(wantedRange, rangeSetIndex, inputValue)
	-- to do, Event!
	local spec = self.spec_realManualTransmission;

	-- check if wantedRange is not nil
	if wantedRange ~= nil then
		local rangeSet = nil;
		-- first, see which rangeSet we are about to change the range in 
		if rangeSetIndex ~= nil then
			if rangeSetIndex == 1 then
				rangeSet = spec.rangeSet1;
			elseif rangeSetIndex == 2 then
				rangeSet = spec.rangeSet2;
			elseif rangeSetIndex == 3 then
				rangeSet = spec.rangeSet3;
			end;
		else
			rangeSet = spec.rangeSet1; -- default to 1 if rangeSetIndex is nil or invalid
		end;
		-- now we need to check if the rangeSet even exists 
		if rangeSet ~= nil then
		
			-- now see if inputValue is not 0 (0 means neutral)
			if inputValue ~= 0 then
				-- make sure our wantedRange is between min and max range we have 
				wantedRange = math.max(1, math.min(wantedRange, rangeSet.numberOfRanges));
				local wantedNeutral = false;
				
				-- lockout check 
				-- check if we are locked out of the range we want to shift in or any other prevention of shifting 
				if rangeSetIndex == 1 then
					-- check if we can shift into this range or if it is disabled in the gear we are in 
					if spec.rangeSet1.ranges[wantedRange].disableGearsTable ~= nil and spec.rangeSet1.ranges[wantedRange].disableGearsTable[tostring(spec.currentGear)] then 
						if spec.rangeSet1.ranges[wantedRange].disableGearsType == "lock" then -- we can not shift into this range because it is locked in this gear 
							wantedRange = nil;
						elseif spec.rangeSet1.ranges[wantedRange].disableGearsType == "neutral" then -- we can shift into the current range but we shift the gear to neutral 
							wantedNeutral = true;
						end;
					end;
					
					-- check if the range we want to shift into is disabled in the current Range of the other 2 sets we are in 
					if spec.rangeSet2 ~= nil and spec.rangeSet2.ranges[spec.currentRange2].disableRanges1Table ~= nil and spec.rangeSet2.ranges[spec.currentRange2].disableRanges1Table[tostring(wantedRange)] then
						if spec.rangeSet2.ranges[spec.currentRange2].disableRanges1Type == "lock" then -- we can not shift into this range since it is locked 
							wantedRange = nil;
						elseif spec.rangeSet2.ranges[spec.currentRange2].disableRanges1Type == "neutral" then
							-- not implemented yet 
						end;
					end;
					if spec.rangeSet3 ~= nil and spec.rangeSet3.ranges[spec.currentRange3].disableRanges1Table ~= nil and spec.rangeSet3.ranges[spec.currentRange3].disableRanges1Table[tostring(wantedRange)] then
						if spec.rangeSet3.ranges[spec.currentRange3].disableRanges1Type == "lock" then -- we can not shift into this range since it is locked 
							wantedRange = nil;
						elseif spec.rangeSet3.ranges[spec.currentRange3].disableRanges1Type == "neutral" then
							-- not implemented yet 
						end;
					end;
				elseif rangeSetIndex == 2 then
					-- check if we can shift into this range or if it is disabled in the gear we are in 
					if spec.rangeSet2.ranges[wantedRange].disableGearsTable ~= nil and spec.rangeSet2.ranges[wantedRange].disableGearsTable[tostring(spec.currentGear)] then 
						if spec.rangeSet2.ranges[wantedRange].disableGearsType == "lock" then -- we can not shift into this range because it is locked in this gear 
							wantedRange = nil;
						elseif spec.rangeSet2.ranges[wantedRange].disableGearsType == "neutral" then -- we can shift into the current range but we shift the gear to neutral 
							spec.neutral = true;
						end;
					end;
					
					-- check if the range we want to shift into is disabled in the current Range of the other 2 sets we are in 
					if spec.rangeSet1 ~= nil and spec.rangeSet1.ranges[spec.currentRange1].disableRanges2Table ~= nil and spec.rangeSet1.ranges[spec.currentRange1].disableRanges2Table[tostring(wantedRange)] then
						if spec.rangeSet1.ranges[spec.currentRange1].disableRanges2Type == "lock" then -- we can not shift into this range since it is locked 
							wantedRange = nil;
						elseif spec.rangeSet1.ranges[spec.currentRange1].disableRanges2Type == "neutral" then
							-- not implemented yet 
						end;
					end;
					if spec.rangeSet3 ~= nil and spec.rangeSet3.ranges[spec.currentRange3].disableRanges2Table ~= nil and spec.rangeSet3.ranges[spec.currentRange3].disableRanges2Table[tostring(wantedRange)] then
						if spec.rangeSet3.ranges[spec.currentRange3].disableRanges2Type == "lock" then -- we can not shift into this range since it is locked 
							wantedRange = nil;
						elseif spec.rangeSet3.ranges[spec.currentRange3].disableRanges2Type == "neutral" then
							-- not implemented yet 
						end;
					end;
				elseif rangeSetIndex == 3 then
					-- check if we can shift into this range or if it is disabled in the gear we are in 
					if spec.rangeSet3.ranges[wantedRange].disableGearsTable ~= nil and spec.rangeSet3.ranges[wantedRange].disableGearsTable[tostring(spec.currentGear)] then 
						if spec.rangeSet3.ranges[wantedRange].disableGearsType == "lock" then -- we can not shift into this range because it is locked in this gear 
							wantedRange = nil;
						elseif spec.rangeSet3.ranges[wantedRange].disableGearsType == "neutral" then -- we can shift into the current range but we shift the gear to neutral 
							spec.neutral = true;
						end;
					end;
					
					-- check if the range we want to shift into is disabled in the current Range of the other 2 sets we are in 
					if spec.rangeSet1 ~= nil and spec.rangeSet1.ranges[spec.currentRange1].disableRanges3Table ~= nil and spec.rangeSet1.ranges[spec.currentRange1].disableRanges3Table[tostring(wantedRange)] then
						if spec.rangeSet1.ranges[spec.currentRange1].disableRanges3Type == "lock" then -- we can not shift into this range since it is locked 
							wantedRange = nil;
						elseif spec.rangeSet1.ranges[spec.currentRange1].disableRanges3Type == "neutral" then
							-- not implemented yet 
						end;
					end;
					if spec.rangeSet2 ~= nil and spec.rangeSet2.ranges[spec.currentRange2].disableRanges3Table ~= nil and spec.rangeSet2.ranges[spec.currentRange2].disableRanges3Table[tostring(wantedRange)] then
						if spec.rangeSet2.ranges[spec.currentRange2].disableRanges3Type == "lock" then -- we can not shift into this range since it is locked 
							wantedRange = nil;
						elseif spec.rangeSet2.ranges[spec.currentRange2].disableRanges3Type == "neutral" then
							-- not implemented yet 
						end;
					end;
				end;
				-- end of lockout check 
				
				-- now see if wantedRange is still not nil, only continue if its not nil 
				if wantedRange ~= nil then
					-- check if clutch is pressed or range is powershift 
					if spec.clutchPercent < 0.4 or rangeSet.powerShift then
						-- return wantedRange 
						if rangeSetIndex == 1 then
							spec.currentRange1 = wantedRange;
							rangeSet.currentRange = spec.currentRange1
						elseif rangeSetIndex == 2 then
							spec.currentRange2 = wantedRange;
							rangeSet.currentRange = spec.currentRange2;
						elseif rangeSetIndex == 3 then
							spec.currentRange3 = wantedRange;
							rangeSet.currentRange = spec.currentRange3;
						end;
						
						-- if we want to shift gears into neutral due to range lockout, we do that now when the clutch is pressed.
						if wantedNeutral then 
							spec.neutral = true;
						end;
					end;				
				end;
				

				-- now for the automatic clutch 
				-- check if we use auto clutch, check if gears aren't powershift. Check if we didn't already set the gear by manually pressing the clutch (or if we try to set the gear we are already in)
				-- also check if the wantedGear is set to nil because its disabled in the range we are in. In that case, also don't open clutch 
				if spec.useAutomaticClutch and not rangeSet.powerShift and rangeSet.currentRange ~= wantedRange and wantedRange ~= nil and wantedRange <= rangeSet.numberOfRanges then
					-- start opening clutch 
					spec.automaticClutch.wantOpen = true; 
					spec.automaticClutch.timer = spec.automaticClutch.openTime; -- put openTime in timer 
					spec.automaticClutch.timerMax = spec.automaticClutch.timer; -- store the max timer value, we need that later 
					spec.automaticClutch.wantedRange = wantedRange; -- store wantedGear for later when clutch is open 
					spec.automaticClutch.rangeSetIndex = rangeSetIndex; -- store wantedGear for later when clutch is open 
				end;				
				
			elseif inputValue == 0 then
				-- if the rangeSet has a neutral position and we have buttonReleaseNeutral active, we want to turn into neutral 
				-- this is only for real hardcore players that want to use a second H-Shifter for ranges :)
				if rangeSet.hasNeutralPosition and spec.buttonReleaseNeutral then
					rangeSet.neutral = true;
				end;
			end;
		end;

	end;
end;

function realManualTransmission:selectGear(wantedGear, inputValue, mappingValue)
	--print("select gear called");
	-- to do, Event!
	local spec = self.spec_realManualTransmission;
	local lockedOut = false;
	
	-- first check if wantedGear is not nil and inputValue is not 0
	if wantedGear ~= nil and inputValue ~= 0 then
		
		
		-- check if wantedGear is not -1, -1 means we want to set it to neutral 
		if wantedGear ~= -1 then
			-- now check if wantedGear isn't the actual gear we want, in case we had a mappingValue assigned to the selectGear call 
			if mappingValue ~= nil then
				wantedGear = spec.gearMappings[mappingValue];
			end;
			
			-- now make sure that wantedGear isn't above our highest gear 
			wantedGear = math.max(1, math.min(wantedGear, spec.numberOfGears));
			
		end;
		-- if wantedGear is not nil yet, we are pretty sure wantedGear is valid and the gear we want 
		
		-- next, see if we can even shift into that gear in the range we are currently in 
		-- check for each of the rangeSets 
		
		if spec.rangeSet1 ~= nil and spec.rangeSet1.ranges[spec.currentRange1].disableGearsTable ~= nil and spec.rangeSet1.ranges[spec.currentRange1].disableGearsTable[tostring(wantedGear)] then 
			-- it doesn't matter it the disableType is lock or neutral because we're not trying to shift into the range but into the disabled gear so its always locked out 
			if spec.rangeSet1.ranges[spec.currentRange1].disableGearsType == "lock" or spec.rangeSet1.ranges[spec.currentRange1].disableGearsType == "neutral" then 
				wantedGear = nil;
				lockedOut = true;
			end;
		end;			
		if spec.rangeSet2 ~= nil and spec.rangeSet2.ranges[spec.currentRange2].disableGearsTable ~= nil and spec.rangeSet2.ranges[spec.currentRange2].disableGearsTable[tostring(wantedGear)] then 
			if spec.rangeSet2.ranges[spec.currentRange2].disableGearsType == "lock" or spec.rangeSet2.ranges[spec.currentRange1].disableGearsType == "neutral" then
				wantedGear = nil;
				lockedOut = true;
			end;
		end;		
		if spec.rangeSet3 ~= nil and spec.rangeSet3.ranges[spec.currentRange3].disableGearsTable ~= nil and spec.rangeSet3.ranges[spec.currentRange3].disableGearsTable[tostring(wantedGear)] then 
			if spec.rangeSet3.ranges[spec.currentRange3].disableGearsType == "lock" or spec.rangeSet3.ranges[spec.currentRange1].disableGearsType == "neutral" then 
				wantedGear = nil;
				lockedOut = true;
			end;
		end;

			
		-- now check if clutch is pressed enough to allow gearshift or if gears can be shifted under power 
		if spec.clutchPercent < 0.4 or spec.gearsPowershift then
			-- -1 means we want to go into neutral 
			if wantedGear == -1 then 
				spec.neutral = true;
			else
				-- return wanted gear 
				if wantedGear ~= nil then
					spec.currentGear = wantedGear;
					spec.neutral = false; -- set neutral to false if we are in gear 
				end;
			end;
		end;
		
		-- now for the automatic clutch 
		-- check if we use auto clutch, check if gears aren't powershift. Check if we didn't already set the gear by manually pressing the clutch (or if we try to set the gear we are already in)
		-- also check if the wantedGear is set to nil because its disabled in the range we are in. In that case, also don't open clutch 
		if spec.useAutomaticClutch and not spec.gearsPowershift and spec.currentGear ~= wantedGear and wantedGear ~= nil and wantedGear <= spec.numberOfGears then
			-- start opening clutch 
			spec.automaticClutch.wantOpen = true; 
			spec.automaticClutch.timer = spec.automaticClutch.openTime; -- put openTime in timer 
			spec.automaticClutch.timerMax = spec.automaticClutch.timer; -- store the max timer value, we need that later 
			spec.automaticClutch.wantedGear = wantedGear; -- store wantedGear for later when clutch is open 	
		end;			
	end;
	
	-- if inputValue is 0 and we have buttonReleaseNeutral active (automatically go back to neutral if you stop "pressing" the gear button
	-- then go to neutral (that way if it goes to neutral with Gearshifters like Logitech G27 if you get out of gear on the shifter)
	if inputValue == 0 and spec.buttonReleaseNeutral then
		spec.neutral = true;
	end;
	return lockedOut;
end;


function realManualTransmission:selectReverser(isForward, inputValue)

	local rev = self.spec_realManualTransmission.reverser;
	
	-- first, check if reverser is preselect type 
	if rev.type == "preselect" then
		rev.wantForward = isForward; -- set wanted forward value 
		rev.allowDirectionChange = true;
	else
		-- check if we even need to change direction
		if rev.isForward ~= isForward then
			-- now, see if we are braking, if not, do so
			if not rev.isBraking then
				rev.isBraking = true;
			end;
			rev.wantForward = isForward; -- set wanted forward value 
		end;
	end;

end;
function realManualTransmission:onUpdate(dt) 

	-- debugs...
	local firstTimeRun1 = false;
	if not firstTimeRun1 then
		--DebugUtil.printTableRecursively(self.spec_dashboard, "-" , 0, 3)

		firstTimeRun1 = true;
	end;
	
	if self:getIsActive() then

		
		-- check if we are a hired worker, turn rmt off if worker is hired 
		if self.spec_aiVehicle ~= nil then
			if self.spec_aiVehicle.isActive and self.rmtIsOnBackup == nil then
				self.rmtIsOnBackup = self.rmtIsOn;
				self.rmtIsOn = false;
			elseif not self.spec_aiVehicle.isActive and self.rmtIsOnBackup ~= nil then
				self.rmtIsOn = self.rmtIsOnBackup;
				self.rmtIsOnBackup = nil;
			end;
		end;	
	
		if self.hasRMT and self.rmtIsOn then 
			local spec = self.spec_realManualTransmission;
			
			-- first, really FIRST, see if analog or digital clutch is more open, use the more open one!
			-- that is to remove glitches when using automatic clutch in reverser together with clutch pedal 
			-- which ever is smaller, use that one
			spec.clutchPercent = math.min(spec.clutchPercentAuto, spec.clutchPercentManual);
			
			if self.spec_motorized.isMotorStarted then
				
				-- every other frame check clutch percentage, we check every other frame to combat slight inaccuracies with manual clutch pedal 
				-- we want to know if the clutch is currently closing 
				spec.everyOtherFrame = not spec.everyOtherFrame;
				if spec.everyOtherFrame then
					if spec.clutchPercent > spec.lastClutchPercent2frames then
						spec.clutchIsClosing = true;
					else
						spec.clutchIsClosing = false;
					end;
					spec.lastClutchPercent2frames = spec.clutchPercent
				end;
			
			
				-- local variables for motor and rpm and load and wanted rpm/load (axis forward)
				local motor = self.spec_motorized.motor;
				local rpm = motor.lastRealMotorRpm;
				--local mLoad = self.spec_motorized.actualLoadPercentage;		
				local mAxisForward = self:getAxisForward()
				
				spec.lastAxisForward = mAxisForward;
				--renderText(0.4, 0.4, 0.04, "lastAxisForward: "..tostring(mAxisForward));
			
				-- motor load for sound 
				local loadPercentage = self.spec_motorized.motor:getMotorAppliedTorque() / math.max( self.spec_motorized.motor:getMotorAvailableTorque(), 0.0001)

				--print("external torque: "..tostring(self.spec_motorized.motor:getMotorExternalTorque()));
				--print("applied torque: "..tostring(self.spec_motorized.motor:getMotorAppliedTorque()));
				
				-- we need the load percentage without PTO to calculate engine brake effect 
				local loadPercentageNoPTO = (self.spec_motorized.motor:getMotorAppliedTorque()-self.spec_motorized.motor:getMotorExternalTorque()) / math.max( self.spec_motorized.motor:getMotorAvailableTorque(), 0.0001)
				--print(loadPercentageNoPTO);
				
				if spec.clutchPercent < 0.6 or spec.neutral then
					-- if clutch is pressed or neutral, load percentage is calculated using wanted and actual RPM 
					if (rpm / motor.maxRpm) < mAxisForward then
						loadPercentage = 1;
					else
						loadPercentage = 0;
					end;
				end;
			
				-- actual load percentage 
				self.spec_motorized.actualLoadPercentage = loadPercentage
				
				-- smoothed load percentage 
				local newAverage = self:getSmoothingTableAverage(spec.loadPercentageSmoothing, loadPercentage);
				self.spec_motorized.smoothedLoadPercentage = newAverage;			
			
				--self.spec_motorized.smoothedLoadPercentage = spec.loadPercentage;
				
				--self.spec_motorized.smoothedLoadPercentage = 0.8 * self.spec_motorized.smoothedLoadPercentage + 0.2 * spec.loadPercentage --0.5* self.spec_motorized.smoothedLoadPercentage + 0.5*loadPercentage
				
				
				-- calculate engine brake 
				local wantedEngineBrake =  (1 - (spec.currentWantedSpeed / (spec.maxSpeedPossible*1.1))) * spec.engineBrakeBase * spec.engineBrakeModifier * ((rpm / motor.maxRpm)^2) * ((spec.clutchPercent - 0.199)*1.25);
		

				-- now find out if we are off-load and engine is in pushmode
				local axisWantedRPM = 0;
				local isLowBraking = false;
				
				-- previously used accelerator pedal and wantedRPM vs. actual RPM do check if we are low braking.. Didn't work well.
				-- try using motor load instead, if load is 0 we are in pushmode 
				-- tried smoothed motor load, didn't work after I changed to the new acceleration "model". Now we use actualLoadPercentage but we have a timer of 300ms so it only starts braking if we are without load for at least 300ms 
				-- that way it doesn't get into a brake-accelerate-brake-accelerate loop at low loads 
				if loadPercentageNoPTO == 0 then 
					spec.isLowBrakingTimer = math.max(spec.isLowBrakingTimer - dt, 0);
					if spec.isLowBrakingTimer == 0 then
						isLowBraking = true;
					end;
				else
					spec.isLowBrakingTimer = 255;
				end;
				
				-- since the delay is still too much using motorLoad, instant low braking when we are completely off the accelerator 
				-- take hand throttle into account fix 0.4.0.3
				if mAxisForward <= 0.001 and spec.handThrottlePercent == 0 then
					isLowBraking = true;
				end;
				
				-- no brake force if we are in neutral or clutch is completely disengaged.. 
				if spec.neutral or spec.clutchPercent < 0.2 then 
					isLowBraking = false;
				end;
				
				-- simple smoothing of low brakeforce so the changes are not as sudden 
				if isLowBraking then
					spec.wantedEngineBrake = (0.1 * spec.wantedEngineBrake ) + (0.9 * wantedEngineBrake);
				else
					spec.wantedEngineBrake = math.max(0, spec.wantedEngineBrake - 0.1);
				end;
				
				-- debugs 
				if spec.debug then
					renderText(0.1, 0.5, 0.02, "axisWantedRPM: "..tostring(axisWantedRPM).." rpm "..tostring(rpm).." diff: "..tostring(rpm / axisWantedRPM).." gr: "..tostring(axisWantedRPM > rpm));
				end;
				
				-- ### 
				-- now for the calculation of the actual gear ratio including the clutch calculation 
				local actualGearRatio = 0;
				local currentGearRatio = 0;
			
				-- first get the current theoretical gear ratio based on wheel speed 
				-- calculate relative axle speed: 
				local wheelSpeed = 0;
				local numWheels = 0;
				for _, wheel in pairs(self.spec_wheels.wheels) do
			
					local rpm = getWheelShapeAxleSpeed(wheel.node, wheel.wheelShape)*30/math.pi
					wheelSpeed = wheelSpeed + (rpm * wheel.radius);
					numWheels = numWheels + 1;
					
				end;		
				wheelSpeed = math.abs(wheelSpeed / numWheels);
				
				wheelSpeed = math.max(wheelSpeed, 2);
				
				-- calculate theoretical gear ratio dependent on current RPM 
				currentGearRatio = motor.lastMotorRpm / wheelSpeed;
				--currentGearRatio = motor.lastRealMotorRpm / wheelSpeed; -- don't use real, use smoothed version instead 
				
				-- cap that gear ratio at 1000 
				currentGearRatio = math.min(currentGearRatio, 1000);
				-- current gear ratio is now the current ratio between the tires and the engine 
				
				-- smoothing lastGearRatio (actual ratio value) 
				spec.lastGearRatio = (0.9 * spec.lastGearRatio) + (0.1*currentGearRatio);
				
				if spec.clutchPercent < 0.999 then
					-- calculate gear ratio based on clutch percentage between actual gear ratio and wanted gear ratio 
					--actualGearRatio = math.max((spec.wantedGearRatio * ((spec.clutchPercent-0.2)*1.25)) + (spec.lastGearRatio * (1-(spec.clutchPercent-0.2)*1.25)), 0);  -- old version, buggy 
					
					--actualGearRatio = maxRatioPossible;
					
					local clutchPercent = math.max((spec.clutchPercent-0.2)*1.25, 0); -- calculate clutchPercent in a way that < 0.2 clutch equals 0 
					actualGearRatio = math.max(spec.wantedGearRatio * clutchPercent + spec.lastGearRatio * (1-clutchPercent), 0); -- now calculate gear ratio between clutch and actual 
				else
					-- if clutch is fully engaged just use wanted gear ratio 
					actualGearRatio = spec.wantedGearRatio;
				end;
				
				-- no need to put it into a proper variable atm.. but since I've had to debug a lot around this stuff this is here.. and it stays for now 
				spec.lastActualRatio = actualGearRatio;
				
				-- if we are in neutral of clutch all the way in we need to set gearRatio to 1 because giants physics do have some sort of enginebrake that I can not turn off so it is always low braking depending on gearRatio 
				if spec.neutral or spec.clutchPercent < 0.2 then 
					spec.lastActualRatio = 1; 
				end;	
				
				-- debugs.. 
				if spec.debug then
					renderText(0.1, 0.6, 0.02, "actualGearRatio: "..tostring(actualGearRatio).." currentGearRatio: "..tostring(currentGearRatio).." wheelSpeed: "..tostring(wheelSpeed).." lastRealMotorRpm: "..tostring(motor.lastRealMotorRpm));
				end;
				
				-- finally set the gear ratio values 
				motor.minForwardGearRatio = spec.lastActualRatio;
				motor.maxForwardGearRatio = spec.lastActualRatio;
				
				motor.minBackwardGearRatio = spec.lastActualRatio;
				motor.maxBackwardGearRatio = spec.lastActualRatio;	
				
				motor.minGearRatio = spec.lastActualRatio;
				motor.maxGearRatio = spec.lastActualRatio;

			end;
			
			-- first, get total ranges ratio between all 3 possible rangeSets 
			local rangeRatio = 1;
			if spec.rangeSet1 ~= nil then
				rangeRatio = rangeRatio * spec.rangeSet1.ranges[spec.currentRange1].ratio;
			end;
			if spec.rangeSet2 ~= nil then
				rangeRatio = rangeRatio * spec.rangeSet2.ranges[spec.currentRange2].ratio;
			end;
			if spec.rangeSet3 ~= nil then	
				rangeRatio = rangeRatio * spec.rangeSet3.ranges[spec.currentRange3].ratio;
			end;
			-- now calculate wanted gear ratio with gear and rangeRatio and final ratio 
			-- we need to divide since its inverse ratio 
			spec.wantedGearRatio = spec.gears[spec.currentGear].ratio / rangeRatio / spec.finalRatio;
			spec.currentWantedSpeed = spec.gears[spec.currentGear].speed * rangeRatio * spec.finalRatio;
			

			-- calculating hand throttle 
			if spec.handThrottleDown then
				spec.handThrottlePercent = math.max(0, spec.handThrottlePercent - 0.001*dt);
			elseif spec.handThrottleUp then
				spec.handThrottlePercent = math.min(1, spec.handThrottlePercent + 0.001*dt);
			end;
				
			-- calculating the reverser 
			if spec.reverser ~= nil then
				
					-- print(tostring(self.lastSpeed*3600));
					-- if the reverser is in brake-mode, calculate brake force and open clutch 
					if spec.reverser.isBraking then 
						-- clutch 
						if not spec.automaticClutch.wantOpen and not spec.automaticClutch.isOpen then
							spec.automaticClutch.wantOpen = true;
							spec.automaticClutch.timer = 450;
							spec.automaticClutch.timerMax = spec.automaticClutch.timer;
							spec.automaticClutch.preventClosing = true;
							spec.automaticClutch.reverserFlag = true;
						end;
						
						-- brake force 
						spec.reverser.lastBrakeForce = 1 * spec.reverser.brakeAggressionBias; 
						if math.abs(self.lastSpeed*3600) < 0.7 then
							--spec.reverser.lastBrakeForce = spec.reverser.lastBrakeForce * self.lastRealSpeed;
							spec.reverser.isBraking = false;
							spec.reverser.allowDirectionChange = true;
						end;			
						
					else
						spec.reverser.lastBrakeForce = 0;
					end;
				
					-- if the clutch is open, change direction 
					if spec.clutchPercent < 0.2 and spec.reverser.allowDirectionChange then 
						spec.reverser.isForward = spec.reverser.wantForward;
						spec.automaticClutch.preventClosing = false;
						spec.reverser.allowDirectionChange = nil;
					end;
					-- the clutch is automatically closing after it opened anyways, so nothing more to do here 
			end;
		
			
			-- calculating the automatic clutch 
			if spec.useAutomaticClutch or spec.reverser ~= nil and spec.reverser.type == "normal" then
			
				if spec.automaticClutch.wantOpen then -- currently opening 
					-- remove from opening timer 
					spec.automaticClutch.timer = math.max(spec.automaticClutch.timer - dt, 0);
					-- check if timer is 0
					if spec.automaticClutch.timer == 0 then
						spec.automaticClutch.isOpen = true;
						spec.automaticClutch.wantOpen = false;
					end;
					-- set clutch value according to opening timer 
					spec.clutchPercentAuto = spec.automaticClutch.timer / spec.automaticClutch.timerMax; 	
					--print(tostring(spec.automaticClutch.timer));				
				end;
				
				
				-- check if clutch is fully open, now change gear 
				if spec.automaticClutch.isOpen then 
					-- check if preventClosing is active (this is active if we have the clutch-button pressed)
					if not spec.automaticClutch.preventClosing then
						local ratio = 1; 
						-- change the gear or range depending on which we selected 
						if spec.automaticClutch.wantedGear ~= nil then
							self:selectGear(spec.automaticClutch.wantedGear, 1);
							-- the further the new ratio is away from the current ratio, the smaller the ratio number gets 
							if spec.lastGearRatio < spec.wantedGearRatio then 
								ratio = spec.lastGearRatio / spec.wantedGearRatio;
							elseif spec.lastGearRatio >= spec.wantedGearRatio then
								ratio = spec.wantedGearRatio / spec.lastGearRatio;
							end;	
							if spec.automaticClutch.wantedGear == -1 then -- we shifted into neutral, just use closeTimeMin 
								ratio = 0;
							end;						
						elseif spec.automaticClutch.wantedRange ~= nil then
							self:selectRange(spec.automaticClutch.wantedRange, spec.automaticClutch.rangeSetIndex, 1);
						end;
						-- set state to closing 
						spec.automaticClutch.wantClose = true;
						-- now set the closing timer. It depends on current speed / speed difference and max closing time (only for gears, on ranges we always use max. closing time)
					
						ratio = 1-ratio; -- remove ratio value from one, thus, if the ratio is really far apart we get almost 1, if the ratio is much closer we get almost 0 
						
						-- if the clutch was opened by the reverser we calculate the clutch time differently 
						if spec.automaticClutch.reverserFlag then -- the lower the rpm the slower the clutch will close 
							spec.automaticClutch.timer = spec.reverser.clutchTime;
							spec.automaticClutch.timerMax = spec.automaticClutch.timer; -- we need that for calculating how far the clutch is closed 	
						else
							spec.automaticClutch.timer = (spec.automaticClutch.closeTimeMax - spec.automaticClutch.closeTimeMin) * ratio + spec.automaticClutch.closeTimeMin; -- maxTime * ratio is our closing time 
							spec.automaticClutch.timerMax = spec.automaticClutch.timer; -- we need that for calculating how far the clutch is closed 		
						end;
						spec.automaticClutch.isOpen = false;
					end;
					spec.clutchPercentAuto = 0;
				end;
				
				-- check if the clutch is closing 
				if spec.automaticClutch.wantClose then
					--print(tostring(spec.automaticClutch.timer));
					spec.automaticClutch.timer = math.max(spec.automaticClutch.timer - dt, 0); -- remove from timer 
					if spec.automaticClutch.timer == 0 then -- timer is 0, clutch is closed, reset everything
						--spec.automaticClutch.isOpen = false; 
						spec.automaticClutch.wantClose = false;
						spec.automaticClutch.wantedGear = nil;
						spec.automaticClutch.wantedRange = nil;
					end;
					spec.clutchPercentAuto = 1- (spec.automaticClutch.timer / spec.automaticClutch.timerMax); 
				end;
				
				
				-- check if we have automatic opening at minRpm enabled 
				if spec.automaticClutch.enableOpeningAtLowRPM  then
					-- check if we are below openingRPM and accelerator is not 1
					-- only open clutch if we aren't trying to accelerate. That way you can still stall a tractor if you keep trying to accelerate below min RPM 
					-- but as soon as you let off the throttle the clutch will open 
					local axisFWD = math.max(0, self:getAxisForward())
					if self.spec_motorized.motor.lastRealMotorRpm < spec.automaticClutch.openingAtLowRPMLimit and axisFWD < 0.5 then
						-- check if clutch is already opening or already open,  if not, open it 
						if not spec.automaticClutch.wantOpen and not spec.automaticClutch.isOpen then
							spec.automaticClutch.wantOpen = true; 
							spec.automaticClutch.timer = spec.automaticClutch.openTime; -- put openTime in timer 
							spec.automaticClutch.timerMax = spec.automaticClutch.timer; -- store the max timer value, we need that later 
							spec.automaticClutch.wantedGear = nil; -- no wanted gear, we just want to open the clutch  
							spec.automaticClutch.preventClosing = true;
							spec.automaticClutch.openingAtLowRPMTriggered = true;
						end;
					else 
						-- check if clutch is open
						-- check if we automatically opened the clutch, in that case close it again 
						if spec.automaticClutch.preventClosing and spec.automaticClutch.openingAtLowRPMTriggered then
							spec.automaticClutch.preventClosing = false;
							spec.automaticClutch.openingAtLowRPMTriggered = false;
						end;
					
					end;
				
				end;
					
			
			end;
			
			-- direction selection
			-- check if the gear or range we are in is reverse
			local reverseRatio = 1; -- we start out in forward mode 
			if spec.gears[spec.currentGear].isReverse then
				reverseRatio = reverseRatio * -1; -- if the gear is reverse, * -1 puts us in reverse 
			end;
			if spec.rangeSet1 ~= nil then
				if spec.rangeSet1.ranges[spec.currentRange1].isReverse then
					reverseRatio = reverseRatio * -1; -- if the range is reverse, -1 puts us in reverse. If we already are in reverse, it puts us back forward 
				end;
			end;
			if spec.rangeSet2 ~= nil then
				if spec.rangeSet2.ranges[spec.currentRange2].isReverse then
					reverseRatio = reverseRatio * -1; -- same here. This is useless kinda, but IRL if you had 2 different ranges or gears with reverse-sets thats exactly what would happen 
				end;
			end;
			if spec.rangeSet3 ~= nil then
				if spec.rangeSet3.ranges[spec.currentRange3].isReverse then
					reverseRatio = reverseRatio * -1; -- not sure if there will ever be such a configuration in FS, I don't know a vehicle that has such a configuration.
				end;									-- but as my aim is to create configuration options that would be realistically possible and work like IRL, I'll do it anyways 
			end;
			-- check if we have reverser 
			if spec.reverser ~= nil then
				if not spec.reverser.isForward then 
					reverseRatio = reverseRatio * -1;
				end;
			
			end;
			-- so now we have current wanted range and direction, also apply to spec.isForward variable 
			if reverseRatio == 1 then
				spec.isForward = true;
			else
				spec.isForward = false;
			end;
			
			-- apply reverse 
			self.spec_drivable.reverserDirection = reverseRatio;	

			if spec.debug then
				renderText(0.7, 0.4, 0.02, "wantedLowBrakeForceScale: "..tostring(spec.wantedLowBrakeForceScale));
				renderText(0.7, 0.42, 0.02, "lowBrakeForceScale: "..tostring(self.spec_motorized.motor.lowBrakeForceScale));
				renderText(0.7, 0.44, 0.02, "reverserDirection: "..tostring(self.spec_drivable.reverserDirection));
				renderText(0.7, 0.46, 0.02, "ratio range ratio: "..tostring(spec.wantedGearRatio / spec.gearRatioRange));
				renderText(0.7, 0.48, 0.02, "wantedGearRatio: "..tostring(spec.wantedGearRatio));
				renderText(0.7, 0.5, 0.02, "gearRatioRange: "..tostring(spec.gearRatioRange));
				renderText(0.7, 0.52, 0.02, "actualLoadPercentage: "..tostring(self.spec_motorized.actualLoadPercentage));
				renderText(0.7, 0.54, 0.02, "smoothedLoadPercentage: "..tostring(self.spec_motorized.smoothedLoadPercentage));
				renderText(0.7, 0.56, 0.02, "reverseRatio: "..tostring(reverseRatio));
				renderText(0.7, 0.58, 0.02, "curGear is Reverse: "..tostring(spec.gears[spec.currentGear].isReverse));
				if spec.rangeSet1 ~= nil then
					renderText(0.7, 0.6, 0.02, "range1 is Reverse: "..tostring(spec.rangeSet1.ranges[spec.currentRange1].isReverse));
				end;
				if spec.rangeSet2 ~= nil then
					renderText(0.7, 0.62, 0.02, "range2 is Reverse: "..tostring(spec.rangeSet2.ranges[spec.currentRange2].isReverse));
				end;
				if spec.rangeSet3 ~= nil then
					renderText(0.7, 0.64, 0.02, "range3 is Reverse: "..tostring(spec.rangeSet3.ranges[spec.currentRange3].isReverse));
				end;
			end;
				
		else	-- reset stuff if we turn RMT off 
			if self.hasRMT and not self.rmtIsOn then
					
				-- reset gear ratios 
				self.spec_motorized.motor.minForwardGearRatio = self.spec_realManualTransmission.minForwardGearRatioBackup;
				self.spec_motorized.motor.maxForwardGearRatio = self.spec_realManualTransmission.maxForwardGearRatioBackup;
		
				self.spec_motorized.motor.minBackwardGearRatio = self.spec_realManualTransmission.minBackwardGearRatioBackup;
				self.spec_motorized.motor.maxBackwardGearRatio= self.spec_realManualTransmission.maxBackwardGearRatioBackup;	
				
				-- reset low brakeforce 
				self.spec_motorized.motor.lowBrakeForceScale = self.spec_realManualTransmission.lowBrakeForceScaleBackup;
				
				-- reset driving direction
				self.spec_drivable.reverserDirection = 1;
			end;
		end;
	end;
end;

-- the getRequiredMotorRpmRange makes sure that the vehicle always operates in the by the PTO implement required RPM range.. E.g. exact RPM.
-- with CVT/automatic gearbox this is what we want.. But with manual gearbox, this is not what we want.. 
-- so we need to disable that mechanic.
local oldGetRequiredMotorRpmRange = VehicleMotor.getRequiredMotorRpmRange;
function realManualTransmission:getRequiredMotorRpmRange()
	if not self.vehicle.hasRMT or not self.vehicle.rmtIsOn then
		return oldGetRequiredMotorRpmRange(self)
	else
	
		--local motorPtoRpm = math.min(PowerConsumer.getMaxPtoRpm(self.vehicle)*self.ptoMotorRpmRatio, self.maxRpm)
		--if motorPtoRpm ~= 0 then
		--	return motorPtoRpm, motorPtoRpm
		--end
		return self.minRpm, self.maxRpm
	end;
end
VehicleMotor.getRequiredMotorRpmRange = realManualTransmission.getRequiredMotorRpmRange;

local oldMotorUpdate = VehicleMotor.update;
function realManualTransmission:newMotorUpdate(dt)
	local vehicle = self.vehicle
	if not vehicle.hasRMT or not vehicle.rmtIsOn then
		oldMotorUpdate(self, dt);	
	else
		
		if next(vehicle.spec_motorized.differentials) ~= nil and vehicle.spec_motorized.motorizedNode ~= nil then
			-- Only update the physics values if a physics simulation was performed
			if g_physicsDtNonInterpolated > 0.0 then
				local lastMotorRotSpeed = self.motorRotSpeed;
				local lastDiffRotSpeed = self.differentialRotSpeed
				self.motorRotSpeed, self.differentialRotSpeed, self.gearRatio = getMotorRotationSpeed(vehicle.spec_motorized.motorizedNode)
				
				
				self.motorAvailableTorque, self.motorAppliedTorque, self.motorExternalTorque = getMotorTorque(vehicle.spec_motorized.motorizedNode)
			

				local motorRotAcceleration = (self.motorRotSpeed - lastMotorRotSpeed) / (g_physicsDtNonInterpolated*0.001)
				self.motorRotAcceleration = motorRotAcceleration
				self.motorRotAccelerationSmoothed = 0.8 * self.motorRotAccelerationSmoothed + 0.2 * motorRotAcceleration

				local diffRotAcc = (self.differentialRotSpeed - lastDiffRotSpeed) / (g_physicsDtNonInterpolated*0.001)
				self.differentialRotAcceleration = diffRotAcc
				self.differentialRotAccelerationSmoothed = 0.8 * self.differentialRotAccelerationSmoothed + 0.2 * diffRotAcc

				--print(string.format("update rpms: %.2f %.2f acc: %.2f", self.motorRotSpeed*30/math.pi, self.differentialRotSpeed*self.gearRatio*30/math.pi, motorRotAcceleration))
			end

			self.requiredMotorPower = math.huge

		else
			local _, gearRatio = self:getMinMaxGearRatio()
			self.differentialRotSpeed = WheelsUtil.computeDifferentialRotSpeedNonMotor(vehicle)
			self.motorRotSpeed = math.max(self.differentialRotSpeed * gearRatio, 0)
			self.gearRatio = gearRatio
		end

		local clampedMotorRpm = math.max(self.motorRotSpeed*30/math.pi, self.minRpm)
		
		
		self.lastPtoRpm = clampedMotorRpm;
		
		-- modelleicher 
		-- if clutch is pressed, motor RPM is not dependent on wheel speed anymore.. Instead, calculate motor RPM based on accelerator pedal input 
		if vehicle.spec_realManualTransmission.clutchPercent < 0.999 or vehicle.spec_realManualTransmission.neutral then
			local clutchPercent = vehicle.spec_realManualTransmission.clutchPercent;
			if vehicle.spec_realManualTransmission.neutral then
				clutchPercent = 0;
			end;	
			local accInput = 0
			if vehicle.getAxisForward ~= nil then
				accInput = math.max(0, vehicle:getAxisForward());
			end;
			
			-- take hand throttle into account 
			accInput = math.max(accInput, vehicle.spec_realManualTransmission.handThrottlePercent);
			
			local wantedRpm = (self.maxRpm - self.minRpm) * accInput + self.minRpm;
			local currentRpm = self.lastRealMotorRpm;
			if currentRpm < wantedRpm then
				currentRpm = math.min(currentRpm + 2 * dt, wantedRpm);  -- to do, do proper engine rpm increase calculation 
			elseif currentRpm > wantedRpm then
				currentRpm = math.max(currentRpm - 1 * dt, wantedRpm);
			end;
			
			self.lowBrakeForceScale = 0 --(vehicle.spec_realManualTransmission.wantedLowBrakeForceScale * clutchPercent) + (0.0001 * (1-clutchPercent));
			
			--local multi = clutchPercent * 0.7;
			if clutchPercent < 0.2 then
				clampedMotorRpm = currentRpm;
			else
				clampedMotorRpm = (clampedMotorRpm * ((clutchPercent-0.2)*1.25)) + (currentRpm * (1-((clutchPercent-0.2)*1.25)));
			end;
			--renderText(0.1, 0.2, 0.02, "clampedMotorRpm: "..tostring(clampedMotorRpm).." currentRpm: "..tostring(currentRpm).." wantedRpm: "..tostring(wantedRpm).." accInput: "..tostring(accInput));
		else
			
			self.lowBrakeForceScale = 0 --vehicle.spec_realManualTransmission.wantedLowBrakeForceScale;
			--clampedMotorRpm = math.max(self.motorRotSpeed*30/math.pi, ptoRpm, self.minRpm)
			
			-- get clutch RPM shut off motor if RPM gets too low , disable "auto clutch" of FS
			local clutchRpm = math.abs(self:getClutchRotSpeed() *  9.5493);
			
			if clutchRpm < self.minRpm then
				clampedMotorRpm = (self.lastRealMotorRpm * 0.7) + (clutchRpm * 0.3);
			end;
			--renderText(0.1, 0.3, 0.02, "clutchRpm: "..tostring(clutchRpm));
		end;
		
		if clampedMotorRpm < 500 then -- to do, add stall rpm variable 
			-- stall the engine 
			vehicle.spec_realManualTransmission.stallTimer = math.max(vehicle.spec_realManualTransmission.stallTimer - dt, 0);
			if vehicle.spec_realManualTransmission.stallTimer == 0 then
				vehicle:stopMotor()
			end;
		else
			vehicle.spec_realManualTransmission.stallTimer = 500;
		end;
		
		clampedMotorRpm = math.max(clampedMotorRpm, 500);
		
		-- stupid smoothing 
		vehicle.spec_realManualTransmission.lastRealRpm = (vehicle.spec_realManualTransmission.lastRealRpm * 0.1) + (clampedMotorRpm * 0.9);
		
		-- end modelleicher 
		--

		self:setLastRpm(vehicle.spec_realManualTransmission.lastRealRpm)

		self.equalizedMotorRpm = (self.equalizedMotorRpm * 0.8) + ( 0.2 * vehicle.spec_realManualTransmission.lastRealRpm);
	end;
end;
VehicleMotor.update = realManualTransmission.newMotorUpdate;

-- I'm trying to somehow get the sound to pitch above a modifier value of 1.. but so far no success
-- anyhow.. this is how to overwrite a modifier return function..
function realManualTransmission:returnRpmNonClamped()
	return self.spec_motorized.motor.lastRealMotorRpm / self.spec_motorized.motor.maxRpm;
end;
--g_soundManager.modifierTypeIndexToDesc[SoundModifierType.MOTOR_RPM].func = realManualTransmission.returnRpmNonClamped

-- g_soundManager.modifierTypeIndexToDesc[SoundModifierType.MOTOR_LOAD].func = function (self) return 0.5 end

-- Motorized:getMotorLoadPercentage()
	
-- self:getMotorRpmPercentage()
local oldUpdateWheelsPhysics = WheelsUtil.updateWheelsPhysics;
function realManualTransmission.newUpdateWheelsPhysics(self, dt, currentSpeed, acceleration, doHandbrake, stopAndGoBraking)
	if not self.hasRMT or not self.rmtIsOn then
		oldUpdateWheelsPhysics(self, dt, currentSpeed, acceleration, doHandbrake, stopAndGoBraking);
	else

		local acceleratorPedal = 0
	    local brakePedal = 0
		
	
	    local reverserDirection = 1
	    if self.spec_drivable ~= nil then
	        reverserDirection = self.spec_drivable.reverserDirection
	    end
		
		-- back up acceleration variable before we do any changes to it. This is only for debug reasons 
		local accBackup = acceleration;
		

		
		-- different acceleration calculation ( V 0.0.3.5 )
		
		local motor = self.spec_motorized.motor;
		local spec = self.spec_realManualTransmission;
		
		local newWantedAcceleration = 0;
		-- use acceleration as rpm setting 
		if acceleration >= 0 then -- we are not braking 
		
			-- if hand throttle is more than acceleration, use hand throttle value 
			acceleration = math.max(acceleration, self.spec_realManualTransmission.handThrottlePercent);	
			
			-- calculate the currently wanted RPM depending on acceleration (e.g. pedal position)
			local wantedRpm = (motor.maxRpm - motor.minRpm) * acceleration + motor.minRpm;
			
			-- if our wantedRPM is higher than the currentRPM, increase acceleration, if its lower, decrease acceleration
			if wantedRpm > motor.lastRealMotorRpm then
				--local difference = 1 - (motor.lastRealMotorRpm / wantedRpm);
				newWantedAcceleration = 1;
			else
				newWantedAcceleration = 0;
			end;
		
		end;
		
		spec.lastWantedAcceleration = newWantedAcceleration;
		
		--renderText(0.3, 0.3, 0.02, "last wanted acceleration: "..tostring(spec.lastWantedAcceleration));
		
		acceleration = spec.lastWantedAcceleration;
		
		-- if engine rpm falls below minRpm acceleration is 1
		if acceleration >= 0 and self.spec_motorized.motor.lastRealMotorRpm <= (self.spec_motorized.motor.minRpm +2) then
			acceleration = 1;
		end;
				
		-- if hand throttle is more than acceleration, use hand throttle value 
		--acceleration = math.max(acceleration, self.spec_realManualTransmission.handThrottlePercent);
		
	
		-- if we are in neutral, don't accelerate
		if self.spec_realManualTransmission.neutral then
			acceleration = 0; 
		end;
		
		-- also, acceleration if clutch is present is dependent on clutch engagement percentage (only on positive acceleration, not on braking)
		if acceleration > 0 then
			acceleration = math.min(acceleration, acceleration*(self.spec_realManualTransmission.clutchPercent)) -- at 20% clutch engagement we already want almost 80% acceleration, this feels better 
		end;
		
		-- version 0.0.2.5 change 
		if self.spec_realManualTransmission.clutchPercent < 0.2 then -- at 0.2 the clutch is "fully disengaged" the other 20% are empty movement like IRL 
			acceleration = 0;
		end;
		
		
		if self.spec_realManualTransmission.clutchIsClosing then -- if the clutch is currently moving and moving towards closing, we want to give an acceleration boost to combat the fakeness of the clutch engagement 
			acceleration = math.min(acceleration, 0.3);
		end;
		
		-- if the motor is off, don't accelerate either, but allow for braking
		-- we need to get the axis for this since acceleration in this function is 0 when the motor is off 
		if not self.spec_motorized.isMotorStarted then
			
			if self.getAxisForward ~= nil then
				acceleration = math.min(0, self:getAxisForward());
			end;
			
		end;			
				
		-- sadly, we can't accelerate and brake at the same time.. So.. 
		if accBackup < 0 then -- negative value, braking
			acceleration = accBackup;
		end;		
		
	    self.nextMovingDirection = Utils.getNoNil(self.nextMovingDirection, 0)
		
		-- set accelerationPedal desired value 
		if acceleration > 0 then
			acceleratorPedal = acceleration;
		end;
		
		-- set brake pedal desired value  
		if acceleration < 0 then
			brakePedal = math.abs(acceleration);
		end;
		-- 
	
	    acceleratorPedal = motor:updateGear(acceleratorPedal, dt)
	

	    -- ToDo: move to Lights ?!
	    if self.spec_lights ~= nil then
	        if self.setBrakeLightsVisibility ~= nil then
	            self:setBrakeLightsVisibility(math.abs(brakePedal) > 0)
	        end
	
	        if self.setReverseLightsVisibility ~= nil then
	            self:setReverseLightsVisibility((currentSpeed < -0.0006 or acceleratorPedal < 0) and reverserDirection == 1)
	        end
	    end
	
	    --acceleratorPedal, brakePedal = WheelsUtil.getSmoothedAcceleratorAndBrakePedals(self, acceleratorPedal, brakePedal, dt)
	
	    if next(self.spec_motorized.differentials) ~= nil and self.spec_motorized.motorizedNode ~= nil then
	
	        local absAcceleratorPedal = math.abs(acceleratorPedal)
	        local minGearRatio, maxGearRatio = motor:getMinMaxGearRatio()
			
			-- modelleicher addition, if we set acceleration to 0 while going reverse it somehow makes gearRatio positive again.. That makes the engine break a lot. We don't want that!
			if not self.spec_realManualTransmission.isForward then
				if MathUtil.sign(minGearRatio) == 1 then
					minGearRatio = minGearRatio * -1;
					maxGearRatio = maxGearRatio * -1;
				end;
			end;
			-- 
	
	        local maxSpeed;
	        if maxGearRatio >= 0 then
	            maxSpeed = motor:getMaximumForwardSpeed()
	        else
	            maxSpeed = motor:getMaximumBackwardSpeed()
	        end
	
	        maxSpeed = math.min(maxSpeed, motor:getSpeedLimit() / 3.6)
	        local maxAcceleration = motor:getAccelerationLimit()
	        local minMotorRpm, maxMotorRpm = motor:getRequiredMotorRpmRange()
			
			--print("max acceleration: "..tostring(maxAcceleration));
			
			
	        local neededPtoTorque = PowerConsumer.getTotalConsumedPtoTorque(self) / motor:getPtoMotorRpmRatio();
			
			local maxClutchTorque = motor:getMaxClutchTorque()
			local clutchPercent = math.max((self.spec_realManualTransmission.clutchPercent-0.2)*1.25, 0);
			maxClutchTorque = maxClutchTorque * (clutchPercent*clutchPercent);
			--print(maxClutchTorque);
			
			maxAcceleration = maxAcceleration * (clutchPercent*clutchPercent);
			--print(maxAcceleration);
	
	        --print(string.format("set vehicle props:   accPed=%.1f   speed=%.1f gearRatio=[%.1f %.1f] rpm=[%.1f %.1f]", absAcceleratorPedal, maxSpeed, minGearRatio, maxGearRatio, minMotorRpm, maxMotorRpm))
	        controlVehicle(self.spec_motorized.motorizedNode, absAcceleratorPedal, maxSpeed, maxAcceleration, minMotorRpm*math.pi/30, maxMotorRpm*math.pi/30, motor:getMotorRotationAccelerationLimit(), minGearRatio, maxGearRatio, maxClutchTorque, neededPtoTorque)
	    end
		
	    self:brake(brakePedal)
	end;
end;
WheelsUtil.updateWheelsPhysics = realManualTransmission.newUpdateWheelsPhysics;


