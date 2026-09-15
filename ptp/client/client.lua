addEventHandler("onClientResourceStart", resourceRoot, function()
    setAmbientSoundEnabled("gunfire", false)
    triggerServerEvent("onClientReady", resourceRoot)
end)

addEvent("ptp:onRoundEnd", true)
addEventHandler("ptp:onRoundEnd", resourceRoot, function(reason)
    if reason == "president_killed" then
        showGameText("#FF0000The President was killed!", 5)
    elseif reason == "president_quit" then
        showGameText("#FF0000The President disconnected!", 5)
    else
        showGameText("#FF0000Round has ended!", 5)
    end
end)

addEventHandler("onClientPlayerDamage", localPlayer, function(attacker, _, _, _)
    if attacker and isElement(attacker) then
        local attackerPlayer = attacker

        -- If damage was caused by a vehicle (e.g. ramming), get the driver
        if getElementType(attacker) == "vehicle" then
            attackerPlayer = getVehicleController(attacker)
        end

        if attackerPlayer and isElement(attackerPlayer)
            and getElementType(attackerPlayer) == "player" and attackerPlayer ~= localPlayer then
            local myTeam = getPlayerTeam(localPlayer)
            local attackerTeam = getPlayerTeam(attackerPlayer)
            if myTeam and attackerTeam then
                local myTeamID = getTeamID(myTeam)
                local attackerTeamID = getTeamID(attackerTeam)

                -- Cancel damage if both attacker and victim are in the defending alliance
                if AlliedTeams[myTeamID] and AlliedTeams[attackerTeamID] then
                    cancelEvent()
                end
            end
        end
    end
end)

-- Prevent stealth knife kills between allies
addEventHandler("onClientPlayerStealthKill", localPlayer, function(target)
    local myTeam = getPlayerTeam(localPlayer)
    local targetTeam = getPlayerTeam(target)

    if myTeam and targetTeam then
        local myTeamID = getTeamID(myTeam)
        local targetTeamID = getTeamID(targetTeam)
        if AlliedTeams[myTeamID] and AlliedTeams[targetTeamID] then
            cancelEvent()
        end
    end
end)
