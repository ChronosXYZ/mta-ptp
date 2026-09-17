local teams = {}

local function giveTeamWeapons(player, teamID)
    local weapons = Teams[teamID].weapons
    if not weapons then return end
    for _, weaponID in ipairs(weapons) do
        giveWeapon(player, weaponID, 9999, false)
    end
end

local teamSelectDimCounter = 1000
local function getTeamSelectDimension()
    teamSelectDimCounter = teamSelectDimCounter + 1
    if teamSelectDimCounter > 60000 then
        teamSelectDimCounter = 1000
    end
    return teamSelectDimCounter
end

local SPAWN_RANDOM_RADIUS = 2.5

local function getRandomizedSpawnPosition(x, y, teamID)
    local numX = tonumber(x) or 0
    local numY = tonumber(y) or 0
    if teamID == TEAM_PRESIDENT then
        return numX, numY
    end
    local angle = math.random() * 2 * math.pi
    local dist = 0.5 + math.random() * (SPAWN_RANDOM_RADIUS - 0.5)
    return numX + math.cos(angle) * dist, numY + math.sin(angle) * dist
end

local function spawnPlayerOnTeamBase(player, x, y, z, rotation, skinID, teamID)
    showCursor(player, false)
    local spawnX, spawnY = getRandomizedSpawnPosition(x, y, teamID)
    spawnPlayer(player, spawnX, spawnY, tonumber(z) or 0, tonumber(rotation) or 0, tonumber(skinID) or 0, 0, 0)
    setElementDimension(player, 0)
    setElementInterior(player, 0)
    setElementCollisionsEnabled(player, true)
    setCameraTarget(player)
    setPlayerHudComponentVisible(player, "all", true)
    if RoundManager.is("running") then
        toggleAllControls(player, true, true, true)
        setElementFrozen(player, false)
    else
        setElementFrozen(player, true)
        toggleAllControls(player, false, true, false)
    end

    giveTeamWeapons(player, teamID)
end

local function enterTeamSelectMenu(player)
    local dim = getTeamSelectDimension()
    local cam = MapManager.getSkinSelectionCamera()
    local spawn = MapManager.getSkinSelectionSpawn()
    setCameraMatrix(player, cam.x, cam.y, cam.z, cam.lookX, cam.lookY, cam.lookZ)
    spawnPlayer(player, spawn.x, spawn.y, spawn.z, spawn.rot, 0, 0, dim)
    setElementDimension(player, dim)
    setElementInterior(player, 0)
    setElementCollisionsEnabled(player, false)
    toggleAllControls(player, false, true, false)
    setElementFrozen(player, true)
    setPlayerHudComponentVisible(player, "all", false)
    fadeCamera(player, true, 1.0)
    outputChatBox("Please select the class and skin of your player", player, 255, 255, 0)
    triggerClientEvent(player, "enterTeamSelectMenu", resourceRoot)
end

local function onPlayerTeamSelected(player, teamID, skinID)
    if type(teamID) ~= "string" or type(skinID) ~= "number" then
        outputDebugString("[GameRules] onPlayerTeamSelected: Invalid argument type", 1)
        return
    end

    local selectedTeam = teams[teamID]
    local teamMeta = Teams[teamID]
    if not selectedTeam or not teamMeta then
        outputDebugString("[GameRules] onPlayerTeamSelected: Invalid team ID '" .. tostring(teamID) .. "'", 1)
        return
    end

    setPlayerTeam(player, selectedTeam)
    setElementData(player, "ptp.skinID", skinID)
    setPlayerNametagColor(player, teamMeta.color.r, teamMeta.color.g, teamMeta.color.b)

    local spawn = MapManager.getTeamSpawn(teamID)
    if spawn then
        spawnPlayerOnTeamBase(player, spawn[1], spawn[2], spawn[3], spawn[4], skinID, teamID)
    else
        outputDebugString("[GameRules] Spawn for team '" .. tostring(teamID) .. "' not found!", 1)
    end

    triggerClientEvent(player, "onPlayerTeamSelectedSuccessful", resourceRoot)
end

