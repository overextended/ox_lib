---@param coords vector3 The coords to check from.
---@param maxDistance number The max distance to check.
---@return number? playerSource
---@return number? playerPed
---@return vector3? playerCoords
function lib.getClosestPlayer(coords, maxDistance)
    local players = GetPlayers()
    local closestId, closestPed, closestCoords
    maxDistance = maxDistance or 2.0

    for i = 1, #players do
        local playerSource = tonumber(players[i])

        local playerPed = GetPlayerPed(playerSource)
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(coords - playerCoords)

        if distance < maxDistance then
            maxDistance = distance
            closestId = playerSource
            closestPed = playerPed
            closestCoords = playerCoords
        end
    end

    return closestId, closestPed, closestCoords
end

return lib.getClosestPlayer
