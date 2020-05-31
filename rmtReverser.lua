rmtReverser = {};

function rmtReverser.prerequisitesPresent(specializations)
    return true;
end;

function rmtReverser.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", rmtReverser); 
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", rmtReverser); 	
end;

function rmtReverser:onLoad(savegame)
    self.selectReverser = rmtReverser.selectReverser;
	self.loadFromXML_reverser = rmtReverser.loadFromXML_reverser;
	self.getDirectionAndRatio_reverser = rmtReverser.getDirectionAndRatio_reverser;
	
	self.spec_rmtReverser = {};
end;

function rmtReverser:loadFromXML_reverser(xmlFile, key, i)
    local spec = self.spec_rmtReverser;
    local reverserType = getXMLString(xmlFile, key.."realManualTransmission("..i..").reverser#type");
    if reverserType ~= nil and reverserType ~= "" then
        spec.type = reverserType;
        spec.forwardRatio = Utils.getNoNil(getXMLFloat(xmlFile, key.."realManualTransmission("..i..").reverser.ratios#forward"), 1);
        spec.reverseRatio = Utils.getNoNil(getXMLFloat(xmlFile, key.."realManualTransmission("..i..").reverser.ratios#reverse"), 1);
        spec.brakeAggressionBias = Utils.getNoNil(getXMLFloat(xmlFile, key.."realManualTransmission("..i..").reverser.settings#brakeAggressionBias"), 1);
        spec.clutchTime = Utils.getNoNil(getXMLFloat(xmlFile, key.."realManualTransmission.reverser("..i..").settings#clutchTime"), 500);
                    
        spec.isForward = true;
        spec.wantForward = true;
        spec.isBraking = false;
        spec.isClutching = false;
        spec.lastBrakeForce = 0;
	else
		self.spec_rmtReverser = nil;
	end;
	
end;

function rmtReverser:selectReverser(isForward, noEventSend)
	selectReverserEvent.sendEvent(self, isForward, noEventSend);
	local spec = self.spec_rmtReverser;
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

function rmtReverser:onUpdate(dt)
	if self:getIsActive() then
		if self.hasRMT and self.rmtIsOn then 
			local spec = self.spec_rmtReverser;
			local rmt = self.spec_realManualTransmission;
			-- #### outsource reverser calculation to rmtReverser 
			if spec ~= nil then
				-- if the reverser is in brake-mode, calculate brake force and open clutch 
				if spec.isBraking then 
					-- clutch 
					if not rmt.automaticClutch.wantOpen and not rmt.automaticClutch.isOpen then
						rmt.automaticClutch.wantOpen = true;
						rmt.automaticClutch.timer = 450;
						rmt.automaticClutch.timerMax = rmt.automaticClutch.timer;
						rmt.automaticClutch.preventClosing = true;
						rmt.automaticClutch.reverserFlag = true;
					end;
					
					-- brake force 
					spec.lastBrakeForce = 1 * spec.brakeAggressionBias; 
					if math.abs(self.lastSpeed*3600) < 0.7 then
						--spec.reverser.lastBrakeForce = spec.reverser.lastBrakeForce * self.lastRealSpeed;
						spec.isBraking = false;
						spec.allowDirectionChange = true;
					end;			
					
				else
					spec.lastBrakeForce = 0;
				end;

				-- if the clutch is open, change direction 
				if rmt.clutchPercent < 0.2 and spec.allowDirectionChange then 
					spec.isForward = spec.wantForward;
					rmt.automaticClutch.preventClosing = false;
					spec.allowDirectionChange = nil;
				end;
				-- the clutch is automatically closing after it opened anyways, so nothing more to do here 
			end;
		end;
	end;
end;

-- return direction and ratio for reverser. If forceDirection is added I use it as direction value instead of actual for wanted calculation
-- returns direction of forward (true) and ratio of 1 if reverser is nil 
function rmtReverser:getDirectionAndRatio_reverser(forceDirection)
	local spec = self.spec_rmtReverser;
	local dir = Utils.getNoNil(forceDirection, true)
	local ratio = 1;

	if spec ~= nil then
		dir = Utils.getNoNil(forceDirection, spec.isForward);
		if dir then 
			ratio = spec.forwardRatio;
		else
			ratio = spec.reverseRatio;
		end;
	end;

	return dir, ratio;
end;