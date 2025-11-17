local MAPS = { "ptp-ls" }
local ROUND_TIME_LIMIT = 1 * 60 -- seconds

local function killTimerIfExists(t)
    if t and isTimer(t) then
        killTimer(t)
    end
end

local function getRandomMap()
    return MAPS[math.random(1, #MAPS)]
end

MapManager = class(function(self)
    self.current_map = nil
    self.next_map = getRandomMap()
    self.timers = {
        round = nil,
        countdown = nil,
    }

    self.state_machine = machine.create({
        initial = 'idle',
        events = {
            { name = 'load_map',        from = { 'idle', 'unloading' }, to = 'loading' },
            { name = 'enter_countdown', from = 'loading',               to = 'countdown' },
            { name = 'start_round',     from = 'countdown',             to = 'running' },
            { name = 'end_round',       from = 'running',               to = 'round_end' },
            { name = 'unload_map',      from = 'round_end',             to = 'unloading' },
        },
        callbacks = {
            onloading = function()
                self:loadMap(self.next_map)
            end,
            oncountdown = function()
                self:startCountDown(5)
            end,
            onrunning = function()
                self:startRound()
            end,
            onround_end = function()
                self:endRound()
            end,
            onunloading = function()
                self:unloadCurrentMap()
            end,
            onstatechange = function(self, evt, from, to, ...)
                outputDebugString(("[MapManager] state changed %s -> %s via %s"):format(from, to, evt))
            end,
        },
    })

    addEventHandler("onResourceStop", root, function(stoppedResource)
        self:onResourceStop(stoppedResource)
    end)


    addEventHandler("onResourceStart", resourceRoot, function()
        self.state_machine:load_map()
    end)
end)

function MapManager:unloadCurrentMap()
    if self.current_map == nil then
        return
    end

    stopResource(self.current_map)
    teamSpawns = {}
end

function MapManager:onResourceStop(stoppedResource)
    if stoppedResource ~= self.current_map then
        return
    end
    setTimer(function()
        self.current_map = nil
        self.state_machine:load_map()
    end, 50, 1)
end

function MapManager:loadMap(mapName)
    local resource = getResourceFromName(mapName)
    if not resource then
        outputDebugString("Map resource " .. tostring(mapName) .. " not found!", 1)
        return false
    end

    startResource(resource)
    setElementData(resourceRoot, "ptp.current_map", self.current_map)
    outputDebugString("Map " .. tostring(self.current_map) .. " loaded")

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

    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        toggleVehicleRespawn(vehicle, true)
    end

    self.state_machine:enter_countdown()
    return true
end

function MapManager:startCountDown(seconds)
    killTimerIfExists(self.timers.countdown)
    local remainingSecs = seconds
    self.timers.countdown = setTimer(function()
        if remainingSecs > 0 then
            outputChatBox("Round starts in " .. tostring(remainingSecs) .. " seconds!", root, 255, 255, 0) -- FIXME
            playSoundFrontEnd(root, 43)
            if remainingSecs == 4 then
                triggerEvent("onRoundSelectPresident", root)
            end
            remainingSecs = remainingSecs - 1
        else
            killTimerIfExists(self.timers.countdown)
            self.timers.countdown = nil

            self.state_machine:start_round()
        end
    end, 1000, seconds + 1)
end

function MapManager:startRound()
    killTimerIfExists(self.timers.round)
    self.timers.round = setTimer(function()
        self.next_map = getRandomMap()
        self.state_machine:end_round()
    end, ROUND_TIME_LIMIT * 1000, 1)

    triggerEvent("onRoundStart", root, self.current_map)
    outputChatBox("Round has started! Good luck!", root, 0, 255, 0) -- FIXME
end

function MapManager:endRound()
    killTimerIfExists(self.timers.round)
    self.timers.round = nil

    triggerEvent("onRoundEnd", root, self.current_map)
    -- 5 seconds break between rounds, then countdown of 10 seconds
    setTimer(function()
        self.state_machine:load_map()
    end, 5 * 1000, 1)
end

mapManager = MapManager()
