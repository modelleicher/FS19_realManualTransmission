


processToggleOnOffEvent = {};
processToggleOnOffEvent_mt = Class(processToggleOnOffEvent, Event);
InitEventClass(processToggleOnOffEvent, "processToggleOnOffEvent");

function processToggleOnOffEvent:emptyNew()  
    local self = Event:new(processToggleOnOffEvent_mt );
    self.className="processToggleOnOffEvent";
    return self;
end;
function processToggleOnOffEvent:new(vehicle, state) 
    self.vehicle = vehicle;
    self.state = state;
    return self;
end;
function processToggleOnOffEvent:readStream(streamId, connection)  
    self.vehicle = NetworkUtil.readNodeObject(streamId); 
    self.state = streamReadBool(streamId); 
    self:run(connection);  
end;
function processToggleOnOffEvent:writeStream(streamId, connection)   
	NetworkUtil.writeNodeObject(streamId, self.vehicle);   
    streamWriteBool(streamId, self.state );   
end;
function processToggleOnOffEvent:run(connection) 
    self.vehicle:processToggleOnOff(self.state, false, true);
    if not connection:getIsServer() then  
        g_server:broadcastEvent(processToggleOnOffEvent:new(self.vehicle, self.state), nil, connection, self.object);
    end;
end;
function processToggleOnOffEvent.sendEvent(vehicle, state, noEventSend) 
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then   
            g_server:broadcastEvent(processToggleOnOffEvent:new(vehicle, state), nil, nil, vehicle);
        else 
            g_client:getServerConnection():sendEvent(processToggleOnOffEvent:new(vehicle, state));
        end;
    end;
end;