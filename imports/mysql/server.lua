local MySQL = {}

MySQL.ready = function(cb)
	CreateThread(function()
		repeat Wait(50) until GetResourceState('oxmysql') == 'started'
		cb()
	end)
end

local Store = setmetatable({currentId=0}, {
	__call = function(self, query)
		local id = self.currentId + 1
		self.currentId = id
		self[id] = query
		return id
	end
})

MySQL.store = function(query)
	local type = type(query)
	assert(type == 'string', ('MySQL.store requires a string (received %s)'):format(type))
	return Store(query)
end

local function safeArgs(query, parameters, cb, transaction)
	if type(query) == 'number' then query = Store[query] end

	if transaction then
		assert(type(query) == 'table', ('A table was expected for the transaction (received %s)'):format(query))
	else
		assert(type(query) == 'string', ('A string was expected for the query (received %s)'):format(query))
	end

	if cb then assert(type(cb) == 'function', ('A callback function was expected (received %s)'):format(cb)) end

	local type = parameters and type(parameters)
	if type and type ~= 'table' and type ~= 'function' then
		assert(nil, ('A %s was expected, but instead received %s'):format(cb and 'table' or 'function', parameters))
	end
	return query, parameters, cb
end

local oxmysql = exports.oxmysql

---@param query string
---@param parameters? table|function
---@param cb? function
---@return table result
---returns array of matching rows or result data
function MySQL.execute(query, parameters, cb)
	oxmysql:execute(safeArgs(query, parameters, cb))
end

---@param query string
---@param parameters? table|function
---@param cb? function
---@return table result
---returns table containing key value pairs
function MySQL.single(query, parameters, cb)
	oxmysql:single(safeArgs(query, parameters, cb))
end

---@param query string
---@param parameters? table|function
---@param cb? function
---@return number|string
---returns value of the first column of a single row
function MySQL.scalar(query, parameters, cb)
	oxmysql:scalar(safeArgs(query, parameters, cb))
end

---@param query string
---@param parameters? table|function
---@param cb? function
---@return number result
---returns number of rows updated by the executed query
function MySQL.update(query, parameters, cb)
	oxmysql:update(safeArgs(query, parameters, cb))
end

---@param query string
---@param parameters? table|function
---@param cb? function
---@return table result
---returns the last inserted id
function MySQL.insert(query, parameters, cb)
	oxmysql:insert(safeArgs(query, parameters, cb))
end

---@param queries table
---@param parameters? table|function
---@param cb? function
---@return boolean result successful transaction
function MySQL.transaction(queries, parameters, cb)
	oxmysql:transaction(safeArgs(queries, parameters, cb, true))
end

---@param query string
---@param parameters? table|function
---@param cb? function
---@return table results table containing the results for each query executed
function MySQL.prepare(query, parameters, cb)
	oxmysql:prepare(safeArgs(query, parameters, cb))
end

---@param query string
---@param parameters? table|function
---@return table result
---returns array of matching rows or result data
function MySQL.executeSync(query, parameters)
	query, parameters = safeArgs(query, parameters)
	local promise = promise.new()
	oxmysql:execute(query, parameters, function(result)
		promise:resolve(result)
	end)
	return Citizen.Await(promise)
end

---@param query string
---@param parameters? table|function
---@return table result
---returns table containing key value pairs
function MySQL.singleSync(query, parameters)
	query, parameters = safeArgs(query, parameters)
	local promise = promise.new()
	oxmysql:single(query, parameters, function(result)
		promise:resolve(result)
	end)
	return Citizen.Await(promise)
end

---@param query string
---@param parameters? table|function
---@return number|string
---returns value of the first column of a single row
function MySQL.scalarSync(query, parameters)
	query, parameters = safeArgs(query, parameters)
	local promise = promise.new()
	oxmysql:scalar(query, parameters, function(result)
		promise:resolve(result)
	end)
	return Citizen.Await(promise)
end

---@param query string
---@param parameters? table|function
---@return number result
---returns number of rows updated by the executed query
function MySQL.updateSync(query, parameters)
	query, parameters = safeArgs(query, parameters)
	local promise = promise.new()
	oxmysql:update(query, parameters, function(result)
		promise:resolve(result)
	end)
	return Citizen.Await(promise)
end

---@param query string
---@param parameters? table|function
---@return table result
---returns the last inserted id
function MySQL.insertSync(query, parameters)
	query, parameters = safeArgs(query, parameters)
	local promise = promise.new()
	oxmysql:insert(query, parameters, function(result)
		promise:resolve(result)
	end)
	return Citizen.Await(promise)
end

---@param queries table
---@param parameters? table|function
---@return boolean result successful transaction
function MySQL.transactionSync(queries, parameters)
	queries, parameters = safeArgs(queries, parameters, false, true)
	oxmysql:transaction(queries, parameters, function(result)
		promise:resolve(result)
	end)
	return Citizen.Await(promise)
end

---@param query string
---@param parameters? table|function
---@return table results table containing the results for each query executed
function MySQL.prepareSync(query, parameters)
	query, parameters = safeArgs(query, parameters)
	local promise = promise.new()
	oxmysql:prepare(query, parameters, function(result)
		promise:resolve(result)
	end)
	return Citizen.Await(promise)
end

return MySQL