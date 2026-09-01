loadstring([[
-- ROCKET::META_UI_V7_ANIMATION
-- ПЛАВНОЕ ПОЯВЛЕНИЕ МЕНЮ ПРИ ЗАПУСКЕ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local ScreenSize = Camera.ViewportSize

_G.CustomThemeEnabled = false
_G.MenuThemeColor = Color3.fromRGB(59, 130, 246)
_G.CurrentLang = "EN"
_G.MenuOpacity = 12
_G.RainbowEnabled = false
_G.MenuScale = 45
_G.FlyingDots = false

local Dots = {}
local DotConnection = nil
local lastScale = _G.MenuScale

local LANG = {
    RU = {
        Tabs = {"Аимбот", "Визуал", "Настройки"},
        Toggles = {
            UI_Color = {"Цвет интерфейса", "Включить кастомизацию цвета интерфейса"},
            Opacity = {"Прозрачность", "Регулировка прозрачности меню (0-50%)"},
            Rainbow = {"Разноцветная обводка", "Включить радужную обводку меню"},
            Scale = {"Scaling the menu", "Масштабирование меню (60-140%)"},
            FlyingDots = {"Летающие точки", "Точки, летающие с верха меню"},
            Reset = {"Сброс настроек", "Вернуть все настройки к стандартным"}
        }
    },
    EN = {
        Tabs = {"Aimbot", "Visuals", "Settings"},
        Toggles = {
            UI_Color = {"UI Color", "Enable interface color customization"},
            Opacity = {"Opacity", "Adjust menu transparency (0-50%)"},
            Rainbow = {"UI Rainbow Color", "Enable rainbow menu outline"},
            Scale = {"Scaling the menu", "Menu scaling (60-140%)"},
            FlyingDots = {"Flying Dots", "Floating dots from the top of the menu"},
            Reset = {"Reset Settings", "Return all settings to default"}
        }
    }
}

local function GetLang()
    return _G.CurrentLang == "RU" and LANG.RU or LANG.EN
end

local function PlayTabSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://88442833509532"
    sound.Volume = 0.5
    sound.Parent = SoundService
    sound:Play()
    task.delay(sound.TimeLength + 0.1, function() sound:Destroy() end)
end

local function PlayClickSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://88442833509532"
    sound.Volume = 0.3
    sound.Parent = SoundService
    sound:Play()
    task.delay(sound.TimeLength + 0.1, function() sound:Destroy() end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "META_GUI_V7"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 640 * (_G.MenuScale / 45), 0, 470 * (_G.MenuScale / 45))
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(17, 20, 26)
MainFrame.BackgroundTransparency = _G.MenuOpacity / 100
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Selectable = true

-- ===== АНИМАЦИЯ ПОЯВЛЕНИЯ =====
MainFrame.BackgroundTransparency = 1
MainFrame.Size = UDim2.new(0, 640 * (_G.MenuScale / 45) * 0.7, 0, 470 * (_G.MenuScale / 45) * 0.7)

task.wait(0.05)

TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 640 * (_G.MenuScale / 45), 0, 470 * (_G.MenuScale / 45)),
    BackgroundTransparency = _G.MenuOpacity / 100
}):Play()

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = _G.MenuThemeColor
MainStroke.Transparency = 0.4
MainStroke.Parent = MainFrame

local function UpdateMenuScale()
    if not MainFrame then return end
    local scale = _G.MenuScale / 45
    MainFrame.Size = UDim2.new(0, 640 * scale, 0, 470 * scale)
    if _G.FlyingDots then
        RebuildDots()
    end
end

local OwnerLabel = Instance.new("TextLabel")
OwnerLabel.Size = UDim2.new(0.3, 0, 0, 20)
OwnerLabel.Position = UDim2.new(0.01, 0, 0.92, 0)
OwnerLabel.BackgroundTransparency = 1
OwnerLabel.Text = "Owner : QwertyX01"
OwnerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
OwnerLabel.TextSize = 12
OwnerLabel.Font = Enum.Font.Gotham
OwnerLabel.TextXAlignment = Enum.TextXAlignment.Left
OwnerLabel.TextYAlignment = Enum.TextYAlignment.Bottom
OwnerLabel.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "META"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextYAlignment = Enum.TextYAlignment.Center
Title.Parent = Header

local Version = Instance.new("TextLabel")
Version.Size = UDim2.new(0.5, 0, 1, 0)
Version.Position = UDim2.new(0.5, 0, 0, 0)
Version.BackgroundTransparency = 1
Version.Text = "v7.0"
Version.TextColor3 = Color3.fromRGB(156, 163, 175)
Version.TextSize = 14
Version.Font = Enum.Font.Gotham
Version.TextXAlignment = Enum.TextXAlignment.Right
Version.TextYAlignment = Enum.TextYAlignment.Center
Version.Parent = Header

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, -20, 0, 1)
Separator.Position = UDim2.new(0, 10, 0, 38)
Separator.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
Separator.BorderSizePixel = 0
Separator.Parent = MainFrame

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 48)
TabContainer.Position = UDim2.new(0, 0, 0, 39)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local TabNames = {"Aimbot", "Visuals", "Settings"}
local TabButtons = {}
local ContentPages = {}
local activeIndex = 1
local langUpdateCallbacks = {}
local rainbowConnection = nil

-- ===== НОВАЯ МЕХАНИКА ИНДИКАТОРОВ =====
local IndicatorLine = nil
local IndicatorColor = _G.MenuThemeColor

local function CreateIndicatorLine()
    if IndicatorLine then
        IndicatorLine:Destroy()
        IndicatorLine = nil
    end
    
    IndicatorLine = Instance.new("Frame")
    IndicatorLine.Size = UDim2.new(0.12, 0, 0, 2)
    IndicatorLine.Position = UDim2.new(0.02, 0, 1, -2)
    IndicatorLine.BackgroundColor3 = IndicatorColor
    IndicatorLine.BorderSizePixel = 0
    IndicatorLine.Parent = TabContainer
    IndicatorLine.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = IndicatorLine
