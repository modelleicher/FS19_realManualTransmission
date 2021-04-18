-- TO DO

-- move rmtIsOn onReadStream / onWriteStream back to main RMT 

rmtClassicTransmission = {};

function rmtClassicTransmission.prerequisitesPresent(specializations)
    return true;
end;

function rmtClassicTransmission.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", rmtClassicTransmission);
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", rmtClassicTransmission);	
    SpecializationUtil.registerEventListener(vehicleType, "onReadStream", rmtClassicTransmission);
    SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", rmtClassicTransmission);       
end;

function rmtClassicTransmission:onLoad(savegame)
    self.loadGears = rmtClassicTransmission.loadGears;
    self.loadRanges = rmtClassicTransmission.loadRanges;
    self.selectGear = rmtClassicTransmission.selectGear;
    self.selectRange = rmtClassicTransmission.selectRange;
    self.synchGearsAndRanges = rmtClassicTransmission.synchGearsAndRanges;
    self.processGearInputs = rmtClassicTransmission.processGearInputs;
    self.processRangeInputs = rmtClassicTransmission.processRangeInputs;
	self.checkRangeLockOut = rmtClassicTransmission.checkRangeLockOut;
	self.loadFromXML_classicTransmission = rmtClassicTransmission.loadFromXML_classicTransmission
	self.getDirectionAndRatio_classicTransmission = rmtClassicTransmission.getDirectionAndRatio_classicTransmission
	self.getMaxSpeedPossible_classicTransmission = rmtClassicTransmission.getMaxSpeedPossible_classicTransmission

	self.spec_rmtClassicTransmission = {};

end;

function rmtClassicTransmission:loadFromXML_classicTransmission(xmlFile, key, i)
	local spec = self.spec_rmtClassicTransmission;
	local rmt = self.spec_realManualTransmission;
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

	spec.autoRangeMatching = Utils.getNoNil(getXMLBool(self.xmlFile, key.."realManualTransmission("..i..")#autoRangeMatching"), false);

	spec.currentGear = spec.defaultGear;
	spec.neutral = true;	
end;

function rmtClassicTransmission:onReadStream(streamId, connection)
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
end;

function rmtClassicTransmission:onWriteStream(streamId, connection)
	local spec = self.spec_rmtClassicTransmission;
	
	if self.hasRMT then
		streamWriteBool(streamId, Utils.getNoNil(self.rmtIsOn, false));
	
		streamWriteInt8(streamId, Utils.getNoNil(spec.currentGear, 1));
		streamWriteInt8(streamId, Utils.getNoNil(spec.currentRange1, 1));
		streamWriteInt8(streamId, Utils.getNoNil(spec.currentRange2, 1));
		streamWriteInt8(streamId, Utils.getNoNil(spec.currentRange3, 1));
		streamWriteBool(streamId, Utils.getNoNil(spec.neutral, false));
	end;
end;


function rmtClassicTransmission:synchGearsAndRanges(currentGear, currentRange1, currentRange2, currentRange3, neutral, noEventSend)
	currentGear = Utils.getNoNil(currentGear, 1);
	currentRange1 = Utils.getNoNil(currentRange1, 1);
	currentRange2 = Utils.getNoNil(currentRange2, 1);
	currentRange3 = Utils.getNoNil(currentRange3, 1);
	neutral = Utils.getNoNil(neutral, false);

	synchGearsAndRangesEvent.sendEvent(self, currentGear, currentRange1, currentRange2, currentRange3, neutral, noEventSend);
	local spec = self.spec_rmtClassicTransmission;
	spec.currentGear = currentGear;
	spec.currentRange1 = currentRange1;
	spec.currentRange2 = currentRange2;
	spec.currentRange3 = currentRange3;
	spec.neutral = neutral;
end;


