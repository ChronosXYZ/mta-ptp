local MAPS = { "ptp-ls", "ptp-sf", "ptp-lv" }
local VEHICLE_IDLE_RESPAWN_DELAY = 2 * 60 * 1000 -- 2 minutes

local currentMap = nil
local nextMap = MAPS[math.random(1, #MAPS)]
local teamSpawns = {}

MapManager = {}

function MapManager.getRandomMap()
    return MAPS[math.random(1, #MAPS)]
end

function MapManager.loadMap(mapName)
    local targetMap = mapName or nextMap
    local resource = getResourceFromName(targetMap)
    if not resource then
        outputDebugString("[MapManager] Map resource '" .. tostring(targetMap) .. "' not found!", 1)
        return false
    end

    if currentMap and currentMap ~= targetMap then
        MapManager.unloadMap()
    end

    startResource(resource)
    currentMap = targetMap
    setElementData(resourceRoot, "ptp.current_map", currentMap)
    outputDebugString("[MapManager] Map '" .. tostring(currentMap) .. "' loaded")

    teamSpawns = {}
    for _, v in ipairs(getElementsByType("spawnpoint")) do
        local teamID = getElementData(v, "team")
        if type(teamID) == "string" and Teams[teamID] then
            teamSpawns[teamID] = {
                getElementData(v, "x"),
                getElementData(v, "y"),
                getElementData(v, "z"),
                getElementData(v, "rot")
            }
        end
    end

    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        toggleVehicleRespawn(vehicle, true)
        setVehicleIdleRespawnDelay(vehicle, VEHICLE_IDLE_RESPAWN_DELAY)
    end

    nextMap = MapManager.getRandomMap()
    return true
end

function MapManager.unloadMap()
    if not currentMap then
        return false
    end

    local resource = getResourceFromName(currentMap)
    if resource and getResourceState(resource) == "running" then
        stopResource(resource)
    end

    outputDebugString("[MapManager] Map '" .. tostring(currentMap) .. "' unloaded")
    currentMap = nil
    teamSpawns = {}
    return true
end

function MapManager.getTeamSpawn(teamID)
    return teamSpawns[teamID]
end

function MapManager.getAllSpawns()
    return teamSpawns
end

function MapManager.getCurrentMap()
    return currentMap
end

function MapManager.getNextMap()
    return nextMap
end

function MapManager.setNextMap(mapName)
    nextMap = mapName
end