end

local function UpdateIndicatorPosition(index)
    if not IndicatorLine then return end
    if index < 1 or index > #TabButtons then return end
    
    local btn = TabButtons[index]
    local width = 0.12
    local xPos = 0.02 + (index - 1) * (width + 0.03)
    
    TweenService:Create(IndicatorLine, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Position = UDim2.new(xPos, 0, 1, -2),
        Size = UDim2.new(width + 0.02, 0, 0, 2)
    }):Play()
end

local function UpdateIndicatorColor(color)
    IndicatorColor = color
    if IndicatorLine then
        TweenService:Create(IndicatorLine, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = color
        }):Play()
    end
end

-- ===== ФУНКЦИИ ОБНОВЛЕНИЯ ВКЛАДОК =====
local function UpdateTabsLanguage()
    local lang = GetLang()
    for i, btn in ipairs(TabButtons) do
        btn.Text = lang.Tabs[i]
    end
end

local function UpdateAllTexts()
    UpdateTabsLanguage()
    for _, cb in ipairs(langUpdateCallbacks) do
        pcall(cb)
    end
end

for i, name in ipairs(TabNames) do
    local btn = Instance.new("TextButton")
    local width = 0.12
    btn.Size = UDim2.new(width, 0, 0, 32)
    btn.Position = UDim2.new(0.02 + (i-1) * (width + 0.03), 0, 0.15, 0)
    btn.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(156, 163, 175)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = TabContainer

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    if i == 1 then
        btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Size = UDim2.new(width + 0.02, 0, 0, 36)
    end

    btn.MouseEnter:Connect(function()
        if activeIndex ~= i then
            btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)

    btn.MouseLeave:Connect(function()
        if activeIndex ~= i then
            btn.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
            btn.TextColor3 = Color3.fromRGB(156, 163, 175)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        PlayTabSound()
        
        for _, b in ipairs(TabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
            b.TextColor3 = Color3.fromRGB(156, 163, 175)
            TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(width, 0, 0, 32)
            }):Play()
        end
        
        btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(width + 0.02, 0, 0, 36)
        }):Play()
        
        for _, page in pairs(ContentPages) do
            page.Visible = false
        end
        local targetPage = ContentPages[name]
        if targetPage then targetPage.Visible = true end
        activeIndex = i
        
        UpdateIndicatorPosition(i)
    end)

    table.insert(TabButtons, btn)

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "_Page"
    page.Size = UDim2.new(1, -20, 1, -96)
    page.Position = UDim2.new(0, 10, 0, 87)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 4
    page.Visible = (i == 1)
    page.ZIndex = 5
    page.Parent = MainFrame
    ContentPages[name] = page
end

CreateIndicatorLine()
task.wait(0.05)
UpdateIndicatorPosition(1)

local aimbotPage = ContentPages["Aimbot"]
if aimbotPage then
    aimbotPage.CanvasSize = UDim2.new(0, 0, 0, 10)
end

local visualsPage = ContentPages["Visuals"]
if visualsPage then
    visualsPage.CanvasSize = UDim2.new(0, 0, 0, 10)
end

