processGearInputsEvent = {};
processGearInputsEvent_mt = Class(processGearInputsEvent, Event);
InitEventClass(processGearInputsEvent, "processGearInputsEvent");

function processGearInputsEvent:emptyNew()  
    local self = Event:new(processGearInputsEvent_mt );
    self.className="processGearInputsEvent";
    return self;
end;
function processGearInputsEvent:new(vehicle, gearValue, sequentialDir) 
    self.vehicle = vehicle;
    self.gearValue = gearValue;
	self.sequentialDir = sequentialDir;
    return self;
end;
function processGearInputsEvent:readStream(streamId, connection)  
    self.vehicle = NetworkUtil.readNodeObject(streamId); 
    self.gearValue = streamReadInt8(streamId); 
	self.sequentialDir = streamReadIntN(streamId, 2);
    self:run(connection);  
end;
function processGearInputsEvent:writeStream(streamId, connection)   
	NetworkUtil.writeNodeObject(streamId, self.vehicle);   
    streamWriteInt8(streamId, self.gearValue );  
	streamWriteIntN(streamId, self.sequentialDir, 2);
end;
function processGearInputsEvent:run(connection) 
    self.vehicle:processGearInputs(self.gearValue, self.sequentialDir, true);
    if not connection:getIsServer() then  
        g_server:broadcastEvent(processGearInputsEvent:new(self.vehicle, self.gearValue, self.sequentialDir), nil, connection, self.object);
    end;
end;
function processGearInputsEvent.sendEvent(vehicle, gearValue, sequentialDir, noEventSend)  
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then   
            g_server:broadcastEvent(processGearInputsEvent:new(vehicle, gearValue, sequentialDir), nil, nil, vehicle);
        else 
            g_client:getServerConnection():sendEvent(processGearInputsEvent:new(vehicle, gearValue, sequentialDir));
        end;
    end;
end;