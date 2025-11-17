-- Client-side countdown display
local COUNTDOWN_SOUND = 43
local COUNTDOWN_SOUND_GO = 45

local countdownActive = false
local remaining = 0
local screenW, screenH = guiGetScreenSize()
local cx = screenW * 0.5

local function stopCountdown()
    countdownActive = false
    remaining = 0
end

local function enableCountdown(seconds)
    countdownActive = true
    remaining = seconds
end

local function onRender()
    if not countdownActive then return end
    local text
    if remaining > 0 then
        if remaining <= 3 then
            text = tostring(remaining)
        else
            text = "Round starts in " .. tostring(remaining)
        end
    else
        text = "GO!"
        setTimer(function()
            stopCountdown()
            removeEventHandler("onClientRender", root, onRender)
        end, 1000, 1)
    end

    local fontScale = (remaining <= 3 and 4) or 1.4
    local r, g, b = 255, 255, 255
    local cy = screenH * 0.35
    local left = cx - 400
    local top = cy - 80
    local right = cx + 400
    local bottom = cy + 80
    -- draw outline by rendering the text in black at several offsets
    local outlineColor = tocolor(0, 0, 0, 200)
    local offsets = { { -2, 0 }, { 2, 0 }, { 0, -2 }, { 0, 2 }, { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }
    for _, off in ipairs(offsets) do
        dxDrawText(text, left + off[1], top + off[2], right + off[1], bottom + off[2], outlineColor, fontScale,
            "default-bold", "center", "center", false, false, false, true)
    end
    -- main text
    dxDrawText(text, left, top, right, bottom, tocolor(r, g, b, 255), fontScale, "default-bold", "center", "center",
        false, false, false, true)
end

local function playTickSound()
    if remaining > 0 then
        playSoundFrontEnd(COUNTDOWN_SOUND)
    else
        playSoundFrontEnd(COUNTDOWN_SOUND_GO)
    end
end

addEvent("onCountdown", true)
addEventHandler("onCountdown", resourceRoot, function(seconds)
    if countdownActive == false then
        enableCountdown(seconds)
        addEventHandler("onClientRender", root, onRender)
    end
    remaining = seconds

    playTickSound()
end)

addEventHandler("onClientResourceStop", resourceRoot, stopCountdown)
