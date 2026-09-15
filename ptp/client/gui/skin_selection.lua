loadstring(exports.dgs:dgsImportFunction())()

local POLICE_SKINS = { 280, 281, 282, 283, 284, 285, 288, 265, 266, 267 }
local SECRET_SERVICE_SKINS = { 163, 164, 165, 166, 194 }
local TERRORISTS_SKINS = { 124, 125, 126, 127, 111, 112 }

-- Module state
local isOpen = false
local isSubmitting = false
local isTeamFull = false
local teamSelected = nil
local currentSkinArray = nil
local currentSkinIndex = 1

-- GUI Elements
local titleLabel = nil
local teamPromptLabel = nil
local skinCounterLabel = nil
local instructionLabel = nil
local teamFullLabel = nil

local secretServiceTeamButton = nil
local policeTeamButton = nil
local terroristsTeamButton = nil

SkinSelectionMenu = {}

local function createGui()
    titleLabel = dgsCreateLabel(0.2870, 0.0528, 0.3864, 0.0648, "Protect The President", true)
    dgsSetFont(titleLabel, "bankgothic")
    dgsSetProperty(titleLabel, "textSize", { 2.0, 2.0 })
    dgsSetProperty(titleLabel, "textColor", tocolor(255, 255, 255, 255))
    dgsSetProperty(titleLabel, "shadow", { 2.0, 2.0, tocolor(0, 0, 0, 255), 1 })
    dgsSetVisible(titleLabel, false)

    teamPromptLabel = dgsCreateLabel(0.0896, 0.2685, 0.2797, 0.0565, "Select the team:", true)
    dgsSetFont(teamPromptLabel, "bankgothic")
    dgsSetProperty(teamPromptLabel, "textSize", { 2.0, 2.0 })
    dgsSetProperty(teamPromptLabel, "textColor", tocolor(255, 255, 255, 255))
    dgsSetProperty(teamPromptLabel, "shadow", { 2.0, 2.0, tocolor(0, 0, 0, 255), 1 })
    dgsSetVisible(teamPromptLabel, false)

    skinCounterLabel = dgsCreateLabel(0.30, 0.77, 0.40, 0.04, "", true)
    dgsSetFont(skinCounterLabel, "default-bold")
    dgsSetProperty(skinCounterLabel, "textSize", { 1.5, 1.5 })
    dgsSetProperty(skinCounterLabel, "textColor", tocolor(255, 215, 0, 255))
    dgsSetProperty(skinCounterLabel, "alignment", { "center", "center" })
    dgsSetProperty(skinCounterLabel, "shadow", { 1.5, 1.5, tocolor(0, 0, 0, 255), 1 })
    dgsSetVisible(skinCounterLabel, false)

    instructionLabel = dgsCreateLabel(0.15, 0.82, 0.70, 0.06,
        "Use Left & Right Arrow keys to switch skin. Press Space to confirm.", true)
    dgsSetFont(instructionLabel, "default-bold")
    dgsSetProperty(instructionLabel, "textSize", { 1.6, 1.6 })
    dgsSetProperty(instructionLabel, "textColor", tocolor(255, 255, 255, 255))
    dgsSetProperty(instructionLabel, "alignment", { "center", "center" })
    dgsSetProperty(instructionLabel, "shadow", { 1.5, 1.5, tocolor(0, 0, 0, 255), 1 })
    dgsSetVisible(instructionLabel, false)

    teamFullLabel = dgsCreateLabel(0.6896, 0.5630, 0.20, 0.0509, "Team is full!", true)
    dgsSetFont(teamFullLabel, "default-bold")
    dgsSetProperty(teamFullLabel, "textSize", { 1.8, 1.8 })
    dgsSetProperty(teamFullLabel, "textColor", tocolor(241, 6, 0, 255))
    dgsSetProperty(teamFullLabel, "shadow", { 1.5, 1.5, tocolor(0, 0, 0, 255), 1 })
    dgsSetVisible(teamFullLabel, false)

    secretServiceTeamButton = dgsCreateButton(
        0.0896, 0.3574, 0.2786, 0.0481,
        "Secret Service", true
    )
    dgsSetFont(secretServiceTeamButton, "pricedown")
    dgsSetProperty(secretServiceTeamButton, "textSize", { 2.0, 2.0 })
    dgsSetProperty(secretServiceTeamButton, "color", {
        tocolor(29, 253, 0, 200),
        tocolor(54, 255, 25, 230),
        tocolor(20, 200, 0, 255)
    })
    dgsSetProperty(secretServiceTeamButton, "textColor", tocolor(255, 255, 255, 255))
    dgsSetProperty(secretServiceTeamButton, "shadow", { 2.0, 2.0, tocolor(0, 0, 0, 255) })
    dgsSetVisible(secretServiceTeamButton, false)
    addEventHandler("onDgsMouseClickUp", secretServiceTeamButton, function(button)
        if button == "left" then
            SkinSelectionMenu.selectTeam(TEAM_SECRET_SERVICE, SECRET_SERVICE_SKINS)
        end
    end, false)

    policeTeamButton = dgsCreateButton(
        0.0891, 0.4278, 0.2792, 0.0454,
        "Police", true
    )
    dgsSetFont(policeTeamButton, "pricedown")
    dgsSetProperty(policeTeamButton, "textSize", { 2.0, 2.0 })
    dgsSetProperty(policeTeamButton, "color", {
        tocolor(0, 23, 252, 200),
        tocolor(40, 60, 255, 230),
        tocolor(0, 15, 200, 255)
    })
    dgsSetProperty(policeTeamButton, "textColor", tocolor(255, 255, 255, 255))
    dgsSetProperty(policeTeamButton, "shadow", { 2.0, 2.0, tocolor(0, 0, 0, 255) })
    dgsSetVisible(policeTeamButton, false)
    addEventHandler("onDgsMouseClickUp", policeTeamButton, function(button)
        if button == "left" then
            SkinSelectionMenu.selectTeam(TEAM_POLICE, POLICE_SKINS)
        end
    end, false)

    terroristsTeamButton = dgsCreateButton(
        0.0891, 0.4917, 0.2792, 0.0472,
        "Terrorists", true
    )
    dgsSetFont(terroristsTeamButton, "pricedown")
    dgsSetProperty(terroristsTeamButton, "textSize", { 2.0, 2.0 })
    dgsSetProperty(terroristsTeamButton, "color", {
        tocolor(251, 0, 0, 200),
        tocolor(255, 45, 45, 230),
        tocolor(200, 0, 0, 255)
    })
    dgsSetProperty(terroristsTeamButton, "textColor", tocolor(255, 255, 255, 255))
    dgsSetProperty(terroristsTeamButton, "shadow", { 2.0, 2.0, tocolor(0, 0, 0, 255) })
    dgsSetVisible(terroristsTeamButton, false)
    addEventHandler("onDgsMouseClickUp", terroristsTeamButton, function(button)
        if button == "left" then
            SkinSelectionMenu.selectTeam(TEAM_TERRORISTS, TERRORISTS_SKINS)
        end
    end, false)
