loadstring(exports.dgs:dgsImportFunction())()

SkinSelectionMenu = class(function(menu)
    menu.isTeamFull = false
    menu.policeSkins = { 280, 281, 282, 283, 284, 285, 288, 265, 266, 267 }
    menu.secretServiceSkins = { 163, 164, 165, 166, 194 }
    menu.terroristsSkins = { 124, 125, 126, 127, 111, 112 }
    menu.isOpen = false
    menu.isSubmitting = false
    menu.teamSelected = nil
    menu._currentSkinArray = nil
    menu._currentSkinIndex = 1

    menu._selectSecretService = function()
        menu.teamSelected = Teams.SECRET_SERVICE
        menu._currentSkinArray = menu.secretServiceSkins
        menu._currentSkinIndex = 1
        setElementModel(localPlayer, menu._currentSkinArray[menu._currentSkinIndex])
        menu:updateButtonSelections()
        menu:updateSkinCounter()
    end

    menu._selectPolice = function()
        menu.teamSelected = Teams.POLICE
        menu._currentSkinArray = menu.policeSkins
        menu._currentSkinIndex = 1
        setElementModel(localPlayer, menu._currentSkinArray[menu._currentSkinIndex])
        menu:updateButtonSelections()
        menu:updateSkinCounter()
    end

    menu._selectTerrorists = function()
        menu.teamSelected = Teams.TERRORISTS
        menu._currentSkinArray = menu.terroristsSkins
        menu._currentSkinIndex = 1
        setElementModel(localPlayer, menu._currentSkinArray[menu._currentSkinIndex])
        menu:updateButtonSelections()
        menu:updateSkinCounter()
    end

    menu._boundSwitchLeft = function()
        menu:switchSkin("arrow_l")
    end

    menu._boundSwitchRight = function()
        menu:switchSkin("arrow_r")
    end

    menu._boundSelectTeamAndSpawn = function()
        menu:submitSelection()
    end
end)

function SkinSelectionMenu:updateButtonSelections()
    local selectedOutline = { "in", 3, tocolor(255, 255, 255, 255) }

    if isElement(self.secretServiceTeamButton) then
        dgsSetProperty(self.secretServiceTeamButton, "outline",
            self.teamSelected == Teams.SECRET_SERVICE and selectedOutline or false)
    end
    if isElement(self.policeTeamButton) then
        dgsSetProperty(self.policeTeamButton, "outline",
            self.teamSelected == Teams.POLICE and selectedOutline or false)
    end
    if isElement(self.terroristsTeamButton) then
        dgsSetProperty(self.terroristsTeamButton, "outline",
            self.teamSelected == Teams.TERRORISTS and selectedOutline or false)
    end
end

