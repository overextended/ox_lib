---@param coords vector3 The coords to check from.
---@param maxDistance? number The max distance to check.
---@return number? playerId
---@return number? playerPed
---@return vector3? playerCoords
function lib.getClosestPlayer(coords, maxDistance)
    local players = GetActivePlayers()
    local closestId, closestPed, closestCoords
    maxDistance = maxDistance or 2.0

    for i = 1, #players do
        local playerId = players[i]
        local playerPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(coords - playerCoords)

        if distance < maxDistance then
            maxDistance = distance
            closestId = playerId
            closestPed = playerPed
            closestCoords = playerCoords
        end
    end

    return closestId, closestPed, closestCoords
end

return lib.getClosestPlayer
