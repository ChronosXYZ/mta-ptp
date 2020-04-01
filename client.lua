local screenW, screenH = guiGetScreenSize()

SkinSelectionMenu = class(function(menu)
    menu.isTeamFull = false
    menu.policeSkins = {280, 281, 282, 283, 284, 285, 288, 265, 266, 267}
    menu.secretServiceSkins = {163, 164, 165, 166, 194}
    menu.terroristsSkins = {124, 125, 126, 127, 111, 112}
    menu._selectSecretService = function()
        menu.teamSelected = Teams.SECRET_SERVICE
        setElementModel(localPlayer, menu.secretServiceSkins[1])
        menu._currentSkinIndex = 1
        menu._currentSkinArray = menu.secretServiceSkins
    end
    menu._selectPolice = function()
        menu.teamSelected = Teams.POLICE
        setElementModel(localPlayer, menu.policeSkins[1])
        menu._currentSkinIndex = 1
        menu._currentSkinArray = menu.policeSkins
    end
    menu._selectTerrorists = function()
        menu.teamSelected = Teams.TERRORISTS
        setElementModel(localPlayer, menu.terroristsSkins[1])
        menu._currentSkinIndex = 1
        menu._currentSkinArray = menu.terroristsSkins
    end
end)

function SkinSelectionMenu:showSkinSelectionDxLabels()
    dxDrawText("Protect The President", (screenW * 0.2870) - 1, (screenH * 0.0528) - 1, (screenW * 0.6734) - 1, (screenH * 0.1176) - 1, tocolor(0, 0, 0, 255), 2.00, "bankgothic", "left", "top", false, false, false, false, false)
    dxDrawText("Protect The President", (screenW * 0.2870) + 1, (screenH * 0.0528) - 1, (screenW * 0.6734) + 1, (screenH * 0.1176) - 1, tocolor(0, 0, 0, 255), 2.00, "bankgothic", "left", "top", false, false, false, false, false)
    dxDrawText("Protect The President", (screenW * 0.2870) - 1, (screenH * 0.0528) + 1, (screenW * 0.6734) - 1, (screenH * 0.1176) + 1, tocolor(0, 0, 0, 255), 2.00, "bankgothic", "left", "top", false, false, false, false, false)
    dxDrawText("Protect The President", (screenW * 0.2870) + 1, (screenH * 0.0528) + 1, (screenW * 0.6734) + 1, (screenH * 0.1176) + 1, tocolor(0, 0, 0, 255), 2.00, "bankgothic", "left", "top", false, false, false, false, false)
    dxDrawText("Protect The President", screenW * 0.2870, screenH * 0.0528, screenW * 0.6734, screenH * 0.1176, tocolor(255, 255, 255, 255), 2.00, "bankgothic", "left", "top", false, false, false, false, false)

    dxDrawText("Select the team:", (screenW * 0.0896) - 1, (screenH * 0.2685) - 1, (screenW * 0.3693) - 1, (screenH * 0.3250) - 1, tocolor(0, 0, 0, 255), 2.00, "bankgothic", "left", "top", false, false, false, false, false)
    dxDrawText("Select the team:", (screenW * 0.0896) + 1, (screenH * 0.2685) - 1, (screenW * 0.3693) + 1, (screenH * 0.3250) - 1, tocolor(0, 0, 0, 255), 2.00, "bankgothic", "left", "top", false, false, false, false, false)
    dxDrawText("Select the team:", (screenW * 0.0896) - 1, (screenH * 0.2685) + 1, (screenW * 0.3693) - 1, (screenH * 0.3250) + 1, tocolor(0, 0, 0, 255), 2.00, "bankgothic", "left", "top", false, false, false, false, false)
    dxDrawText("Select the team:", (screenW * 0.0896) + 1, (screenH * 0.2685) + 1, (screenW * 0.3693) + 1, (screenH * 0.3250) + 1, tocolor(0, 0, 0, 255), 2.00, "bankgothic", "left", "top", false, false, false, false, false)
    dxDrawText("Select the team:", screenW * 0.0896, screenH * 0.2685, screenW * 0.3693, screenH * 0.3250, tocolor(255, 255, 255, 255), 2.00, "bankgothic", "left", "top", false, false, false, false, false)

    dxDrawText("You can change skin via left & right arrow buttons. When you are done - click Space", screenW * 0.3089, screenH * 0.8111, screenW * 0.6896, screenH * 0.9185, tocolor(255, 255, 255, 255), 3.00, "arial", "left", "top", false, true, false, false, false)
    if self.isTeamFull then
        dxDrawText("Team is full!", (screenW * 0.6896) + 1, (screenH * 0.5630) + 1, (screenW * 0.7984) + 1, (screenH * 0.6139) + 1, tocolor(0, 0, 0, 255), 3.00, "arial", "left", "top", false, false, false, false, false)
        dxDrawText("Team is full!", screenW * 0.6896, screenH * 0.5630, screenW * 0.7984, screenH * 0.6139, tocolor(241, 6, 0, 254), 3.00, "arial", "left", "top", false, false, false, false, false)
    end
