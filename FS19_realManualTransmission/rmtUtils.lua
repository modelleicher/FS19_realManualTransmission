

rmtUtils = {};

-- using tables and average values to smooth stuff 
-- this function adds/fills the initial table with a default value to the given depth 
function rmtUtils:addSmoothingTable(depth, default)
	local smoothingTable = {}
	for i = 1, depth do
		smoothingTable[i] = default;
	end;
	return smoothingTable; -- return the defailt table 
end;

-- this function returns the average of the given table and optionally adds a new Value to it 
function rmtUtils:getSmoothingTableAverage(smoothingTable, addedValue)
	if addedValue ~= nil then
		for i = 2, #smoothingTable do -- shift over each value to the previous spot
			smoothingTable[i-1] = smoothingTable[i];
		end;
		smoothingTable[#smoothingTable] = addedValue; -- add new value into last spot 
	end;
	local average = 0;
	for i = 1, #smoothingTable do
		average = average + smoothingTable[i];
	end;
	average = average / #smoothingTable;
	return average;
end;

-- this function maps a value from one range to another one 
function rmtUtils:mapValue(value, startMin, startMax, endMin, endMax)
	return endMin + (value - startMin)*(endMax - endMin) / (startMax - startMin);
end;



