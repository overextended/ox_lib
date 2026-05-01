---@alias OxSelectorItem {[1]: number, [2]: any}
---@alias OxSelectorSet OxSelectorItem[]

---@class OxSelector: OxClass
---@field private sets OxSelectorSet | table<string, OxSelectorItem[]>
---@field private totalWeights table<string, number>
local OxSelector = lib.class("OxSelector")

local DEFAULT_SET = 'default'
local deepClone = lib.table.deepclone


local function calculateTotalWeight(set)
    local total = 0
    for i = 1, #set do
        local item = set[i]
        assert(type(item) == "table", "Each OxSelectorItem must be a table")
        local weight = item[1]
        assert(type(weight) == "number" and weight >= 0, "weight must be 0 or more")
        total += weight
    end
    return total
end


---@param sets OxSelectorSet | table<string, OxSelectorItem[]>
function OxSelector:constructor(sets)
    if type(sets) ~= "table" then
        lib.print.error("Invalid sets provided to OxSelector constructor")
    end

    if lib.table.type(sets) == "array" then
        sets = { [DEFAULT_SET] = sets }
    end

    self.private.totalWeights = {}
    self.private.sets = {}

    for setName, set in pairs(sets) do
        assert(type(set) == "table" and lib.table.type(set) == "array", "Each set must be an array of OxSelectorItem")
        assert(#set > 0, "Each set must contain at least one OxSelectorItem")

        self.private.totalWeights[setName] = calculateTotalWeight(set)
    end

    self.private.sets = sets
end

--- Get a random non-weighted item from a specific set
---@param setName? string
---@return OxSelectorItem?
function OxSelector:getRandom(setName)
    local set = (setName and self.private.sets[setName]) or self.private.sets[DEFAULT_SET]
    if not set then return nil end
    local item = set[math.random(#set)][2]

    return type(item) == "table" and deepClone(item) or item
end

--- Get a random weighted item from a specific set
---@param setName? string
---@return OxSelectorItem?
function OxSelector:getRandomWeighted(setName)
    local set = (setName and self.private.sets[setName]) or self.private.sets[DEFAULT_SET]
    if not set then return nil end

    local totalWeight = self.private.totalWeights[setName or DEFAULT_SET]
    if totalWeight == 0 then return nil end

    local randomWeight = math.random() * totalWeight
    local cumulativeWeight = 0

    for i = 1, #set do
        cumulativeWeight = cumulativeWeight + set[i][1]
        if randomWeight < cumulativeWeight then
            local item = set[i][2]
            return type(item) == "table" and deepClone(item) or item
        end
    end

    return nil
end

--- get multiple non-weighted random items from a specific set
---@param setName? string
---@param count number
---@return OxSelectorItem[]
function OxSelector:getRandomAmount(setName, count)
    assert(type(count) == "number" and count > 0, "Count must be a positive number")
    local items = {}
    for _ = 1, count do
        local item = self:getRandom(setName)
        if item then
            table.insert(items, item)
        end
    end
    return items
end

--- get multiple weighted random items from a specific set
---@param setName? string
---@param count number
---@return OxSelectorItem[]
function OxSelector:getRandomWeightedAmount(setName, count)
    assert(type(count) == "number" and count > 0, "Count must be a positive number")
    local items = {}
    for _ = 1, count do
        local item = self:getRandomWeighted(setName)
        if item then
            table.insert(items, item)
        end
    end
    return items
end

--- get all items from a specific set
---@param setName? string
---@return OxSelectorItem[]
function OxSelector:getSet(setName)
    return deepClone((setName and self.private.sets[setName]) or self.private.sets[DEFAULT_SET])
end

--- get all sets
---@return table<string, OxSelectorItem[]>
function OxSelector:getAllSets()
    return deepClone(self.private.sets)
end

--- add a new set
---@param setName string
---@param items OxSelectorItem[]
function OxSelector:addSet(setName, items)
    assert(type(setName) == "string", "setName must be a string")

    if self.private.sets[setName] then
        lib.print.error("Selector set '" .. setName .. "' already exists.")
        return
    end

    assert(type(items) == "table" and lib.table.type(items) == "array", "items must be an array")
    assert(#items > 0, "set must contain at least one OxSelectorItem")

    self.private.totalWeights[setName] = calculateTotalWeight(items)
    self.private.sets[setName] = items
end

--- update an existing set
---@param setName string
---@param newItems OxSelectorItem[]
function OxSelector:updateSet(setName, newItems)
    assert(type(setName) == "string", "setName must be a string")

    if not self.private.sets[setName] then
        lib.print.error("Selector set '" .. setName .. "' does not exist.")
        return
    end

    assert(type(newItems) == "table" and lib.table.type(newItems) == "array", "newItems must be an array")
    assert(#newItems > 0, "set must contain at least one OxSelectorItem")

    self.private.totalWeights[setName] = calculateTotalWeight(newItems)
    self.private.sets[setName] = newItems
end

--- remove a set
---@param setName string
function OxSelector:removeSet(setName)
    assert(type(setName) == "string", "setName must be a string")

    self.private.totalWeights[setName] = nil
    self.private.sets[setName] = nil
end

lib.selector = OxSelector
return lib.selector
