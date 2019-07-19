selectReverserEvent = {};
selectReverserEvent_mt = Class(selectReverserEvent, Event);
InitEventClass(selectReverserEvent, "selectReverserEvent");

function selectReverserEvent:emptyNew()  
    local self = Event:new(selectReverserEvent_mt );
    self.className="selectReverserEvent";
    return self;
end;
function selectReverserEvent:new(vehicle, isForward) 
    self.vehicle = vehicle;
    self.isForward = isForward;
    return self;
end;
function selectReverserEvent:readStream(streamId, connection)  
    self.vehicle = NetworkUtil.readNodeObject(streamId); 
    self.isForward = streamReadBool(streamId); 
    self:run(connection);  
end;
function selectReverserEvent:writeStream(streamId, connection)   
	NetworkUtil.writeNodeObject(streamId, self.vehicle);   
    streamWriteBool(streamId, self.isForward );  
end;
function selectReverserEvent:run(connection) 
    self.vehicle:selectReverser(self.isForward, true);
    if not connection:getIsServer() then  
        g_server:broadcastEvent(selectReverserEvent:new(self.vehicle, self.isForward), nil, connection, self.object);
    end;
end;
function selectReverserEvent.sendEvent(vehicle, isForward, noEventSend)  
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then   
            g_server:broadcastEvent(selectReverserEvent:new(vehicle, isForward), nil, nil, vehicle);
        else 
            g_client:getServerConnection():sendEvent(selectReverserEvent:new(vehicle, isForward));
        end;
    end;
end;