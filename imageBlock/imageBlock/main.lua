--[[ 

	///////////////////////////////////
	//	Image->Starbound paste tool  //
	///////////////////////////////////

	Made by P_2the_inni  
	Version 1.0.0
	Available at: https://github.com/P-2the-inni/Image-To-Starbound-Converter
	
	If u get missing dependancy errors on the .exe, try installing `Microsoft Visual C++ Redistributable`, this shouldn't be needed but idk
	If ur on mac on linux then its probably not going to work so id just give up now if i were u

	Yes a lot of this code is questionable
	This was an old project that I returned to
	I figured it would be easier to add to the existing shitty code rather than make a new one from scratch
	Pls let me know any bugs or suggestions
	Have fun :)
	
	The current .exe converter is using re-written code from the lua converter as c++ so there may be bugs/issues/things i missed
	This is version 1.0.0 so dont expect perfection
	
	todo:
		- rewrite entire lua item as this one is pretty messy
		- optimise generator
		- see if i can optimise paster
		- previewer ingame? along with tickbox for preview
--]]

require "/scripts/vec2.lua"

require "/imageBlock/util.lua"
require "/imageBlock/placer.lua" -- functionality for breaking and placing blocks

-- global variables
require "/imageBlock/imageData.lua" -- 'toPaste = {...}'

-- these variable names are all shit but i dont want to change them out of fear of it breaking
pasted = false
pastePos = nil
doBackground = false
finished = false
startTime = 0

frontBroken = false
frontBrokenDelay = 0
backBroken = false
backBrokenDelay = -50 -- just to add a bit of delay between stages

tiles = {} -- list of positions for the area
placeList1 = {} 
placeList2 = {} -- foreground paste places half the blocks at a time, this is probably no longer needed but oh well

-- locals
local pixelLimit = 20000 --20000 -- the generator also has a limit so this value practically makes no difference
local fastMode = true -- just leave this as true, this was just for testing an alternative algorithm

local backgroundComplete = false
local checkCount = 0
local firstPlace = true
local firstPlaceTimer = 0

local mode = "" -- leave this as "", let interface set its value

local firstClear = false
local fastPlaceForeground = true
local backgroundFinished = false
local clearingFinished = false

local delay = 0 -- when making the background mode the delay was made significantly less bad

function init()
	activeItem.setTwoHandedGrip(false)
	activeItem.setHoldingItem(false)
	activeItem.setScriptedAnimationParameter("lightning", {})
	
	if not (toPaste.width or toPaste.height or toPaste.paintEnabled) then
		addLine("No input found")
		addMessage("No input found")
		animator.playSound("error")
		return;
	end
	if toPaste.width*toPaste.height > pixelLimit then
		addLine(("Input exceeds limit, %s > %s"):format(toPaste.width*toPaste.height, pixelLimit))
		addMessage(("Input exceeds limit, %s > %s"):format(toPaste.width*toPaste.height, pixelLimit))
		animator.playSound("error")
		return;
	end	
    message.setHandler("paster_setMode", function(_, ownClient, newMode)
        if ownClient then
			mode = newMode
			activeItem.setHoldingItem(true)
			animator.playSound("equip")
			addMessage(("%sx%s image\n(%s blocks)\npaint enabled: %s\nfast place: %s\nmode: %s"):format(toPaste.width, toPaste.height, getBlockCount(), toPaste.paintEnabled, fastMode, mode))
        end
    end)
	
	script.setUpdateDelta(2) -- 1 is every frame, 60 every second... etc, if u want to speed the item up change this to 1
end

function uninit() end

local firstTick = true