function rmtClassicTransmission:processGearInputs(gearValue, sequentialDir, noEventSend)
	-- send the event here, this is the last clienct & server function 
	processGearInputsEvent.sendEvent(self, gearValue, sequentialDir, noEventSend);
	-- now start the server-stuff 
	if self.isServer then
		local spec = self.spec_rmtClassicTransmission;
		local rmt = self.spec_realManualTransmission;
		if sequentialDir == 0 then -- we called this via direct selection, so we select the gear or range directly 
			self:selectGear(gearValue, gearValue);
		end;
		
		if sequentialDir == 1 or sequentialDir == -1 then -- we called this via up/down keys e.g. sequential

			-- added calculatingGear step to enable shifting multiple gears at once with automatic clutch V 0.6.1.3
			local calculatingGear = spec.currentGear;

			if rmt.useAutomaticClutch and rmt.automaticClutch ~= nil and rmt.automaticClutch.wantedGear ~= nil then 
				calculatingGear = rmt.automaticClutch.wantedGear;
			end;

			-- just select the gear we want to.. see if we get lockOut back 
			local lockOut = self:selectGear(calculatingGear + (1*sequentialDir));
			-- if we get locked out of the gear we want to shift in, try to shift down/up to the next gear and the next
			-- to see if we can shift into the next allowed gear, stop if 1 or max is reached 

			if lockOut then
				if sequentialDir == 1 then -- upshifting 
					local i = calculatingGear + 1; 
					while true do -- try for each gear upwards from currentGear 
						local checkGear = math.min(calculatingGear + i, spec.numberOfGears);
						lockOut = self:selectGear(checkGear); 
						if lockOut and checkGear == spec.numberOfGears or lockOut == false then -- stop if max gear is reached and still lockout, or lockout returned false 
							break;
						end;
						i = i + 1;
					end;
				elseif sequentialDir == -1 then -- downshifting
					local i = calculatingGear - 1;
					while true do -- try for each gear downwards from currentGear 
						local checkGear = math.max(calculatingGear - i, 1);
						lockOut = self:selectGear(checkGear);
						if lockOut and checkGear == 1 or lockOut == false then
							break;
						end;
						i = i - 1;
					end;
				end;
			end;
		end;
	end;
end;

function rmtClassicTransmission:processRangeInputs(up, index, force, noEventSend)
	-- send the event here, this is the last clienct & server function 
	force = Utils.getNoNil(force, 0);
	processRangeInputsEvent.sendEvent(self, up, index, force, noEventSend);
	--print("process range inputs");
	-- now start the server-stuff 
	if self.isServer then
		local spec = self.spec_rmtClassicTransmission;
		local rmt = self.spec_realManualTransmission;

		
		local rangeSet = spec["rangeSet"..tostring(index)]; -- convert range set index to table 
		local other1, other2;
		if index == 1 then other1 = 2; other2 = 3 end;
		if index == 2 then other1 = 1; other2 = 3 end;
		if index == 3 then other1 = 1; other2 = 2 end;

		-- added calculatingRange to allow multiple range shifts at once while autoClutch is enabled V 0.6.1.3
		local calculatingRange = spec["currentRange"..tostring(index)]

		if rmt.useAutomaticClutch and rmt.automaticClutch ~= nil and rmt.automaticClutch.wantedRange ~= nil then 
			calculatingRange = rmt.automaticClutch.wantedRange;
		end;

		calculatingRange = calculatingRange + up;

		if force ~= 0 and force ~= nil then
			calculatingRange = force;
		end;
		
		-- make sure our wantedRange is between min and max range we have 
		calculatingRange = math.max(1, math.min(calculatingRange, rangeSet.numberOfRanges));
		
		local lockOutTrue, wantedNeutral = self:checkRangeLockOut(calculatingRange, index, other1, other2);
		
		if lockOutTrue then
			calculatingRange = nil;
		end;	
		
		if calculatingRange ~= nil then
			self:selectRange(calculatingRange, index, wantedNeutral);
		end;
	end;
end;

