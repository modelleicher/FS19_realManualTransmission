-- by modelleicher
-- all the overrides for default functions are in this script 



rmtOverride = {};


-- the getRequiredMotorRpmRange makes sure that the vehicle always operates in the by the PTO implement required RPM range.. E.g. exact RPM.
-- with CVT/automatic gearbox this is what we want.. But with manual gearbox, this is not what we want.. 
-- so we need to disable that mechanic.
function rmtOverride.newGetRequiredMotorRpmRange(self, superFunc)
	if not self.vehicle.hasRMT or not self.vehicle.rmtIsOn then
		return superFunc(self)
	else
	
		--local motorPtoRpm = math.min(PowerConsumer.getMaxPtoRpm(self.vehicle)*self.ptoMotorRpmRatio, self.maxRpm)
		--if motorPtoRpm ~= 0 then
		--	return motorPtoRpm, motorPtoRpm
		--end
		return self.minRpm, self.maxRpm
	end;
end
VehicleMotor.getRequiredMotorRpmRange = Utils.overwrittenFunction(VehicleMotor.getRequiredMotorRpmRange, rmtOverride.newGetRequiredMotorRpmRange)


local oldMotorUpdate = VehicleMotor.update;
function rmtOverride.newMotorUpdate(self, superFunc, dt)
	local vehicle = self.vehicle
	if not vehicle.hasRMT or not vehicle.rmtIsOn then
		superFunc(self, dt);	
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
				--if clutchPercent < 0.2 then
				--	clampedMotorRpm = currentRpm;
				--else
				--	clampedMotorRpm = (clampedMotorRpm * ((clutchPercent-0.2)*1.25)) + (currentRpm * (1-((clutchPercent-0.2)*1.25)));
				--end;
				
				-- new bit V 0.5.1.5
				
				if clutchPercent < 0.2 then -- below 20% the clutch is fully opened, just use our RPM calculation
					clampedMotorRpm = currentRpm;
				elseif clutchPercent < 0.8 then -- up to 80% the clutch can still slip a lot, use fixed percentage 
					clampedMotorRpm = (clampedMotorRpm * 0.1) + (currentRpm * 0.9);
					--clampedMotorRpm = currentRpm;
				else
					clampedMotorRpm = (clampedMotorRpm * ((clutchPercent-0.2)*1.25)) + (currentRpm * (1-((clutchPercent-0.2)*1.25)));
				end;
				
				
				--renderText(0.1, 0.2, 0.02, "clampedMotorRpm: "..tostring(clampedMotorRpm).." currentRpm: "..tostring(currentRpm).." wantedRpm: "..tostring(wantedRpm).." accInput: "..tostring(accInput));
			else

				self.lowBrakeForceScale = 0 --vehicle.spec_realManualTransmission.wantedLowBrakeForceScale;
				--clampedMotorRpm = math.max(self.motorRotSpeed*30/math.pi, ptoRpm, self.minRpm)
				
				-- get clutch RPM shut off motor if RPM gets too low , disable "auto clutch" of FS
				local clutchRpm = math.abs(self:getClutchRotSpeed() *  9.5493);
				
				-- clutch RPM is 0 / nil on clients in Multiplayer! 
				
				if clutchRpm < self.minRpm and clutchRpm > 0 then -- only if not 0 cause Multiplayer 
					clampedMotorRpm = (self.lastRealMotorRpm * 0.7) + (clutchRpm * 0.3);
				end;
				
				-- V 0.6.0.3 addition, stop engine if wheels stopped turning. (I think I had this here before and removed it for some reason, so if there's issues, its because of this)
				if clutchRpm <= 0 and self.isServer then -- check if we're server 
					vehicle:stopMotor()
					clampedMotorRpm = self.minRpm;
					vehicle.spec_realManualTransmission.lastRealRpm = self.minRpm;
				end;

			end;
			
			if clampedMotorRpm < vehicle.spec_realManualTransmission.engineStallRpm then -- to do, add stall rpm variable 
				-- stall the engine 
				vehicle.spec_realManualTransmission.stallTimer = math.max(vehicle.spec_realManualTransmission.stallTimer - dt, 0);
				if vehicle.spec_realManualTransmission.stallTimer == 0 then
					vehicle:stopMotor()
					clampedMotorRpm = self.minRpm;
					vehicle.spec_realManualTransmission.lastRealRpm = self.minRpm;
				end;
			else
				vehicle.spec_realManualTransmission.stallTimer = vehicle.spec_realManualTransmission.engineStallTimer;
			end;
			-- stall the engine if rpm = 0 (V 0.6.0.3 added this, not sure if I need it though since the wheels stop turning before smoothed RPM reaches 0)
			if clampedMotorRpm <= 0 then
				vehicle:stopMotor()
				clampedMotorRpm = self.minRpm;
				vehicle.spec_realManualTransmission.lastRealRpm = self.minRpm;
			end;
			

			clampedMotorRpm = math.max(clampedMotorRpm, 0); -- V 0.6.0.3 changed from stallRpm to 0 because technically the engine can reach 0 rpm
			
			-- stupid smoothing 
			if clampedMotorRpm < vehicle.spec_realManualTransmission.lastRealRpm * 0.73 or clampedMotorRpm > vehicle.spec_realManualTransmission.lastRealRpm * 1.27 then
				vehicle.spec_realManualTransmission.lastRealRpm = (vehicle.spec_realManualTransmission.lastRealRpm * 0.9) + (clampedMotorRpm * 0.1);
			else
				vehicle.spec_realManualTransmission.lastRealRpm = (vehicle.spec_realManualTransmission.lastRealRpm * 0.1) + (clampedMotorRpm * 0.9);
			end;
			


		self:setLastRpm(vehicle.spec_realManualTransmission.lastRealRpm)
		
		--self.equalizedMotorRpm = vehicle:getSmoothingTableAverage(vehicle.spec_realManualTransmission.clientRpmSmoothing, clampedMotorRpm);

		if self.vehicle.isServer then -- self.equalizedMotorRpm gets synchronized somewhere to the clients.. so only server-side this 
			self.equalizedMotorRpm = (self.equalizedMotorRpm * 0.9) + ( 0.1 * vehicle.spec_realManualTransmission.lastRealRpm);
		end;

		-- end modelleicher 
		--

	end;
end;
VehicleMotor.update = Utils.overwrittenFunction(VehicleMotor.update, rmtOverride.newMotorUpdate);

-- I'm trying to somehow get the sound to pitch above a modifier value of 1.. but so far no success
-- anyhow.. this is how to overwrite a modifier return function..
--function realManualTransmission:returnRpmNonClamped()
--	return self.spec_motorized.motor.lastRealMotorRpm / self.spec_motorized.motor.maxRpm;
--end;
--g_soundManager.modifierTypeIndexToDesc[SoundModifierType.MOTOR_RPM].func = realManualTransmission.returnRpmNonClamped

-- g_soundManager.modifierTypeIndexToDesc[SoundModifierType.MOTOR_LOAD].func = function (self) return 0.5 end

-- Motorized:getMotorLoadPercentage()

--SoundManager:registerModifierType(typeName, func, minFunc, maxFunc)


-- return load only, not influenced by RPM 
function rmtOverride.newGetMotorLoadPercentage(self, superFunc)
	if not self.hasRMT or not self.rmtIsOn then
		return superFunc(self);
	end;
	return self.spec_motorized.smoothedLoadPercentage;
end
Motorized.getMotorLoadPercentage = Utils.overwrittenFunction(Motorized.getMotorLoadPercentage, rmtOverride.newGetMotorLoadPercentage);

	
function rmtOverride.newUpdateWheelsPhysics(self, superFunc, dt, currentSpeed, acceleration, doHandbrake, stopAndGoBraking)
	if not self.hasRMT or not self.rmtIsOn then
		superFunc(self, dt, currentSpeed, acceleration, doHandbrake, stopAndGoBraking);
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
					
	
		-- if we are in neutral, don't accelerate
		if self.spec_realManualTransmission.neutral then
			acceleration = 0; 
		end;
		
		-- also, acceleration if clutch is present is dependent on clutch engagement percentage (only on positive acceleration, not on braking)
		if acceleration > 0 then
			acceleration = math.min(acceleration, acceleration*(math.min(self.spec_realManualTransmission.clutchPercent*4))) -- at 20% clutch engagement we already want almost 80% acceleration, this feels better 
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
			--maxClutchTorque = maxClutchTorque * (clutchPercent);
			--print(maxClutchTorque);
			
			--maxAcceleration = maxAcceleration * (clutchPercent);
			--print(maxAcceleration);
	
	        --print(string.format("set vehicle props:   accPed=%.1f   speed=%.1f gearRatio=[%.1f %.1f] rpm=[%.1f %.1f]", absAcceleratorPedal, maxSpeed, minGearRatio, maxGearRatio, minMotorRpm, maxMotorRpm))
	        controlVehicle(self.spec_motorized.motorizedNode, absAcceleratorPedal, maxSpeed, maxAcceleration, minMotorRpm*math.pi/30, maxMotorRpm*math.pi/30, motor:getMotorRotationAccelerationLimit(), minGearRatio, maxGearRatio, maxClutchTorque, neededPtoTorque)
	    end
		
	    self:brake(brakePedal)
	end;
end;
WheelsUtil.updateWheelsPhysics = Utils.overwrittenFunction(WheelsUtil.updateWheelsPhysics, rmtOverride.newUpdateWheelsPhysics)