end

function SkinSelectionMenu:showSkinSelectionButtons()
    self.secretServiceTeamButton = DxButton(
        "secret_service",
        0.0896,
        0.3574,
        0.2786,
        0.0481,
        tocolor(29, 253, 0, 200),
        "Secret Service",
        "pricedown",
        2.0,
        tocolor(255, 255, 255, 255),
        true,
        self._selectSecretService
    )

    self.policeTeamButton = DxButton(
        "police",
        0.0891,
        0.4278,
        0.2792,
        0.0454,
        tocolor(0, 23, 252, 200),
        "Police",
        "pricedown",
        2.0,
        tocolor(255, 255, 255, 255),
        true,
        self._selectPolice
    )

    self.terroristsTeamButton = DxButton(
        "terrorists",
        0.0891,
        0.4917,
        0.2792,
        0.0472,
        tocolor(251, 0, 0, 200),
        "Terrorists",
        "pricedown",
        2.0,
        tocolor(255, 255, 255, 255),
        true,
        self._selectTerrorists
    )

    self.secretServiceTeamButton:show()
    self.policeTeamButton:show()
    self.terroristsTeamButton:show()
end

function SkinSelectionMenu:hideSkinSelectionButtons()
    self.secretServiceTeamButton:hide()
    self.policeTeamButton:hide()
    self.terroristsTeamButton:hide()
end

function SkinSelectionMenu:switchSkin(key)
    if not self.teamSelected then
        outputChatBox("Please select the team!")
        return
    end
    if key == "arrow_r" then
        if self._currentSkinIndex + 1 > #self._currentSkinArray then
            self._currentSkinIndex = 1
            setElementModel(localPlayer, self._currentSkinArray[self._currentSkinIndex])
            return
        else
            self._currentSkinIndex = self._currentSkinIndex + 1
            setElementModel(localPlayer, self._currentSkinArray[self._currentSkinIndex])
            return
        end
    elseif key == "arrow_l" then
        if self._currentSkinIndex - 1 < 1 then
            self._currentSkinIndex = #self._currentSkinArray
            setElementModel(localPlayer, self._currentSkinArray[self._currentSkinIndex])
            return
        else
            self._currentSkinIndex = self._currentSkinIndex - 1
            setElementModel(localPlayer, self._currentSkinArray[self._currentSkinIndex])
            return
        end
    end
end

local function selectTeamAndSpawn(team, skin)
    triggerServerEvent("onPlayerTeamSelected", localPlayer, team, skin)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    setAmbientSoundEnabled("gunfire", false)
    skinSelectionMenu = SkinSelectionMenu()
    skinSelectionMenu:showSkinSelectionButtons()
    skinSelectionMenu._showLabels = function()
        skinSelectionMenu:showSkinSelectionDxLabels()
    end
    skinSelectionMenu._switchSkin = function(key)
        skinSelectionMenu:switchSkin(key)
    end
    bindKey("arrow_l", "down", skinSelectionMenu._switchSkin)
    bindKey("arrow_r", "down", skinSelectionMenu._switchSkin)
    addEventHandler("onClientRender", root, skinSelectionMenu._showLabels)
    function _selectTeamAndSpawn()
        selectTeamAndSpawn(skinSelectionMenu.teamSelected, skinSelectionMenu._currentSkinArray[skinSelectionMenu._currentSkinIndex])
    end
    bindKey("space", "down", _selectTeamAndSpawn)
    skinSelectionMenu._selectSecretService()
end)

addEvent("onPlayerTeamFull", true)
addEventHandler("onPlayerTeamFull", root, function()
    skinSelectionMenu.isTeamFull = true
    setTimer(function()
        skinSelectionMenu.isTeamFull = false
    end, 2000, 1)
end)

addEvent("onPlayerTeamSelectedSuccessful", true)
addEventHandler("onPlayerTeamSelectedSuccessful", root, function()
    unbindKey("arrow_l", "down", skinSelectionMenu._switchSkin)
    unbindKey("arrow_r", "down", skinSelectionMenu._switchSkin)
    unbindKey("space", "down", _selectTeamAndSpawn)
    removeEventHandler("onClientRender", root, skinSelectionMenu._showLabels)
    skinSelectionMenu:hideSkinSelectionButtons()
end)
