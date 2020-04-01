local teamSpawns = {}

local function mainOnPlayerJoin()
    setCameraMatrix(source, 1654.3691, -1643.5967, 85.176224, 1658.8364, -1545.6569, 65.482597)
    spawnPlayer(source, 1654.524, -1637.7119, 85.157089, 180.0, 0)
    toggleAllControls(source, false, true, false)
    setPlayerHudComponentVisible(source, "all", false)
    fadeCamera(source, true, 5)
    showCursor(source, true)
    outputChatBox("Please select the class and skin of your player", source, 255, 255, 0)
end

local function spawnPlayerOnTeamBase(player, x, y, z, rotation, skinID)
    showCursor(player, false)
    spawnPlayer(player, x, y, z, rotation, skinID)
    setCameraTarget(player)
    --fadeCamera(player, true)
    setPlayerHudComponentVisible(player, "all", true)
    toggleAllControls(player, true, true, true)
end

local function mainOnPlayerTeamSelected(team, skinID)
    if type(team) ~= "string" or type(skinID) ~= "number" then
        outputDebugString("OnPlayerTeamSelected: Invalid argument type")
    end
    if team == Teams.SECRET_SERVICE then
        local team = getTeamFromName(Teams.SECRET_SERVICE)
        setPlayerTeam(source, team)
        setElementData(source, "team."..Teams.SECRET_SERVICE..".skinID", skinID)
        spawnPlayerOnTeamBase(source, teamSpawns[Teams.SECRET_SERVICE][1], teamSpawns[Teams.SECRET_SERVICE][2], teamSpawns[Teams.SECRET_SERVICE][3], teamSpawns[Teams.SECRET_SERVICE][4], skinID)
    elseif team == Teams.POLICE then
        local team = getTeamFromName(Teams.POLICE)
        setPlayerTeam(source, team)
        setElementData(source, "team."..Teams.POLICE..".skinID", skinID)
        spawnPlayerOnTeamBase(source, teamSpawns[Teams.POLICE][1], teamSpawns[Teams.POLICE][2], teamSpawns[Teams.POLICE][3], teamSpawns[Teams.POLICE][4], skinID)
    elseif team == Teams.TERRORISTS then
        local team = getTeamFromName(Teams.TERRORISTS)
        setPlayerTeam(source, team)
        setElementData(source, "team."..Teams.TERRORISTS..".skinID", skinID)
        spawnPlayerOnTeamBase(source, teamSpawns[Teams.TERRORISTS][1], teamSpawns[Teams.TERRORISTS][2], teamSpawns[Teams.TERRORISTS][3], teamSpawns[Teams.TERRORISTS][4], skinID)
    end
    triggerClientEvent(source, "onPlayerTeamSelectedSuccessful", resourceRoot)
end

addEvent("onPlayerTeamSelected", true)
addEventHandler("onPlayerTeamSelected", root, mainOnPlayerTeamSelected)
addEventHandler("onPlayerJoin", root, mainOnPlayerJoin)

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
            setTimer( spawnPlayerOnTeamBase, 3000, 1, source, teamSpawns[teamName][1], teamSpawns[teamName][2], teamSpawns[teamName][3], teamSpawns[teamName][4], getElementData(source, "team."..teamName..".skinID"))
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
    function ()
       createTeam(Teams.SECRET_SERVICE, 29, 253, 0)
       createTeam(Teams.POLICE, 0, 23, 252)
       createTeam(Teams.TERRORISTS, 251, 0, 0)
       teamSpawns[Teams.SECRET_SERVICE] = { 2795.0, -1825.0, 9.9, 90 }
       teamSpawns[Teams.POLICE] = { 1532.6, -1677.3, 5.9, 270 }
       teamSpawns[Teams.TERRORISTS] = { 1774.0, -1926.5, 13.5, 270 }
    end
)
