local input

function lib.inputDialog(heading, rows)
	if input then return end
	input = promise.new()

	SetNuiFocus(true, true)
	SendNUIMessage({
		action = 'openDialog',
		data = {
			heading = heading,
			inputs = rows
		}
	})

	return Citizen.Await(input)
end

RegisterNUICallback('inputData', function(data, cb)
	cb(1)
	if not input then return end
	if not data then input:resolve() else input:resolve(data) end
	SetNuiFocus(false, false)
	input = nil
end)
