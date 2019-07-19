processRangeInputsEvent = {};
processRangeInputsEvent_mt = Class(processRangeInputsEvent, Event);
InitEventClass(processRangeInputsEvent, "processRangeInputsEvent");

function processRangeInputsEvent:emptyNew()  
    local self = Event:new(processRangeInputsEvent_mt );
    self.className="processRangeInputsEvent";
    return self;
end;
function processRangeInputsEvent:new(vehicle, up, index, force) 
    self.vehicle = vehicle;
    self.up = up;
	self.index = index;
	self.force = force;
    return self;
end;
function processRangeInputsEvent:readStream(streamId, connection)  
    self.vehicle = NetworkUtil.readNodeObject(streamId); 
    self.up = streamReadIntN(streamId, 2);
	self.index = streamReadIntN(streamId, 4);
	self.force = streamReadInt8(streamId);
    self:run(connection);  
end;
function processRangeInputsEvent:writeStream(streamId, connection)   
	NetworkUtil.writeNodeObject(streamId, self.vehicle);   
    streamWriteIntN(streamId, self.up, 2 );  
    streamWriteIntN(streamId, self.index, 4 );  
    streamWriteInt8(streamId, self.force);  

end;
function processRangeInputsEvent:run(connection) 
    self.vehicle:processRangeInputs(self.up, self.index, self.force, true);
    if not connection:getIsServer() then  
        g_server:broadcastEvent(processRangeInputsEvent:new(self.vehicle, self.up, self.index, self.force), nil, connection, self.object);
    end;
end;
function processRangeInputsEvent.sendEvent(vehicle, up, index, force, noEventSend) 
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then   
            g_server:broadcastEvent(processRangeInputsEvent:new(vehicle, up, index, force), nil, nil, vehicle);
        else 
            g_client:getServerConnection():sendEvent(processRangeInputsEvent:new(vehicle, up, index, force));
        end;
    end;
end;