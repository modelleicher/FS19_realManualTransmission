-- by modelleicher
-- temporary end goal: working manual gearbox with clutch, possibly support for full powershift transmissions.
-- start date: 08.01.2019
-- release Beta on Github date: 03.02.2019

-- Changelog:
-- V 0.6.0.0 ###
	-- added possibility to add RMT to DLC vehicles via basegameConfigs.xml 
	-- added Claas Arion 400 Quadrashift transmission to  basegameConfigs.xml 
-- V 0.5.1.9 ###
	-- Multiplayer load sound calculation final fix and some other small fixes 
-- V 0.5.1.8 ###
	-- can't remember what I fixed and forgot to add here.. 
-- V 0.5.1.7 ###
	-- small change to load return for sound, load-sound starts to play even at low RPM now 
	-- fixed bug with rangeSet3 lockout code 
	-- improved motorLoad calculation clientSide in multiplayer 
-- V 0.5.1.6 ###
	-- added ability for autoDownshiftSpeed to ranges. For example for Fendt's 40kph variant of the Fendt 500, it automatically downshifts from IV to III at 43.5kph
	-- added support for specific rangeMatching calculation per gear 
-- V 0.5.1.5 ###
	-- autoRangeMatching speedMatching percentage up/down values optional per gear in XML now 
	-- possible fix for error on Servers if vehicle does NOT have RMT 
	-- outsourced Inputs to rmtInputs spec 
	-- added fluid clutch support (for Fendt Turbomatik and similar systems)
	-- added default Config for 500 Fendt to basegameConfigs 
	-- reworked clutch calculation, clutch feeling is different now (tell me if its better) no more stalling tractors trying to slowly slip the clutch on a hill since RPM is pulled down less 	
-- V 0.5.1.4 ###
	-- outsourced functions to rmtUils script 
	-- added new calculateRatio function for future-proofing
	-- changes to the range matching calculation, it should fit better when upshifting now 
-- V 0.5.1.3 ###
	-- fixed reverser naming inconsistency in hud 
-- V 0.5.1.2 ###
	-- fixed Reverser not working when RMT is off 
	-- added automatic range matching 
-- V 0.5.1.1 ###
	-- fixed MP bug where RMT of your vehicle was controlled by other people too
	-- possibly fixed joining synch bug which locks up RMT in some cases 
-- V 0.5.1.0 ###
	-- fixed Range Lockout Bug which made it impossible to shift ranges in some vehicles (also caused an error) 
	-- fixed clutch not working Bug 
-- V 0.5.0.9 ###
	-- MP Beta 2, added rest of the events, fixed things, everything should work in MP now..
-- V 0.5.0.4 ### 
	-- MP Beta, changed lots of stuff around to make MP compatabilty work, added events
-- V 0.4.2.0 ###
	-- added rangeAdjust where you can set up to automatically adjust the range when changing from one gear to another 
	-- changed loadPercentage smoothing, now load increase if actual load is above 0.99 e.g. 1 is smoothed half as much as otherwise to increase reaction time when rev matching 
-- V 0.4.1.0 ###
	-- fixed gear up/down keys being the wrong way around 
-- V 0.4.0.9 ###
	-- fixed Neutral not working with H-Shifter bug that was introduced with the last version 
	-- more basegameConfigs thanks to Johny6210!! Much more basegame vehicles have RMT set up for them already now :)
-- V 0.4.0.8 ###
	-- change and compaction of inputAction adding 
	-- all the overriding moved to rmtOverride now 
	-- reverser mode "clutchOnly" added where you can only reverse driving direction through the reverser if clutch is pressed 
-- V 0.4.0.7 ###
	-- added default naming for gears if name="" attribute is missing in config 
	-- having gears is no longer needed (in order for other transmission types to work later on)
-- V 0.4.0.6 ###
	-- fixed Log Error when shifting into non-existing gear with H-Shifter 
	-- added realManualTransmissionConfigurations so you can have multiple transmission configs in one vehicle 
	-- fixed bug that menu settings did not save 
	-- fixed bug in disableRange feature where you could still shift into disabled range 
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

