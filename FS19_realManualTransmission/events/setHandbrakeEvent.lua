setHandbrakeEvent = {};
setHandbrakeEvent_mt = Class(setHandbrakeEvent, Event);
InitEventClass(setHandbrakeEvent, "setHandbrakeEvent");

function setHandbrakeEvent:emptyNew()  
    local self = Event:new(setHandbrakeEvent_mt );
    self.className="setHandbrakeEvent";
    return self;
end;
function setHandbrakeEvent:new(vehicle, state) 
    self.vehicle = vehicle;
    self.state = state;
    return self;
end;
function setHandbrakeEvent:readStream(streamId, connection)  
    self.vehicle = NetworkUtil.readNodeObject(streamId); 
    self.state = streamReadBool(streamId); 
    self:run(connection);  
end;
function setHandbrakeEvent:writeStream(streamId, connection)   
	NetworkUtil.writeNodeObject(streamId, self.vehicle);   
    streamWriteBool(streamId, self.state );   
end;
function setHandbrakeEvent:run(connection) 
    self.vehicle:setHandBrake(self.state, true);
    if not connection:getIsServer() then  
        g_server:broadcastEvent(setHandbrakeEvent:new(self.vehicle, self.state), nil, connection, self.object);
    end;
end;
function setHandbrakeEvent.sendEvent(vehicle, state, noEventSend) 
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then   
            g_server:broadcastEvent(setHandbrakeEvent:new(vehicle, state), nil, nil, vehicle);
        else 
            g_client:getServerConnection():sendEvent(setHandbrakeEvent:new(vehicle, state));
        end;
    end;
end;