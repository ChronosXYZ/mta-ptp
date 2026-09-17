--[[
    Map Limits System

    Monitors player positions and ensures they stay within defined maplimit polygons.
    Players outside limits are warned and periodically damaged until returning or dying.

    XML format in map files:
    <maplimit>
        <point x="100.0" y="200.0" />
        <point x="300.0" y="200.0" />
        <point x="300.0" y="400.0" />
        <point x="100.0" y="400.0" />
    </maplimit>
]]

local CHECK_INTERVAL_MS = 200
local DAMAGE_PER_TICK = 1
local KILL_HEALTH_THRESHOLD = 10

mapLimits = {}
local warningDisplay = nil
local warningTextItem = nil
local checkTimer = nil

-- Tests if point (x2, y2) is Left|On|Right of the directed line from (x0, y0) to (x1, y1)
-- > 0 for left of line, = 0 on line, < 0 for right of line
function isLeft(x0, y0, x1, y1, x2, y2)
	return ((x1 - x0) * (y2 - y0) - (x2 - x0) * (y1 - y0))
end

-- Point-in-polygon test using winding number algorithm
-- Supports both CW and CCW vertex ordering, and properly closes polygon (V[n] -> V[1])
function isInPoli(x0, y0, polyTable)
	if not polyTable or #polyTable < 3 then
		return 0
	end

	-- Bounding box fast-rejection
	if polyTable.minX and (x0 < polyTable.minX or x0 > polyTable.maxX or y0 < polyTable.minY or y0 > polyTable.maxY) then
		return 0
	end

	local wn = 0
	local n = #polyTable
	for i = 1, n do
		local p1 = polyTable[i]
		local p2 = polyTable[(i % n) + 1]

		if p1.y <= y0 then
			if p2.y > y0 and isLeft(p1.x, p1.y, p2.x, p2.y, x0, y0) > 0 then
				wn = wn + 1
			end
		else
			if p2.y <= y0 and isLeft(p1.x, p1.y, p2.x, p2.y, x0, y0) < 0 then
				wn = wn - 1
			end
		end
	end

	return wn
end

-- Checks if coordinates (x, y) are inside at least one defined maplimit polygon
function isPositionWithinLimits(x, y)
	if #mapLimits == 0 then
		return true
	end

	for i = 1, #mapLimits do
		if isInPoli(x, y, mapLimits[i]) ~= 0 then
			return true
		end
	end

	return false
end

