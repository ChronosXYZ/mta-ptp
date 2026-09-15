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
