-- Register functionality by: Ian898 
-- Date: 26/11/2018
-- THANK YOU IAN!

-- "by" modelleicher
--


g_specializationManager:addSpecialization("realManualTransmission", "realManualTransmission", g_currentModDirectory.."realManualTransmission.lua")
g_specializationManager:addSpecialization("rmtMenu", "rmtMenu", g_currentModDirectory.."rmtMenu.lua")
g_specializationManager:addSpecialization("rmtInputs", "rmtInputs", g_currentModDirectory.."rmtInputs.lua")

g_specializationManager:addSpecialization("rmtClassicTransmission", "rmtClassicTransmission", g_currentModDirectory.."rmtClassicTransmission.lua")
g_specializationManager:addSpecialization("rmtReverser", "rmtReverser", g_currentModDirectory.."rmtReverser.lua")
g_specializationManager:addSpecialization("rmtAutomatic", "rmtAutomatic", g_currentModDirectory.."rmtAutomatic.lua")

registerRMT = {}


function registerRMT:register(name)
    
    for _, vehicle in pairs(g_vehicleTypeManager:getVehicleTypes()) do
        
        local drivable = false;
        local realManualTransmission = false;
        
        for _, spec in pairs(vehicle.specializationNames) do
        
            if spec == "drivable" then -- check for drivable, only insert into drivable
                drivable = true;
            end
            
            if spec == "realManualTransmission" then -- don't insert if already inserted
                realManualTransmission = true;
            end
			
        end    
        if drivable and not realManualTransmission then
			g_vehicleTypeManager:addSpecialization(vehicle.name, "FS19_realManualTransmission.rmtMenu")
            g_vehicleTypeManager:addSpecialization(vehicle.name, "FS19_realManualTransmission.rmtInputs")
            g_vehicleTypeManager:addSpecialization(vehicle.name, "FS19_realManualTransmission.rmtClassicTransmission")        
            g_vehicleTypeManager:addSpecialization(vehicle.name, "FS19_realManualTransmission.rmtReverser")        
            g_vehicleTypeManager:addSpecialization(vehicle.name, "FS19_realManualTransmission.rmtAutomatic")                    
            g_vehicleTypeManager:addSpecialization(vehicle.name, "FS19_realManualTransmission.realManualTransmission")   
        end
    end
    
end

VehicleTypeManager.finalizeVehicleTypes = Utils.prependedFunction(VehicleTypeManager.finalizeVehicleTypes, registerRMT.register)

rmtLoadXMLConfigs = {};

rmtLoadXMLConfigs.modDirectory = g_currentModDirectory;

function rmtLoadXMLConfigs:loadMap(n)

    print("load map RMT true")
	g_currentMission.rmtGlobals = {};
	g_currentMission.rmtGlobals.basegameConfigsXML = loadXMLFile("basegameConfigs", rmtMenuMain.modDirectory.."basegameConfigs.xml");

	
end;

addModEventListener(rmtLoadXMLConfigs);































