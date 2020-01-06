function roundNumber(number)
    local _, decimals = math.modf(number)
    if decimals < 0.5 then return math.floor(number) end
    return math.ceil(number)
end

function shadeColor(red, green, blue, percent)
    --[[red = (red * (100 + percent) / 100)
    green = (green * (100 + percent) / 100)
    blue = (blue * (100 + percent) / 100)]]

    --percent = percent / 100
    -- //FIXME don't work properly
    red = red + (255 - red) * percent
    green = green + (255 - green) * percent
    blue = blue + (255 - blue) * percent

    if red > 255 then
        red = 255
    end

    if green > 255 then
        green = 255
    end

    if blue > 255 then
        blue = 255
    end

    red = roundNumber(red)
    blue = roundNumber(blue)
    green = roundNumber(green)

    return red, green, blue
end

function extractRgbFromColor(color)
    local red = bitExtract(color, 0, 8)
    local green = bitExtract(color, 8, 8)
    local blue = bitExtract(color, 16, 8)
    local alpha = bitExtract(color, 24, 8)

    return red, green, blue, alpha
end