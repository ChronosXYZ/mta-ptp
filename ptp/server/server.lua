teamSpawns = {}
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

local function spawnPlayerAt(player, x, y, z, rotation, skinID, teamId)
    showCursor(player, false)
    spawnPlayer(player, x, y, z, rotation, skinID)
    setCameraTarget(player)
    setPlayerHudComponentVisible(player, "all", true)
    toggleAllControls(player, true, true, true)
    giveTeamWeapons(player, teamId)
end

local function spawnPlayerOnTeamBase(player, x, y, z, rotation, skinID, teamName)
    showCursor(player, false)
    spawnPlayer(player, x, y, z, rotation, skinID)
    setCameraTarget(player)
    setPlayerHudComponentVisible(player, "all", true)
    if mapManager:state() == "running" then
        toggleAllControls(player, true, true, true)
    end

    for _, weaponID in ipairs(teamWeapons[teamName]) do
        giveWeapon(player, weaponID, 9999, false)
    end
end
local function enterTeamSelectMenu(player)
    setCameraMatrix(player, 1654.3691, -1643.5967, 85.176224, 1658.8364, -1545.6569, 65.482597)
    spawnPlayer(player, 1654.524, -1637.7119, 84.0, 180.0, 0)
    toggleAllControls(player, false, true, false)
    setPlayerHudComponentVisible(player, "all", false)
    fadeCamera(player, true, 1.0)
    outputChatBox("Please select the class and skin of your player", player, 255, 255, 0)
    triggerClientEvent(player, "enterTeamSelectMenu", resourceRoot)
end

local function onPlayerTeamSelected(player, team, skinID)
    if type(team.id) ~= "string" or type(skinID) ~= "number" then
        outputDebugString("OnPlayerTeamSelected: Invalid argument type")
    end

    local selectedTeam = getTeamFromName(team.name)
    ---@diagnostic disable-next-line: param-type-mismatch
    setPlayerTeam(player, selectedTeam)
    setElementData(player, "ptp.skinID", skinID)
    spawnPlayerOnTeamBase(player, teamSpawns[team.id][1], teamSpawns[team.id][2],
        teamSpawns[team.id][3], teamSpawns[team.id][4], skinID, team.id)
    triggerClientEvent(player, "onPlayerTeamSelectedSuccessful", resourceRoot)
end

local function onPlayerWasted()
    local player = source
    local team = getPlayerTeam(player)
    if not team then return end

    local teamName = getTeamName(team)
    local teamID = Teams_name_to_id[teamName]
    local skinID = getElementData(player, "ptp.skinID")
    local spawn = teamSpawns[teamID]
    setTimer(spawnPlayerAt, 3000, 1, player, spawn[1], spawn[2], spawn[3], spawn[4], skinID, teamID)
end

local function vehicleSpawnHandler()
    setTimer(setElementHealth, 50, 1, source, getElementData(source, "health"))
end

addEventHandler("onVehicleRespawn", root, vehicleSpawnHandler)

addEvent("onPlayerTeamSelected", true)
addEventHandler("onPlayerTeamSelected", resourceRoot, function(team, skinID)
    onPlayerTeamSelected(client, team, skinID)
end)

addEvent("onClientReady", true)
addEventHandler("onClientReady", resourceRoot, function()
    outputChatBox("Welcome to Protect The President!", client, 255, 255, 0)
    enterTeamSelectMenu(client)
end)

-- addEventHandler("onVehicleExplode", root, respawnExplodedVehicle)
-- setTimer(respawnDrownVehicle, 20000, 0)
addEventHandler("onPlayerWasted", root, onPlayerWasted)

addEvent("onRoundSelectPresident", true)
addEventHandler("onRoundSelectPresident", root, function()
    local players = getElementsByType("player")
    if #players == 0 then
        return
    end
    local president = players[math.random(1, #players)]
    outputChatBox("You have been selected as the President for this round!", president, 255, 215, 0) -- FIXME
    outputDebugString("Player " .. tostring(getPlayerName(president)) .. " selected as President")
    onPlayerTeamSelected(president, Teams.PRESIDENT, 147)
end)

addEventHandler("onResourceStart", resourceRoot,
    function()
        createTeam(Teams.SECRET_SERVICE.name, 29, 253, 0)
        createTeam(Teams.POLICE.name, 0, 23, 252)
        createTeam(Teams.TERRORISTS.name, 251, 0, 0)
        createTeam(Teams.PRESIDENT.name, 255, 255, 255)
    end
)

addEvent("onRoundPrepare", false);
addEventHandler("onRoundPrepare", resourceRoot, function()
    for _, player in ipairs(getElementsByType("player")) do
        setPlayerTeam(player, nil)
        enterTeamSelectMenu(player)
    end
end)