function update(dt, fireMode)

	if backBroken then return end
	
	if firstTick then
		player.interact( "ScriptPane", root.assetJson( "/imageBlock/interface/interface.json" ) )
		firstTick = false
	end
	
	if mode == "" then return end
	
	if not (toPaste.width or toPaste.height or toPaste.paintEnabled) then
		addMessage("No input found")
		return;
	end
	if toPaste.width*toPaste.height > pixelLimit then
		addMessage(("Input exceeds limit, %s > %s"):format(toPaste.width*toPaste.height, pixelLimit))
		return;
	end	
	
	delay = math.max(0, delay - dt)
	
	local aimAngle, aimDirection = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
	activeItem.setArmAngle(aimAngle)
	activeItem.setFacingDirection(aimDirection)

	if not pasted then
		world.debugPoint(vec2.add(getPos(activeItem.ownerAimPosition()), {1,1}), "green")
		world.debugPoint(vec2.add(getPos(activeItem.ownerAimPosition()), {toPaste.width,1}), "green")
		world.debugPoint(vec2.add(getPos(activeItem.ownerAimPosition()), {1,toPaste.height}), "green")
		displayLine(toPaste.paintEnabled)
	end
	
	if fireMode == "primary" and not pasted then -- begin paste
		-- should check its possible to place anywhere within the region before starting
		animator.playSound("click")
		pasted = true
		pastePos = getPos(activeItem.ownerAimPosition())
		doBackground = true
		addMessage(("Pasting %sx%s image"):format(toPaste.width, toPaste.height))
		addLine(("Pasting %sx%s image"):format(toPaste.width, toPaste.height))
	
		-- generate tiles only once
		for x=1, toPaste.width do
			for y=1, toPaste.height do
				table.insert(tiles, vec2.add({x,y}, pastePos))
			end
		end
		-- generate 'toPlaceList' only once
		generateToPlace()
		addMessage("Generated start list")
		startTime = os.clock()
	end
	
	if mode == "foreground" then
		if not backgroundComplete and pastePos then -- only check if its complete until it is complete, otherwise skip the loop to save processing power
			backgroundComplete = checkDone()
		--	checkCount = checkCount + 1
		--	local maxChecks = 25
		--	if not fastMode then
		--		maxChecks = maxChecks*10
		--	end
		--	if checkCount > maxChecks then -- if we fail to place the background too many times then just give up -> should change this to check if the background is still getting placed or not
		--		backBroken = true
		--		addMessage("Aborted paste")
		--		animator.playSound("error")
		--		return;
		--	end
		end
		if pasted and not backgroundComplete then -- background placing
			addMessage(("Fast place mode: %s"):format(fastMode))
			if fastMode then
				fastBackgroundPlace()
			else
				slowBackgroundPlace()
			end
		elseif pasted and not finished then
			if frontBroken then
				if frontBrokenDelay > 150 then
					if (firstPlaceTimer >= 100) or firstPlace then
						pasteBlocks2(firstPlace)
						if firstPlace then
							firstPlace = false
						else
							finished = true
							animator.playSound("place")
							addMessage(("Placed %s blocks, fastMode: %s"):format(getBlockCount(), fastPlaceForeground))
						end
					else
						if fastPlaceForeground then
							firstPlaceTimer = 100
						else
							firstPlaceTimer = math.min(100, firstPlaceTimer + 2.5)
							addMessage(("Waiting %s"):format(firstPlaceTimer))
						end
					end
				else
					frontBrokenDelay = frontBrokenDelay + 5
					addMessage("Clearing foreground... (" .. tostring(math.round(math.min(100, (frontBrokenDelay/150)*100))) .. "%)")
					if frontBrokenDelay < 50 then
						breakTiles("foreground")
					end
				end
			else	
				breakTiles("foreground")
				frontBroken = true
				frontBrokenDelay = 0
				addLine("Beginning foreground clear...")
			end
		elseif finished then -- if we have pasted the foreground blocks 
			if backBrokenDelay >= 50 then -- once we have waited, then clear the background blocks
				for i=1, 3 do
					breakTiles("background")
				end
				addMessage(("Completed %s blocks in %.2f seconds."):format(getBlockCount(), os.clock() - startTime))
				addLine(("Completed %s blocks in %.2f seconds."):format(getBlockCount(), os.clock() - startTime))
				backBroken = true
			else
				backBrokenDelay = backBrokenDelay + 5
				if backBrokenDelay > 0 then
					addMessage("Waiting to clear background... (" .. tostring(math.round(math.min(100, backBrokenDelay*2))) .. "%)")
				end
			end
		end
	elseif mode == "background" and pasted then
        if not firstClear and delay == 0 then -- break initial background
            addMessage("clearing area...")
            selectiveClearBackground()
            firstClear = not checkDone()
            delay = 0.5
        else
            if not backgroundFinished and delay == 0 then
                backgroundFinished = checkDone2()
            end
            if backgroundFinished and delay == 0 then
                clearIrreliventBackground()
                addMessage("Removing placeholder blocks...")
                delay = 0.5
				addMessage(("Completed %s blocks in %.2f seconds."):format(getBlockCount(), os.clock() - startTime))
				animator.playSound("place")
				breakTiles("foreground")
				backBroken = true;
            elseif delay == 0 then
                placeBlocksBackgroundMode()
                addMessage("placing")
            end
        end
	else
		if pasted then
			addMessage("Invalid mode selected: " .. tostring(mode))
		end
	end
end

