-- by modelleicher
-- temporary end goal: working manual gearbox with clutch, possibly support for full powershift transmissions.
-- start date: 08.01.2019
-- release Beta on Github date: 03.02.2019

-- current version and changelog:
-- V 0.6.1.4 ###
	-- fixed gear shifting axis so it doesn't override everything else unless the axis is moved 
	-- removed old menu, started on new menu 

realManualTransmission = {};

function realManualTransmission.prerequisitesPresent(specializations)
    return true;
end;

function realManualTransmission.initSpecialization()
	g_configurationManager:addConfigurationType("realManualTransmission", "realManualTransmission", nil, nil, nil, nil, ConfigurationUtil.SELECTOR_MULTIOPTION) -- add config option 
end

function realManualTransmission.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", realManualTransmission);
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", realManualTransmission);
	SpecializationUtil.registerEventListener(vehicleType, "saveToXMLFile", realManualTransmission);
	SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", realManualTransmission);
	
	--SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", realManualTransmission);
	SpecializationUtil.registerEventListener(vehicleType, "onWriteUpdateStream", realManualTransmission);
	--SpecializationUtil.registerEventListener(vehicleType, "onReadStream", realManualTransmission);
	SpecializationUtil.registerEventListener(vehicleType, "onReadUpdateStream", realManualTransmission);
end;