function SkinSelectionMenu:updateSkinCounter()
    if isElement(self.skinCounterLabel) and self._currentSkinArray and self._currentSkinIndex then
        dgsSetText(self.skinCounterLabel, ("Skin: %d / %d"):format(self._currentSkinIndex, #self._currentSkinArray))
    end
end

function SkinSelectionMenu:showSkinSelectionLabels()
    if not isElement(self.titleLabel) then
        self.titleLabel = dgsCreateLabel(0.2870, 0.0528, 0.3864, 0.0648, "Protect The President", true)
        dgsSetFont(self.titleLabel, "bankgothic")
        dgsSetProperty(self.titleLabel, "textSize", { 2.0, 2.0 })
        dgsSetProperty(self.titleLabel, "textColor", tocolor(255, 255, 255, 255))
        dgsSetProperty(self.titleLabel, "shadow", { 2.0, 2.0, tocolor(0, 0, 0, 255), 1 })
    end

    if not isElement(self.teamPromptLabel) then
        self.teamPromptLabel = dgsCreateLabel(0.0896, 0.2685, 0.2797, 0.0565, "Select the team:", true)
        dgsSetFont(self.teamPromptLabel, "bankgothic")
        dgsSetProperty(self.teamPromptLabel, "textSize", { 2.0, 2.0 })
        dgsSetProperty(self.teamPromptLabel, "textColor", tocolor(255, 255, 255, 255))
        dgsSetProperty(self.teamPromptLabel, "shadow", { 2.0, 2.0, tocolor(0, 0, 0, 255), 1 })
    end

    if not isElement(self.skinCounterLabel) then
        self.skinCounterLabel = dgsCreateLabel(0.30, 0.77, 0.40, 0.04, "", true)
        dgsSetFont(self.skinCounterLabel, "default-bold")
        dgsSetProperty(self.skinCounterLabel, "textSize", { 1.5, 1.5 })
        dgsSetProperty(self.skinCounterLabel, "textColor", tocolor(255, 215, 0, 255))
        dgsSetProperty(self.skinCounterLabel, "alignment", { "center", "center" })
        dgsSetProperty(self.skinCounterLabel, "shadow", { 1.5, 1.5, tocolor(0, 0, 0, 255), 1 })
    end

    if not isElement(self.instructionLabel) then
        self.instructionLabel = dgsCreateLabel(0.15, 0.82, 0.70, 0.06,
            "Use Left & Right Arrow keys to switch skin. Press Space to confirm.", true)
        dgsSetFont(self.instructionLabel, "default-bold")
        dgsSetProperty(self.instructionLabel, "textSize", { 1.6, 1.6 })
        dgsSetProperty(self.instructionLabel, "textColor", tocolor(255, 255, 255, 255))
        dgsSetProperty(self.instructionLabel, "alignment", { "center", "center" })
        dgsSetProperty(self.instructionLabel, "shadow", { 1.5, 1.5, tocolor(0, 0, 0, 255), 1 })
    end

    if not isElement(self.teamFullLabel) then
        self.teamFullLabel = dgsCreateLabel(0.6896, 0.5630, 0.20, 0.0509, "Team is full!", true)
        dgsSetFont(self.teamFullLabel, "default-bold")
        dgsSetProperty(self.teamFullLabel, "textSize", { 1.8, 1.8 })
        dgsSetProperty(self.teamFullLabel, "textColor", tocolor(241, 6, 0, 255))
        dgsSetProperty(self.teamFullLabel, "shadow", { 1.5, 1.5, tocolor(0, 0, 0, 255), 1 })
    end

    dgsSetVisible(self.titleLabel, true)
    dgsSetVisible(self.teamPromptLabel, true)
    dgsSetVisible(self.skinCounterLabel, true)
    dgsSetVisible(self.instructionLabel, true)
    dgsSetVisible(self.teamFullLabel, self.isTeamFull)
    self:updateSkinCounter()
end

function SkinSelectionMenu:hideSkinSelectionLabels()
    if isElement(self.titleLabel) then dgsSetVisible(self.titleLabel, false) end
    if isElement(self.teamPromptLabel) then dgsSetVisible(self.teamPromptLabel, false) end
    if isElement(self.skinCounterLabel) then dgsSetVisible(self.skinCounterLabel, false) end
    if isElement(self.instructionLabel) then dgsSetVisible(self.instructionLabel, false) end
    if isElement(self.teamFullLabel) then dgsSetVisible(self.teamFullLabel, false) end
end

function SkinSelectionMenu:showSkinSelectionButtons()
    if not isElement(self.secretServiceTeamButton) then
        self.secretServiceTeamButton = dgsCreateButton(
            0.0896, 0.3574, 0.2786, 0.0481,
            "Secret Service", true
        )
        dgsSetFont(self.secretServiceTeamButton, "pricedown")
        dgsSetProperty(self.secretServiceTeamButton, "textSize", { 2.0, 2.0 })
        dgsSetProperty(self.secretServiceTeamButton, "color", {
            tocolor(29, 253, 0, 200),
            tocolor(54, 255, 25, 230),
            tocolor(20, 200, 0, 255)
        })
        dgsSetProperty(self.secretServiceTeamButton, "textColor", tocolor(255, 255, 255, 255))
        dgsSetProperty(self.secretServiceTeamButton, "shadow", { 2.0, 2.0, tocolor(0, 0, 0, 255) })
        addEventHandler("onDgsMouseClickUp", self.secretServiceTeamButton, function(button)
            if button == "left" then
                self._selectSecretService()
            end
        end, false)
    end

    if not isElement(self.policeTeamButton) then
        self.policeTeamButton = dgsCreateButton(
            0.0891, 0.4278, 0.2792, 0.0454,
            "Police", true
        )
        dgsSetFont(self.policeTeamButton, "pricedown")
        dgsSetProperty(self.policeTeamButton, "textSize", { 2.0, 2.0 })
        dgsSetProperty(self.policeTeamButton, "color", {
            tocolor(0, 23, 252, 200),
            tocolor(40, 60, 255, 230),
            tocolor(0, 15, 200, 255)
        })
        dgsSetProperty(self.policeTeamButton, "textColor", tocolor(255, 255, 255, 255))
        dgsSetProperty(self.policeTeamButton, "shadow", { 2.0, 2.0, tocolor(0, 0, 0, 255) })
        addEventHandler("onDgsMouseClickUp", self.policeTeamButton, function(button)
            if button == "left" then
                self._selectPolice()
            end
        end, false)
    end

    if not isElement(self.terroristsTeamButton) then
        self.terroristsTeamButton = dgsCreateButton(
            0.0891, 0.4917, 0.2792, 0.0472,
            "Terrorists", true
        )
        dgsSetFont(self.terroristsTeamButton, "pricedown")
        dgsSetProperty(self.terroristsTeamButton, "textSize", { 2.0, 2.0 })
        dgsSetProperty(self.terroristsTeamButton, "color", {
            tocolor(251, 0, 0, 200),
            tocolor(255, 45, 45, 230),
            tocolor(200, 0, 0, 255)
        })
        dgsSetProperty(self.terroristsTeamButton, "textColor", tocolor(255, 255, 255, 255))
        dgsSetProperty(self.terroristsTeamButton, "shadow", { 2.0, 2.0, tocolor(0, 0, 0, 255) })
        addEventHandler("onDgsMouseClickUp", self.terroristsTeamButton, function(button)
            if button == "left" then
                self._selectTerrorists()
            end
        end, false)
    end

    dgsSetVisible(self.secretServiceTeamButton, true)
    dgsSetVisible(self.policeTeamButton, true)
    dgsSetVisible(self.terroristsTeamButton, true)
    self:updateButtonSelections()
end

function SkinSelectionMenu:hideSkinSelectionButtons()
    if isElement(self.secretServiceTeamButton) then
        dgsSetVisible(self.secretServiceTeamButton, false)
    end
    if isElement(self.policeTeamButton) then
        dgsSetVisible(self.policeTeamButton, false)
    end
    if isElement(self.terroristsTeamButton) then
        dgsSetVisible(self.terroristsTeamButton, false)
    end
end

function SkinSelectionMenu:switchSkin(key)
    if not self.teamSelected or not self._currentSkinArray or #self._currentSkinArray == 0 then
        outputChatBox("Please select a team first!")
        return
    end

    if key == "arrow_r" then
        self._currentSkinIndex = self._currentSkinIndex + 1
        if self._currentSkinIndex > #self._currentSkinArray then
            self._currentSkinIndex = 1
        end
    elseif key == "arrow_l" then
        self._currentSkinIndex = self._currentSkinIndex - 1
        if self._currentSkinIndex < 1 then
            self._currentSkinIndex = #self._currentSkinArray
        end
    end

    setElementModel(localPlayer, self._currentSkinArray[self._currentSkinIndex])
    self:updateSkinCounter()
end

function SkinSelectionMenu:submitSelection()
    if not self.isOpen or self.isSubmitting then return end
    if not self.teamSelected or not self._currentSkinArray then
        outputChatBox("Please select a team before confirming!")
        return
    end

    self.isSubmitting = true
    triggerServerEvent("onPlayerTeamSelected", resourceRoot, self.teamSelected,
        self._currentSkinArray[self._currentSkinIndex])
end

function SkinSelectionMenu:open()
    if self.isOpen then
        self:close()
    end
    self.isOpen = true
    self.isSubmitting = false

    showCursor(true)
    self:showSkinSelectionButtons()
    self:showSkinSelectionLabels()
    self:_selectSecretService()

    bindKey("arrow_l", "down", self._boundSwitchLeft)
    bindKey("arrow_r", "down", self._boundSwitchRight)
    bindKey("space", "down", self._boundSelectTeamAndSpawn)
end

function SkinSelectionMenu:close()
    if not self.isOpen then return end
    self.isOpen = false
    self.isSubmitting = false

    showCursor(false)

    unbindKey("arrow_l", "down", self._boundSwitchLeft)
    unbindKey("arrow_r", "down", self._boundSwitchRight)
    unbindKey("space", "down", self._boundSelectTeamAndSpawn)

    self:hideSkinSelectionButtons()
    self:hideSkinSelectionLabels()
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    setAmbientSoundEnabled("gunfire", false)
    triggerServerEvent("onClientReady", resourceRoot)
end)

skinSelectionMenu = SkinSelectionMenu()

addEvent("enterTeamSelectMenu", true)
addEventHandler("enterTeamSelectMenu", resourceRoot, function()
    skinSelectionMenu:open()
end)

addEvent("onPlayerTeamSelectedSuccessful", true)
addEventHandler("onPlayerTeamSelectedSuccessful", resourceRoot, function()
    skinSelectionMenu:close()
end)

addEvent("ptp:onRoundEnd", true)
addEventHandler("ptp:onRoundEnd", resourceRoot, function(reason)
    if reason == "president_killed" then
        showGameText("#FF0000The President was killed!", 5)
    elseif reason == "president_quit" then
        showGameText("#FF0000The President disconnected!", 5)
    else
        showGameText("#FF0000Round has ended!", 5)
    end
end)
