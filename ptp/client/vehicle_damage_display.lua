-- Client-side 3D damage percent display
-- Draws vehicle.damagePercent (0-100) above vehicles as 3D text

local MAX_DIST = 80       -- max distance to draw
local HEIGHT_OFFSET = 1.5 -- meters above vehicle
local MIN_SCALE = 0.6
local MAX_SCALE = 1.4

local function percentToColor(p)
    -- p: 0..100 health percent -> red (0) -> yellow (50) -> green (100)
    p = math.max(0, math.min(100, p))
    if p >= 50 then
        -- yellow (50) -> green (100)
        local t = (p - 50) / 50
        local r = math.floor(255 * (1 - t))
        local g = 255
        return r, g, 0
    else
        -- red (0) -> yellow (50)
        local t = p / 50
        local r = 255
        local g = math.floor(255 * t)
        return r, g, 0
    end
end

local function drawTextAtScreen(text, sx, sy, scale, r, g, b)
    local alpha = 255
    -- shadow
    dxDrawText(text, sx + 1, sy + 1, sx + 1, sy + 1, tocolor(0, 0, 0, alpha), scale, "default-bold", "center", "bottom")
    dxDrawText(text, sx, sy, sx, sy, tocolor(r, g, b, alpha), scale, "default-bold", "center", "bottom")
end

local function onRender()
    local px, py, pz = getElementPosition(localPlayer)
    if not px then return end
    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        if isElementStreamedIn(vehicle) then
            local dmg = math.floor(getElementHealth(vehicle) / 10 + 0.5)
            if dmg ~= nil then
                local vx, vy, vz = getElementPosition(vehicle)
                if vx then
                    local dist = getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz)
                    if dist <= MAX_DIST then
                        local sx, sy = getScreenFromWorldPosition(vx, vy, vz + HEIGHT_OFFSET)
                        if sx then
                            local tscale = 1 - (dist / MAX_DIST)
                            local scale = math.max(MIN_SCALE, MAX_SCALE * tscale)
                            local r, g, b = percentToColor(dmg)
                            drawTextAtScreen(tostring(dmg) .. "%", sx, sy, scale, r, g, b)
                        end
                    end
                end
            end
        end
    end
end

addEventHandler("onClientRender", root, onRender)

addEventHandler("onClientResourceStop", resourceRoot, function()
    removeEventHandler("onClientRender", root, onRender)
end)

return true
