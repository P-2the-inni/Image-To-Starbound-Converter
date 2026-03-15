-- foreground plcaer
function pasteBlocks()
	local foregroundPlace = {}
	for x=1, toPaste.width do
		for y=1, toPaste.height do
			if toPaste[x][y] then
				if toPaste[x][y].block ~= "" then
					table.insert(foregroundPlace, {pos = vec2.add({x,y}, pastePos), block = toPaste[x][y].block, hue = toPaste[x][y].hue or 0})
				end
			end
		end
	end
	for i, v in ipairs(foregroundPlace) do
		world.placeMaterial(v.pos, "foreground", v.block, v.hue or 0, true)
	end
end

function pasteBlocks2(first)
--	local checkVal = 0
--	if first then
--		checkVal = 1
--	end
--	local foregroundPlace = {}
--	for x=1, toPaste.width do
--		if x%2 == checkVal then
--			for y=1, toPaste.height do
--				if toPaste[x][y] then
--					if toPaste[x][y].block ~= "" then
--					--	table.insert(foregroundPlace, {pos = vec2.add({x,y}, pastePos), block = toPaste[x][y].block, hue = toPaste[x][y].hue or 0})
--						world.placeMaterial(vec2.add({x,y}, pastePos), "foreground", toPaste[x][y].block, toPaste[x][y].hue or 0, true)
--					end
--				end
--			end
--		end
--	end
--	for i, v in ipairs(foregroundPlace) do
--		world.placeMaterial(v.pos, "foreground", v.block, v.hue or 0, true)
--	end
	if first then
		for i, v in ipairs(placeList1) do
			world.placeMaterial(v.pos, "foreground", v.block, math.max(0, v.hue or 0), true)
		end
	else
		for i, v in ipairs(placeList2) do
			world.placeMaterial(v.pos, "foreground", v.block, math.max(0, v.hue or 0), true)
		end
	end
end

-- breaker function
function breakTiles(layer)
	world.damageTiles(tiles, layer, {0,0}, "blockish", math.huge, 0)
end

-- background place functions
function fastBackgroundPlace()
--	local toPlace = {}
	
--	for i, v in ipairs(tiles) do
--		if not world.material(v, "background") then
--			table.insert(toPlace, v)
--		end
--	end
--		
--	for i, v in ipairs(toPlace) do
--		world.placeMaterial(v, "background", "hazard")
--	end
	for i, v in ipairs(tiles) do
		if not world.material(v, "background") then
			world.placeMaterial(v, "background", "hazard")
		end
	end
end

function slowBackgroundPlace()
	local placeit = false
	local check = { {0,1}, {1,1}, {1,0}, {1,-1}, {0, -1}, {-1, -1}, {-1, 0}, {-1, 1} }
	
	local toPlace = {}
	for i, v in ipairs(tiles) do
		placeit = false
		if not world.material(v, "background") then
			for _, checkOffset in ipairs(check) do
				if world.material(vec2.add(checkOffset, v), "background") then
					placeit = true
					break;
				end
			end
			if not placeit then
				if world.material(v, "foreground") then
					placeit = true
				end
			end
		end
		if placeit then
			if not world.material(v, "background") then
				table.insert(toPlace, v)
			end
		end
	end
	
	for i, v in ipairs(toPlace) do
		world.placeMaterial(v, "background", "hazard")
	end
end

function selectiveClearBackground()
	local area = {}
	for x=1, toPaste.width do
		for y=1, toPaste.height do
			if toPaste[x][y] then
				if toPaste[x][y].block ~= "" then
					table.insert(area, vec2.add({x,y}, pastePos))
				end
			end
		end	
	end
	world.damageTiles(area, "background", {0,0}, "blockish", math.huge, 0)
end

function placeBlocksBackgroundMode()
	for x=1, toPaste.width do
		for y=1, toPaste.height do
			if toPaste[x][y] then
				if toPaste[x][y].block ~= "" then
					world.placeMaterial(vec2.add({x,y}, pastePos), "background", toPaste[x][y].block, math.max(0, toPaste[x][y].hue or 0), true)
				end
			else
				world.placeMaterial(vec2.add({x,y}, pastePos), "background", "hazard")
			end
		end	
	end
end

function clearIrreliventBackground()
	local area = {}
	for x=1, toPaste.width do
		for y=1, toPaste.height do
			if not toPaste[x][y] then
				table.insert(area, vec2.add({x,y}, pastePos))
			end
		end	
	end
	world.damageTiles(area, "background", {0,0}, "blockish", math.huge, 0)
end