-- Parses all <maplimit> elements from currently loaded maps
function buildTables()
	mapLimits = {}
	local limitElements = getElementsByType("maplimit")

	for _, limitElem in ipairs(limitElements) do
		local pointElements = getElementChildren(limitElem, "point")
		if #pointElements == 0 then
			for _, child in ipairs(getElementChildren(limitElem)) do
				if getElementType(child) == "point" then
					pointElements[#pointElements + 1] = child
				end
			end
		end

		if #pointElements < 3 then
			outputDebugString(
			"[MapLimits] Warning: <maplimit> element has fewer than 3 points (got " .. #pointElements .. "), skipping.",
				2)
		else
			local limit = {
				minX = math.huge,
				maxX = -math.huge,
				minY = math.huge,
				maxY = -math.huge,
			}
			local valid = true

			for _, ptElem in ipairs(pointElements) do
				local px = tonumber(getElementData(ptElem, "x"))
				local py = tonumber(getElementData(ptElem, "y"))
				if px and py then
					limit[#limit + 1] = { x = px, y = py }
					if px < limit.minX then limit.minX = px end
					if px > limit.maxX then limit.maxX = px end
					if py < limit.minY then limit.minY = py end
					if py > limit.maxY then limit.maxY = py end
				else
					valid = false
					outputDebugString("[MapLimits] Warning: Point element missing numeric x/y coordinates.", 2)
					break
				end
			end

			if valid and #limit >= 3 then
				mapLimits[#mapLimits + 1] = limit
			end
		end
	end
end

-- Warning display management
local function initWarningDisplay()
	if not warningDisplay then
		warningDisplay = textCreateDisplay()
	end
	if not warningTextItem then
		warningTextItem = textCreateTextItem("GO BACK TO THE GAME AREA!", 0.5, 0.5, "high", 255, 0, 0, 255, 2.5, "center",
			"center")
		textDisplayAddText(warningDisplay, warningTextItem)
	end
	mapl_disp = warningDisplay
	mapl_text = warningTextItem
end

local function destroyWarningDisplay()
	if warningDisplay then
		for _, player in ipairs(getElementsByType("player")) do
			if textDisplayIsObserver(warningDisplay, player) then
				textDisplayRemoveObserver(warningDisplay, player)
			end
		end
		textDestroyDisplay(warningDisplay)
		warningDisplay = nil
		mapl_disp = nil
	end

	if warningTextItem then
		textDestroyTextItem(warningTextItem)
		warningTextItem = nil
		mapl_text = nil
	end
end

-- Evaluates limits for an individual player
function checkPlayerLimits(player)
	if not isElement(player) then
		return
	end

	-- Dead or non-spawned players don't take limit damage
	if isPedDead(player) or getElementHealth(player) <= 0 then
		if warningDisplay and textDisplayIsObserver(warningDisplay, player) then
			textDisplayRemoveObserver(warningDisplay, player)
		end
		return
	end

	-- Map limits only apply in the main game world (interior 0, dimension 0)
	if getElementInterior(player) ~= 0 or getElementDimension(player) ~= 0 then
		if warningDisplay and textDisplayIsObserver(warningDisplay, player) then
			textDisplayRemoveObserver(warningDisplay, player)
		end
		return
	end

	-- If no map limits are loaded, remove warning if active
	if #mapLimits == 0 then
		if warningDisplay and textDisplayIsObserver(warningDisplay, player) then
			textDisplayRemoveObserver(warningDisplay, player)
		end
		return
	end

	local x, y, _ = getElementPosition(player)
	local isInside = isPositionWithinLimits(x, y)

	if not isInside then
		-- Player is out of bounds
		if warningDisplay and not textDisplayIsObserver(warningDisplay, player) then
			textDisplayAddObserver(warningDisplay, player)
		end

		local hp = getElementHealth(player)
		if hp > KILL_HEALTH_THRESHOLD then
			setElementHealth(player, hp - DAMAGE_PER_TICK)
		else
			killPed(player)
		end
	else
		-- Player is within limits
		if warningDisplay and textDisplayIsObserver(warningDisplay, player) then
			textDisplayRemoveObserver(warningDisplay, player)
		end
	end
end

-- Backward compatibility alias for stuff()
function stuff(player, ...)
	if isElement(player) then
		checkPlayerLimits(player)
	end
end

-- Central limit checking loop
function checkAllPlayersLimits()
	if #mapLimits == 0 then
		return
	end

	local players = getElementsByType("player")
	for i = 1, #players do
		checkPlayerLimits(players[i])
	end
end

-- Lifecycle event handlers
local function handleResourceStart(startedResource)
	if startedResource == getThisResource() then
		initWarningDisplay()
		buildTables()
		if not isTimer(checkTimer) then
			checkTimer = setTimer(checkAllPlayersLimits, CHECK_INTERVAL_MS, 0)
		end
	else
		-- Map or other resource started; reload boundaries
		buildTables()
	end
end

local function handleResourceStop(stoppedResource)
	if stoppedResource == getThisResource() then
		if isTimer(checkTimer) then
			killTimer(checkTimer)
			checkTimer = nil
		end
		destroyWarningDisplay()
		mapLimits = {}
	else
		-- When a map resource stops, give MTA a tick to destroy elements before rebuilding
		setTimer(function()
			buildTables()
			if #mapLimits == 0 and warningDisplay then
				for _, player in ipairs(getElementsByType("player")) do
					if textDisplayIsObserver(warningDisplay, player) then
						textDisplayRemoveObserver(warningDisplay, player)
					end
				end
			end
		end, 50, 1)
	end
end

local function handlePlayerWasted()
	if warningDisplay and textDisplayIsObserver(warningDisplay, source) then
		textDisplayRemoveObserver(warningDisplay, source)
	end
end

local function handlePlayerQuit()
	if warningDisplay and textDisplayIsObserver(warningDisplay, source) then
		textDisplayRemoveObserver(warningDisplay, source)
	end
end

addEventHandler("onResourceStart", root, handleResourceStart)
addEventHandler("onResourceStop", root, handleResourceStop)
addEventHandler("onPlayerWasted", root, handlePlayerWasted)
addEventHandler("onPlayerQuit", root, handlePlayerQuit)