end

local function setVisible(visible)
    dgsSetVisible(titleLabel, visible)
    dgsSetVisible(teamPromptLabel, visible)
    dgsSetVisible(skinCounterLabel, visible)
    dgsSetVisible(instructionLabel, visible)
    dgsSetVisible(teamFullLabel, visible and isTeamFull)
    dgsSetVisible(secretServiceTeamButton, visible)
    dgsSetVisible(policeTeamButton, visible)
    dgsSetVisible(terroristsTeamButton, visible)
end

function SkinSelectionMenu.updateButtonSelections()
    local selectedOutline = { "in", 3, tocolor(255, 255, 255, 255) }

    dgsSetProperty(secretServiceTeamButton, "outline",
        teamSelected == TEAM_SECRET_SERVICE and selectedOutline or false)
    dgsSetProperty(policeTeamButton, "outline",
        teamSelected == TEAM_POLICE and selectedOutline or false)
    dgsSetProperty(terroristsTeamButton, "outline",
        teamSelected == TEAM_TERRORISTS and selectedOutline or false)
end

function SkinSelectionMenu.updateSkinCounter()
    if currentSkinArray and currentSkinIndex then
        dgsSetText(skinCounterLabel, ("Skin: %d / %d"):format(currentSkinIndex, #currentSkinArray))
    end
end

function SkinSelectionMenu.selectTeam(teamID, skinArray)
    teamSelected = teamID
    currentSkinArray = skinArray
    currentSkinIndex = 1
    setElementModel(localPlayer, currentSkinArray[currentSkinIndex])
    SkinSelectionMenu.updateButtonSelections()
    SkinSelectionMenu.updateSkinCounter()
end

function SkinSelectionMenu.switchSkin(key)
    if not teamSelected or not currentSkinArray or #currentSkinArray == 0 then
        outputChatBox("Please select a team first!")
        return
    end

    if key == "arrow_r" then
        currentSkinIndex = currentSkinIndex + 1
        if currentSkinIndex > #currentSkinArray then
            currentSkinIndex = 1
        end
    elseif key == "arrow_l" then
        currentSkinIndex = currentSkinIndex - 1
        if currentSkinIndex < 1 then
            currentSkinIndex = #currentSkinArray
        end
    end

    setElementModel(localPlayer, currentSkinArray[currentSkinIndex])
    SkinSelectionMenu.updateSkinCounter()
end

function SkinSelectionMenu.submitSelection()
    if not isOpen or isSubmitting then return end
    if not teamSelected or not currentSkinArray then
        outputChatBox("Please select a team before confirming!")
        return
    end

    isSubmitting = true
    triggerServerEvent("onPlayerTeamSelected", resourceRoot, teamSelected,
        currentSkinArray[currentSkinIndex])
end

local function onSwitchLeft()
    SkinSelectionMenu.switchSkin("arrow_l")
end

local function onSwitchRight()
    SkinSelectionMenu.switchSkin("arrow_r")
end

local function onSelectTeamAndSpawn()
    SkinSelectionMenu.submitSelection()
end

function SkinSelectionMenu.open()
    if isOpen then
        SkinSelectionMenu.close()
    end
    isOpen = true
    isSubmitting = false

    showCursor(true)
    setVisible(true)

    SkinSelectionMenu.selectTeam(TEAM_SECRET_SERVICE, SECRET_SERVICE_SKINS)

    bindKey("arrow_l", "down", onSwitchLeft)
    bindKey("arrow_r", "down", onSwitchRight)
    bindKey("space", "down", onSelectTeamAndSpawn)
end

function SkinSelectionMenu.close()
    if not isOpen then return end
    isOpen = false
    isSubmitting = false

    showCursor(false)

    unbindKey("arrow_l", "down", onSwitchLeft)
    unbindKey("arrow_r", "down", onSwitchRight)
    unbindKey("space", "down", onSelectTeamAndSpawn)

    setVisible(false)
end

function SkinSelectionMenu.isOpen()
    return isOpen
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    createGui()
end)

addEvent("enterTeamSelectMenu", true)
addEventHandler("enterTeamSelectMenu", resourceRoot, function()
    SkinSelectionMenu.open()
end)

addEvent("onPlayerTeamSelectedSuccessful", true)
addEventHandler("onPlayerTeamSelectedSuccessful", resourceRoot, function()
    SkinSelectionMenu.close()
end)
