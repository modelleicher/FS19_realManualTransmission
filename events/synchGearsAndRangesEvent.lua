synchGearsAndRangesEvent = {};
synchGearsAndRangesEvent_mt = Class(synchGearsAndRangesEvent, Event);
InitEventClass(synchGearsAndRangesEvent, "synchGearsAndRangesEvent");

function synchGearsAndRangesEvent:emptyNew()  
    local self = Event:new(synchGearsAndRangesEvent_mt );
    self.className="synchGearsAndRangesEvent";
    return self;
end;
function synchGearsAndRangesEvent:new(vehicle, currentGear, currentRange1, currentRange2, currentRange3, neutral) 
    self.vehicle = vehicle;
	self.currentGear = currentGear;
	self.currentRange1 = currentRange1;
	self.currentRange2 = currentRange2;
	self.currentRange3 = currentRange3;
	self.neutral = neutral;
    return self;
end;
function synchGearsAndRangesEvent:readStream(streamId, connection)  
    self.vehicle = NetworkUtil.readNodeObject(streamId); 
	
	self.currentGear = streamReadInt8(streamId);
	self.currentRange1 = streamReadInt8(streamId);
	self.currentRange2 = streamReadInt8(streamId);
	self.currentRange3 = streamReadInt8(streamId);
	self.neutral = streamReadBool(streamId);
	
    self:run(connection);  
end;
function synchGearsAndRangesEvent:writeStream(streamId, connection)   
	NetworkUtil.writeNodeObject(streamId, self.vehicle);   
	
	streamWriteInt8(streamId, self.currentGear);
	streamWriteInt8(streamId, self.currentRange1);
	streamWriteInt8(streamId, self.currentRange2);
	streamWriteInt8(streamId, self.currentRange3);
	streamWriteBool(streamId, self.neutral);
end;
function synchGearsAndRangesEvent:run(connection) 
    self.vehicle:synchGearsAndRanges(self.currentGear, self.currentRange1, self.currentRange2, self.currentRange3, self.neutral, true);
    if not connection:getIsServer() then  
        g_server:broadcastEvent(synchGearsAndRangesEvent:new(self.vehicle, self.currentGear, self.currentRange1, self.currentRange2, self.currentRange3, self.neutral), nil, connection, self.object);
    end;
end;
function synchGearsAndRangesEvent.sendEvent(vehicle, currentGear, currentRange1, currentRange2, currentRange3, neutral , noEventSend)  
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then   
            g_server:broadcastEvent(synchGearsAndRangesEvent:new(vehicle, currentGear, currentRange1, currentRange2, currentRange3, neutral), nil, nil, vehicle);
        else 
            g_client:getServerConnection():sendEvent(synchGearsAndRangesEvent:new(vehicle, currentGear, currentRange1, currentRange2, currentRange3, neutral ));
        end;
    end;
end;