local function selectPresident()
    local players = getElementsByType("player")
    if #players == 0 then
        return
    end
    local president = players[math.random(1, #players)]
    outputChatBox("You have been selected as the President for this round!", president, 255, 215, 0)
    outputDebugString("[GameRules] Player " .. tostring(getPlayerName(president)) .. " selected as President")
    onPlayerTeamSelected(president, TEAM_PRESIDENT, 147)
end

local function onPlayerWasted(totalAmmo, killer, killerWeapon, bodypart)
    local player = source
    local team = getPlayerTeam(player)
    if not team then return end

    local teamID = getTeamID(team)

    if teamID == TEAM_PRESIDENT then
        if killer and isElement(killer) and getElementType(killer) == "player" and killer ~= player then
            outputChatBox("The President was assassinated by " .. getPlayerName(killer) .. "!", root, 255, 0, 0)
        else
            outputChatBox("The President has been killed!", root, 255, 0, 0)
        end
        RoundManager.endRound("president_killed")
        return
    end

    local skinID = getElementData(player, "ptp.skinID")
    local spawn = MapManager.getTeamSpawn(teamID)
    if spawn and RoundManager.is("running") then
        setTimer(spawnPlayerOnTeamBase, 3000, 1, player, spawn[1], spawn[2], spawn[3], spawn[4], skinID, teamID)
    end
end

local function vehicleSpawnHandler()
    setTimer(setElementHealth, 50, 1, source, getElementData(source, "health") or 1000)
end

-- ============================================================================
-- Round Lifecycle Event Handlers
-- ============================================================================

-- Round preparation: reset player teams and show class selection
addEvent("ptp:onRoundPrepare", false)
addEventHandler("ptp:onRoundPrepare", resourceRoot, function()
    for _, player in ipairs(getElementsByType("player")) do
        setPlayerTeam(player, nil)
        enterTeamSelectMenu(player)
    end
end)

-- Countdown tick: select President at 5 seconds remaining
addEvent("ptp:onCountdownTick", false)
addEventHandler("ptp:onCountdownTick", resourceRoot, function(remainingSecs)
    if remainingSecs == 5 then
        selectPresident()
    end
end)

-- Round start: unfreeze players and enable controls
addEvent("ptp:onRoundStart", false)
addEventHandler("ptp:onRoundStart", root, function(mapName)
    for _, player in ipairs(getElementsByType("player")) do
        if getPlayerTeam(player) ~= nil then
            setElementFrozen(player, false)
            toggleAllControls(player, true, true, true)
        end
    end
    outputChatBox("Round has started! Good luck!", root, 0, 255, 0)
end)

-- Round end: freeze players and disable controls
addEvent("ptp:onRoundEnd", false)
addEventHandler("ptp:onRoundEnd", root, function(mapName)
    for _, player in ipairs(getElementsByType("player")) do
        if not isPedDead(player) then
            setElementFrozen(player, true)
            toggleAllControls(player, false, true, false)
        end
    end
end)

-- ============================================================================
-- Player & World Events
-- ============================================================================

addEvent("onClientReady", true)
addEventHandler("onClientReady", resourceRoot, function()
    outputChatBox("Welcome to Protect The President!", client, 255, 255, 0)
    if RoundManager.is("idle") then
        RoundManager.startCountdown()
    else
        enterTeamSelectMenu(client)
    end
end)

addEvent("onPlayerTeamSelected", true)
addEventHandler("onPlayerTeamSelected", resourceRoot, function(teamID, skinID)
    onPlayerTeamSelected(client, teamID, skinID)
end)

addEventHandler("onVehicleRespawn", root, vehicleSpawnHandler)
addEventHandler("onPlayerWasted", root, onPlayerWasted)

addEventHandler("onPlayerQuit", root, function()
    local team = getPlayerTeam(source)
    if team and getTeamID(team) == TEAM_PRESIDENT and RoundManager.is("running") then
        outputChatBox("The President has left the server!", root, 255, 0, 0)
        RoundManager.endRound("president_quit")
    end
end)

local function initTeams()
    for id, t in pairs(Teams) do
        local team = createTeam(t.name, t.color.r, t.color.g, t.color.b)
        setTeamID(team, id)
        setTeamFriendlyFire(team, false)
        teams[id] = team
    end
end

-- init resource

local function init()
    math.randomseed(getTickCount())
    initTeams()
end

addEventHandler("onResourceStart", resourceRoot, function()
    init()
end)
