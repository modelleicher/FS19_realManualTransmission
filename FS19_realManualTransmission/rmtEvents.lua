-- by modelleicher



-- Handbrake Event

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
	print("setHandBrakeEvent: "..tostring(self.state));
    if not connection:getIsServer() then  
        g_server:broadcastEvent(setHandbrakeEvent:new(self.vehicle, self.state), nil, connection, self.object);
    end;
end;
function setHandbrakeEvent.sendEvent(vehicle, state, noEventSend) 
	print("setHandbrakeEvent.sendEvent "..tostring(noEventSend));
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then   
            g_server:broadcastEvent(setHandbrakeEvent:new(vehicle, state), nil, nil, vehicle);
        else 
            g_client:getServerConnection():sendEvent(setHandbrakeEvent:new(vehicle, state));
        end;
    end;
end;

-- process clutch event 
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
	print("processClutchInput: "..tostring(self.inputValue));
    if not connection:getIsServer() then  
        g_server:broadcastEvent(processClutchInputEvent:new(self.vehicle, self.inputValue), nil, connection, self.object);
    end;
end;
function processClutchInputEvent.sendEvent(vehicle, inputValue, noEventSend)  
	print("processClutchInputEvent.sendEvent "..tostring(noEventSend));
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then   
            g_server:broadcastEvent(processClutchInputEvent:new(vehicle, inputValue), nil, nil, vehicle);
        else 
            g_client:getServerConnection():sendEvent(processClutchInputEvent:new(vehicle, inputValue));
        end;
    end;
end;

-- select range Event 

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
	print("processGearInputsEvent: "..tostring(self.gearValue).."-"..tostring(self.sequentialDir));
    if not connection:getIsServer() then  
        g_server:broadcastEvent(processGearInputsEvent:new(self.vehicle, self.gearValue, self.sequentialDir), nil, connection, self.object);
    end;
end;
function processGearInputsEvent.sendEvent(vehicle, gearValue, sequentialDir, noEventSend)  
	print("processGearInputsEvent.sendEvent "..tostring(noEventSend));
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then   
            g_server:broadcastEvent(processGearInputsEvent:new(vehicle, gearValue, sequentialDir), nil, nil, vehicle);
        else 
            g_client:getServerConnection():sendEvent(processGearInputsEvent:new(vehicle, gearValue, sequentialDir));
        end;
    end;
end;

-- process range events
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
	print("processRangeInputsEvent: "..tostring(self.up).."-"..tostring(self.index).."-"..tostring(self.force));
    if not connection:getIsServer() then  
        g_server:broadcastEvent(processRangeInputsEvent:new(self.vehicle, self.up, self.index, self.force), nil, connection, self.object);
    end;
end;
function processRangeInputsEvent.sendEvent(vehicle, up, index, force, noEventSend) 
	print("processRangeInputsEvent.sendEvent "..tostring(noEventSend));
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then   
            g_server:broadcastEvent(processRangeInputsEvent:new(vehicle, up, index, force), nil, nil, vehicle);
        else 
            g_client:getServerConnection():sendEvent(processRangeInputsEvent:new(vehicle, up, index, force));
        end;
    end;
end;

-- selectReverser 
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
	print("selectReverserEvent: "..tostring(self.isForward));
    if not connection:getIsServer() then  
        g_server:broadcastEvent(selectReverserEvent:new(self.vehicle, self.isForward), nil, connection, self.object);
    end;
end;
function selectReverserEvent.sendEvent(vehicle, isForward, noEventSend)  
	print("selectReverserEvent.sendEvent "..tostring(noEventSend));
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then   
            g_server:broadcastEvent(selectReverserEvent:new(vehicle, isForward), nil, nil, vehicle);
        else 
            g_client:getServerConnection():sendEvent(selectReverserEvent:new(vehicle, isForward));
        end;
    end;
end;



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
	print("synchGearsAndRangesEvent: "..tostring(self.currentGear));
    if not connection:getIsServer() then  
        g_server:broadcastEvent(synchGearsAndRangesEvent:new(self.vehicle, self.currentGear, self.currentRange1, self.currentRange2, self.currentRange3, self.neutral), nil, connection, self.object);
    end;
end;
function synchGearsAndRangesEvent.sendEvent(vehicle, currentGear, currentRange1, currentRange2, currentRange3, neutral , noEventSend)  
	print("synchGearsAndRangesEvent.sendEvent "..tostring(noEventSend));
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then   
            g_server:broadcastEvent(synchGearsAndRangesEvent:new(vehicle, currentGear, currentRange1, currentRange2, currentRange3, neutral), nil, nil, vehicle);
        else 
            g_client:getServerConnection():sendEvent(synchGearsAndRangesEvent:new(vehicle, currentGear, currentRange1, currentRange2, currentRange3, neutral ));
        end;
    end;
end;


-- Handbrake Event

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
	print("synchMenuInputEvent: "..tostring(self.state));
    if not connection:getIsServer() then  
        g_server:broadcastEvent(synchMenuInputEvent:new(self.vehicle, self.synchId, self.state), nil, connection, self.object);
    end;
end;
function synchMenuInputEvent.sendEvent(vehicle, synchId, state, noEventSend) 
	print("synchMenuInputEvent.sendEvent "..tostring(synchId).." "..tostring(state).." "..tostring(noEventSend));
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then   
            g_server:broadcastEvent(synchMenuInputEvent:new(vehicle, synchId, state), nil, nil, vehicle);
        else 
            g_client:getServerConnection():sendEvent(synchMenuInputEvent:new(vehicle, synchId, state));
        end;
    end;
end;

