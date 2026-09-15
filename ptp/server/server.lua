local teamWeapons = {
    [Teams.PRESIDENT.id] = { 3, 23, 25, 29 },      -- Nightstick, Silenced, Shotgun, MP5
    [Teams.SECRET_SERVICE.id] = { 3, 23, 25, 29 }, -- Nightstick, Silenced, Shotgun, MP5
    [Teams.POLICE.id] = { 22, 25, 29, 31 },        -- Colt 45, Shotgun, MP5, M4
    [Teams.TERRORISTS.id] = { 27, 28, 16, 30 }     -- Grenade, Combat Shotgun, Uzi, AK47
}

local function giveTeamWeapons(player, teamId)
    local weapons = teamWeapons[teamId]
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

local function spawnPlayerAt(player, x, y, z, rotation, skinID, teamId)
    showCursor(player, false)
    spawnPlayer(player, x, y, z, rotation, skinID, 0, 0)
    setElementDimension(player, 0)
    setElementInterior(player, 0)
    setElementCollisionsEnabled(player, true)
    setCameraTarget(player)
    setPlayerHudComponentVisible(player, "all", true)
    toggleAllControls(player, true, true, true)
    giveTeamWeapons(player, teamId)
end

local function spawnPlayerOnTeamBase(player, x, y, z, rotation, skinID, teamName)
    showCursor(player, false)
    spawnPlayer(player, x, y, z, rotation, skinID, 0, 0)
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

    giveTeamWeapons(player, teamName)
end

local function enterTeamSelectMenu(player)
    local dim = getTeamSelectDimension()
    setCameraMatrix(player, 1654.3691, -1643.5967, 85.176224, 1658.8364, -1545.6569, 65.482597)
    spawnPlayer(player, 1654.524, -1637.7119, 84.0, 180.0, 0, 0, dim)
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

local function onPlayerTeamSelected(player, team, skinID)
    if type(team) ~= "table" or type(team.id) ~= "string" or type(skinID) ~= "number" then
        outputDebugString("[GameRules] onPlayerTeamSelected: Invalid argument type", 1)
        return
    end

    local selectedTeam = getTeamFromName(team.name)
    setPlayerTeam(player, selectedTeam)
    setElementData(player, "ptp.skinID", skinID)
    setPlayerNametagColor(player, team.color.r, team.color.g, team.color.b)

    local spawn = MapManager.getTeamSpawn(team.id)
    if spawn then
        spawnPlayerOnTeamBase(player, spawn[1], spawn[2], spawn[3], spawn[4], skinID, team.id)
    else
        outputDebugString("[GameRules] Spawn for team '" .. tostring(team.id) .. "' not found!", 1)
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
    onPlayerTeamSelected(president, Teams.PRESIDENT, 147)
end

local function onPlayerWasted(totalAmmo, killer, killerWeapon, bodypart)
    local player = source
    local team = getPlayerTeam(player)
    if not team then return end

    local teamName = getTeamName(team)
    local teamID = Teams_name_to_id[teamName]

    if teamID == Teams.PRESIDENT.id then
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
        setTimer(spawnPlayerAt, 3000, 1, player, spawn[1], spawn[2], spawn[3], spawn[4], skinID, teamID)
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
addEventHandler("onPlayerTeamSelected", resourceRoot, function(team, skinID)
    onPlayerTeamSelected(client, team, skinID)
end)

addEventHandler("onVehicleRespawn", root, vehicleSpawnHandler)
addEventHandler("onPlayerWasted", root, onPlayerWasted)

addEventHandler("onPlayerQuit", root, function()
    local team = getPlayerTeam(source)
    if team and getTeamName(team) == Teams.PRESIDENT.name and RoundManager.is("running") then
        outputChatBox("The President has left the server!", root, 255, 0, 0)
        RoundManager.endRound("president_quit")
    end
end)

addEventHandler("onResourceStart", resourceRoot, function()
    createTeam(Teams.SECRET_SERVICE.name, 29, 253, 0)
    createTeam(Teams.POLICE.name, 0, 23, 252)
    createTeam(Teams.TERRORISTS.name, 251, 0, 0)
    createTeam(Teams.PRESIDENT.name, 255, 255, 255)
end)