function realManualTransmission.initSpecialization()
	g_configurationManager:addConfigurationType("realManualTransmission", "realManualTransmission", nil, nil, nil, nil, ConfigurationUtil.SELECTOR_MULTIOPTION) -- add config option 

	--realManualTransmission.modifier_MOTOR_LOAD_GOV = g_soundManager:registerModifierType("MOTOR_LOAD_GOV", realManualTransmission.returnMotorLoadGov, realManualTransmission.returnMotorLoadGovMin, realManualTransmission.returnMotorLoadGovMax);
end


function realManualTransmission.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", realManualTransmission);
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", realManualTransmission);
	SpecializationUtil.registerEventListener(vehicleType, "saveToXMLFile", realManualTransmission);
	SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", realManualTransmission);
	
	SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", realManualTransmission);
	SpecializationUtil.registerEventListener(vehicleType, "onWriteUpdateStream", realManualTransmission);
	SpecializationUtil.registerEventListener(vehicleType, "onReadStream", realManualTransmission);
	SpecializationUtil.registerEventListener(vehicleType, "onReadUpdateStream", realManualTransmission);
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


function realManualTransmission:processGearInputs(gearValue, sequentialDir, noEventSend)
	-- send the event here, this is the last clienct & server function 
	processGearInputsEvent.sendEvent(self, gearValue, sequentialDir, noEventSend);
	-- now start the server-stuff 
	if self.isServer then
		local spec = self.spec_realManualTransmission;
		if sequentialDir == 0 then -- we called this via direct selection, so we select the gear or range directly 
			self:selectGear(gearValue, gearValue);
		end;
		
		if sequentialDir == 1 or sequentialDir == -1 then -- we called this via up/down keys e.g. sequential
			-- just select the gear we want to.. see if we get lockOut back 
			local lockOut = self:selectGear(spec.currentGear + (1*sequentialDir));
			-- if we get locked out of the gear we want to shift in, try to shift down to the next gear and the next
			-- to see if we can shift into the next allowed gear, stop if 1 is reached 
			if lockOut then
				local i = 2;
				while true do
					local curGear = math.min(math.max(1, spec.currentGear - (i*sequentialDir)), spec.numberOfGears); -- cur wanted gear is i or 1
					lockOut = self:selectGear(curGear); -- try the next gear, return if we are locked out again 
					if lockOut and (curGear == 1 or curGear == spec.numberOfGears) or lockOut == false then -- if we're still locked out but curGear is 1 or max gear, stop looking for gears 
						break;
					end;	
					i = i+1;
				end;
			end;
		end;
	end;
end;

function realManualTransmission:processRangeInputs(up, index, force, noEventSend)
	-- send the event here, this is the last clienct & server function 
	processRangeInputsEvent.sendEvent(self, up, index, force, noEventSend);
	--print("process range inputs");
	-- now start the server-stuff 
	if self.isServer then
		local spec = self.spec_realManualTransmission;

		
		local rangeSet = spec["rangeSet"..tostring(index)]; -- convert range set index to table 
		local other1, other2;
		if index == 1 then other1 = 2; other2 = 3 end;
		if index == 2 then other1 = 1; other2 = 3 end;
		if index == 3 then other1 = 1; other2 = 2 end;
		
		local wantedRange = spec["currentRange"..tostring(index)] + up;
		
		if force ~= 0 and force ~= nil then
			wantedRange = force;
		end;
		
		-- make sure our wantedRange is between min and max range we have 
		wantedRange = math.max(1, math.min(wantedRange, rangeSet.numberOfRanges));
		
		local lockOutTrue, wantedNeutral = self:checkRangeLockOut(wantedRange, index, other1, other2);
		
		if lockOutTrue then
			wantedRange = nil;
		end;	
		
		if wantedRange ~= nil then
			self:selectRange(wantedRange, index, wantedNeutral);
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

