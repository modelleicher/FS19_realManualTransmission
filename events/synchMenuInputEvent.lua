synchMenuInputEvent = {};
synchMenuInputEvent_mt = Class(synchMenuInputEvent, Event);
InitEventClass(synchMenuInputEvent, "synchMenuInputEvent");

function synchMenuInputEvent:emptyNew()  
    local self = Event:new(synchMenuInputEvent_mt );
    self.className="synchMenuInputEvent";
    return self;
end;
function synchMenuInputEvent:new(vehicle, synchId, state) 
    self.vehicle = vehicle;
	self.synchId = synchId;
    self.state = state;
    return self;
end;
function synchMenuInputEvent:readStream(streamId, connection)  
    self.vehicle = NetworkUtil.readNodeObject(streamId); 
	self.synchId = streamReadInt8(streamId);
    self.state = streamReadBool(streamId); 
    self:run(connection);  
end;
function synchMenuInputEvent:writeStream(streamId, connection)   
	NetworkUtil.writeNodeObject(streamId, self.vehicle);   
	streamWriteInt8(streamId, self.synchId);
    streamWriteBool(streamId, self.state );   
end;
function synchMenuInputEvent:run(connection) 
    self.vehicle:synchMenuInput(self.synchId, self.state, true);
    if not connection:getIsServer() then  
        g_server:broadcastEvent(synchMenuInputEvent:new(self.vehicle, self.synchId, self.state), nil, connection, self.object);
    end;
end;
function synchMenuInputEvent.sendEvent(vehicle, synchId, state, noEventSend) 
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then   
            g_server:broadcastEvent(synchMenuInputEvent:new(vehicle, synchId, state), nil, nil, vehicle);
        else 
            g_client:getServerConnection():sendEvent(synchMenuInputEvent:new(vehicle, synchId, state));
        end;
    end;
end;