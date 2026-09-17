local MAPS = { "ptp-ls", "ptp-sf", "ptp-lv" }
local VEHICLE_IDLE_RESPAWN_DELAY = 2 * 60 * 1000 -- 2 minutes

local currentMap = nil
local nextMap = MAPS[math.random(1, #MAPS)]
local teamSpawns = {}
local DEFAULT_SKIN_SELECTION = {
    camera = {
        x = 1654.3691,
        y = -1643.5967,
        z = 85.176224,
        lookX = 1658.8364,
        lookY = -1545.6569,
        lookZ = 65.482597,
        [1] = 1654.3691,
        [2] = -1643.5967,
        [3] = 85.176224,
        [4] = 1658.8364,
        [5] = -1545.6569,
        [6] = 65.482597
    },
    spawn = {
        x = 1654.524,
        y = -1637.7119,
        z = 84.0,
        rot = 180.0,
        [1] = 1654.524,
        [2] = -1637.7119,
        [3] = 84.0,
        [4] = 180.0
    }
}

local skinSelection = nil

local function loadSkinSelectionFromMap()
    skinSelection = nil
    local skinSelectionElements = getElementsByType("skinselection")

    for _, skinElem in ipairs(skinSelectionElements) do
        local cameraElements = getElementChildren(skinElem, "camera")
        if #cameraElements == 0 then
            for _, child in ipairs(getElementChildren(skinElem)) do
                if getElementType(child) == "camera" then
                    cameraElements[#cameraElements + 1] = child
                end
            end
        end

        local spawnElements = getElementChildren(skinElem, "spawnpoint")
        if #spawnElements == 0 then
            for _, child in ipairs(getElementChildren(skinElem)) do
                if getElementType(child) == "spawnpoint" then
                    spawnElements[#spawnElements + 1] = child
                end
            end
        end

        local parsedCamera = nil
        if #cameraElements > 0 then
            local cam = cameraElements[1]
            local x = tonumber(getElementData(cam, "x"))
            local y = tonumber(getElementData(cam, "y"))
            local z = tonumber(getElementData(cam, "z"))
            local lookX = tonumber(getElementData(cam, "lookX") or getElementData(cam, "lookx") or
                getElementData(cam, "targetX"))
            local lookY = tonumber(getElementData(cam, "lookY") or getElementData(cam, "looky") or
                getElementData(cam, "targetY"))
            local lookZ = tonumber(getElementData(cam, "lookZ") or getElementData(cam, "lookz") or
                getElementData(cam, "targetZ"))

            if x and y and z and lookX and lookY and lookZ then
                parsedCamera = {
                    x = x,
                    y = y,
                    z = z,
                    lookX = lookX,
                    lookY = lookY,
                    lookZ = lookZ,
                    [1] = x,
                    [2] = y,
                    [3] = z,
                    [4] = lookX,
                    [5] = lookY,
                    [6] = lookZ
                }
            else
                outputDebugString("[MapManager] Warning: <camera> in <skinselection> missing numeric coordinates.", 2)
            end
        end

        local parsedSpawn = nil
        if #spawnElements > 0 then
            local sp = spawnElements[1]
            local x = tonumber(getElementData(sp, "x"))
            local y = tonumber(getElementData(sp, "y"))
            local z = tonumber(getElementData(sp, "z"))
            local rot = tonumber(getElementData(sp, "rot") or getElementData(sp, "rotation")) or 0.0

            if x and y and z then
                parsedSpawn = {
                    x = x,
                    y = y,
                    z = z,
                    rot = rot,
                    [1] = x,
                    [2] = y,
                    [3] = z,
                    [4] = rot
                }
            else
                outputDebugString("[MapManager] Warning: <spawnpoint> in <skinselection> missing numeric coordinates.", 2)
            end
        end

        if parsedCamera or parsedSpawn then
            skinSelection = {
                camera = parsedCamera or DEFAULT_SKIN_SELECTION.camera,
                spawn = parsedSpawn or DEFAULT_SKIN_SELECTION.spawn
            }
            outputDebugString(string.format(
                "[MapManager] Loaded skinselection: cam(%.1f, %.1f, %.1f) spawn(%.1f, %.1f, %.1f rot: %.1f)",
                skinSelection.camera.x, skinSelection.camera.y, skinSelection.camera.z,
                skinSelection.spawn.x, skinSelection.spawn.y, skinSelection.spawn.z, skinSelection.spawn.rot))
            break
        end
    end

    if not skinSelection then
        outputDebugString("[MapManager] No valid <skinselection> element found in map, using defaults.", 2)
        skinSelection = {
            camera = DEFAULT_SKIN_SELECTION.camera,
            spawn = DEFAULT_SKIN_SELECTION.spawn
        }
    end
end

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
            local x = tonumber(getElementData(v, "x")) or 0.0
            local y = tonumber(getElementData(v, "y")) or 0.0
            local z = tonumber(getElementData(v, "z")) or 0.0
            local rot = tonumber(getElementData(v, "rot") or getElementData(v, "rotation")) or 0.0
            teamSpawns[teamID] = { x, y, z, rot }
        end
    end

    loadSkinSelectionFromMap()

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
    skinSelection = nil
    return true
end

function MapManager.getTeamSpawn(teamID)
    return teamSpawns[teamID]
end

function MapManager.getAllSpawns()
    return teamSpawns
end

function MapManager.getSkinSelection()
    return skinSelection or DEFAULT_SKIN_SELECTION
end

function MapManager.getSkinSelectionCamera()
    return (skinSelection and skinSelection.camera) or DEFAULT_SKIN_SELECTION.camera
end

function MapManager.getSkinSelectionSpawn()
    return (skinSelection and skinSelection.spawn) or DEFAULT_SKIN_SELECTION.spawn
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
