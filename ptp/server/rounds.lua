local MAPS = { "ptp-ls" }
local ROUND_TIME_LIMIT = 10 * 60 -- seconds

RoundSystem = class(function(self)
    self.current_map = nil
    self.timers = {
        round = nil,
        countdown = nil,
    }
end)

local function killTimerIfExists(t)
    if t and isTimer(t) then
        killTimer(t)
    end
end

local function getRandomMap()
    return MAPS[math.random(1, #MAPS)]
end

function RoundSystem:unloadCurrentMap()
    if self.current_map then
        stopResource(self.current_map)
        self.current_map = nil
        teamSpawns = {}
        setElementData(resourceRoot, "ptp.current_map", nil)
    end
end

function RoundSystem:loadMap(mapName)
    local resource = getResourceFromName(mapName)
    if not resource then
        outputDebugString("Map resource " .. tostring(mapName) .. " not found!", 1)
        return false
    end

    self:unloadCurrentMap()
    startResource(resource)
    self.current_map = resource
    setElementData(resourceRoot, "ptp.current_map", mapName)
    outputDebugString("Map " .. tostring(mapName) .. " loaded")

    teamSpawns = {}
    for _, v in ipairs(getElementsByType("spawnpoint")) do
        local teamName = getElementData(v, "team")
        if teamName and Teams[teamName:upper()].id == teamName then
            teamSpawns[teamName] = {
                getElementData(v, "x"),
                getElementData(v, "y"),
                getElementData(v, "z"),
                getElementData(v, "rot")
            }
        end
    end

    return true
end

function RoundSystem:countDownToRoundStart(seconds)
    killTimerIfExists(self.timers.countdown)
    local remainingSecs = seconds
    self.timers.countdown = setTimer(function()
        if remainingSecs > 0 then
            outputChatBox("Round starts in " .. tostring(remainingSecs) .. " seconds!", root, 255, 255, 0) -- FIXME
            playSoundFrontEnd(root, 43)
            remainingSecs = remainingSecs - 1
            if remainingSecs == 5 then
                triggerEvent("onRoundSelectPresident", root)
            end
        else
            killTimerIfExists(self.timers.countdown)
            self.timers.countdown = nil
            self:startRound()
        end
    end, 1000, seconds + 1)
end

function RoundSystem:startRound()
    killTimerIfExists(self.timers.round)
    self.timers.round = setTimer(function()
        self:endRound()
    end, ROUND_TIME_LIMIT * 1000, 1)

    triggerEvent("onRoundStart", root, self.current_map)
    outputDebugString("Round started")
    outputChatBox("Round has started! Good luck!", root, 0, 255, 0) -- FIXME
end

function RoundSystem:endRound()
    killTimerIfExists(self.timers.round)
    self.timers.round = nil

    triggerEvent("onRoundEnd", root, self.current_map)
    -- 10 seconds break between rounds, then countdown of 10 seconds
    setTimer(function()
        self:loadMap(getRandomMap())
        self:countDownToRoundStart(10)
    end, 10 * 1000, 1)
    outputDebugString("Round ended")
end

local rounds = RoundSystem()

addEventHandler("onResourceStart", resourceRoot, function()
    rounds:loadMap(getRandomMap())
    rounds:countDownToRoundStart(10)
end)