function rmtClassicTransmission:checkRangeLockOut(wantedRange, rangeSet, other1, other2)
	local spec = self.spec_rmtClassicTransmission;
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
		if spec[strRangeSet1].ranges[wantedRange].disableGearsTable ~= nil and spec[strRangeSet1].ranges[wantedRange].disableGearsTable[tostring(spec.currentGear)] then 
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

function rmtClassicTransmission:selectGear(wantedGear, mappingValue)
	local spec = self.spec_rmtClassicTransmission;
	local rmt = self.spec_realManualTransmission;
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

	-- if wanted gear still isn't nil, we can try to shift into that gear. 
		
	-- now check if clutch is pressed enough to allow gearshift or if gears can be shifted under power 
	if wantedGear ~= nil and rmt.clutchPercent < 0.24 or spec.gearsPowershift then
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
						print("range Adjusts")
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
			
			print("Auto Range Matching hit")

			-- go through all the ranges, see which one matches the closest to the current speed 
			for i = 1, rangeSet.numberOfRanges do 
			
				-- first, get the max speed in the possible range 
				--local speedMax = spec.gears[spec.currentGear].speed * rangeSet.ranges[i].ratio * rangeRatio * spec.finalRatio; -- V 0.5.1.4 removed this 
				
				local speedMax = self:calculateRatio(true, spec.currentGear, i);
				print("SpeedMax:"..tostring(speedMax))
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
	if rmt.useAutomaticClutch and not spec.gearsPowershift and spec.currentGear ~= wantedGear and wantedGear ~= nil and wantedGear <= spec.numberOfGears then
		-- start opening clutch 
		rmt.automaticClutch.wantOpen = true; 
		rmt.automaticClutch.timer = rmt.automaticClutch.openTime; -- put openTime in timer 
		rmt.automaticClutch.timerMax = rmt.automaticClutch.timer; -- store the max timer value, we need that later 
		rmt.automaticClutch.wantedGear = wantedGear; -- store wantedGear for later when clutch is open 		
	end;
	
	-- if inputValue is 0 and we have buttonReleaseNeutral active (automatically go back to neutral if you stop "pressing" the gear button
	-- then go to neutral (that way if it goes to neutral with Gearshifters like Logitech G27 if you get out of gear on the shifter)
	return lockedOut;
end;

function rmtClassicTransmission:selectRange(wantedRange, rangeSetIndex, wantedNeutral)
	local spec = self.spec_rmtClassicTransmission;
	local rmt = self.spec_realManualTransmission;

	local rangeSet = spec["rangeSet"..tostring(rangeSetIndex)]; -- convert range set index to table 	
	-- check if clutch is pressed or range is powershift 
	if rmt.clutchPercent < 0.24 or rangeSet.powerShift then
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
	if rmt.useAutomaticClutch and not rangeSet.powerShift and rangeSet.currentRange ~= wantedRange and wantedRange ~= nil and wantedRange <= rangeSet.numberOfRanges then
		-- start opening clutch 
		rmt.automaticClutch.wantOpen = true; 
		rmt.automaticClutch.timer = rmt.automaticClutch.openTime; -- put openTime in timer 
		rmt.automaticClutch.timerMax = rmt.automaticClutch.timer; -- store the max timer value, we need that later 
		rmt.automaticClutch.wantedRange = wantedRange; -- store wantedGear for later when clutch is open 
		rmt.automaticClutch.rangeSetIndex = rangeSetIndex; -- store wantedGear for later when clutch is open 
	end;				
	
	-- if the rangeSet has a neutral position and we have buttonReleaseNeutral active, we want to turn into neutral 
	-- this is only for real hardcore players that want to use a second H-Shifter for ranges :)
	--if rangeSet.hasNeutralPosition and spec.buttonReleaseNeutral then
	--	rangeSet.neutral = true;
	--end;

end;