local settingsPage = ContentPages["Settings"]
if settingsPage then
    settingsPage.CanvasSize = UDim2.new(0, 0, 0, 600)

    local settingsContainer = Instance.new("Frame")
    settingsContainer.Size = UDim2.new(1, 0, 0, 500)
    settingsContainer.Position = UDim2.new(0, 0, 0, 55)
    settingsContainer.BackgroundTransparency = 1
    settingsContainer.ClipsDescendants = true
    settingsContainer.Parent = settingsPage

    -- ===== Чекбокс UI Color =====
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 45)
    toggleFrame.Position = UDim2.new(0, 0, 0, 10)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = settingsPage

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "UI Color"
    label.TextColor3 = Color3.fromRGB(209, 213, 219)
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(0.7, 0, 0, 16)
    desc.Position = UDim2.new(0, 0, 0, 22)
    desc.BackgroundTransparency = 1
    desc.Text = "Enable interface color customization"
    desc.TextColor3 = Color3.fromRGB(113, 113, 122)
    desc.TextSize = 11
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = toggleFrame

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 44, 0, 24)
    toggleBg.Position = UDim2.new(0.88, 0, 0.1, 0)
    toggleBg.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = toggleFrame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg

    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 18, 0, 18)
    handle.Position = UDim2.new(0, 3, 0.5, -9)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.BorderSizePixel = 0
    handle.Parent = toggleBg

    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle

    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(0, 44, 0, 24)
    clickArea.Position = UDim2.new(0.88, 0, 0.1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 10
    clickArea.Parent = toggleFrame

    -- ===== ЦВЕТОВОЙ КРУГ =====
    local pickerContainer = Instance.new("Frame")
    pickerContainer.Size = UDim2.new(1, -30, 0, 140)
    pickerContainer.Position = UDim2.new(0, 15, 0, 55)
    pickerContainer.BackgroundTransparency = 1
    pickerContainer.Visible = _G.CustomThemeEnabled
    pickerContainer.ZIndex = 30
    pickerContainer.Parent = settingsPage

    local wheelImage = Instance.new("ImageLabel")
    wheelImage.Size = UDim2.new(0, 120, 0, 120)
    wheelImage.Position = UDim2.new(0.5, -60, 0.5, -60)
    wheelImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    wheelImage.BackgroundTransparency = 1
    wheelImage.Image = "rbxassetid://7393858625"
    wheelImage.ZIndex = 31
    wheelImage.Parent = pickerContainer

    local wheelCorner = Instance.new("UICorner")
    wheelCorner.CornerRadius = UDim.new(1, 0)
    wheelCorner.Parent = wheelImage

    local pickerDot = Instance.new("Frame")
    pickerDot.Size = UDim2.new(0, 10, 0, 10)
    pickerDot.Position = UDim2.new(0.5, -5, 0.5, -5)
    pickerDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    pickerDot.ZIndex = 32
    pickerDot.Parent = wheelImage

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = pickerDot

    local dotStroke = Instance.new("UIStroke")
    dotStroke.Thickness = 1.5
    dotStroke.Color = Color3.fromRGB(0, 0, 0)
    dotStroke.Parent = pickerDot

    local dragArea = Instance.new("TextButton")
    dragArea.Size = UDim2.new(1, 0, 1, 0)
    dragArea.BackgroundTransparency = 1
    dragArea.Text = ""
    dragArea.ZIndex = 33
    dragArea.Parent = wheelImage

    local isDraggingColor = false
    local scrollFrame = settingsPage

    local function UpdateWheelColor(inputPosition)
        if not _G.CustomThemeEnabled then return end
        
        local wheelCenter = wheelImage.AbsolutePosition + (wheelImage.AbsoluteSize / 2)
        local delta = Vector2.new(inputPosition.X, inputPosition.Y) - wheelCenter
        local distance = delta.Magnitude
        local radius = wheelImage.AbsoluteSize.X / 2
        local clampedDistance = math.clamp(distance, 0, radius)
        local angle = math.atan2(delta.Y, delta.X)
        
        local xPos = clampedDistance * math.cos(angle)
        local yPos = clampedDistance * math.sin(angle)
        pickerDot.Position = UDim2.new(0, xPos + radius - 5, 0, yPos + radius - 5)
        
        if angle < 0 then angle = angle + (math.pi * 2) end
        local hue = angle / (math.pi * 2)
        local saturation = clampedDistance / radius
        local pickedColor = Color3.fromHSV(hue, saturation, 1)
        
        if not _G.RainbowEnabled then
            MainStroke.Color = pickedColor
            UpdateIndicatorColor(pickedColor)
        end
        _G.MenuThemeColor = pickedColor
    end

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingColor = true
            if scrollFrame and scrollFrame:IsA("ScrollingFrame") then
                scrollFrame.ScrollingEnabled = false
            end
            UpdateWheelColor(input.Position)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDraggingColor and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            UpdateWheelColor(input.Position)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingColor = false
            if scrollFrame and scrollFrame:IsA("ScrollingFrame") then
                scrollFrame.ScrollingEnabled = true
            end
        end
    end)

    -- ===== ФУНКЦИЯ ПЛАВНОГО СМЕЩЕНИЯ =====
    local function ShiftContainer(shiftDown)
        local targetY = shiftDown and 150 or 0
        TweenService:Create(settingsContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0, 0, 0, 55 + targetY)
        }):Play()
    end

    local function UpdateColorPickerVisibility()
        if _G.CustomThemeEnabled then
            pickerContainer.Visible = true
            ShiftContainer(true)
        else
            pickerContainer.Visible = false
            ShiftContainer(false)
        end
    end

    local function SetToggleState(value)
        if value then
            TweenService:Create(toggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(59, 130, 246)
            }):Play()
            TweenService:Create(handle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0, 23, 0.5, -9)
            }):Play()
        else
            TweenService:Create(toggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(42, 47, 58)
            }):Play()
            TweenService:Create(handle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0, 3, 0.5, -9)
            }):Play()
        end
        _G.CustomThemeEnabled = value
        UpdateColorPickerVisibility()
        if not value and not _G.RainbowEnabled then
            MainStroke.Color = _G.MenuThemeColor
            UpdateIndicatorColor(_G.MenuThemeColor)
        end
    end

    SetToggleState(_G.CustomThemeEnabled)

    local function UpdateUIColorText()
        local lang = GetLang()
        label.Text = lang.Toggles.UI_Color[1]
        desc.Text = lang.Toggles.UI_Color[2]
    end
    table.insert(langUpdateCallbacks, UpdateUIColorText)

    clickArea.MouseButton1Click:Connect(function()
        PlayClickSound()
        SetToggleState(not _G.CustomThemeEnabled)
    end)

    -- ===== БЛОК ПЕРЕКЛЮЧАТЕЛЯ ЯЗЫКА =====
    local langFrame = Instance.new("Frame")
    langFrame.Size = UDim2.new(1, -20, 0, 42)
    langFrame.Position = UDim2.new(0, 10, 0, 10)
    langFrame.BackgroundTransparency = 1
    langFrame.Parent = settingsContainer

    local langButtons = {}

    local function CreateLangButton(text, langCode, xPos)
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(0.42, 0, 0, 32)
        bg.Position = UDim2.new(xPos, 0, 0, 0)
        bg.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
        bg.BackgroundTransparency = 0.5
        bg.Parent = langFrame

        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 6)
        bgCorner.Parent = bg

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = text
        txt.TextColor3 = Color3.fromRGB(156, 163, 175)
        txt.TextSize = 14
        txt.Font = Enum.Font.GothamBold
        txt.TextXAlignment = Enum.TextXAlignment.Center
        txt.TextYAlignment = Enum.TextYAlignment.Center
        txt.Parent = bg

        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.ZIndex = 10
        clickBtn.Parent = bg

        local function UpdateLangButton()
            if _G.CurrentLang == langCode then
                bg.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
                bg.BackgroundTransparency = 0
                txt.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                bg.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
                bg.BackgroundTransparency = 0.5
                txt.TextColor3 = Color3.fromRGB(156, 163, 175)
            end
        end

        UpdateLangButton()

        clickBtn.MouseButton1Click:Connect(function()
            PlayClickSound()
            if _G.CurrentLang == langCode then return end
            _G.CurrentLang = langCode
            for _, btn in ipairs(langButtons) do
                pcall(btn.Update)
            end
            UpdateAllTexts()
            print("[LANG] Switched to: " .. langCode)
        end)

        local btnData = {Update = UpdateLangButton}
        table.insert(langButtons, btnData)
        return btnData
    end

    CreateLangButton("Русский", "RU", 0.03)
    CreateLangButton("English", "EN", 0.55)

    -- ===== ПОЛЗУНОК ПРОЗРАЧНОСТИ =====
    local opacityFrame = Instance.new("Frame")
    opacityFrame.Size = UDim2.new(1, -20, 0, 55)
    opacityFrame.Position = UDim2.new(0, 10, 0, 60)
    opacityFrame.BackgroundTransparency = 1
    opacityFrame.Parent = settingsContainer

    local opacityLabel = Instance.new("TextLabel")
    opacityLabel.Size = UDim2.new(0.5, 0, 0, 20)
    opacityLabel.Position = UDim2.new(0, 0, 0, 0)
    opacityLabel.BackgroundTransparency = 1
    opacityLabel.Text = "Opacity"
    opacityLabel.TextColor3 = Color3.fromRGB(209, 213, 219)
    opacityLabel.TextSize = 13
    opacityLabel.Font = Enum.Font.GothamBold
    opacityLabel.TextXAlignment = Enum.TextXAlignment.Left
    opacityLabel.Parent = opacityFrame

    local opacityDesc = Instance.new("TextLabel")
    opacityDesc.Size = UDim2.new(0.5, 0, 0, 16)
    opacityDesc.Position = UDim2.new(0, 0, 0, 22)
    opacityDesc.BackgroundTransparency = 1
    opacityDesc.Text = "Adjust menu transparency (0-50%)"
    opacityDesc.TextColor3 = Color3.fromRGB(113, 113, 122)
    opacityDesc.TextSize = 11
    opacityDesc.Font = Enum.Font.Gotham
    opacityDesc.TextXAlignment = Enum.TextXAlignment.Left
    opacityDesc.Parent = opacityFrame

    local opacityValue = Instance.new("TextLabel")
    opacityValue.Size = UDim2.new(0.15, 0, 0, 20)
    opacityValue.Position = UDim2.new(0.85, 0, 0, 0)
    opacityValue.BackgroundTransparency = 1
    opacityValue.Text = tostring(_G.MenuOpacity) .. "%"
    opacityValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    opacityValue.TextSize = 14
    opacityValue.Font = Enum.Font.GothamBold
    opacityValue.TextXAlignment = Enum.TextXAlignment.Right
    opacityValue.Parent = opacityFrame

    local opacitySliderBg = Instance.new("Frame")
    opacitySliderBg.Size = UDim2.new(0.5, 0, 0, 6)
    opacitySliderBg.Position = UDim2.new(0, 0, 0, 40)
    opacitySliderBg.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    opacitySliderBg.BorderSizePixel = 0
    opacitySliderBg.Parent = opacityFrame

    local opacitySliderCorner = Instance.new("UICorner")
    opacitySliderCorner.CornerRadius = UDim.new(1, 0)
    opacitySliderCorner.Parent = opacitySliderBg

    local opacitySliderFill = Instance.new("Frame")
    local opacityInitialPercent = _G.MenuOpacity / 50
    opacitySliderFill.Size = UDim2.new(opacityInitialPercent, 0, 1, 0)
    opacitySliderFill.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    opacitySliderFill.BorderSizePixel = 0
    opacitySliderFill.Parent = opacitySliderBg

    local opacitySliderFillCorner = Instance.new("UICorner")
    opacitySliderFillCorner.CornerRadius = UDim.new(1, 0)
    opacitySliderFillCorner.Parent = opacitySliderFill

    local opacitySliderHandle = Instance.new("Frame")
    opacitySliderHandle.Size = UDim2.new(0, 16, 0, 16)
    opacitySliderHandle.Position = UDim2.new(opacityInitialPercent, -8, 0.5, -8)
    opacitySliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    opacitySliderHandle.BorderSizePixel = 0
    opacitySliderHandle.Parent = opacitySliderBg

    local opacitySliderHandleCorner = Instance.new("UICorner")
    opacitySliderHandleCorner.CornerRadius = UDim.new(1, 0)
    opacitySliderHandleCorner.Parent = opacitySliderHandle

    local isDraggingOpacity = false

    local function UpdateOpacity(mouseX)
        local absPos = opacitySliderBg.AbsolutePosition.X
        local width = opacitySliderBg.AbsoluteSize.X
        if width <= 0 then return end
        local percent = math.clamp((mouseX - absPos) / width, 0, 1)
        local val = math.round(percent * 50)
        val = math.clamp(val, 0, 50)
        local p = val / 50
        opacitySliderFill.Size = UDim2.new(p, 0, 1, 0)
        opacitySliderHandle.Position = UDim2.new(p, -8, 0.5, -8)
        opacityValue.Text = tostring(val) .. "%"
        _G.MenuOpacity = val
        MainFrame.BackgroundTransparency = val / 100
    end

    opacitySliderHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingOpacity = true
            UpdateOpacity(input.Position.X)
        end
    end)

    opacitySliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingOpacity = true
            UpdateOpacity(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingOpacity = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDraggingOpacity and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateOpacity(input.Position.X)
        end
    end)

    local function UpdateOpacityText()
        local lang = GetLang()
        opacityLabel.Text = lang.Toggles.Opacity[1]
        opacityDesc.Text = lang.Toggles.Opacity[2]
    end
    table.insert(langUpdateCallbacks, UpdateOpacityText)

    -- ===== UI RAINBOW COLOR =====
    local rainbowFrame = Instance.new("Frame")
    rainbowFrame.Size = UDim2.new(1, 0, 0, 45)
    rainbowFrame.Position = UDim2.new(0, 0, 0, 120)
    rainbowFrame.BackgroundTransparency = 1
    rainbowFrame.Parent = settingsContainer

    local rainbowLabel = Instance.new("TextLabel")
    rainbowLabel.Size = UDim2.new(0.6, 0, 0, 20)
    rainbowLabel.Position = UDim2.new(0, 0, 0, 0)
    rainbowLabel.BackgroundTransparency = 1
    rainbowLabel.Text = "UI Rainbow Color"
    rainbowLabel.TextColor3 = Color3.fromRGB(209, 213, 219)
    rainbowLabel.TextSize = 13
    rainbowLabel.Font = Enum.Font.GothamBold
    rainbowLabel.TextXAlignment = Enum.TextXAlignment.Left
    rainbowLabel.Parent = rainbowFrame

    local rainbowDesc = Instance.new("TextLabel")
    rainbowDesc.Size = UDim2.new(0.7, 0, 0, 16)
    rainbowDesc.Position = UDim2.new(0, 0, 0, 22)
    rainbowDesc.BackgroundTransparency = 1
    rainbowDesc.Text = "Enable rainbow menu outline"
    rainbowDesc.TextColor3 = Color3.fromRGB(113, 113, 122)
    rainbowDesc.TextSize = 11
    rainbowDesc.Font = Enum.Font.Gotham
    rainbowDesc.TextXAlignment = Enum.TextXAlignment.Left
    rainbowDesc.Parent = rainbowFrame

    local rainbowToggleBg = Instance.new("Frame")
    rainbowToggleBg.Size = UDim2.new(0, 44, 0, 24)
    rainbowToggleBg.Position = UDim2.new(0.88, 0, 0.1, 0)
    rainbowToggleBg.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    rainbowToggleBg.BorderSizePixel = 0
    rainbowToggleBg.Parent = rainbowFrame

    local rainbowToggleCorner = Instance.new("UICorner")
    rainbowToggleCorner.CornerRadius = UDim.new(1, 0)
    rainbowToggleCorner.Parent = rainbowToggleBg

    local rainbowHandle = Instance.new("Frame")
    rainbowHandle.Size = UDim2.new(0, 18, 0, 18)
    rainbowHandle.Position = UDim2.new(0, 3, 0.5, -9)
    rainbowHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    rainbowHandle.BorderSizePixel = 0
    rainbowHandle.Parent = rainbowToggleBg

    local rainbowHandleCorner = Instance.new("UICorner")
    rainbowHandleCorner.CornerRadius = UDim.new(1, 0)
    rainbowHandleCorner.Parent = rainbowHandle

    local rainbowClickArea = Instance.new("TextButton")
    rainbowClickArea.Size = UDim2.new(0, 44, 0, 24)
    rainbowClickArea.Position = UDim2.new(0.88, 0, 0.1, 0)
    rainbowClickArea.BackgroundTransparency = 1
    rainbowClickArea.Text = ""
    rainbowClickArea.ZIndex = 10
    rainbowClickArea.Parent = rainbowFrame

    local function SetRainbowToggleState(value)
        if value then
            TweenService:Create(rainbowToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(59, 130, 246)
            }):Play()
            TweenService:Create(rainbowHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0, 23, 0.5, -9)
            }):Play()
        else
            TweenService:Create(rainbowToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(42, 47, 58)
            }):Play()
            TweenService:Create(rainbowHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0, 3, 0.5, -9)
            }):Play()
        end
        _G.RainbowEnabled = value
        if value then
            if rainbowConnection then rainbowConnection:Disconnect() end
            rainbowConnection = RunService.Heartbeat:Connect(function()
                local hue = (tick() * 0.1) % 1
                local color = Color3.fromHSV(hue, 1, 1)
                MainStroke.Color = color
                UpdateIndicatorColor(color)
            end)
        else
            if rainbowConnection then
                rainbowConnection:Disconnect()
                rainbowConnection = nil
                MainStroke.Color = _G.MenuThemeColor
                UpdateIndicatorColor(_G.MenuThemeColor)
            end
        end
    end

    SetRainbowToggleState(_G.RainbowEnabled)

    rainbowClickArea.MouseButton1Click:Connect(function()
        PlayClickSound()
        SetRainbowToggleState(not _G.RainbowEnabled)
    end)

    local function UpdateRainbowText()
        local lang = GetLang()
        rainbowLabel.Text = lang.Toggles.Rainbow[1]
        rainbowDesc.Text = lang.Toggles.Rainbow[2]
    end
    table.insert(langUpdateCallbacks, UpdateRainbowText)

    -- ===== СЛАЙДЕР МАСШТАБА =====
    local scaleFrame = Instance.new("Frame")
    scaleFrame.Size = UDim2.new(1, -20, 0, 55)
    scaleFrame.Position = UDim2.new(0, 10, 0, 170)
    scaleFrame.BackgroundTransparency = 1
    scaleFrame.Parent = settingsContainer

    local scaleLabel = Instance.new("TextLabel")
    scaleLabel.Size = UDim2.new(0.6, 0, 0, 20)
    scaleLabel.Position = UDim2.new(0, 0, 0, 0)
    scaleLabel.BackgroundTransparency = 1
    scaleLabel.Text = "Scaling the menu"
    scaleLabel.TextColor3 = Color3.fromRGB(209, 213, 219)
    scaleLabel.TextSize = 13
    scaleLabel.Font = Enum.Font.GothamBold
    scaleLabel.TextXAlignment = Enum.TextXAlignment.Left
    scaleLabel.Parent = scaleFrame

    local scaleDesc = Instance.new("TextLabel")
    scaleDesc.Size = UDim2.new(0.6, 0, 0, 16)
    scaleDesc.Position = UDim2.new(0, 0, 0, 22)
    scaleDesc.BackgroundTransparency = 1
    scaleDesc.Text = "Menu scaling (60-140%)"
    scaleDesc.TextColor3 = Color3.fromRGB(113, 113, 122)
    scaleDesc.TextSize = 11
    scaleDesc.Font = Enum.Font.Gotham
    scaleDesc.TextXAlignment = Enum.TextXAlignment.Left
    scaleDesc.Parent = scaleFrame

    local scaleValue = Instance.new("TextLabel")
    scaleValue.Size = UDim2.new(0.15, 0, 0, 20)
    scaleValue.Position = UDim2.new(0.85, 0, 0, 0)
    scaleValue.BackgroundTransparency = 1
    scaleValue.Text = tostring(math.round((_G.MenuScale / 45) * 100)) .. "%"
    scaleValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    scaleValue.TextSize = 14
    scaleValue.Font = Enum.Font.GothamBold
    scaleValue.TextXAlignment = Enum.TextXAlignment.Right
    scaleValue.Parent = scaleFrame

    local scaleSliderBg = Instance.new("Frame")
    scaleSliderBg.Size = UDim2.new(0.5, 0, 0, 6)
    scaleSliderBg.Position = UDim2.new(0, 0, 0, 40)
    scaleSliderBg.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    scaleSliderBg.BorderSizePixel = 0
    scaleSliderBg.Parent = scaleFrame

    local scaleSliderCorner = Instance.new("UICorner")
    scaleSliderCorner.CornerRadius = UDim.new(1, 0)
    scaleSliderCorner.Parent = scaleSliderBg

    local scaleSliderFill = Instance.new("Frame")
    local scaleInitialPercent = (_G.MenuScale - 27) / 36
    scaleSliderFill.Size = UDim2.new(scaleInitialPercent, 0, 1, 0)
    scaleSliderFill.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    scaleSliderFill.BorderSizePixel = 0
    scaleSliderFill.Parent = scaleSliderBg

    local scaleSliderFillCorner = Instance.new("UICorner")
    scaleSliderFillCorner.CornerRadius = UDim.new(1, 0)
    scaleSliderFillCorner.Parent = scaleSliderFill

    local scaleSliderHandle = Instance.new("Frame")
    scaleSliderHandle.Size = UDim2.new(0, 16, 0, 16)
    scaleSliderHandle.Position = UDim2.new(scaleInitialPercent, -8, 0.5, -8)
    scaleSliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    scaleSliderHandle.BorderSizePixel = 0
    scaleSliderHandle.Parent = scaleSliderBg

    local scaleSliderHandleCorner = Instance.new("UICorner")
    scaleSliderHandleCorner.CornerRadius = UDim.new(1, 0)
    scaleSliderHandleCorner.Parent = scaleSliderHandle

    local isDraggingScale = false

    local function UpdateScale(mouseX)
        local absPos = scaleSliderBg.AbsolutePosition.X
        local width = scaleSliderBg.AbsoluteSize.X
        if width <= 0 then return end
        local percent = math.clamp((mouseX - absPos) / width, 0, 1)
        local val = math.round(27 + percent * 36)
        val = math.clamp(val, 27, 63)
        local p = (val - 27) / 36
        scaleSliderFill.Size = UDim2.new(p, 0, 1, 0)
        scaleSliderHandle.Position = UDim2.new(p, -8, 0.5, -8)
        local percentDisplay = math.round((val / 45) * 100)
        scaleValue.Text = tostring(percentDisplay) .. "%"
        _G.MenuScale = val
        UpdateMenuScale()
    end

    scaleSliderHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingScale = true
            UpdateScale(input.Position.X)
        end
    end)

    scaleSliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingScale = true
            UpdateScale(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingScale = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDraggingScale and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateScale(input.Position.X)
        end
    end)

    local function UpdateScaleText()
        local lang = GetLang()
        scaleLabel.Text = lang.Toggles.Scale[1]
        scaleDesc.Text = lang.Toggles.Scale[2]
    end
    table.insert(langUpdateCallbacks, UpdateScaleText)

    -- ===== FLYING DOTS =====
    local flyingFrame = Instance.new("Frame")
    flyingFrame.Size = UDim2.new(1, 0, 1, 0)
    flyingFrame.Position = UDim2.new(0, 0, 0, 0)
    flyingFrame.BackgroundTransparency = 1
    flyingFrame.ZIndex = 100
    flyingFrame.Parent = MainFrame

    local dotContainer = Instance.new("Frame")
    dotContainer.Size = UDim2.new(1, 0, 1, 0)
    dotContainer.BackgroundTransparency = 1
    dotContainer.ClipsDescendants = true
    dotContainer.Parent = flyingFrame

    local function RebuildDots()
        for _, data in ipairs(Dots) do
            if data and data.Frame then
                data.Frame:Destroy()
            end
        end
        Dots = {}

        if not _G.FlyingDots then return end

        local scale = _G.MenuScale / 45
        local w = 640 * scale
        local h = 470 * scale
        local count = math.floor(30 + scale * 20)

        for i = 1, count do
            local dot = Instance.new("Frame")
            local size = math.random(15, 25) / 10
            dot.Size = UDim2.new(0, size, 0, size)
            dot.Position = UDim2.new(0, math.random(0, w), 0, math.random(0, h))
            dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dot.BackgroundTransparency = 0.25
            dot.BorderSizePixel = 0

            local dotCorner = Instance.new("UICorner")
            dotCorner.CornerRadius = UDim.new(1, 0)
            dotCorner.Parent = dot

            local glow = Instance.new("UIStroke")
            glow.Thickness = 0.8
            glow.Color = Color3.fromRGB(255, 255, 255)
            glow.Transparency = 0.8
            glow.Parent = dot

            dot.Parent = dotContainer
            dot.ZIndex = 101

            local speed = 0.5 + scale * 0.4
            local speedX = (math.random() - 0.5) * speed * 0.6
            local speedY = math.random() * speed * 0.5 + speed * 0.15
            local rotSpeed = (math.random() - 0.5) * 0.025

            table.insert(Dots, {
                Frame = dot,
                SpeedX = speedX,
                SpeedY = speedY,
                RotSpeed = rotSpeed,
                Angle = math.random() * math.pi * 2,
                PosX = math.random(0, w),
                PosY = math.random(0, h),
                w = w,
                h = h
            })
        end
    end

    local function UpdateDots()
        local scale = _G.MenuScale / 45
        local w = 640 * scale
        local h = 470 * scale

        for _, data in ipairs(Dots) do
            if data and data.Frame then
                data.PosX = data.PosX + data.SpeedX
                data.PosY = data.PosY + data.SpeedY
                data.Angle = data.Angle + data.RotSpeed

                if data.PosX < 0 then data.PosX = w end
                if data.PosX > w then data.PosX = 0 end
                if data.PosY > h then
                    data.PosY = 0
                    data.PosX = math.random(0, w)
                end

                data.Frame.Position = UDim2.new(0, data.PosX, 0, data.PosY)
                data.Frame.Rotation = math.deg(data.Angle)
            end
        end
    end

    local function ToggleFlyingDots(state)
        _G.FlyingDots = state
        if state then
            RebuildDots()
            if DotConnection then DotConnection:Disconnect() end
            DotConnection = RunService.Heartbeat:Connect(UpdateDots)
        else
            if DotConnection then
                DotConnection:Disconnect()
                DotConnection = nil
            end
            for _, data in ipairs(Dots) do
                if data and data.Frame then
                    data.Frame:Destroy()
                end
            end
            Dots = {}
        end
    end

    local function CheckScaleChange()
        if _G.MenuScale ~= lastScale then
            lastScale = _G.MenuScale
            if _G.FlyingDots then
                RebuildDots()
            end
        end
    end

    RunService.Heartbeat:Connect(CheckScaleChange)

    -- Чекбокс Flying Dots
    local flyingToggleFrame = Instance.new("Frame")
    flyingToggleFrame.Size = UDim2.new(1, 0, 0, 45)
    flyingToggleFrame.Position = UDim2.new(0, 0, 0, 230)
    flyingToggleFrame.BackgroundTransparency = 1
    flyingToggleFrame.Parent = settingsContainer

    local flyingLabel = Instance.new("TextLabel")
    flyingLabel.Size = UDim2.new(0.6, 0, 0, 20)
    flyingLabel.Position = UDim2.new(0, 0, 0, 0)
    flyingLabel.BackgroundTransparency = 1
    flyingLabel.Text = "Flying Dots"
    flyingLabel.TextColor3 = Color3.fromRGB(209, 213, 219)
    flyingLabel.TextSize = 13
    flyingLabel.Font = Enum.Font.GothamBold
    flyingLabel.TextXAlignment = Enum.TextXAlignment.Left
    flyingLabel.Parent = flyingToggleFrame

    local flyingDesc = Instance.new("TextLabel")
    flyingDesc.Size = UDim2.new(0.7, 0, 0, 16)
    flyingDesc.Position = UDim2.new(0, 0, 0, 22)
    flyingDesc.BackgroundTransparency = 1
    flyingDesc.Text = "Floating dots from the top of the menu"
    flyingDesc.TextColor3 = Color3.fromRGB(113, 113, 122)
    flyingDesc.TextSize = 11
    flyingDesc.Font = Enum.Font.Gotham
    flyingDesc.TextXAlignment = Enum.TextXAlignment.Left
    flyingDesc.Parent = flyingToggleFrame

    local flyingToggleBg = Instance.new("Frame")
    flyingToggleBg.Size = UDim2.new(0, 44, 0, 24)
    flyingToggleBg.Position = UDim2.new(0.88, 0, 0.1, 0)
    flyingToggleBg.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    flyingToggleBg.BorderSizePixel = 0
    flyingToggleBg.Parent = flyingToggleFrame

    local flyingToggleCorner = Instance.new("UICorner")
    flyingToggleCorner.CornerRadius = UDim.new(1, 0)
    flyingToggleCorner.Parent = flyingToggleBg

    local flyingHandle = Instance.new("Frame")
    flyingHandle.Size = UDim2.new(0, 18, 0, 18)
    flyingHandle.Position = UDim2.new(0, 3, 0.5, -9)
    flyingHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    flyingHandle.BorderSizePixel = 0
    flyingHandle.Parent = flyingToggleBg

    local flyingHandleCorner = Instance.new("UICorner")
    flyingHandleCorner.CornerRadius = UDim.new(1, 0)
    flyingHandleCorner.Parent = flyingHandle

    local flyingClickArea = Instance.new("TextButton")
    flyingClickArea.Size = UDim2.new(0, 44, 0, 24)
    flyingClickArea.Position = UDim2.new(0.88, 0, 0.1, 0)
    flyingClickArea.BackgroundTransparency = 1
    flyingClickArea.Text = ""
    flyingClickArea.ZIndex = 10
    flyingClickArea.Parent = flyingToggleFrame

    local function SetFlyingToggleState(value)
        if value then
            TweenService:Create(flyingToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(59, 130, 246)
            }):Play()
            TweenService:Create(flyingHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0, 23, 0.5, -9)
            }):Play()
        else
            TweenService:Create(flyingToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(42, 47, 58)
            }):Play()
            TweenService:Create(flyingHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0, 3, 0.5, -9)
            }):Play()
        end
        ToggleFlyingDots(value)
    end

    SetFlyingToggleState(_G.FlyingDots)

    flyingClickArea.MouseButton1Click:Connect(function()
        PlayClickSound()
        SetFlyingToggleState(not _G.FlyingDots)
    end)

    local function UpdateFlyingText()
        local lang = GetLang()
        flyingLabel.Text = lang.Toggles.FlyingDots[1]
        flyingDesc.Text = lang.Toggles.FlyingDots[2]
    end
    table.insert(langUpdateCallbacks, UpdateFlyingText)

    -- ===== RESET SETTINGS =====
    local resetFrame = Instance.new("Frame")
    resetFrame.Size = UDim2.new(1, 0, 0, 45)
    resetFrame.Position = UDim2.new(0, 0, 0, 280)
    resetFrame.BackgroundTransparency = 1
    resetFrame.Parent = settingsContainer

    local resetLabel = Instance.new("TextLabel")
    resetLabel.Size = UDim2.new(0.6, 0, 0, 20)
    resetLabel.Position = UDim2.new(0, 0, 0, 0)
    resetLabel.BackgroundTransparency = 1
    resetLabel.Text = "Reset Settings"
    resetLabel.TextColor3 = Color3.fromRGB(209, 213, 219)
    resetLabel.TextSize = 13
    resetLabel.Font = Enum.Font.GothamBold
    resetLabel.TextXAlignment = Enum.TextXAlignment.Left
    resetLabel.Parent = resetFrame

    local resetDesc = Instance.new("TextLabel")
    resetDesc.Size = UDim2.new(0.7, 0, 0, 16)
    resetDesc.Position = UDim2.new(0, 0, 0, 22)
    resetDesc.BackgroundTransparency = 1
    resetDesc.Text = "Return all settings to default"
    resetDesc.TextColor3 = Color3.fromRGB(113, 113, 122)
    resetDesc.TextSize = 11
    resetDesc.Font = Enum.Font.Gotham
    resetDesc.TextXAlignment = Enum.TextXAlignment.Left
    resetDesc.Parent = resetFrame

    local resetToggleBg = Instance.new("Frame")
    resetToggleBg.Size = UDim2.new(0, 44, 0, 24)
    resetToggleBg.Position = UDim2.new(0.88, 0, 0.1, 0)
    resetToggleBg.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    resetToggleBg.BorderSizePixel = 0
    resetToggleBg.Parent = resetFrame

    local resetToggleCorner = Instance.new("UICorner")
    resetToggleCorner.CornerRadius = UDim.new(1, 0)
    resetToggleCorner.Parent = resetToggleBg

    local resetHandle = Instance.new("Frame")
    resetHandle.Size = UDim2.new(0, 18, 0, 18)
    resetHandle.Position = UDim2.new(0, 3, 0.5, -9)
    resetHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    resetHandle.BorderSizePixel = 0
    resetHandle.Parent = resetToggleBg

    local resetHandleCorner = Instance.new("UICorner")
    resetHandleCorner.CornerRadius = UDim.new(1, 0)
    resetHandleCorner.Parent = resetHandle

    local resetClickArea = Instance.new("TextButton")
    resetClickArea.Size = UDim2.new(0, 44, 0, 24)
    resetClickArea.Position = UDim2.new(0.88, 0, 0.1, 0)
    resetClickArea.BackgroundTransparency = 1
    resetClickArea.Text = ""
    resetClickArea.ZIndex = 10
    resetClickArea.Parent = resetFrame

    local isResetOn = false

    local function UpdateResetToggle(value)
        if value then
            TweenService:Create(resetToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(59, 130, 246)
            }):Play()
            TweenService:Create(resetHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0, 23, 0.5, -9)
            }):Play()
        else
            TweenService:Create(resetToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(42, 47, 58)
            }):Play()
            TweenService:Create(resetHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0, 3, 0.5, -9)
            }):Play()
        end
        isResetOn = value
    end

    local function PerformReset()
        _G.CustomThemeEnabled = false
        _G.MenuThemeColor = Color3.fromRGB(59, 130, 246)
        _G.CurrentLang = "EN"
        _G.MenuOpacity = 12
        _G.RainbowEnabled = false
        _G.MenuScale = 45
        _G.FlyingDots = false
        
        MainFrame.BackgroundTransparency = 0.12
        MainStroke.Color = _G.MenuThemeColor
        UpdateIndicatorColor(_G.MenuThemeColor)
        
        for _, btn in ipairs(langButtons) do
            pcall(btn.Update)
        end
        
        UpdateAllTexts()
        
        if rainbowConnection then
            rainbowConnection:Disconnect()
            rainbowConnection = nil
        end
        SetRainbowToggleState(false)
        
        if DotConnection then
            DotConnection:Disconnect()
            DotConnection = nil
        end
        for _, data in ipairs(Dots) do
            if data and data.Frame then
                data.Frame:Destroy()
            end
        end
        Dots = {}
        _G.FlyingDots = false
        SetFlyingToggleState(false)
        
        UpdateMenuScale()
        
        SetToggleState(false)
        pickerContainer.Visible = false
        ShiftContainer(false)
        
        local opacityPercent = _G.MenuOpacity / 50
        opacitySliderFill.Size = UDim2.new(opacityPercent, 0, 1, 0)
        opacitySliderHandle.Position = UDim2.new(opacityPercent, -8, 0.5, -8)
        opacityValue.Text = tostring(_G.MenuOpacity) .. "%"
        
        local scalePercent = (_G.MenuScale - 27) / 36
        scaleSliderFill.Size = UDim2.new(scalePercent, 0, 1, 0)
        scaleSliderHandle.Position = UDim2.new(scalePercent, -8, 0.5, -8)
        scaleValue.Text = tostring(math.round((_G.MenuScale / 45) * 100)) .. "%"
        
        pickerDot.Position = UDim2.new(0.5, -5, 0.5, -5)
        
        print("[RESET] All settings restored to default")
        PlayClickSound()
        
        UpdateResetToggle(false)
    end

    resetClickArea.MouseButton1Click:Connect(function()
        PlayClickSound()
        if isResetOn then
            UpdateResetToggle(false)
        else
            UpdateResetToggle(true)
            PerformReset()
        end
    end)

    local function UpdateResetText()
        local lang = GetLang()
        resetLabel.Text = lang.Toggles.Reset[1]
        resetDesc.Text = lang.Toggles.Reset[2]
    end
    table.insert(langUpdateCallbacks, UpdateResetText)

    settingsPage.CanvasSize = UDim2.new(0, 0, 0, 600)
end

UpdateAllTexts()

if TabButtons[1] then
    local btn = TabButtons[1]
    btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Size = UDim2.new(0.14, 0, 0, 36)
    local firstPage = ContentPages["Aimbot"]
    if firstPage then firstPage.Visible = true end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("[META] META v7.0 - Fade in animation added")
print("[META] Press Insert to toggle menu")
]])()
