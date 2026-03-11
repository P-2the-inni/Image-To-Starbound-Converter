function rgbToHex(r, g, b)
    r = math.max(0, math.min(255, r))
    g = math.max(0, math.min(255, g))
    b = math.max(0, math.min(255, b))

    return string.format("%02X%02X%02X", r, g, b)
end

function displayLine(rgb)
    local targetPos = getPos(activeItem.ownerAimPosition())

    local p1 = {1, 1}
    local p2 = {toPaste.width, 1}
    local p4 = {toPaste.width, toPaste.height}
    local p3 = {1, toPaste.height}
	
	local colourz = {255,255,255,255}
	if rgb then
		colourz = {math.abs(math.sin(os.clock())*255),math.abs(math.sin(os.clock()+math.pi/3)*255),math.abs(math.sin(os.clock()+math.pi/3+math.pi/2)*255),255}
	end

    local baseLine = {
        displacement = 0.0001,
        minDisplacement = 0.01,
        forks = 0,
        forkAngleRange = 1,
        width = 1.5,
        color = colourz
    }

    local function makeLine(startPos, endPos)
        local line = {}
        for k, v in pairs(baseLine) do line[k] = v end
        line.worldStartPosition = vec2.add(targetPos, startPos)
        line.worldEndPosition = vec2.add(targetPos, endPos)
        return line
    end

    local myLines = {
        makeLine(p1, p3),
        makeLine(p4, p3),
        makeLine(p4, p2),
        makeLine(p1, p2)
    }

    activeItem.setScriptedAnimationParameter("lightning", myLines)
	animator.setGlobalTag("directives", "?saturation=-100?multiply=" .. rgbToHex(math.round(colourz[1]), math.round(colourz[2]), math.round(colourz[3])))
end

function getBlockCount()
	local count = 0
	for x=1, toPaste.width do
		for y=1, toPaste.height do
			if toPaste[x][y] then
				if toPaste[x][y].block ~= "" then
					count = count + 1
				end
			end
		end
	end
	return count
end

-- checks if all background blocks have been placed
function checkDone()
	for i, v in ipairs(tiles) do
		if not world.material(v, "background") then
			return false
		end
	end
	return true
end

function checkDone2()
	local count = 0
	for x=1, toPaste.width do
		for y=1, toPaste.height do
			if toPaste[x][y] then
				if toPaste[x][y].block ~= "" then
					if world.material(vec2.add({x,y}, pastePos), "background") then
						count = count + 1
					else
						count = count - 1
					end
				end
			end
		end	
	end
	return count == getBlockCount()
end

function generateToPlace()
	for x=1, toPaste.width do
		if x%2 == 0 then
			for y=1, toPaste.height do
				if toPaste[x][y] then
					if toPaste[x][y].block ~= "" then
						table.insert(placeList1, {pos = vec2.add({x,y}, pastePos), block = toPaste[x][y].block, hue = toPaste[x][y].hue or 0})
					end
				end
			end
		else
			for y=1, toPaste.height do
				if toPaste[x][y] then
					if toPaste[x][y].block ~= "" then
						table.insert(placeList2, {pos = vec2.add({x,y}, pastePos), block = toPaste[x][y].block, hue = toPaste[x][y].hue or 0})
					end
				end
			end
		end
	end
end

function getPos(pos)
    return vec2.sub(vec2.round(pos), {0.5, 0.5})
end

function vec2.round(vector)
    return {math.round(vector[1]), math.round(vector[2])}
end

function math.round(x)
    if x%2 ~= 0.5 then
      return math.floor(x+0.5)
    end
    return x-0.5
end

-- external dll functions, replace with equivilent if u have one
function addMessage(msg)
	if not starDll then return; end
	starDll.chat_addMessage(msg)
end

function addLine(msg)
	if not starDll then return; end
	starDll.chat_addLine("[Paster] " .. msg)
end