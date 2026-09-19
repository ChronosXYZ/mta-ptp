local ROUND_TIME_SECONDS = 10 * 60        -- 10 minutes
local ROUND_END_BREAK_TIME_MS = 10 * 1000 -- 10 seconds break between rounds
local COUNTDOWN_TIME_SECONDS = 10         -- 10 seconds countdown

-- Module state
local timeRemaining = ROUND_TIME_SECONDS
local stateMachine = nil
local countdownTimer = nil
local roundClockTimer = nil
local breakTimer = nil

local function killTimerIfExists(t)
    if t and isTimer(t) then
        killTimer(t)
    end
end

local function clearAllTimers()
    killTimerIfExists(countdownTimer)
    killTimerIfExists(roundClockTimer)
    killTimerIfExists(breakTimer)
    countdownTimer = nil
    roundClockTimer = nil
    breakTimer = nil
end

local function hasReadyPlayers(excludePlayer)
    for _, player in ipairs(getElementsByType("player")) do
        if player ~= excludePlayer and getElementData(player, "ptp.ready") == true then
            return true
        end
    end
    return false
end

local function loadMap()
    clearAllTimers()
    MapManager.loadMap()

    if hasReadyPlayers() then
        stateMachine:enter_countdown()
    else
        stateMachine:set_idle()
    end
end

RoundManager = {}

function RoundManager.getState()
    return stateMachine and stateMachine.current or "idle"
end

function RoundManager.is(state)
    return stateMachine and stateMachine:is(state) or false
end

function RoundManager.getTimeRemaining()
    return timeRemaining
end

function RoundManager.startCountdown()
    if RoundManager.is("idle") then
        if not MapManager.getCurrentMap() then
            MapManager.loadMap()
        end
        stateMachine:enter_countdown()
        return true
    end
    return false
end

function RoundManager.endRound(reason)
    if RoundManager.is("running") then
        stateMachine:end_round(reason)
        return true
    end
    return false
end

function RoundManager.setIdle()
    clearAllTimers()
    if stateMachine and stateMachine:can("set_idle") then
        stateMachine:set_idle()
        return true
    end
    return false
end

function RoundManager.init()
    stateMachine = machine.create({
        initial = 'idle',
        events = {
            { name = 'enter_countdown', from = { 'idle', 'loading' },                 to = 'countdown' },
            { name = 'start_round',     from = 'countdown',                           to = 'running' },
            { name = 'end_round',       from = 'running',                             to = 'round_end' },
            { name = 'next_map',        from = 'round_end',                           to = 'loading' },
            { name = 'set_idle',        from = { 'loading', 'countdown', 'running' }, to = 'idle' },
        },
        callbacks = {
            onidle = function()
                clearAllTimers()
                outputDebugString("[RoundManager] Idle - waiting for players to join...")
            end,

            oncountdown = function()
                clearAllTimers()
                triggerEvent("ptp:onRoundPrepare", resourceRoot)

                local remaining = COUNTDOWN_TIME_SECONDS
                triggerEvent("ptp:onCountdownTick", resourceRoot, remaining)
                triggerClientEvent(root, "ptp:onCountdown", resourceRoot, remaining)

                countdownTimer = setTimer(function()
                    remaining = remaining - 1
                    triggerEvent("ptp:onCountdownTick", resourceRoot, remaining)
                    triggerClientEvent(root, "ptp:onCountdown", resourceRoot, remaining)

                    if remaining <= 0 then
                        killTimerIfExists(countdownTimer)
                        countdownTimer = nil
                        stateMachine:start_round()
                    end
                end, 1000, COUNTDOWN_TIME_SECONDS)
            end,

            onrunning = function()
                clearAllTimers()
                timeRemaining = ROUND_TIME_SECONDS

                local currentMap = MapManager.getCurrentMap()
                triggerEvent("ptp:onRoundStart", root, currentMap)

                roundClockTimer = setTimer(function()
                    timeRemaining = timeRemaining - 1
                    triggerClientEvent(root, "ptp:timerTick", resourceRoot, timeRemaining)

                    if timeRemaining <= 0 then
                        killTimerIfExists(roundClockTimer)
                        roundClockTimer = nil
                        stateMachine:end_round("timeout")
                    end
                end, 1000, ROUND_TIME_SECONDS)
            end,

            onround_end = function(_, _, _, _, reason)
                clearAllTimers()
                local currentMap = MapManager.getCurrentMap()
                triggerEvent("ptp:onRoundEnd", root, currentMap, reason)
                triggerClientEvent(root, "ptp:onRoundEnd", resourceRoot, reason, currentMap)

                breakTimer = setTimer(function()
                    breakTimer = nil
                    stateMachine:next_map()
                end, ROUND_END_BREAK_TIME_MS, 1)
            end,

            onloading = function()
                loadMap()
            end,

            onstatechange = function(_, evt, from, to)
                outputDebugString(("[RoundManager] state changed %s -> %s via %s"):format(from, to, evt))
            end,
        },
    })

    loadMap()
end

-- Lifecycle hooks
addEventHandler("onResourceStart", resourceRoot, function()
    RoundManager.init()
end)


addEventHandler("onPlayerQuit", root, function()
    if not hasReadyPlayers(source) then
        if RoundManager.is("countdown") then
            outputDebugString("[RoundManager] All players left during countdown. Returning to idle.")
            RoundManager.setIdle()
        elseif RoundManager.is("running") then
            outputDebugString("[RoundManager] All players left during round. Stopping round and returning to idle.")
            RoundManager.setIdle()
        end
    end
end)
