local creatorActive = false
local controlsActive = false
local zoneType, step, xCoord, yCoord, zCoord, heading, height, width, length
local steps = {{0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10, 25, 50, 100}, {0.25, 0.5, 1, 2.5, 5, 15, 30, 45, 60, 90, 180}}
local points = {}
local format = 'array'
local displayModes = {'basic', 'walls', 'axes', 'both'}
local displayMode = 1
local minCheck = steps[1][1] / 2

local function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

local function updateText()
	local text = {
		('------ Creating %s Zone ------  \n'):format(firstToUpper(zoneType)),
		('Step size [Scroll]: %sm/%s&deg;  \n'):format(steps[1][step], steps[2][step]),
		('X coord [A/D]: %s  \n'):format(xCoord),
		('Y coord [W/S]: %s  \n'):format(yCoord),
		('Z coord [R/F]: %s  \n'):format(zCoord),
	}

	if zoneType == 'poly' then
		text[#text + 1] = ('Height [Shift + Scroll]: %s  \n'):format(height)
		text[#text + 1] = ('Cycle display mode [G]: %s  \n'):format(firstToUpper(displayModes[displayMode]))
		text[#text + 1] = 'Create new point - [Space]  \n'
	elseif zoneType == 'box' then
		text[#text + 1] = ('Heading [Q/E]: %s&deg;  \n'):format(heading)
		text[#text + 1] = ('Height [Shift + Scroll]: %s  \n'):format(height)
		text[#text + 1] = ('Width [Ctrl + Scroll]: %s  \n'):format(width)
		text[#text + 1] = ('Length [Alt + Scroll]: %s  \n'):format(length)
		text[#text + 1] = ('Cycle display mode [G]: %s  \n'):format(firstToUpper(displayModes[displayMode]))
		text[#text + 1] = 'Recenter - [Space]  \n'
	elseif zoneType == 'sphere' then
		text[#text + 1] = ('Size [Shift + Scroll]: %s  \n'):format(height)
		text[#text + 1] = 'Recenter - [Space]  \n'
	end

	text[#text + 1] = 'Toggle controls - [X]  \n'
	text[#text + 1] = 'Save - [Enter]  \n'
	text[#text + 1] = 'Cancel - [Esc]'

	lib.showTextUI(table.concat(text))
end

local function round(number)
	return number >= 0 and math.floor(number + 0.5) or math.ceil(number - 0.5)
end

local function closeCreator(cancel)
	if not cancel then
		if zoneType == 'poly' then
			points[#points + 1] = vec(xCoord, yCoord)
		end

		local input = lib.inputDialog(('Name your %s Zone'):format(firstToUpper(zoneType)), {
            { type = 'input', label = 'Name', placeholder = 'none' },
            { type = 'select', label = 'Format', default = format, options = {
                { value = 'function', label = 'Function' },
                { value = 'array', label = 'Array' },
                { value = 'target', label = 'Target'},
            }}
        }) or {}

        format = input[2]

		TriggerServerEvent('ox_lib:saveZone', {
			zoneType = zoneType,
			name = input[1] or 'none',
			format = format,
			xCoord = xCoord,
			yCoord = yCoord,
			zCoord = zCoord,
			heading = heading,
			height = height,
			width = width,
			length = length,
			points = points
		})
	end

	creatorActive = false
	controlsActive = false
	lib.hideTextUI()
	zoneType = nil
end

local function drawRectangle(rec)
    DrawPoly(rec[1].x, rec[1].y, rec[1].z, rec[2].x, rec[2].y, rec[2].z, rec[3].x, rec[3].y, rec[3].z, 255, 42, 24, 100)
    DrawPoly(rec[2].x, rec[2].y, rec[2].z, rec[1].x, rec[1].y, rec[1].z, rec[3].x, rec[3].y, rec[3].z, 255, 42, 24, 100)
    DrawPoly(rec[1].x, rec[1].y, rec[1].z, rec[4].x, rec[4].y, rec[4].z, rec[3].x, rec[3].y, rec[3].z, 255, 42, 24, 100)
    DrawPoly(rec[4].x, rec[4].y, rec[4].z, rec[1].x, rec[1].y, rec[1].z, rec[3].x, rec[3].y, rec[3].z, 255, 42, 24, 100)
end

local function drawLines()
	local thickness = vec(0, 0, height / 2)
    local activeA, activeB = vec(xCoord, yCoord, zCoord) + thickness, vec(xCoord, yCoord, zCoord) - thickness

    if zoneType == 'poly' then
        DrawLine(activeA.x, activeA.y, activeA.z, activeB.x, activeB.y, activeB.z, 255, 42, 24, 225)
    end

	for i = 1, #points do
		points[i] = vec(points[i].x, points[i].y, zCoord)
		local a = points[i] + thickness
		local b = points[i] - thickness
		local c = (points[i + 1] and vec(points[i + 1].x, points[i + 1].y, zCoord) or points[1]) + thickness
		local d = (points[i + 1] and vec(points[i + 1].x, points[i + 1].y, zCoord) or points[1]) - thickness
		local e = points[i]
		local f = (points[i + 1] and vec(points[i + 1].x, points[i + 1].y, zCoord) or points[1])

        if i == #points and zoneType == 'poly' then
            DrawLine(a.x, a.y, a.z, b.x, b.y, b.z, 255, 42, 24, 225)
            DrawLine(activeA.x, activeA.y, activeA.z, c.x, c.y, c.z, 255, 42, 24, 225)
            DrawLine(activeB.x, activeB.y, activeB.z, d.x, d.y, d.z, 255, 42, 24, 225)
            DrawLine(a.x, a.y, a.z, activeA.x, activeA.y, activeA.z, 255, 42, 24, 225)
            DrawLine(b.x, b.y, b.z, activeB.x, activeB.y, activeB.z, 255, 42, 24, 225)
            DrawLine(xCoord, yCoord, zCoord, f.x, f.y, f.z, 255, 42, 24, 225)
            DrawLine(e.x, e.y, e.z, xCoord, yCoord, zCoord, 255, 42, 24, 225)
        else
            DrawLine(a.x, a.y, a.z, b.x, b.y, b.z, 255, 42, 24, 225)
            DrawLine(a.x, a.y, a.z, c.x, c.y, c.z, 255, 42, 24, 225)
            DrawLine(b.x, b.y, b.z, d.x, d.y, d.z, 255, 42, 24, 225)
            DrawLine(e.x, e.y, e.z, f.x, f.y, f.z, 255, 42, 24, 225)
        end

        if displayMode == 2 or displayMode == 4 then
            if i == #points and zoneType == 'poly' then
                drawRectangle({a, b, activeB, activeA})
                drawRectangle({activeA, activeB, d, c})
            else
                drawRectangle({a, b, d, c})
            end
        end
	end
end

local function startCreator(arg)
	creatorActive = true
    controlsActive = true
	zoneType = arg

	step = 5
	local coords = GetEntityCoords(cache.ped)
	xCoord = round(coords.x) + 0.0
	yCoord = round(coords.y) + 0.0
	zCoord = round(coords.z) + 0.0
	heading = 0.0
	height = 4.0
	width = 4.0
	length = 4.0
	points = {}

	updateText()

    while creatorActive do
        Wait(0)

        if IsDisabledControlJustReleased(0, 73) then -- x
            if creatorActive then
                controlsActive = not controlsActive
            end
        end

        if displayMode == 3 or displayMode == 4 then
            DrawLine(xCoord, yCoord, zCoord, xCoord + 2, yCoord, zCoord, 0, 0, 255, 225)
            DrawLine(xCoord, yCoord, zCoord, xCoord, yCoord + 2, zCoord, 0, 0, 255, 225)
            DrawLine(xCoord, yCoord, zCoord, xCoord, yCoord, zCoord + 2, 0, 0, 255, 225)
        end

        if zoneType == 'poly' then
            drawLines()
        elseif zoneType == 'box' then
            local rad = math.rad(-heading)
            local sinH = math.sin(rad)
            local cosH = math.cos(rad)
            local center = vec(xCoord, yCoord)
            ---@type vector2[]
            points = {
                center + vec((width * cosH + length * sinH), (length * cosH - width * sinH)) / 2,
                center + vec(-(width * cosH - length * sinH), (length * cosH + width * sinH)) / 2,
                center + vec(-(width * cosH + length * sinH), -(length * cosH - width * sinH)) / 2,
                center + vec((width * cosH - length * sinH), -(length * cosH + width * sinH)) / 2,
            }

            drawLines()
        elseif zoneType == 'sphere' then
            DrawMarker(28, xCoord, yCoord, zCoord, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, height, height, height, 255, 42, 24, 100, false, false, 0, true, false, false, false)
        end

        if controlsActive then
            DisableAllControlActions()
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            EnableControlAction(0, 245, true) -- t
            local change = false
            local lStep = steps[1][step]
            local rStep = steps[2][step]

            if IsDisabledControlJustReleased(0, 17) then -- scroll up
                if IsDisabledControlPressed(0, 21) then -- shift held down
                    change = true
                    height += lStep
                elseif IsDisabledControlPressed(0, 36) then -- ctrl held down
                    change = true
                    width += lStep
                elseif IsDisabledControlPressed(0, 19) then -- alt held down
                    change = true
                    length += lStep
                elseif step < 11 then
                    change = true
                    step += 1
                end
            elseif IsDisabledControlJustReleased(0, 16) then -- scroll down
                if IsDisabledControlPressed(0, 21) then -- shift held down
                    change = true
                    if height - lStep > lStep then
                        height -= lStep
                    elseif height - lStep > 0 then
                        height = lStep
                    end
                elseif IsDisabledControlPressed(0, 36) then -- ctrl held down
                    change = true
                    if width - lStep > lStep then
                        width -= lStep
                    elseif width - lStep > 0 then
                        width = lStep
                    end
                elseif IsDisabledControlPressed(0, 19) then -- alt held down
                    change = true
                    if length - lStep > lStep then
                        length -= lStep
                    elseif length - lStep > 0 then
                        length = lStep
                    end
                elseif step > 1 then
                    change = true
                    step -= 1
                end
            elseif IsDisabledControlJustReleased(0, 32) then -- w
                change = true
                local newValue = yCoord + lStep
                if math.abs(newValue) < minCheck then
                    newValue = 0.0
                end
                yCoord = newValue
            elseif IsDisabledControlJustReleased(0, 33) then -- s
                change = true
                local newValue = yCoord - lStep
                if math.abs(newValue) < minCheck then
                    newValue = 0.0
                end
                yCoord = newValue
            elseif IsDisabledControlJustReleased(0, 35) then -- d
                change = true
                local newValue = xCoord + lStep
                if math.abs(newValue) < minCheck then
                    newValue = 0.0
                end
                xCoord = newValue
            elseif IsDisabledControlJustReleased(0, 34) then -- a
                change = true
                local newValue = xCoord - lStep
                if math.abs(newValue) < minCheck then
                    newValue = 0.0
                end
                xCoord = newValue
            elseif IsDisabledControlJustReleased(0, 45) then -- r
                change = true
                local newValue = zCoord + lStep
                if math.abs(newValue) < minCheck then
                    newValue = 0.0
                end
                zCoord = newValue
            elseif IsDisabledControlJustReleased(0, 23) then -- f
                change = true
                local newValue = zCoord - lStep
                if math.abs(newValue) < minCheck then
                    newValue = 0.0
                end
                zCoord = newValue
            elseif IsDisabledControlJustReleased(0, 38) then -- e
                change = true
                heading -= rStep
                if heading < 0 then
                    heading += 360
                end
            elseif IsDisabledControlJustReleased(0, 44) then -- q
                change = true
                heading += rStep
                if heading >= 360 then
                    heading -= 360
                end
            elseif IsDisabledControlJustReleased(0, 47) then -- g
                change = true
                if displayMode == #displayModes then
                    displayMode = 1
                else
                    displayMode += 1
                end
            elseif IsDisabledControlJustReleased(0, 22) then -- space
                change = true
                if zoneType == 'poly' then
                    points[#points + 1] = vec2(xCoord, yCoord)
                end

                coords = GetEntityCoords(cache.ped)
                xCoord = round(coords.x)
                yCoord = round(coords.y)
            elseif IsDisabledControlJustReleased(0, 201) then -- enter
                closeCreator()
            elseif IsDisabledControlJustReleased(0, 200) then -- esc
                SetPauseMenuActive(false)
                closeCreator(true)
            end

            if change then
                updateText()
            end
        end
    end
end

RegisterCommand('zone', function(source, args, rawCommand)
	if args[1] == 'poly' or args[1] == 'box' or args[1] == 'sphere' then
		if creatorActive then
			lib.notify({title = 'Already creating a zone', type = 'error'})
		else
            CreateThread(function()
			    startCreator(args[1])
            end)
		end
	end
end, true)

TriggerEvent('chat:addSuggestion', '/zone', 'Starts creation of the specified zone', {
    { name = 'zoneType', help = 'poly, box, sphere' },
})
