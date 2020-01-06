local teams = {}

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
    fadeCamera(source, true)
    setPlayerHudComponentVisible(player, "all", true)
    toggleAllControls(player, true, true, true)
end

local function mainOnPlayerTeamSelected(team, skinID)
    if type(team) ~= "string" or type(skinID) ~= "number" then
        outputDebugString("OnPlayerTeamSelected: Invalid argument type")
    end
    if team == Teams.SECRET_SERVICE then
        spawnPlayerOnTeamBase(source, 2795.0, -1825.0, 9.9, 90, skinID)
    elseif team == Teams.POLICE then
        spawnPlayerOnTeamBase(source, 1532.6, -1677.3, 5.9, 90, skinID)
    elseif team == Teams.TERRORISTS then
        spawnPlayerOnTeamBase(source, 1774.0, -1926.5, 13.5, 90, skinID)
    end
    triggerClientEvent(source, "onPlayerTeamSelectedSuccessful", resourceRoot)
end

addEvent("onPlayerTeamSelected", true)
addEventHandler("onPlayerTeamSelected", root, mainOnPlayerTeamSelected)
addEventHandler("onPlayerJoin", root, mainOnPlayerJoin)
addEventHandler("onResourceStart", root, function()
    teams[Teams.SECRET_SERVICE] = Team(Teams.SECRET_SERVICE, "Secret Service", tocolor(29, 253, 0, 255))
    teams[Teams.POLICE] = Team(Teams.POLICE, "Police", tocolor(0, 23, 252, 55))
    teams[Teams.TERRORISTS] = Team(Teams.TERRORISTS, "Terrorists", tocolor(251, 0, 0, 200))
end)