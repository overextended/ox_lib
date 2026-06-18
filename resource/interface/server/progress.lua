local maxProps = GetConvarInt('ox:progressPropLimit', 2)

---@param props ProgressPropProps | ProgressPropProps[] | nil
RegisterNetEvent('ox_lib:progressProps', function(props)
    if type(props) ~= 'table' then
        return Player(source).state:set('lib:progressProps', nil, true)
    end

    -- The API accepts a single prop or an array, so wrap a lone prop object before validating.
    if props.model ~= nil then props = { props } end

    -- props is replicated to other clients, so only accept a bounded array of prop tables.
    if table.type(props) == 'hash' then
        return Player(source).state:set('lib:progressProps', nil, true)
    end

    local sanitized = {}
    local count = 0

    for i = 1, #props do
        local prop = props[i]
        local model = type(prop) == 'table' and prop.model

        if type(model) == 'string' or type(model) == 'number' then
            count += 1
            sanitized[count] = prop

            if count >= maxProps then break end
        end
    end

    Player(source).state:set('lib:progressProps', count > 0 and sanitized or nil, true)
end)
