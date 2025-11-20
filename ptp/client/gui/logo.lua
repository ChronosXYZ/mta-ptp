local logoLabel

addEventHandler("onClientResourceStart", resourceRoot, function()
    local myFont = dgsCreateFont("fonts/ST-SimpleSquare.ttf", 15)
    logoLabel = dgsCreateLabel(0.78, 0.00, 0.22, 0.06, "Protect the President", true)
    dgsSetFont(logoLabel, myFont)
    dgsLabelSetColor(logoLabel, 180, 25, 29, 200)
    dgsSetProperty(logoLabel, "alignment", { "center", "center" })
    dgsSetProperty(logoLabel, "shadow", { 1.0, 1.0, tocolor(0, 0, 0, 255) })
end)
