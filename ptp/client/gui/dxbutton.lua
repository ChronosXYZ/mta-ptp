DxButton = class(function(button, button_id, startX, startY, width, height, bgColor, text, textFont, textScale, textColor, textShadowEnabled, onClickHandler)
    local screenW, screenH = guiGetScreenSize()
    button.button_id = button_id
    button.startX = startX * screenW
    button.startY = startY * screenH
    button.width = width * screenW
    button.height = height * screenH
    button.bgColor = bgColor
    button.text = text
    button.textFont = textFont
    button.textScale = textScale
    button.textColor = textColor
    button.textShadowEnabled = textShadowEnabled
    button.onClickHandler = onClickHandler
end)

function DxButton:show()
    --self._invisibleLabel = guiCreateLabel(0.09, 0.36, 0.28, 0.05, self.button_id, true)
    self._invisibleLabel = guiCreateLabel(self.startX, self.startY, self.width, self.height, self.button_id, false)
    guiSetAlpha(self._invisibleLabel, 0.0)

    self._drawButton = function()
        dxDrawRectangle(self.startX, self.startY, self.width, self.height, self.bgColor)
        if self._currentButtonUnderCursor then
            local red, green, blue, alpha = extractRgbFromColor(self.bgColor)
            local lightRed, lightGreen, lightBlue = shadeColor(red, green, blue, 20)
            dxDrawRectangle(self.startX, self.startY, self.width, self.height, tocolor(lightRed, lightGreen, lightBlue, alpha))
        end
        if self.textShadowEnabled then
            dxDrawText(self.text, self.startX + 1, self.startY + 1, self.width + 1, self.height + 1, tocolor(0, 0, 0, 255), self.textScale, self.textFont, "left", "top", false, false, false, false, false)
        end
        dxDrawText(self.text, self.startX, self.startY, self.width, self.height, self.textColor, self.textScale, self.textFont, "left", "top", false, false, false, false, false)
    end

    self._handleMouseOverButton = function()
        if guiGetText(source) == self.button_id then
            self._currentButtonUnderCursor = true
        end
    end

    self._handleMouseLeaveButtonRectangle = function()
        self._currentButtonUnderCursor = false
    end

    self._handleClickOnLabel = function()
        if guiGetText(source) == self.button_id then
            self.onClickHandler()
        end
    end

    addEventHandler("onClientRender", root, self._drawButton)
    addEventHandler("onClientMouseEnter", root, self._handleMouseOverButton)
    addEventHandler("onClientMouseLeave", root, self._handleMouseLeaveButtonRectangle)
    addEventHandler("onClientGUIClick", root, self._handleClickOnLabel)
end

function DxButton:hide()
    destroyElement(self._invisibleLabel)
    removeEventHandler("onClientRender", root, self._drawButton)
    removeEventHandler("onClientMouseEnter", root, self._handleMouseOverButton)
    removeEventHandler("onClientMouseLeave", root, self._handleMouseLeaveButtonRectangle)
    removeEventHandler("onClientGUIClick", root, self._handleClickOnLabel)
end