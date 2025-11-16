teamSpawns = {}

local teamWeapons = {
    [Teams.SECRET_SERVICE.id] = { 3, 23, 25, 29 }, -- Nightstick, Silenced, Shotgun, MP5
    [Teams.POLICE.id] = { 22, 25, 29, 31 },        -- Colt 45, Shotgun, MP5, M4
    [Teams.TERRORISTS.id] = { 27, 28, 16, 30 }     -- Grenade, Combat Shotgun, Uzi, AK47
}

local function mainOnPlayerJoin(player)
    setCameraMatrix(player, 1654.3691, -1643.5967, 85.176224, 1658.8364, -1545.6569, 65.482597)
    spawnPlayer(player, 1654.524, -1637.7119, 85.157089, 180.0, 0)
    toggleAllControls(player, false, true, false)
    setPlayerHudComponentVisible(player, "all", false)
    fadeCamera(player, true, 5)
    outputChatBox("Please select the class and skin of your player", player, 255, 255, 0)
end

local function spawnPlayerOnTeamBase(player, x, y, z, rotation, skinID, teamName)
    showCursor(player, false)
    spawnPlayer(player, x, y, z, rotation, skinID)
    setCameraTarget(player)
    --fadeCamera(player, true)
    setPlayerHudComponentVisible(player, "all", true)
    toggleAllControls(player, true, true, true)

    for _, weaponID in ipairs(teamWeapons[teamName]) do
        giveWeapon(player, weaponID, 9999, false)
    end
end

local function mainOnPlayerTeamSelected(team, skinID)
    if type(team.id) ~= "string" or type(skinID) ~= "number" then
        outputDebugString("OnPlayerTeamSelected: Invalid argument type")
    end

    local selectedTeam = getTeamFromName(team.name)
    ---@diagnostic disable-next-line: param-type-mismatch
    setPlayerTeam(source, selectedTeam)
    setElementData(source, "team." .. team.id .. ".skinID", skinID)
    spawnPlayerOnTeamBase(source, teamSpawns[team.id][1], teamSpawns[team.id][2],
        teamSpawns[team.id][3], teamSpawns[team.id][4], skinID, team.id)
    triggerClientEvent(source, "onPlayerTeamSelectedSuccessful", resourceRoot)
end

addEvent("onPlayerTeamSelected", true)
addEventHandler("onPlayerTeamSelected", root, mainOnPlayerTeamSelected)
addEventHandler("onPlayerJoin", root, function()
    mainOnPlayerJoin(source)
end)
addEventHandler("onResourceStart", resourceRoot, function()
    for _, player in ipairs(getElementsByType("player")) do
        mainOnPlayerJoin(player)
    end
end)

-- respawn exploded vehicle
function respawnExplodedVehicle()
    setTimer(respawnVehicle, 9000, 1, source)
end

addEventHandler("onVehicleExplode", root, respawnExplodedVehicle)
--

-- respawn wasted player
addEventHandler("onPlayerWasted", root,
    function()
        local team = getPlayerTeam(source)
        if team then
            local teamName = getTeamName(team)
            local teamID = Teams_name_to_id[teamName]
            setTimer(spawnPlayerOnTeamBase, 3000, 1, source, teamSpawns[teamID][1],
                teamSpawns[teamID][2],
                teamSpawns[teamID][3], teamSpawns[teamID][4],
                getElementData(source, "team." .. teamID .. ".skinID"),
                teamID)
        end
    end
)
--

-- respawn drown vehicle
function respawnDrownVehicle()
    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        if isElementInWater(vehicle) then
            local isOccupied, _ = next(getVehicleOccupants(vehicle))
            if not isOccupied then
                respawnVehicle(vehicle)
            end
        end
    end
end

setTimer(respawnDrownVehicle, 20000, 0)
--

addEventHandler("onResourceStart", root,
    function()
        createTeam(Teams.SECRET_SERVICE.name, 29, 253, 0)
        createTeam(Teams.POLICE.name, 0, 23, 252)
        createTeam(Teams.TERRORISTS.name, 251, 0, 0)
    end
)

function notifyAboutExplosion()
    outputChatBox(getVehicleName(source) .. " just blew up")
end

addEventHandler("onVehicleExplode", root, notifyAboutExplosion)