function realManualTransmission:onLoad(savegame)

	self.loadFromXML = realManualTransmission.loadFromXML;
	self.returnRpmNonClamped = realManualTransmission.returnRpmNonClamped;
	self.setHandBrake = realManualTransmission.setHandBrake;
	self.processClutchInput = realManualTransmission.processClutchInput;
	self.processToggleOnOff = realManualTransmission.processToggleOnOff;
	
	self.calculateRatio = realManualTransmission.calculateRatio;
	self.getClutchPercent = realManualTransmission.getClutchPercent;
	
	--
	self.hasRMT = false;
	self.rmtIsOn = false;
	
	-- creating RMT-spec table.
	self.spec_realManualTransmission = {};  
	local spec = self.spec_realManualTransmission; 

	local xmlFile = self.xmlFile;
	
	-- check if the vehicle has realManualTransmission XML entries
	
	-- self.configFilename 
	-- baseDirectory :: C:/Users/Admin/Documents/My Games/FarmingSimulator2019/mods/FS19_deutzAgroStar661/
	-- customEnvironment = FS19_modname
	
	-- check if this vehicle exists in basegameConfigs 
	local configFile = StringUtil.splitString("/", self.configFileName);
	local baseDirectory = StringUtil.splitString("/", self.baseDirectory);
	local basegameConfigsXML = g_currentMission.rmtGlobals.basegameConfigsXML;

	-- base directory "" -> basegame vehicle,  -- path ends in /pdlc/dlcName so its a DLC
	if self.baseDirectory == "" or baseDirectory[#baseDirectory-2] == "pdlc" then 
		print("RMT Debug: "..tostring(configFile[#configFile]).." is not a Mod.");
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
		
	if hasXMLProperty(xmlFile, "vehicle.realManualTransmission") or hasXMLProperty(xmlFile, "vehicle.realManualTransmissionConfigurations.realManualTransmissionConfiguration") then	
		self.hasRMT = true;
		
		-- load from vehicle XML 
		self:loadFromXML(xmlFile, "vehicle.", 0);
		
		self.rmtIsOn = true;
	end;
	
	if self.hasRMT then

		-- calculate max speeds
		local maxSpeedPossible_classicTransmission = self:getMaxSpeedPossible_classicTransmission()

		spec.maxSpeedPossible = maxSpeedPossible_classicTransmission * spec.finalRatio
		-- TO DO - doesn't include reverser yet since its supposed to be 1 for forward anyways.. 

		
		-- back up gear ratios 
		spec.minForwardGearRatioBackup = self.spec_motorized.motor.minForwardGearRatio;
		spec.maxForwardGearRatioBackup = self.spec_motorized.motor.maxForwardGearRatio;
		
		spec.minBackwardGearRatioBackup = self.spec_motorized.motor.minBackwardGearRatio;
		spec.maxBackwardGearRatioBackup = self.spec_motorized.motor.maxBackwardGearRatio;	
		
		-- back up low brakeforce 
		spec.lowBrakeForceScaleBackup = self.spec_motorized.motor.lowBrakeForceScale;
		self.spec_motorized.motor.lowBrakeForceScale = 0;
		
		-- new smoothing tables 
		spec.loadPercentageSmoothing = rmtUtils:addSmoothingTable(20, 0);
		
		spec.clientRpmSmoothing = rmtUtils:addSmoothingTable(20, 800);
		
		-- neutral variable 
		spec.neutral = true;
		spec.isForward = true;
		--
		spec.maxLowBrakeForceScale = 0.60;
		spec.wantedLowBrakeForceScale = 0;
		
		spec.engineBrakeBase = 0.22;
		spec.engineBrakeModifier = 1;
		spec.wantedEngineBrake = 0;
		
		spec.lastWantedAcceleration = 0;

		-- important clutch stuff 
		spec.clutchPercent = 1; -- this is the "actual" clutch percent value
		spec.clutchPercentManual = 1; -- this is the clutch percent value calculated from the clutch pedal 
		spec.clutchPercentAuto = 1; -- this is the clutch percent value calculated from the automatic clutch in auto mode or reverser 
		spec.clutchPercentFluid = 1;
		spec.clutchPercentAutomatic = 1;

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
		
		--self:addCheckBox("buttonReleaseNeutral", "gear button release neutral", 0.05, 0.05, 0.24, 0.58, "buttonReleaseNeutral"); 
	
		spec.switchGearRangeMapping = Utils.getNoNil(spec.switchGearRangeMapping, false);
		--self:addCheckBox("switchGearRangeMapping", "switch gear range1 mappings", 0.05, 0.05, 0.24, 0.53, "switchGearRangeMapping"); 
		
		-- 
		spec.useAutomaticClutch = false;
		
		--self:addCheckBox("useAutoClutch", "use automatic clutch", 0.05, 0.05, 0.24, 0.68, "useAutomaticClutch", nil, "clutchPercentAuto", 1, 1); 
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
		
		--self:addCheckBox("enableOpeningAtLowRPM", "enable auto-clutch open at low RPM", 0.05, 0.05, 0.24, 0.63, "enableOpeningAtLowRPM", spec.automaticClutch, "clutchPercentAuto", 1, 1); 
		
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
			
		--self:addCheckBox("showHud", "show hud", 0.04, 0.04, 0.56, 0.72, "showHud", self.spec_rmtMenu.hud); 
		--self:addCheckBox("showGear", "show gear", 0.04, 0.04, 0.56, 0.68, "showGear", self.spec_rmtMenu.hud); 
		--self:addCheckBox("showRange", "show range", 0.04, 0.04, 0.56, 0.64, "showRange", self.spec_rmtMenu.hud); 
		--self:addCheckBox("showReverser", "show reverser", 0.04, 0.04, 0.56, 0.60, "showReverser", self.spec_rmtMenu.hud); 
		--self:addCheckBox("showClutch", "show clutch value", 0.04, 0.04, 0.56, 0.56, "showClutch", self.spec_rmtMenu.hud); 
		--self:addCheckBox("showRpm", "show RPM", 0.04, 0.04, 0.56, 0.52, "showRpm", self.spec_rmtMenu.hud); 
		--self:addCheckBox("showHandbrake", "show Handbrake", 0.04, 0.04, 0.56, 0.48, "showHandbrake", self.spec_rmtMenu.hud); 
		--self:addCheckBox("showSpeed", "show wanted speed", 0.04, 0.04, 0.56, 0.44, "showSpeed", self.spec_rmtMenu.hud); 
		--self:addCheckBox("showLoad", "show engine load", 0.04, 0.04, 0.56, 0.40, "showLoad", self.spec_rmtMenu.hud); 

		--
		--
		spec.disableTurningOff = false; -- turn is variable to true in order to disable the ability to turn RMT on/off via Button 
		
		
		spec.synchClutchInputDirtyFlag = self:getNextDirtyFlag()
		--spec.synchRpmDirtyFlag = self:getNextDirtyFlag()

		spec.synchHandThrottleDirtyFlag = self:getNextDirtyFlag()
		
		
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
				if self.spec_rmtReverser ~= nil and self.spec_rmtReverser.lastBrakeForce > 0 then
					brake = math.max(brake, self.spec_rmtReverser.lastBrakeForce); 
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
		
		-- V 0.4.0.6 addition of configurations 
		if self.configurations ~= nil then 
			if self.configurations.realManualTransmission ~= nil then -- see if we have configurations 
				-- change key to config key 
				key = key.."realManualTransmissionConfigurations.realManualTransmissionConfiguration("..(self.configurations.realManualTransmission-1)..").";
			end;

			-- update objectChanges V 0.6.1.3
			local rmtConfigurationId = Utils.getNoNil(self.configurations["realManualTransmission"], 1)
			ObjectChangeUtil.updateObjectChanges(self.xmlFile, "vehicle.realManualTransmissionConfigurations.realManualTransmissionConfiguration", rmtConfigurationId , self.components, self)
						
		end;
		
		-- rated rpm at which max speed is reached, can be different to max rpm (if it doesn't exist it equals max rpm) 
		spec.ratedRpm = Utils.getNoNil(getXMLFloat(xmlFile, key.."realManualTransmission("..i..")#ratedRpm"), self.spec_motorized.motor.maxRpm);
		
		-- 836 @2200rpm is giants "constant" for speed conversion -> the higher the rpm above 2200 lower the value to keep the same speed 
		spec.ratioRpmConstant = 836 * (spec.ratedRpm / 2200 ) 
		
		-- load classic transmission, gears and ranges 
		self:loadFromXML_classicTransmission(xmlFile, key, i);

		self:loadFromXML_reverser(xmlFile, key, i);

		self:loadFromXML_automatic(xmlFile, key, i);
		
		-- fluid clutch (like Fendt Turbomatik)
		local stallRpm = getXMLInt(xmlFile, key.."realManualTransmission("..i..").fluidClutch#stallRpm")
		if stallRpm ~= nil and stallRpm ~= "" then
			spec.fluidClutch = {};
			spec.fluidClutch.stallRpm = stallRpm;
		end;
		
		spec.finalRatio = Utils.getNoNil(getXMLFloat(self.xmlFile, key.."realManualTransmission("..i..")#finalRatio"), 1);
		spec.switchGearRangeMapping = Utils.getNoNil(getXMLFloat(self.xmlFile, key.."realManualTransmission("..i..")#switchGearRangeMapping"), false);


		spec.engineStallRpm = Utils.getNoNil(getXMLFloat(self.xmlFile, key.."realManualTransmission("..i..")#engineStallRpm"), 500)
		spec.engineStallTimer = Utils.getNoNil(getXMLFloat(self.xmlFile, key.."realManualTransmission("..i..")#engineStallTimer"), 500)

end;

function realManualTransmission:setHandBrake(state, noEventSend)
	setHandbrakeEvent.sendEvent(self, state, noEventSend);
	self.spec_realManualTransmission.handBrake = state;
end;

function realManualTransmission:processClutchInput(inputValue, noEventSend)
	processClutchInputEvent.sendEvent(self, inputValue, noEventSend);
	local spec = self.spec_realManualTransmission;
	--print("processClutchInput: "..tostring(inputValue));
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


function realManualTransmission:processToggleOnOff(state, isUserInput, noEventSend)
	
	if self.spec_realManualTransmission ~= nil and self.hasRMT then
		if isUserInput and self.spec_realManualTransmission.disableTurningOff then
			-- TO DO: Show message that disabling RMT was disabled on the server/savegame.
		else
			if state ~= nil then
				self.rmtIsOn = state;
			else
				self.rmtIsOn = not self.rmtIsOn;
				state = self.rmtIsOn;
			end;
			-- if we switched RMT off, reset a few values
			if not self.rmtIsOn then
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
			processToggleOnOffEvent.sendEvent(self, state, noEventSend);
		end;
		
	end;

end;

-- function to calculate the current ratio or speed given all ranges, gears, reversers and so on.
-- can either be used to calculate current actual speed or if given other than current paramenters to calculate possible speed in a different gear/range/setting etc.
function realManualTransmission:calculateRatio(returnSpeed, gear, range1, range2, range3, reverserDirection)
	local spec = self.spec_realManualTransmission;

	-- get reverser direction and ratio 
	local _, reverserRatioGet = self:getDirectionAndRatio_reverser(reverserDirection)

	local _, classicTransmissionRatioGet = self:getDirectionAndRatio_classicTransmission(gear, range1, range2, range3)

	if returnSpeed then
		local speed = spec.maxSpeedPossible * classicTransmissionRatioGet * reverserRatioGet * spec.finalRatio;
		--print("return speed: "..tostring(endRatio))
		return speed;
	end;
	
	local endRatio = classicTransmissionRatioGet / reverserRatioGet / spec.finalRatio;
		
	--print("return end ratio: "..tostring(endRatio))

	return endRatio;
end;

function realManualTransmission:getClutchPercent()
	local spec = self.spec_realManualTransmission;
	return math.min(spec.clutchPercentAuto, spec.clutchPercentManual, spec.clutchPercentFluid, spec.clutchPercentAutomatic);
end;

function realManualTransmission:onUpdate(dt) 

	-- debugs...
	local firstTimeRun1 = false;
	if not firstTimeRun1 then
		-- DEBUGS 
		firstTimeRun1 = true;
	end;
	
	if self:getIsActive() then

		
		-- check if we are a hired worker, turn rmt off if worker is hired 
		if self.spec_aiVehicle ~= nil then -- V 0.5.1.2 change, use function with event 
			if self.spec_aiVehicle.isActive and self.rmtIsOnBackup == nil then
				self.rmtIsOnBackup = self.rmtIsOn;
				self:processToggleOnOff(false, nil, nil);  
			elseif not self.spec_aiVehicle.isActive and self.rmtIsOnBackup ~= nil then
				self:processToggleOnOff(self.rmtIsOnBackup, nil, nil);
				self.rmtIsOnBackup = nil;
			end;
		end;	
	
		if self.hasRMT and self.rmtIsOn then 
			local spec = self.spec_realManualTransmission;
			
			-- first, really FIRST, see if analog or digital clutch is more open, use the more open one!
			-- that is to remove glitches when using automatic clutch in reverser together with clutch pedal 
			-- which ever is smaller, use that one
			spec.clutchPercent = self:getClutchPercent(); 

			
			if self.spec_motorized.isMotorStarted then
				if not self.isServer then
					if spec.clutchPercentManual ~= spec.lastClutchPercentManual then
						self:raiseDirtyFlags(spec.synchClutchInputDirtyFlag)
						spec.lastClutchPercentManual = spec.clutchPercentManual;
					end;
				end;
				
				--[[if self.isServer then
					--print("clutchPercent: "..tostring(spec.clutchPercent).." clutchPercentAuto: "..tostring(spec.clutchPercentAuto).." clutchPercentManual: "..tostring(spec.clutchPercentManual));
					if math.floor(spec.lastRealRpm / 10) ~= spec.lastRealRpmLast then
						self:raiseDirtyFlags(spec.synchRpmDirtyFlag);
						spec.lastRealRpmLast = math.floor(spec.lastRealRpm / 10);
					end;
				end;]]
				
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

				-- insert automatic acc override
				if self.spec_rmtAutomatic ~= nil and self.spec_rmtAutomatic.accelerationOverride ~= nil then
					mAxisForward = self.spec_rmtAutomatic.accelerationOverride;
				end;

				spec.lastAxisForward = mAxisForward;

				-- motor load for sound 
				local loadPercentage = self.spec_motorized.motor:getMotorAppliedTorque() / math.max( self.spec_motorized.motor:getMotorAvailableTorque(), 0.0001)

				-- we need the load percentage without PTO to calculate engine brake effect 
				local loadPercentageNoPTO = (self.spec_motorized.motor:getMotorAppliedTorque()-self.spec_motorized.motor:getMotorExternalTorque()) / math.max( self.spec_motorized.motor:getMotorAvailableTorque(), 0.0001)
	

				-- if we are client, use simplified load percentage calculation 
				-- TO DO : make this more accurate - done 
				if not self.isServer then
					rpm = self.spec_motorized.motor.equalizedMotorRpm;
					-- range is between minRpm and maxRpm 
					local range = motor.maxRpm - motor.minRpm;
					local rawPercentage = mAxisForward - ((rpm-motor.minRpm) / range);
					-- if we decelerate we have negative value 
					if rawPercentage < 0 then 
						-- have a little load on hard deceleration 
						loadPercentage = math.abs(rawPercentage*0.2);
					else
						-- we want to have max. load at 25% difference already 
						loadPercentage = math.min(rawPercentage * 10, 1);
					end;
				
				end;
			
				if spec.clutchPercent < 0.6 or spec.neutral or (self.spec_rmtAutomatic ~= nil and self.spec_rmtAutomatic.accelerationOverride ~= nil ) then
					-- if clutch is pressed or neutral, load percentage is calculated using wanted and actual RPM 
					if (rpm / motor.maxRpm) < mAxisForward then
						loadPercentage = 1;
					else
						loadPercentage = 0;
					end;
				end;
				
				-- actual load percentage 
				self.spec_motorized.actualLoadPercentage = loadPercentage;
				
				self.spec_motorized.motorLoadGov = mAxisForward - (rpm / motor.maxRpm) 
				
				
				-- smoothed load percentage 
				-- if loadPercentage is 1, e.g. max load or clutch/neutral, we add the value twice to the smoothing table to half the smoothing for faster reaction time 
				-- changed in V 0.4.2.0
				if loadPercentage > 0.99 then
					rmtUtils:getSmoothingTableAverage(spec.loadPercentageSmoothing, loadPercentage);
				end;
				local newAverage = rmtUtils:getSmoothingTableAverage(spec.loadPercentageSmoothing, loadPercentage);
				self.spec_motorized.smoothedLoadPercentage = newAverage;			
			
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
				
				-- now for the calculation of the actual gear ratio including the clutch calculation 
				if self.isServer then
					spec.neutral = self.spec_rmtClassicTransmission.neutral;


					-- don't outsource ratio calculations that has to stay in main script 
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
						
						-- pre 0.5.1.5
						--local clutchPercent = math.max((spec.clutchPercent-0.2)*1.25, 0); -- calculate clutchPercent in a way that < 0.2 clutch equals 0 
						--actualGearRatio = math.max(spec.wantedGearRatio * clutchPercent + spec.lastGearRatio * (1-clutchPercent), 0); -- now calculate gear ratio between clutch and actual 
					
						
						local clutchPercent = math.max((spec.clutchPercent-0.2)*1.25, 0); -- calculate clutchPercent in a way that < 0.2 clutch equals 0 
						clutchPercent = clutchPercent * clutchPercent;
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
			end;
			
			
			-- now calculate wanted gear ratio with gear and rangeRatio and final ratio 
			spec.wantedGearRatio = self:calculateRatio()
			
			--print(spec.wantedGearRatio)
			
			-- current wanted speed is needed for engine break calculation
			spec.currentWantedSpeed = spec.ratioRpmConstant / spec.wantedGearRatio;  -- 


			-- calculating hand throttle 
			if spec.handThrottleDown then
				spec.handThrottlePercent = math.max(0, spec.handThrottlePercent - 0.001*dt);
				self:raiseDirtyFlags(spec.synchHandThrottleDirtyFlag)
			elseif spec.handThrottleUp then
				spec.handThrottlePercent = math.min(1, spec.handThrottlePercent + 0.001*dt);
				self:raiseDirtyFlags(spec.synchHandThrottleDirtyFlag)				
			end;
				
			-- calculating the automatic clutch 
			--if spec.useAutomaticClutch or spec.reverser ~= nil and spec.reverser.type == "normal" then
			if spec.automaticClutch ~= nil then
			
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
							self:selectGear(spec.automaticClutch.wantedGear);
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
							self:selectRange(spec.automaticClutch.wantedRange, spec.automaticClutch.rangeSetIndex, nil);
						end;
						-- set state to closing 
						spec.automaticClutch.wantClose = true;
						-- now set the closing timer. It depends on current speed / speed difference and max closing time (only for gears, on ranges we always use max. closing time)
					
						ratio = 1-ratio; -- remove ratio value from one, thus, if the ratio is really far apart we get almost 1, if the ratio is much closer we get almost 0 
						
						-- if the clutch was opened by the reverser we calculate the clutch time differently 
						if spec.automaticClutch.reverserFlag then -- the lower the rpm the slower the clutch will close 
							spec.automaticClutch.timer = self.spec_rmtReverser.clutchTime;
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
			
			-- fluid clutch, like Fendt Turbomatik 
			if spec.fluidClutch ~= nil then
				-- get current RPM 
				local motor = self.spec_motorized.motor;
				rpm = motor.lastRealMotorRpm;
				if rpm < spec.fluidClutch.stallRpm then -- if rpm is smaller than stall RPM, calculate opening percentage 
					-- calculate range via minRpm and currentRpm	
					local range = spec.fluidClutch.stallRpm - motor.minRpm;
					-- get the linear closing percentage 
					local linearPercentage = (rpm - motor.minRpm) / range;
					
					-- V 0.6.0.0 fix/change, use non-linear closing of clutch to lessen the stall effect 
					local nonLinearPercentage = linearPercentage * linearPercentage;
					
					-- IRL, at idle the clutch is already partially closed and the vehicle is only held by the brake 
					nonLinearPercentage = rmtUtils:mapValue(nonLinearPercentage, 0, 1, 0.25, 1);					
					
					spec.clutchPercentFluid = math.max(0, math.min(nonLinearPercentage, 1));
				else
					spec.clutchPercentFluid = 1;
				end;
			end;
			


			local reverseRatio = 1; -- we start out in forward mode 

			local classicTransmissionDir, _ = self:getDirectionAndRatio_classicTransmission()
			if not classicTransmissionDir then
				reverseRatio = reverseRatio * -1;	
			end;

			local reverserDir, _ = self:getDirectionAndRatio_reverser()
			if not reverserDir then
				reverseRatio = reverseRatio * -1;	
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

				renderText(0.7, 0.48, 0.02, "wantedGearRatio: "..tostring(spec.wantedGearRatio));

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
				
		end;
	end;
end;

function realManualTransmission:onWriteUpdateStream(streamId, connection, dirtyMask)
	local spec = self.spec_realManualTransmission;
	--print("dirty: "..tostring(dirtyMask));
	if connection:getIsServer() and self.hasRMT then -- client side
		if streamWriteBool(streamId, bitAND(dirtyMask, spec.synchClutchInputDirtyFlag) ~= 0) then
			streamWriteUIntN(streamId, spec.clutchPercentManual * 100, 7);
		end;
		if streamWriteBool(streamId, bitAND(dirtyMask, spec.synchHandThrottleDirtyFlag) ~= 0) then
			streamWriteUIntN(streamId, spec.handThrottlePercent * 100, 7);
		end;		
	end;
	
	--[[if not connection:getIsServer() and self.hasRMT then -- server-side 
		if streamWriteBool(streamId, bitAND(dirtyMask, spec.synchRpmDirtyFlag) ~= 0) then
			streamWriteUIntN(streamId, spec.lastRealRpm / 10, 9);
			print(tostring(spec.lastRealRpm));
		end;
	end;
	]]

	--print("onWriteUpdateStream called");
end;

function realManualTransmission:onReadUpdateStream(streamId, timestamp, connection)
	local spec = self.spec_realManualTransmission;
	
	if not connection:getIsServer() and self.hasRMT then -- server-side ( V 0.5.1.5 fix, hopefully)
		if streamReadBool(streamId) then
			spec.clutchPercentManual = streamReadUIntN(streamId, 7) / 100;
		end;
		if streamReadBool(streamId) then
			spec.handThrottlePercent = streamReadUIntN(streamId, 7) / 100;
		end;		
	end;
	
	--[[if connection:getIsServer() then
		if streamReadBool(streamId) then
			spec.lastRealRpm = streamReadUIntN(streamId, 9) * 10;
			print(tostring(spec.lastRealRpm));
		end;
	end;
	]]
	
	--print("onReadUpdateStream called");

end;




















