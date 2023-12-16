---@param coords vector3 The coords to check from.
---@param maxDistance? number The max distance to check.
---@return { id: number, ped: number, coords: vector3 }[]
function lib.getNearbyPlayers(coords, maxDistance)
    local players = GetActivePlayers()
    local nearby = {}
    local count = 0
    maxDistance = maxDistance or 2.0

    for i = 1, #players do
        local playerId = players[i]
        local playerPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(coords - playerCoords)

        if distance < maxDistance then
            count += 1
            nearby[count] = {
                id = playerId,
                ped = playerPed,
                coords = playerCoords,
            }
        end
    end

    return nearby
end

return lib.getNearbyPlayers