function realManualTransmission:onLoad(savegame)

	self.loadGears = realManualTransmission.loadGears;
	self.loadRanges = realManualTransmission.loadRanges;
	self.selectGear = realManualTransmission.selectGear;
	self.selectRange = realManualTransmission.selectRange;
	self.selectReverser = realManualTransmission.selectReverser;
	self.loadFromXML = realManualTransmission.loadFromXML;
	self.processGearInputs = realManualTransmission.processGearInputs;
	self.returnRpmNonClamped = realManualTransmission.returnRpmNonClamped;
	self.setHandBrake = realManualTransmission.setHandBrake;
	self.processRangeInputs = realManualTransmission.processRangeInputs;
	self.checkRangeLockOut = realManualTransmission.checkRangeLockOut;
	self.processClutchInput = realManualTransmission.processClutchInput;
	self.synchGearsAndRanges = realManualTransmission.synchGearsAndRanges;
	self.processToggleOnOff = realManualTransmission.processToggleOnOff;
	
	self.calculateRatio = realManualTransmission.calculateRatio;
	
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

	--print(tostring(baseDirectory[#baseDirectory-2]));
	--print(tostring(configFile[#configFile]));	
	
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
		if spec.highestGearSpeed ~= nil then	
			spec.maxSpeedPossible = spec.highestGearSpeed * ratio * spec.finalRatio;
		else
			spec.maxSpeedPossible = 836 / ratio * spec.finalRatio;
		end;
		
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
		spec.loadPercentageSmoothing = rmtUtils:addSmoothingTable(20, 0);
		
		spec.clientRpmSmoothing = rmtUtils:addSmoothingTable(20, 800);
		
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
		spec.clutchPercentFluid = 1;
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
		
		self:addCheckBox("useAutoClutch", "use automatic clutch", 0.05, 0.05, 0.24, 0.68, "useAutomaticClutch", nil, "clutchPercentAuto", 1); 
			
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
		
		self:addCheckBox("enableOpeningAtLowRPM", "enable auto-clutch open at low RPM", 0.05, 0.05, 0.24, 0.63, "enableOpeningAtLowRPM", spec.automaticClutch, "clutchPercentAuto", 1); 
		
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
		spec.disableTurningOff = false; -- turn is variable to true in order to disable the ability to turn RMT on/off via Button 
		
		
		spec.synchClutchInputDirtyFlag = self:getNextDirtyFlag()
		--spec.synchRpmDirtyFlag = self:getNextDirtyFlag()
		
		
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
		
		-- V 0.4.0.6 addition of configurations 
		if self.configurations ~= nil then 
			if self.configurations.realManualTransmission ~= nil then -- see if we have configurations 
				-- change key to config key 
				key = key.."realManualTransmissionConfigurations.realManualTransmissionConfiguration("..(self.configurations.realManualTransmission-1)..").";
			end;
		end;
	
		-- first, load gears from XML 
		local gears, numberOfGears, highestSpeed = self:loadGears(xmlFile, key.."realManualTransmission("..i..").gears.gear(");
		if numberOfGears ~= nil and numberOfGears > 0 then
			spec.gears = gears;
			spec.numberOfGears = numberOfGears;
			spec.defaultGear = Utils.getNoNil(getXMLInt(xmlFile, key.."realManualTransmission("..i..").gears#defaultGear"), 1);
			spec.gearsPowershift = Utils.getNoNil(getXMLBool(xmlFile, key.."realManualTransmission("..i..").gears#powerShift"), false);
			spec.highestGearSpeed = highestSpeed;
		end;
		
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
		---	print("loaded rangeSet1");
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
		---	print("loaded rangeSet2");
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
		--	print("loaded rangeSet3");
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
		
		-- fluid clutch (like Fendt Turbomatik)
		local stallRpm = getXMLInt(xmlFile, key.."realManualTransmission("..i..").fluidClutch#stallRpm")
		if stallRpm ~= nil and stallRpm ~= "" then
			spec.fluidClutch = {};
			spec.fluidClutch.stallRpm = stallRpm;
		end;
		
		spec.finalRatio = Utils.getNoNil(getXMLFloat(self.xmlFile, key.."realManualTransmission("..i..")#finalRatio"), 1);
		spec.switchGearRangeMapping = Utils.getNoNil(getXMLFloat(self.xmlFile, key.."realManualTransmission("..i..")#switchGearRangeMapping"), false);
		spec.autoRangeMatching = Utils.getNoNil(getXMLBool(self.xmlFile, key.."realManualTransmission("..i..")#autoRangeMatching"), false);

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
		
		-- V 0.5.1.6 automatic downshifting at certain speed 
		local autoDownshiftSpeed = getXMLFloat(xmlFile, key..i..")#autoDownshiftSpeed");
		if autoDownshiftSpeed ~= nil then
			range.autoDownshiftSpeed = autoDownshiftSpeed;
		end;
		
				
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
		gear.name = Utils.getNoNil(getXMLString(xmlFile, key..i..")#name"), tostring(i+1));
		gear.isReverse = getXMLBool(xmlFile, key..i..")#isReverse");
		
		-- we can map the gear to a gear-input that is not the number of the gear 
		gear.mappedToGear = Utils.getNoNil(getXMLInt(xmlFile, key..i..")#mappedToGear"), i+1);
		spec.gearMappings[gear.mappedToGear] = i+1;
		
		-- rangeAdjusts, if we want to adjust the range when switching gears 
		local rangeAdjusts = {};
		local r = 0;
		while true do
			local rangeAdjust = {};
			rangeAdjust.from = getXMLInt(xmlFile, key..i..").rangeAdjust("..r..")#from");
			rangeAdjust.range = getXMLInt(xmlFile, key..i..").rangeAdjust("..r..")#range");
			rangeAdjust.rangeSetIndex = Utils.getNoNil(getXMLInt(xmlFile, key..i..").rangeAdjust("..r..")#rangeSetIndex"), 1);
			if rangeAdjust.from == nil then
				break;
			else
				table.insert(rangeAdjusts, rangeAdjust);
			end;
			r = r+1;
		end;
		if r ~= 0 then
			gear.rangeAdjusts = rangeAdjusts;
		end;
		
		-- speedmatching percentage 						
		gear.speedMatchingPercentageUp = 1 + Utils.getNoNil(getXMLFloat(xmlFile, key..i..")#speedMatchingPercentageUp"), 0.25) 
		gear.speedMatchingPercentageDown = 1 + Utils.getNoNil(getXMLFloat(xmlFile, key..i..")#speedMatchingPercentageDown"), 0.0) 
		
		-- insert gear to gears table 
		table.insert(gears, gear);
		i = i+1;
	end;
	local numberOfGears = i; -- count of all gears 
	
	-- return the gears table and the number of gears 
	return gears, numberOfGears, highestSpeed;
end;


function realManualTransmission:checkRangeLockOut(wantedRange, rangeSet, other1, other2)
	local spec = self.spec_realManualTransmission;
	local strRangeSet1 = "rangeSet"..tostring(rangeSet);
	local strRangeSet2 = "rangeSet"..tostring(other1);
	local strRangeSet3 = "rangeSet"..tostring(other2);
	
	local strCurrentRange1 = "currentRange"..tostring(rangeSet);
	local strCurrentRange2 = "currentRange"..tostring(other1);
	local strCurrentRange3 = "currentRange"..tostring(other2);
		
	local strDisableRangesType1 = "disableRanges"..tostring(rangeSet).."Type";
	local strDisableRangesType2 = "disableRanges"..tostring(other1).."Type";
	local strDisableRangesType3 = "disableRanges"..tostring(other2).."Type";
	local strDisableRangesTable1 = "disableRanges"..tostring(other1).."Table";
	local strDisableRangesTable2 = "disableRanges"..tostring(other2).."Table";
	
	local lockOutTrue = false;
	local wantedNeutral = false;
	
	-- check if we can shift into this range or if it is disabled in the gear we are in 
	if spec[strRangeSet1] ~= nil then
		if spec[strRangeSet1].ranges[wantedRange].disableGearsTable ~= nil and spec[strRangeSet1].disableGearsTable[tostring(spec.currentGear)] then 
			if spec[strRangeSet1].ranges[wantedRange].disableGearsType == "lock" then -- we can not shift into this range because it is locked in this gear 
				lockOutTrue = true;
			elseif spec[strRangeSet1].ranges[wantedRange].disableGearsType == "neutral" then -- we can shift into the current range but we shift the gear to neutral 
				wantedNeutral = true;
			end;		
		end;
	end;
	
	-- check if the range we want to shift into is disabled in the current Range of the other 2 sets we are in 
	if spec[strRangeSet2] ~= nil and spec[strRangeSet2].ranges[spec[strCurrentRange2]].disableRanges1Table ~= nil and spec[strRangeSet2].ranges[spec[strCurrentRange2]].disableRanges1Table[tostring(wantedRange)] then
		if spec[strRangeSet2].ranges[spec[strCurrentRange2]][strDisableRangesType1] == "lock" then -- we can not shift into this range since it is locked 
			lockOutTrue = true;
		elseif spec[strRangeSet2].ranges[spec[strCurrentRange2]][strDisableRangesType1] == "neutral" then
			-- not implemented yet 
		end;
	end;
	if spec[strRangeSet3] ~= nil and spec[strRangeSet3].ranges[spec[strCurrentRange3]].disableRanges1Table ~= nil and spec[strRangeSet3].ranges[spec[strCurrentRange3]].disableRanges1Table[tostring(wantedRange)] then
		if spec[strRangeSet3].ranges[spec[strCurrentRange3]][strDisableRangesType1] == "lock" then -- we can not shift into this range since it is locked 
			lockOutTrue = true;
		elseif spec[strRangeSet3].ranges[spec[strCurrentRange3]][strDisableRangesType1] == "neutral" then
			-- not implemented yet 
		end;
	end;	
	
	-- check if the range we want to shift into disables any other ranges and locks us out that way 
	if spec[strRangeSet1].ranges[wantedRange][strDisableRangesTable1] ~= nil and spec[strRangeSet1].ranges[wantedRange][strDisableRangesTable1][tostring(spec.currentRange2)] then
		if spec[strRangeSet1].ranges[wantedRange][strDisableRangesType2] == "lock" then
			lockOutTrue = true;
		end;
	end;
	if spec[strRangeSet1].ranges[wantedRange][strDisableRangesTable2] ~= nil and spec[strRangeSet1].ranges[wantedRange][strDisableRangesTable2][tostring(spec.currentRange3)] then
		if spec[strRangeSet1].ranges[wantedRange][strDisableRangesType3] == "lock" then
			lockOutTrue = true;
		end;
	end;		

	return lockOutTrue, wantedNeutral;
end;


function realManualTransmission:selectRange(wantedRange, rangeSetIndex, wantedNeutral)
	local spec = self.spec_realManualTransmission;

	local rangeSet = spec["rangeSet"..tostring(rangeSetIndex)]; -- convert range set index to table 	
	-- check if clutch is pressed or range is powershift 
	if spec.clutchPercent < 0.24 or rangeSet.powerShift then
		-- return wantedRange 
		spec["currentRange"..tostring(rangeSetIndex)] = wantedRange;
		rangeSet.currentRange = spec["currentRange"..tostring(rangeSetIndex)]

		-- if we want to shift gears into neutral due to range lockout, we do that now when the clutch is pressed.
		if wantedNeutral then 
			spec.neutral = true;
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
	
	-- if the rangeSet has a neutral position and we have buttonReleaseNeutral active, we want to turn into neutral 
	-- this is only for real hardcore players that want to use a second H-Shifter for ranges :)
	--if rangeSet.hasNeutralPosition and spec.buttonReleaseNeutral then
	--	rangeSet.neutral = true;
	--end;

end;

function realManualTransmission:selectGear(wantedGear, mappingValue)
	local spec = self.spec_realManualTransmission;
	local lockedOut = false;
	
	local gearChangeSuccess = false;
	local previousGear = spec.currentGear;
	
	
	-- check if wantedGear is not -1, -1 means we want to set it to neutral 
	if wantedGear ~= -1 then
		-- now check if wantedGear isn't the actual gear we want, in case we had a mappingValue assigned to the selectGear call 
		if mappingValue ~= nil and spec.gearMappings[mappingValue] ~= nil then
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
	if spec.clutchPercent < 0.24 or spec.gearsPowershift then
		-- -1 means we want to go into neutral 
		if wantedGear == -1 then 
			spec.neutral = true;
			spec.lastGear = spec.currentGear;
			gearChangeSuccess = true;
		else
			-- return wanted gear 
			-- sometimes if we change gear we also want to adjust the range 
			-- this is usually dependent on the previous gear we were in
			if spec.gears[wantedGear].rangeAdjusts ~= nil then
				--print("we have range adjusts");
				for _, rangeAdjust in pairs(spec.gears[wantedGear].rangeAdjusts) do
					if rangeAdjust.from == spec.lastGear then
						self:selectRange(rangeAdjust.range, 1, 1)
					end;
				end;
			end;

			if wantedGear ~= nil then
				spec.currentGear = wantedGear;
				spec.neutral = false; -- set neutral to false if we are in gear 
				spec.lastGear = spec.currentGear;
				gearChangeSuccess = true;
			end;
		end;
	end;
	
	-- stuff that needs to happen after we changed gear 
	if gearChangeSuccess and not spec.neutral then 
		-- check if there is automatic range matching
		if spec.autoRangeMatching then
			-- get the current actual speed 
			local currentSpeed = self.lastSpeed*3600;
			local rangeSet = spec.rangeSet1;
			local lastClosestTo1 = 0;
			local idealRange = nil;
			
			-- go through all the ranges, see which one matches the closest to the current speed 
			for i = 1, rangeSet.numberOfRanges do 
			
				-- first, get the max speed in the possible range 
				--local speedMax = spec.gears[spec.currentGear].speed * rangeSet.ranges[i].ratio * rangeRatio * spec.finalRatio; -- V 0.5.1.4 removed this 
				
				local speedMax = self:calculateRatio(true, spec.currentGear, i);
				-- now calculate the min speed in that possible range 
				local speedMin = speedMax * (self.spec_motorized.motor.minRpm / self.spec_motorized.motor.maxRpm);
				-- we don't want to be at minRpm / idle though, so add 26% speed 
				--speedMin = speedMin * 1.26;
				-- now get the average speed
				local speedAverage = (speedMin + speedMax) / 2;
				
				-- old way 
				-- now calculate how far away we are from the current speed 
				--local difference = math.min(currentSpeed, speedAverage) / math.max(currentSpeed, speedAverage)
			
				-- new way  
				-- V 0.5.1.5 added optional increase/decrease percentage for each gear via XML file, defaults to 25%
				local speedMatchingPercentageUp = spec.gears[spec.currentGear].speedMatchingPercentageUp;
				local speedMatchingPercentageDown = spec.gears[spec.currentGear].speedMatchingPercentageDown;
				--print(speedMatchingPercentageUp);
				local difference = math.min(currentSpeed, speedAverage) / math.max(currentSpeed, speedAverage)
				if previousGear > spec.currentGear then -- we downshifted 
					difference = math.min(currentSpeed*speedMatchingPercentageDown, speedMax) / math.max(currentSpeed*speedMatchingPercentageDown, speedMax) -- if we downshifted we want a gear that we reach at the top of our rev range with the current speed 
					--print("Range currently: "..i.." speedMax: "..speedMax.." speedMin: "..speedMin.." speedAverage: "..speedAverage.." difference: "..difference);
				elseif previousGear < spec.currentGear then -- we upshifted 
					difference = math.min(currentSpeed*speedMatchingPercentageUp, speedMax) / math.max(currentSpeed*speedMatchingPercentageUp, speedMax) -- if we upshifted we want a gear that we reach at the bottom of our rev range with the current speed 
					--print("Range currently: "..i.." speedMax: "..speedMax.." speedMin: "..speedMin.." speedAverage: "..speedAverage.." difference: "..difference.." currentSpeed+: "..currentSpeed.." curSpeedX: "..(currentSpeed*speedMatchingPercentageUp));
				end;
				
				
				-- if the current difference is smaller than the last closest to 1, we have a new closest range 
				if difference > lastClosestTo1 then
					idealRange = i; -- our new ideal range is 1
					lastClosestTo1 = difference; -- our new closestTo1 is our difference 
				end;
			end;
			
			if idealRange ~= nil then
				self:processRangeInputs(1, 1, idealRange);
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
	
	-- if inputValue is 0 and we have buttonReleaseNeutral active (automatically go back to neutral if you stop "pressing" the gear button
	-- then go to neutral (that way if it goes to neutral with Gearshifters like Logitech G27 if you get out of gear on the shifter)
	return lockedOut;
end;


function realManualTransmission:selectReverser(isForward, noEventSend)
	selectReverserEvent.sendEvent(self, isForward, noEventSend);
	local rev = self.spec_realManualTransmission.reverser;
	
	-- first, check which reverser type it is
	if rev.type == "preselect" then 
		rev.wantForward = isForward; -- set wanted forward value 
		rev.allowDirectionChange = true;
	elseif rev.type == "normal" then
		-- check if we even need to change direction
		if rev.isForward ~= isForward then
			-- now, see if we are braking, if not, do so
			if not rev.isBraking then
				rev.isBraking = true;
			end;
			rev.wantForward = isForward; -- set wanted forward value 
		end;
	elseif rev.type == "clutchOnly" then
		if self.spec_realManualTransmission.clutchPercent < 0.2 then -- only allow direction change if clutch is pressed 
			rev.wantForward = isForward; -- set wanted forward value 
			rev.allowDirectionChange = true;
		end;
	end;

end;

-- function to calculate the current ratio or speed given all ranges, gears, reversers and so on.
-- can either be used to calculate current actual speed or if given other than current paramenters to calculate possible speed in a different gear/range/setting etc.
function realManualTransmission:calculateRatio(returnSpeed, gear, range1, range2, range3, reverserDirection)
	local spec = self.spec_realManualTransmission;
	gear = Utils.getNoNil(gear, spec.currentGear);
	range1 = Utils.getNoNil(range1, spec.currentRange1);
	range2 = Utils.getNoNil(range2, spec.currentRange2);
	range3 = Utils.getNoNil(range3, spec.currentRange3);
	if spec.reverser ~= nil then
		reverserDirection = Utils.getNoNil(reverserDirection, spec.reverser.isForward);
	end;
	
	-- first, get total ranges ratio between all 3 possible rangeSets 
	local rangeRatio = 1;
	if spec.rangeSet1 ~= nil then
		rangeRatio = rangeRatio * spec.rangeSet1.ranges[range1].ratio;
	end;
	if spec.rangeSet2 ~= nil then
		rangeRatio = rangeRatio * spec.rangeSet2.ranges[range2].ratio;
	end;
	if spec.rangeSet3 ~= nil then	
		rangeRatio = rangeRatio * spec.rangeSet3.ranges[range3].ratio;
	end;				
	
	-- get the reverser ratio 
	local reverserRatio = 1;
	if spec.reverser ~= nil then
		if reverserDirection then
			reverserRatio = spec.reverser.forwardRatio;
		else
			reverserRatio = spec.reverser.reverseRatio;
		end;
	end;
	
	-- get gear ratio 
	local gearRatio = 1;
	if spec.gears ~= nil then
		gearRatio = spec.gears[gear].ratio;
	end;	


	if returnSpeed then
		local speed = spec.gears[gear].speed * rangeRatio * reverserRatio * spec.finalRatio;
		return speed;
	end;
	
	local endRatio = gearRatio / rangeRatio / reverserRatio / spec.finalRatio;
		
	return endRatio;
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
			spec.clutchPercent = math.min(spec.clutchPercentAuto, spec.clutchPercentManual, spec.clutchPercentFluid);
			
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
			
				if spec.clutchPercent < 0.6 or spec.neutral then
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
				
				
				-- set lastGear to nil if we are in neutral and clutch is engaged 
				if spec.clutchPercent > 0.9 and spec.neutral then
					spec.lastGear = nil;
				end;
		

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
				if self.isServer then
					
					-- check if anything changed, if so, synchronize with the clients 
					if spec.currentGear ~= spec.lastGear1 or spec.currentRange1 ~= spec.lastRange1 or spec.currentRange2 ~= spec.lastRange2 or spec.currentRange3 ~= spec.lastRange3 or spec.neutral ~= spec.lastNeutral then
						self:synchGearsAndRanges(spec.currentGear, spec.currentRange1, spec.currentRange2, spec.currentRange3, spec.neutral);

						spec.lastGear1 = spec.currentGear;
						spec.lastRange1 = spec.currentRange1;
						spec.lastRange2 = spec.currentRange2;
						spec.lastRange3 = spec.currentRange3;
						spec.lastNeutral = spec.neutral;
					end;
					
					-- automatic downshifting a range at a certain speed ( V 0.5.1.6 )
					local speed = self.lastSpeed*3600;
					if spec.rangeSet1 ~= nil then
						if spec.rangeSet1.ranges[spec.currentRange1].autoDownshiftSpeed ~= nil then
							if speed > spec.rangeSet1.ranges[spec.currentRange1].autoDownshiftSpeed then
								self:processRangeInputs(-1, 1);
							end;
						end;
					end;
					if spec.rangeSet2 ~= nil then
						if spec.rangeSet2.ranges[spec.currentRange2].autoDownshiftSpeed ~= nil then
							if speed > spec.rangeSet2.ranges[spec.currentRange2].autoDownshiftSpeed then
								self:processRangeInputs(-1, 2);
							end;
						end;
					end;
					if spec.rangeSet3 ~= nil then
						if spec.rangeSet3.ranges[spec.currentRange3].autoDownshiftSpeed ~= nil then
							if speed > spec.rangeSet3.ranges[spec.currentRange3].autoDownshiftSpeed then
								self:processRangeInputs(-1, 3);
							end;
						end;		
					end;
					--

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
			
			-- current wanted speed is needed for engine break calculation
			spec.currentWantedSpeed = 836 / spec.wantedGearRatio;  -- (836 is a "giants constant for converting ratio to speed) 


			-- calculating hand throttle 
			if spec.handThrottleDown then
				spec.handThrottlePercent = math.max(0, spec.handThrottlePercent - 0.001*dt);
			elseif spec.handThrottleUp then
				spec.handThrottlePercent = math.min(1, spec.handThrottlePercent + 0.001*dt);
			end;
				
			-- calculating the reverser 
			if spec.reverser ~= nil then
				
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
			

			
			-- direction selection
			-- check if the gear or range we are in is reverse
			local reverseRatio = 1; -- we start out in forward mode 
			if spec.gears ~= nil and spec.gears[spec.currentGear].isReverse then
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
				
		end;
	end;
end;


function realManualTransmission:synchGearsAndRanges(currentGear, currentRange1, currentRange2, currentRange3, neutral, noEventSend)
	currentGear = Utils.getNoNil(currentGear, 1);
	currentRange1 = Utils.getNoNil(currentRange1, 1);
	currentRange2 = Utils.getNoNil(currentRange2, 1);
	currentRange3 = Utils.getNoNil(currentRange3, 1);
	neutral = Utils.getNoNil(neutral, false);
	--print("synchGearsAndRanges vor Event: "..tostring(neutral));
	synchGearsAndRangesEvent.sendEvent(self, currentGear, currentRange1, currentRange2, currentRange3, neutral, noEventSend);
	local spec = self.spec_realManualTransmission;
	spec.currentGear = currentGear;
	spec.currentRange1 = currentRange1;
	spec.currentRange2 = currentRange2;
	spec.currentRange3 = currentRange3;
	spec.neutral = neutral;
	--print("synchGearsAndRanges nach Event: "..tostring(neutral));	
end;


function realManualTransmission:onReadStream(streamId, connection)
	if self.hasRMT then
		local isOn = Utils.getNoNil(streamReadBool(streamId), false);
		local currentGear = Utils.getNoNil(streamReadInt8(streamId), 1);
		local currentRange1 = Utils.getNoNil(streamReadInt8(streamId), 1);
		local currentRange2 = Utils.getNoNil(streamReadInt8(streamId), 1);
		local currentRange3 = Utils.getNoNil(streamReadInt8(streamId), 1);
		local neutral = Utils.getNoNil(streamReadBool(streamId), false);
		self.rmtIsOn = isOn;
		self:synchGearsAndRanges(currentGear, currentRange1, currentRange2, currentRange3, neutral, true);
	end;
		--print("onReadStream called");
end;

function realManualTransmission:onWriteStream(streamId, connection)
	local spec = self.spec_realManualTransmission;
	
	if self.hasRMT then
		streamWriteBool(streamId, Utils.getNoNil(self.rmtIsOn, false));
	
		streamWriteInt8(streamId, Utils.getNoNil(spec.currentGear, 1));
		streamWriteInt8(streamId, Utils.getNoNil(spec.currentRange1, 1));
		streamWriteInt8(streamId, Utils.getNoNil(spec.currentRange2, 1));
		streamWriteInt8(streamId, Utils.getNoNil(spec.currentRange3, 1));
		streamWriteBool(streamId, Utils.getNoNil(spec.neutral, false));
	end;
	--print("onWriteStream called");
end;

function realManualTransmission:onWriteUpdateStream(streamId, connection, dirtyMask)
	local spec = self.spec_realManualTransmission;
	--print("dirty: "..tostring(dirtyMask));
	if connection:getIsServer() and self.hasRMT then -- client side
		if streamWriteBool(streamId, bitAND(dirtyMask, spec.synchClutchInputDirtyFlag) ~= 0) then
			streamWriteUIntN(streamId, spec.clutchPercentManual * 100, 7);
			--print(tostring(spec.clutchPercentManual));
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
			--print(tostring(spec.clutchPercentManual));
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




















