---@param coords vector3 The coords to check from.
---@param maxDistance number The max distance to check.
---@param includePlayer boolean Whether or not to include the current player.
---@return table players
function lib.getNearbyPlayers(coords, maxDistance, includePlayer)
    local players = GetActivePlayers()
    local nearby = {}
    local count = 0
    maxDistance = maxDistance or 2.0

    for i = 1, #players do
        local playerId = players[i]

        if playerId ~= cache.playerId or includePlayer then
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
    end

    return nearby
end

return lib.getNearbyPlayers
