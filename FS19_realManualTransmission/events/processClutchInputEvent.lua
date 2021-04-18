processClutchInputEvent = {};
processClutchInputEvent_mt = Class(processClutchInputEvent, Event);
InitEventClass(processClutchInputEvent, "processClutchInputEvent");

function processClutchInputEvent:emptyNew()  
    local self = Event:new(processClutchInputEvent_mt );
    self.className="processClutchInputEvent";
    return self;
end;
function processClutchInputEvent:new(vehicle, inputValue) 
    self.vehicle = vehicle;
    self.inputValue = inputValue;
    return self;
end;
function processClutchInputEvent:readStream(streamId, connection)  
    self.vehicle = NetworkUtil.readNodeObject(streamId); 
    self.inputValue = streamReadIntN(streamId, 2); 
    self:run(connection);  
end;
function processClutchInputEvent:writeStream(streamId, connection)   
	NetworkUtil.writeNodeObject(streamId, self.vehicle);   
    streamWriteIntN(streamId, self.inputValue, 2 );   
end;
function processClutchInputEvent:run(connection) 
    self.vehicle:processClutchInput(self.inputValue, true);
    if not connection:getIsServer() then  
        g_server:broadcastEvent(processClutchInputEvent:new(self.vehicle, self.inputValue), nil, connection, self.object);
    end;
end;
function processClutchInputEvent.sendEvent(vehicle, inputValue, noEventSend)  
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then   
            g_server:broadcastEvent(processClutchInputEvent:new(vehicle, inputValue), nil, nil, vehicle);
        else 
            g_client:getServerConnection():sendEvent(processClutchInputEvent:new(vehicle, inputValue));
        end;
    end;
end;