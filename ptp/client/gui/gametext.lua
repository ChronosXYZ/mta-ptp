loadstring(exports.dgs:dgsImportFunction())()
local label
local hideTimer = nil
local isShown = false

function showGameText(text, durationSecs)
    if isShown then
        if hideTimer then
            killTimer(hideTimer)
        end
        isShown = false
    end
    isShown = true
    dgsSetText(label, text)
    hideTimer = setTimer(dgsSetText, durationSecs * 1000, 1, label, "") --clear text after duration
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    label = dgsCreateLabel(0.0, 0.31, 1, 0.07, "", true)
    dgsSetProperty(label, "shadow", { 3.0, 3.0, tocolor(0, 0, 0, 255), 1 })
    dgsSetFont(label, "pricedown")
    dgsSetProperty(label, "textSize", { 2.5, 2.5 })
    dgsSetProperty(label, "alignment", { "center", "center" })
    dgsSetProperty(label, "colorCoded", true)
end)