-- load gears function, we give XML-File and XML-File key, so its easier to use seperate config-files later since we just have to change the function-call 
function rmtClassicTransmission:loadGears(xmlFile, key)
	local spec = self.spec_rmtClassicTransmission;
	local rmt = self.spec_realManualTransmission;
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
			gear.ratio = rmt.ratioRpmConstant / gear.speed; -- conversion for giants calculation 836 constant
		end;
		if gear.speed == nil and gear.ratio ~= nil then 
			gear.speed = rmt.ratioRpmConstant / gear.ratio; -- conversion from Ratio to speed
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

function rmtClassicTransmission:loadRanges(xmlFile, key)
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

function rmtClassicTransmission:onUpdate(dt)
	if self:getIsActive() then
		if self.hasRMT and self.rmtIsOn then 
			local spec = self.spec_rmtClassicTransmission;
			local rmt = self.spec_realManualTransmission;

			-- #### possible outsource to rmtClassicTransmission
			-- set lastGear to nil if we are in neutral and clutch is engaged 
			if rmt.clutchPercent > 0.9 and spec.neutral then
				spec.lastGear = nil;
			end;
			-- ####

			if self.isServer then
				-- #### outsorce to rmtClassicTransmission 
				-- check if anything changed, if so, synchronize with the clients 
				if spec.currentGear ~= spec.lastGear1 or spec.currentRange1 ~= spec.lastRange1 or spec.currentRange2 ~= spec.lastRange2 or spec.currentRange3 ~= spec.lastRange3 or spec.neutral ~= spec.lastNeutral then
					self:synchGearsAndRanges(spec.currentGear, spec.currentRange1, spec.currentRange2, spec.currentRange3, spec.neutral);

					spec.lastGear1 = spec.currentGear;
					spec.lastRange1 = spec.currentRange1;
					spec.lastRange2 = spec.currentRange2;
					spec.lastRange3 = spec.currentRange3;
					spec.lastNeutral = spec.neutral;
				end;
				
				-- automatic downshifting a range at a certain speed ( V 0.5.1.6 )KT
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
			end;
		end;
	end;
end;

function rmtClassicTransmission:getMaxSpeedPossible_classicTransmission()
	local spec = self.spec_rmtClassicTransmission;
	local ratio = 1;
	local maxSpeed = 40;
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
		maxSpeed = spec.highestGearSpeed * ratio
	else
		maxSpeed = self.spec_realManualTransmission.ratioRpmConstant / ratio
	end;	
	return maxSpeed;
end;

function rmtClassicTransmission:getDirectionAndRatio_classicTransmission(forceGear, forceRange1, forceRange2, forceRange3)
	local spec = self.spec_rmtClassicTransmission;
	local ratio = 1;
	local dir = true;

	if spec ~= nil then
		local range1 = Utils.getNoNil(forceRange1, spec.currentRange1);
		local range2 = Utils.getNoNil(forceRange2, spec.currentRange2);
		local range3 = Utils.getNoNil(forceRange3, spec.currentRange3);
		local gear = Utils.getNoNil(forceGear, spec.currentGear);

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
		-- get gear ratio 
		local gearRatio = 1;
		if spec.gears ~= nil then
			gearRatio = spec.gears[gear].ratio;
		end;

		--ratio = ratio * rangeRatio * gearRatio;
		ratio = gearRatio / rangeRatio;

		-- get direction 
		local dirVal = 1;
		if spec.rangeSet1 ~= nil then	
			if spec.rangeSet1.ranges[range1].isReverse then
				dirVal = dirVal * -1;
			end;
		end;
		if spec.rangeSet2 ~= nil then		
			if spec.rangeSet2.ranges[range2].isReverse then
				dirVal = dirVal * -1;
			end;
		end;
		if spec.rangeSet3 ~= nil then
			if spec.rangeSet3.ranges[range3].isReverse then
				dirVal = dirVal * -1;
			end;	
		end;
		if spec.gears[gear].isReverse then
			dirVal = dirVal * -1;
		end;
		if dirVal == -1 then 
			dir = false;
		end;
	end;
	return dir, ratio;
end;