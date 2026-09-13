local MAPS = { "ptp-ls", "ptp-sf" }
local ROUND_TIME_SECONDS = 10 * 60
local ROUND_TIME_LIMIT_MILLIS = ROUND_TIME_SECONDS * 1000
local ROUND_END_BREAK_TIME = 10 * 1000           -- 10 seconds
local COUNTDOWN_TIME = 10                        -- time of countdown in seconds
local VEHICLE_IDLE_RESPAWN_DELAY = 2 * 60 * 1000 -- 2 minutes

-- utility functions
local function getRandomMap()
    return MAPS[math.random(1, #MAPS)]
end

local function killTimerIfExists(t)
    if t and isTimer(t) then
        killTimer(t)
    end
end

-- state variables
local currentMapName = nil
local nextMapName = getRandomMap()
local timers = {
    roundEndTimer = nil,
    countdown = nil,
    timerTick = nil,
}
local stateMachine

local function unloadCurrentMap()
    if currentMapName == nil then
        return
    end
    local mapResource = getResourceFromName(currentMapName)
    if not mapResource then
        outputDebugString("Map resource " .. tostring(currentMapName) .. " not found!", 1)
        return
    end
    stopResource(mapResource)
    gTeamSpawns = {}
end

function getRoundState()
    return stateMachine and stateMachine.current or "idle"
end

function loadMapOrStartCountdown()
    if stateMachine and stateMachine:is("idle") then
        if currentMapName == nil then
            stateMachine:load_map()
        else
            stateMachine:start_countdown()
        end
        return true
    end
    return false
end

local function killRoundTimers()
    killTimerIfExists(timers.countdown)
    timers.countdown = nil
    killTimerIfExists(timers.roundEndTimer)
    timers.roundEndTimer = nil
    killTimerIfExists(timers.timerTick)
    timers.timerTick = nil
end

local function onResourceStop(stoppedResource)
    if getResourceName(stoppedResource) ~= currentMapName then
        return
    end
    setTimer(function()
        currentMapName = nil
        stateMachine:load_map()
    end, 50, 1)
end

local function loadMap(mapName)
    local resource = getResourceFromName(mapName)
    if not resource then
        outputDebugString("Map resource " .. tostring(mapName) .. " not found!", 1)
        return false
    end

    startResource(resource)
    currentMapName = mapName
    setElementData(resourceRoot, "ptp.current_map", currentMapName)
    outputDebugString("Map " .. tostring(currentMapName) .. " loaded")

    gTeamSpawns = {}
    for _, v in ipairs(getElementsByType("spawnpoint")) do
        local teamName = getElementData(v, "team")
        if type(teamName) == "string" then
            if teamName and Teams[teamName:upper()].id == teamName then
                gTeamSpawns[teamName] = {
                    getElementData(v, "x"),
                    getElementData(v, "y"),
                    getElementData(v, "z"),
                    getElementData(v, "rot")
                }
            end
        end
    end

    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        toggleVehicleRespawn(vehicle, true)
        setVehicleIdleRespawnDelay(vehicle, VEHICLE_IDLE_RESPAWN_DELAY)
    end

    if getPlayerCount() > 0 then
        stateMachine:start_countdown()
    else
        stateMachine:set_idle()
    end
    return true
end

local function startCountdown(seconds)
    killTimerIfExists(timers.countdown)

    local remainingSecs = seconds
    for _, player in ipairs(getElementsByType("player")) do
        setElementFrozen(player, true)                -- Freeze all players
        toggleAllControls(player, false, true, false) -- Disable all controls for all players
    end
    timers.countdown = setTimer(function()
        triggerClientEvent(root, "ptp:onCountdown", resourceRoot, remainingSecs)
        if remainingSecs > 0 then
            if remainingSecs == 5 then
                triggerEvent("onRoundSelectPresident", root)
            end
            remainingSecs = remainingSecs - 1
        else
            killTimerIfExists(timers.countdown)
            timers.countdown = nil
            stateMachine:start_round()
        end
    end, 1000, seconds + 1)
end

local function startRound()
    killTimerIfExists(timers.roundEndTimer)
    killTimerIfExists(timers.timerTick)
    timers.roundEndTimer = setTimer(function()
        stateMachine:end_round()
    end, ROUND_TIME_LIMIT_MILLIS, 1)

    for _, player in ipairs(getElementsByType("player")) do
        if getPlayerTeam(player) ~= nil then
            setElementFrozen(player, false)             -- Unfreeze all players
            toggleAllControls(player, true, true, true) -- Enable all controls for all players
        end
    end

    triggerEvent("ptp:onRoundStart", root, currentMapName)
    timers.timerTick = setTimer(function()
        if timers.roundEndTimer == nil then
            killTimerIfExists(timers.timerTick)
            return
        end
        local timeLeft = getTimerDetails(timers.roundEndTimer)
        triggerClientEvent(root, "ptp:timerTick", root, math.floor(timeLeft / 1000))
    end, 1000, ROUND_TIME_SECONDS)
    outputChatBox("Round has started! Good luck!", root, 0, 255, 0) -- FIXME
end

local function endRound()
    killRoundTimers()

    nextMapName = getRandomMap()

    triggerEvent("ptp:onRoundEnd", root, currentMapName)
    triggerClientEvent(root, "ptp:onRoundEnd", root, currentMapName)

    for _, player in ipairs(getElementsByType("player")) do
        setElementFrozen(player, true)                -- Freeze all players
        toggleAllControls(player, false, true, false) -- Disable all controls for all players
    end

    -- break between rounds, then countdown of 10 seconds
    setTimer(function()
        stateMachine:unload_map()
    end, ROUND_END_BREAK_TIME, 1)
end

stateMachine = machine.create({
    initial = 'idle',
    events = {
        { name = 'load_map',        from = { 'idle', 'unloading' },               to = 'loading' },
        { name = 'set_idle',        from = { 'loading', 'countdown', 'running' }, to = 'idle' },
        { name = 'start_countdown', from = { 'loading', 'idle' },                 to = 'countdown' },
        { name = 'start_round',     from = 'countdown',                           to = 'running' },
        { name = 'end_round',       from = 'running',                             to = 'round_end' },
        { name = 'unload_map',      from = 'round_end',                           to = 'unloading' },
    },
    callbacks = {
        onloading = function()
            loadMap(nextMapName)
        end,
        onidle = function()
            outputDebugString("[MapManager] Idle - waiting for players to join...")
        end,
        oncountdown = function()
            -- notify server-side listeners
            triggerEvent("ptp:onRoundPrepare", resourceRoot)
            -- notify clients so they can display countdown UI
            startCountdown(COUNTDOWN_TIME)
        end,
        onrunning = function()
            startRound()
        end,
        onround_end = function()
            endRound()
        end,
        onunloading = function()
            unloadCurrentMap()
        end,
        onstatechange = function(self, evt, from, to, ...)
            outputDebugString(("[MapManager] state changed %s -> %s via %s"):format(from, to, evt))
        end,
    },
})

addEventHandler("onResourceStart", resourceRoot, function()
    if getPlayerCount() > 0 then
        stateMachine:load_map()
    else
        stateMachine:set_idle()
    end
end)

addEventHandler("onResourceStop", root, function(stoppedResource)
    onResourceStop(stoppedResource)
end)

addEventHandler("onPlayerJoin", root, function()
    if stateMachine:is("idle") then
        setTimer(function()
            if stateMachine:is("idle") and getPlayerCount() > 0 then
                loadMapOrStartCountdown()
            end
        end, 5000, 1)
    end
end)

addEventHandler("onPlayerQuit", root, function()
    local remainingPlayers = getPlayerCount() - 1
    if remainingPlayers == 0 then
        outputDebugString("[MapManager] All players left during round. Stopping round and returning to idle.")
        killRoundTimers()
        stateMachine:set_idle()
    end
end)
