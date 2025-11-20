local timerLabel

addEvent("ptp:timerTick", true)
addEventHandler("ptp:timerTick", resourceRoot, function(remainingTime)
    local minutes = math.floor(remainingTime / 60)
    local seconds = remainingTime % 60
    local timeText = string.format("%02d:%02d", minutes, seconds)
    dgsSetText(timerLabel, timeText)
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    timerLabel = dgsCreateLabel(0.10, 0.62, 0.08, 0.05, "", true)
    dgsSetProperty(timerLabel, "shadow", { 3.0, 3.0, tocolor(0, 0, 0, 255) })
    dgsSetFont(timerLabel, "pricedown")
    dgsSetProperty(timerLabel, "textSize", { 2.5, 2.5 })
    dgsSetProperty(timerLabel, "alignment", { "center", "center" })
end)

addEventHandler("ptp:onRoundEnd", resourceRoot, function()
    dgsSetText(timerLabel, "")
end)
