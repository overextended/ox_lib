local maxProps = GetConvarInt('ox:progressPropLimit', 2)

---@param props ProgressPropProps | ProgressPropProps[] | nil
RegisterNetEvent('ox_lib:progressProps', function(props)
    if type(props) == 'table' then
        props = #props > maxProps and { table.unpack(props, 1, maxProps) } or props
    else
        props = nil
    end

    Player(source).state:set('lib:progressProps', props, true)
end)
