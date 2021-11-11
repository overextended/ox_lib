----------------------------------------------------------
--- Add additional functions to the standard table library
----------------------------------------------------------

local table = table
local pairs = pairs

local function contains(tbl, value)
	if type(value) == 'string' then
		for _, v in pairs(tbl) do
			if v == value then return true end
		end
	else
		local matched_values = 0
		local values = 0
		for _, v1 in pairs(value) do
			values += 1

			for _, v2 in pairs(tbl) do
				if v1 == v2 then matched_values += 1 end
			end
		end
		if matched_values == values then return true end
	end
	return false
end
table.contains = contains

local function match(t1, t2)
	if t1 == t2 then return true end
	if type(t1) ~= 'table' then return false end

	local matched_values = 0
	local values = 0

	for _, v in pairs(t1) do
		values += 1
		if type(t2) == 'table' then
			for _, v2 in pairs(t2) do
				if v == v2 then
					matched_values += 1
				elseif match(v, v2) then
					values += 1
					matched_values += #v
				end
			end
		elseif v == t2 then matched_values += 1 end
	end
	return matched_values == values
end
table.match = match

return table