TEAM_SECRET_SERVICE = "secret_service"
TEAM_POLICE = "police"
TEAM_TERRORISTS = "terrorists"
TEAM_PRESIDENT = "president"

Teams = {
    [TEAM_SECRET_SERVICE] = {
        name = "Secret Service",
        color = { r = 29, g = 253, b = 0 },
        weapons = { 3, 23, 25, 29 } -- Nightstick, Silenced, Shotgun, MP5
    },
    [TEAM_POLICE] = {
        name = "Police",
        color = { r = 0, g = 23, b = 255 },
        weapons = { 22, 25, 29, 31 } -- Colt 45, Shotgun, MP5, M4
    },
    [TEAM_TERRORISTS] = {
        name = "Terrorists",
        color = { r = 251, g = 0, b = 0 },
        weapons = { 27, 28, 16, 30 } -- Grenade, Combat Shotgun, Uzi, AK47
    },
    [TEAM_PRESIDENT] = {
        name = "President",
        color = { r = 255, g = 255, b = 255 },
        weapons = { 3, 23, 25, 29 } -- Nightstick, Silenced, Shotgun, MP5
    }
}

function getTeamID(team)
    if not team or getElementType(team) ~= "team" then
        return nil
    end
    return getElementData(team, "ptp.team_id")
end

function setTeamID(team, id)
    if not team or getElementType(team) ~= "team" then
        return
    end
    setElementData(team, "ptp.team_id", id)
end

AlliedTeams = {
    [TEAM_SECRET_SERVICE] = true,
    [TEAM_POLICE] = true,
    [TEAM_PRESIDENT] = true
}
