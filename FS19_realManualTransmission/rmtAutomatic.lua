rmtAutomatic = {};

function rmtAutomatic.prerequisitesPresent(specializations)
    return true;
end;

function rmtAutomatic.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", rmtAutomatic);
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", rmtAutomatic);	     
end;

function rmtAutomatic:onLoad(savegame)
    self.loadFromXML_automatic = rmtAutomatic.loadFromXML_automatic;
    self.findPriorityShift = rmtAutomatic.findPriorityShift;
    self.findPriorityShiftUp = rmtAutomatic.findPriorityShiftUp;
    self.findPriorityShiftDown = rmtAutomatic.findPriorityShiftDown;
    self.loadAutomaticData = rmtAutomatic.loadAutomaticData;
    self.startShiftProcess = rmtAutomatic.startShiftProcess;
    self.finalizeShiftProcess = rmtAutomatic.finalizeShiftProcess;
    self.resetShiftProcess = rmtAutomatic.resetShiftProcess;

    self.spec_rmtAutomatic = {};

end;

function rmtAutomatic:loadFromXML_automatic(xmlFile, key, i)
    local spec = self.spec_rmtAutomatic;
    local rmt = self.spec_realManualTransmission;

    spec.hasAutomatic = false;

    spec.shiftPriority = {};
    
    local gears = {}
    gears.shiftAutomatic = getXMLBool(xmlFile, key.."realManualTransmission("..i..").automatic.gears#shiftAutomatic");
    if gears.shiftAutomatic then
        gears.hasKickdown = Utils.getNoNil(getXMLBool(xmlFile, key.."realManualTransmission("..i..").automatic.gears#hasKickdown"), true);
        gears.shiftPriority = Utils.getNoNil(getXMLInt(xmlFile, key.."realManualTransmission("..i..").automatic.gears#shiftPriority"), 1);

        if spec.shiftPriority[gears.shiftPriority] == nil then
            spec.shiftPriority[gears.shiftPriority] = "currentGear";
        else
            spec.shiftPriority[#spec.shiftPriority+1] = "currentGear";
            print("RMT Warning: Shift Priority "..tostring(gears.shiftPriority).." for gears already in use. Added last in row instead.")
        end;

        gears.longestTime, gears.clutch, gears.revMatch, gears.delayShift = self:loadAutomaticData(xmlFile, key.."realManualTransmission("..i..").automatic.gears")

        spec.gears = gears;
        spec.hasAutomatic = true;       
    end;

    local rangeSet1 = {}
    rangeSet1.shiftAutomatic = getXMLBool(xmlFile, key.."realManualTransmission("..i..").automatic.rangeSet1#shiftAutomatic");
    if rangeSet1.shiftAutomatic then
        rangeSet1.hasKickdown = Utils.getNoNil(getXMLBool(xmlFile, key.."realManualTransmission("..i..").automatic.rangeSet1#hasKickdown"), true);
        rangeSet1.shiftPriority = Utils.getNoNil(getXMLInt(xmlFile, key.."realManualTransmission("..i..").automatic.rangeSet1#shiftPriority"), 2);

        if spec.shiftPriority[rangeSet1.shiftPriority] == nil then
            spec.shiftPriority[rangeSet1.shiftPriority] = "currentRange1";
        else
            spec.shiftPriority[#spec.shiftPriority+1] = "currentRange1";
            print("RMT Warning: Shift Priority "..tostring(rangeSet1.shiftPriority).." for rangeSet1 already in use. Added last in row instead.")
        end;

        rangeSet1.longestTime, rangeSet1.clutch, rangeSet1.revMatch, rangeSet1.delayShift = self:loadAutomaticData(xmlFile, key.."realManualTransmission("..i..").automatic.rangeSet1")
       
        spec.rangeSet1 = rangeSet1;
        spec.hasAutomatic = true;           
    end;

    local rangeSet2 = {}
    rangeSet2.shiftAutomatic = getXMLBool(xmlFile, key.."realManualTransmission("..i..").automatic.rangeSet2#shiftAutomatic");
    if rangeSet2.shiftAutomatic then
        rangeSet2.hasKickdown = Utils.getNoNil(getXMLBool(xmlFile, key.."realManualTransmission("..i..").automatic.rangeSet2#hasKickdown"), true);
        rangeSet2.shiftPriority = Utils.getNoNil(getXMLInt(xmlFile, key.."realManualTransmission("..i..").automatic.rangeSet2#shiftPriority"), 3);

        if spec.shiftPriority[rangeSet2.shiftPriority] == nil then
            spec.shiftPriority[rangeSet2.shiftPriority] = "currentRange2";
        else
            spec.shiftPriority[#spec.shiftPriority+1] = "currentRange2";
            print("RMT Warning: Shift Priority "..tostring(rangeSet2.shiftPriority).." for rangeSet2 already in use. Added last in row instead.")
        end;

        rangeSet2.longestTime, rangeSet2.clutch, rangeSet2.revMatch, rangeSet2.delayShift = self:loadAutomaticData(xmlFile, key.."realManualTransmission("..i..").automatic.rangeSet2")
             
        spec.rangeSet2 = rangeSet2;
        spec.hasAutomatic = true;          
    end;

    local rangeSet3 = {}
    rangeSet3.shiftAutomatic = getXMLBool(xmlFile, key.."realManualTransmission("..i..").automatic.rangeSet3#shiftAutomatic");
    if rangeSet3.shiftAutomatic then
        rangeSet3.hasKickdown = Utils.getNoNil(getXMLBool(xmlFile, key.."realManualTransmission("..i..").automatic.rangeSet3#hasKickdown"), true);
        rangeSet3.shiftPriority = Utils.getNoNil(getXMLInt(xmlFile, key.."realManualTransmission("..i..").automatic.rangeSet3#shiftPriority"), 4);

        if spec.shiftPriority[rangeSet3.shiftPriority] == nil then
            spec.shiftPriority[rangeSet3.shiftPriority] = "currentRange3";
        else
            spec.shiftPriority[#spec.shiftPriority+1] = "currentRange3";
            print("RMT Warning: Shift Priority "..tostring(rangeSet3.shiftPriority).." for rangeSet3 already in use. Added last in row instead.")
        end;

        rangeSet3.longestTime, rangeSet3.clutch, rangeSet3.revMatch, rangeSet3.delayShift = self:loadAutomaticData(xmlFile, key.."realManualTransmission("..i..").automatic.rangeSet3")
                    
        spec.rangeSet3 = rangeSet3;
        spec.hasAutomatic = true;            
    end;    

    if spec.hasAutomatic then

        spec.isActive = true;

        spec.currentlyShifting = false;

        spec.shiftDir = nil;
        spec.shiftDebounceTimer = false;
        spec.shiftDebounceTime = 1000;
        spec.shiftDebounceCurrentTime = 0;

        spec.minUpshiftRpm = Utils.getNoNil(getXMLInt(xmlFile, key.."realManualTransmission("..i..").automatic#minUpshiftRpm"), 1400);
        spec.loadDownshiftRpm = Utils.getNoNil(getXMLInt(xmlFile, key.."realManualTransmission("..i..").automatic#loadDownshiftRpm"), 1200);
        spec.nonLoadDownshiftRpm = Utils.getNoNil(getXMLInt(xmlFile, key.."realManualTransmission("..i..").automatic#nonLoadDownshiftRpm"), 1000);

        print("has AUTOMATIC")
    else 
        spec = nil;
    end;
end;


-- we want the following functionality for automatic shifts
-- optional automatic clutching for gear/range shift that is not classic "powershift"
-- -- this means clutch-time -> shift-time 
-- optional shift-time for powershift (e.g. reaction delay, no clutch simulation needed in FS since its all fake anyhow )
-- optional rev-matching for powershift and auto shift -> time needed to do that 

-- load automatic data 
function rmtAutomatic:loadAutomaticData(xmlFile, key) 
    local longestTime = 0;   
    local clutch = {};
    clutch.time = getXMLInt(xmlFile, key..".clutch#time")
    if clutch.time ~= nil then
        clutch.timer = false;
        clutch.currentTime = 0;
        clutch.isClosing = false;
        if clutch.time > longestTime then
            longestTime = clutch.time;
        end;
    else
        clutch = nil;
    end;

    local revMatch = {};
    revMatch.revMatchUpshift = getXMLBool(xmlFile, key..".revMatch#revMatchUpshift");
    revMatch.revMatchDownshift = getXMLBool(xmlFile, key..".revMatch#revMatchDownshift");
    if revMatch.revMatchDownshift ~= nil or revMatch.revMatchUpshift ~= nil then
        revMatch.delayTime = getXMLFloat(xmlFile, key..".revMatch#delayTime");
        revMatch.timer = false;
        revMatch.currentTime = 0;
        if revMatch.delayTime > longestTime then
            longestTime = revMatch.delayTime;
        end;
    else
        revMatch = nil;
    end;

    local delayShift = {};
    delayShift.delayTime = getXMLFloat(xmlFile, key..".delayShift#delayTime");
    if delayShift.delayTime ~= nil then
        delayShift.timer = false;
        delayShift.currentTime = 0;
        if delayShift.delayTime > longestTime then
            longestTime = delayShift.delayTime;
        end;
    else
        delayShift = nil;
    end;

    return longestTime, clutch, revMatch, delayShift;
end;

function rmtAutomatic:startShiftProcess(gearRange, shiftDir)
    local spec = self.spec_rmtAutomatic;
    -- first see if we have any time-delay
    local timeDelay = false;
    spec.currentShiftData = {}
    
    spec.currentShiftData.time = gearRange.longestTime;
    spec.currentShiftData.timer = true;
    spec.currentShiftData.shiftDir = shiftDir;

    print("startShiftProcess");
    print("gearRange: "..tostring(gearRange));
end;

function rmtAutomatic:finalizeShiftProcess(gearRange)
    local spec = self.spec_rmtAutomatic;
    -- need to figure out what we're actually shifting.. lol.
    if spec.shiftPriority[gearRange.shiftPriority] == "currentGear" then
        print("currentGear true");
        print("shiftDir: "..tostring(spec.currentShiftData.shiftDir));
        if spec.currentShiftData.shiftDir then
            self:processGearInputs(nil, 1)
        else
            self:processGearInputs(nil, -1)
        end;
    elseif spec.shiftPriority[gearRange.shiftPriority] == "currentRange1" then
        if spec.currentShiftData.shiftDir then
            self:processRangeInputs(1, 1)
        else
            self:processRangeInputs(-1, 1)
        end;
    elseif spec.shiftPriority[gearRange.shiftPriority] == "currentRange2" then
        if spec.currentShiftData.shiftDir then
            self:processRangeInputs(1, 2)
        else
            self:processRangeInputs(-1, 2)
        end;
    elseif spec.shiftPriority[gearRange.shiftPriority] == "currentRange3" then
        if spec.currentShiftData.shiftDir then
            self:processRangeInputs(1, 3)
        else
            self:processRangeInputs(-1, 3)
        end;
    end;

    if gearRange.clutch ~= nil then
        gearRange.clutch.currentTime = gearRange.clutch.time;
        gearRange.clutch.timer = true;
        gearRange.clutch.isClosing = true; 
    end;

    print("finalizeShiftProcess");
    print("gearRange: "..tostring(gearRange));   
end;

function rmtAutomatic:resetShiftProcess(dt)
    local spec = self.spec_rmtAutomatic;
    spec.currentlyShifting = false;
    spec.currentShiftData = {};
    spec.currentShiftIndex = nil;
    spec.currentGearRange = nil;

    spec.shiftDebounceCurrentTime = spec.shiftDebounceTime;
    spec.shiftDebounceTimer = true;

    print("reset shifting process")
end;

function rmtAutomatic:onUpdate(dt)

    local spec = self.spec_rmtAutomatic;
    if spec ~= nil then
        if self:getIsActive() then

            if spec.isActive then
            
                local rmt = self.spec_realManualTransmission;
                local motor = self.spec_motorized.motor;
                local rmt_ct = self.spec_rmtClassicTransmission
                
                -- get accelerator pedal position
                local acc = self:getAxisForward()

                -- get current RPM 
                local rpm = motor.lastRealMotorRpm;

                --renderText(0.1, 0.1, 0.02, "clutch percent: "..tostring(rmt.clutchPercentAutomatic));

                -- now into some shifting "mathematics"
                
                -- if accelerator is above 85% we are in kickdown mode. Unfortunately keyboard players will always be in kickdown mode
                -- TO DO - fix kickdown for keyboard players 

                if spec.shiftDebounceTimer then
                    spec.shiftDebounceCurrentTime = math.max(0, spec.shiftDebounceCurrentTime - dt);
                    --print("debounce")
                    if spec.shiftDebounceCurrentTime == 0 then
                        spec.shiftDebounceTimer = false;
                    end;
                end;


                if not spec.currentlyShifting and not spec.shiftDebounceTimer then



                    local shiftDir = nil;

                    -- check if we are currently in a position to upshift      

                    if acc > 0.85 and rpm > (motor.maxRpm * 0.8) then
                        shiftDir = true;
                        --renderText(0.1, 0.22, 0.02, "upshift condition met");
                    elseif acc > 0.25 and rpm > spec.minUpshiftRpm then
                        shiftDir = true;
                        --renderText(0.1, 0.12, 0.02, "upshift condition met");
                    end;             

                    -- downshifting
                    if acc > 0 and rpm < spec.loadDownshiftRpm then
                        shiftDir = false;
                        --renderText(0.1, 0.14, 0.02, "downshift load condition met");                   
                    end;

                    if acc <= 0 and rpm < spec.nonLoadDownshiftRpm then
                        shiftDir = false;
                        --renderText(0.1, 0.16, 0.02, "downshift no load condition met");                      
                    end;

                    --renderText(0.1, 0.18, 0.02, "rpm: "..tostring(rpm));
                    --renderText(0.1, 0.2, 0.02, "acc: "..tostring(acc));

                    spec.shiftDir = shiftDir;


                    -- now that we know we want to upshift or downshift..
                    -- find prefered shift

                    local shiftIndex = false;
                    local gearRange = nil;
                    if spec.shiftDir then
                        shiftIndex, gearRange = self:findPriorityShift("up");       
                    end;
                    if spec.shiftDir == false then
                        shiftIndex, gearRange = self:findPriorityShift("down");
                    end;                  
                    
                    -- we found a gear or range to shift into, set stuff in motion
                    if shiftIndex ~= false and gearRange ~= nil then
                        spec.currentlyShifting = true; -- set currentlyShifting to true so we don't keep searching for new gears until shift has happened
                        spec.currentShiftIndex = shiftIndex;
                        spec.currentGearRange = gearRange;

                        self:startShiftProcess(gearRange, spec.shiftDir)
                    end;                -- we found a gear or range to shift into, set stuff in motion
                    if shiftIndex ~= false and gearRange ~= nil then
                        spec.currentlyShifting = true; -- set currentlyShifting to true so we don't keep searching for new gears until shift has happened
                        spec.currentShiftIndex = shiftIndex;
                        spec.currentGearRange = gearRange;

                        self:startShiftProcess(gearRange, spec.shiftDir)
                    end;                        
                end;

                    
                
                --end;
                -- now we know if we want to upshift or downshift and we know the shift index
                -- next need to check if we need to use clutch or do rev matching.. in short, start the shifting process
                if spec.currentlyShifting then
                    --print("currently shifting")
                    -- start shiftin
                    local currentShiftData = spec.currentShiftData;
                    local gearRange = spec.currentGearRange;
                    -- we have a timer running
                    if currentShiftData.timer then
                        currentShiftData.time = math.max(0, currentShiftData.time - dt);

                        -- certain things need to happen at certain points of the countdown
                        if gearRange.clutch ~= nil then 
                            --print("Clutch")
                            -- within clutch timeframe, start clutch stuff
                            if currentShiftData.time < gearRange.clutch.time then 
                               -- print("Timer")
                                -- start clutch timer if not started
                                if not gearRange.clutch.timer then
                                    --print("start")
                                    gearRange.clutch.timer = true;
                                end;
                                -- do clutch operation
                                if gearRange.clutch.timer then
                                    --print("do")
                                    rmt.clutchPercentAutomatic = currentShiftData.time / gearRange.clutch.time;
                                end;
                            end;
                            if currentShiftData.time == 0 then
                                --print("0 clutch")
                                rmt.clutchPercentAutomatic = 0;
                            end;
                        end;

                        if gearRange.revMatch ~= nil then
                            -- oh boy rev matching.. 
                            if currentShiftData.time < gearRange.revMatch.delayTime then
                                -- upshift or downshift 
                                if spec.shiftDir then -- upshift, just let off the gas for a moment
                                    spec.accelerationOverride = 0;
                                elseif spec.shiftDir == false then -- downshift, just hit the gas for a moment
                                    spec.accelerationOverride = 1;
                                end;
                            end;
                            if currentShiftData.time == 0 then
                                spec.accelerationOverride = nil;
                            end;
                        end;
                        if gearRange.delayShift ~= nil then
                            -- don't do anything until countdown.. I think.
                        end;

                        -- now countdown endet. Finalize shift.
                        if currentShiftData.time == 0 then
                            self:finalizeShiftProcess(gearRange)
                            currentShiftData.timer = false;
                            if gearRange.clutch == nil then
                                self:resetShiftProcess(dt);
                            end;
                        end;

                    end;

                    -- close clutch 
                    if gearRange.clutch ~= nil then
                        if gearRange.clutch.timer and gearRange.clutch.isClosing then
                            --print("clutch closing stuffs")
                            gearRange.clutch.currentTime = math.max(0, gearRange.clutch.currentTime - dt);
                            --print(gearRange.clutch.currentTime)

                            rmt.clutchPercentAutomatic = 1 - gearRange.clutch.currentTime / gearRange.clutch.time;
                            if gearRange.clutch.currentTime == 0 then
                                gearRange.clutch.timer = false;
                                gearRange.clutch.isClosing = false;
                                rmt.clutchPercentAutomatic = 1;
                                self:resetShiftProcess(dt);
                            end;
                        end;
                    end;
                
                end;
            end;
        end;
    end;
end;

function rmtAutomatic:findPriorityShift(dir)
    local index, gearRange = false, false;
    if dir == "up" then
        for i = 1, 4 do
            index, gearRange = self:findPriorityShiftUp(i);
            if gearRange ~= nil then
                break
            end;
        end;
    elseif dir == "down" then
        for i = 1, 4 do
            index, gearRange = self:findPriorityShiftDown(i);
            if gearRange ~= nil then
                break
            end;
        end;
    end;
    return index, gearRange;
end;

function rmtAutomatic:findPriorityShiftUp(index)
    print("findPriorityShiftUp "..tostring(index))
    local spec = self.spec_rmtAutomatic;
    local rmt_ct = self.spec_rmtClassicTransmission;
    local rmt = self.realManualTransmission;
    if index == 5 then -- can't upshift anymore 
        return false;
    end;
    if spec.shiftPriority[index] == "currentGear" then 
        print("currentGear hit")
        if rmt_ct.currentGear < rmt_ct.numberOfGears then 
            return index, spec.gears;
        end;
    elseif spec.shiftPriority[index] == "currentRange1" then 
        if rmt_ct.currentRange1	< rmt_ct.rangeSet1.numberOfRanges then
            return index, spec.rangeSet1;
        end;       
    elseif spec.shiftPriority[index] == "currentRange2" then 
        if rmt_ct.currentRange2	< rmt_ct.rangeSet2.numberOfRanges then
            return index, spec.rangeSet2;
        end;                
    elseif spec.shiftPriority[index] == "currentRange3" then 
        if rmt_ct.currentRange3	< rmt_ct.rangeSet3.numberOfRanges then
            return index, spec.rangeSet3;
        end;    
    end;
end;

function rmtAutomatic:findPriorityShiftDown(index)
    print("findPriorityShiftDown "..tostring(index))    
    local spec = self.spec_rmtAutomatic;
    local rmt_ct = self.spec_rmtClassicTransmission;
    local rmt = self.realManualTransmission;
    if index == 5 then -- can't downshift anymore 
        return false;
    end;
    if spec.shiftPriority[index] == "currentGear" then 
        if rmt_ct.currentGear > 1 then 
            return index, spec.gears;
        end;
    elseif spec.shiftPriority[index] == "currentRange1" then 
        if rmt_ct.currentRange1	> 1 then
            return index, spec.rangeSet1;
        end;       
    elseif spec.shiftPriority[index] == "currentRange2" then 
        if rmt_ct.currentRange2	> 1 then
            return index, spec.rangeSet2;
        end;                
    elseif spec.shiftPriority[index] == "currentRange3" then 
        if rmt_ct.currentRange3	> 1 then
            return index, spec.rangeSet3;
        end;    
    end;
end;