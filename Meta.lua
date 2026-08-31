-- ROCKET::META_UI_V7.0.24
-- CHAMS ТОЛЬКО ДЛЯ ВРАГОВ + ВКЛЮЧЕНИЕ ПО КЛИКУ

-- Генерация случайного ключа для защиты от обнаружения по имени переменной
local UI_NAME_MASK = "RobloxGui" .. tostring(math.random(1000, 9999))

-- Проверяем доступность безопасного хранилища CoreGui
local parentFolder = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Создаем основу интерфейса под маской системного элемента
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = UI_NAME_MASK
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Защита от базовых скриптов слежки
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = parentFolder
end

-- ===== ОСНОВНОЕ МЕНЮ =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

_G.CustomThemeEnabled = false
_G.MenuThemeColor = Color3.fromRGB(59, 130, 246)
_G.CurrentLang = "EN"
_G.MenuOpacity = 12
_G.RainbowEnabled = false
_G.MenuScale = 45
_G.FlyingDots = false
_G.ChamsEnabled = false

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
            Scale = {"Масштабирование меню", "Масштабирование меню (60-140%)"},
            FlyingDots = {"Летающие точки", "Точки, летающие с верха меню"},
            Chams = {"Chams", "Подсветка врагов"},
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
            Chams = {"Chams", "Highlight enemies"},
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

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local MetaLabel = Instance.new("TextLabel")
MetaLabel.Size = UDim2.new(0.1, 0, 1, 0)
MetaLabel.Position = UDim2.new(0, 15, 0, 0)
MetaLabel.BackgroundTransparency = 1
MetaLabel.Text = "META"
MetaLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MetaLabel.TextSize = 20
MetaLabel.Font = Enum.Font.GothamBold
MetaLabel.TextXAlignment = Enum.TextXAlignment.Left
MetaLabel.TextYAlignment = Enum.TextYAlignment.Center
MetaLabel.Parent = Header

local GameNameLabel = Instance.new("TextLabel")
GameNameLabel.Size = UDim2.new(0.35, 0, 1, 0)
GameNameLabel.Position = UDim2.new(0.32, 0, 0, 0)
GameNameLabel.BackgroundTransparency = 1
GameNameLabel.Text = "Loading..."
GameNameLabel.TextColor3 = Color3.fromRGB(156, 163, 175)
GameNameLabel.TextSize = 13
GameNameLabel.Font = Enum.Font.Gotham
GameNameLabel.TextXAlignment = Enum.TextXAlignment.Left
GameNameLabel.TextYAlignment = Enum.TextYAlignment.Center
GameNameLabel.Parent = Header

pcall(function()
    local MarketplaceService = game:GetService("MarketplaceService")
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    if info and info.Name then
        GameNameLabel.Text = info.Name
    else
        GameNameLabel.Text = "Unknown Game"
    end
end)

-- ===== ПОИСК =====
local SearchContainer = Instance.new("Frame")
SearchContainer.Size = UDim2.new(0.3, 0, 0.7, 0)
SearchContainer.Position = UDim2.new(0.68, 0, 0.15, 0)
SearchContainer.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
SearchContainer.BackgroundTransparency = 0.5
SearchContainer.BorderSizePixel = 0
SearchContainer.Parent = Header

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 6)
SearchCorner.Parent = SearchContainer

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Thickness = 1
SearchStroke.Color = _G.MenuThemeColor
SearchStroke.Transparency = 0.6
SearchStroke.Parent = SearchContainer

local SearchInput = Instance.new("TextBox")
SearchInput.Size = UDim2.new(1, -12, 1, 0)
SearchInput.Position = UDim2.new(0, 8, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.Text = "Search..."
SearchInput.TextColor3 = Color3.fromRGB(209, 213, 219)
SearchInput.TextSize = 13
SearchInput.Font = Enum.Font.Gotham
SearchInput.TextXAlignment = Enum.TextXAlignment.Left
SearchInput.TextYAlignment = Enum.TextYAlignment.Center
SearchInput.ClearTextOnFocus = false
SearchInput.Parent = SearchContainer

local SearchClose = Instance.new("TextButton")
SearchClose.Size = UDim2.new(0, 16, 1, 0)
SearchClose.Position = UDim2.new(1, -20, 0, 0)
SearchClose.BackgroundTransparency = 1
SearchClose.Text = "✕"
SearchClose.TextColor3 = Color3.fromRGB(156, 163, 175)
SearchClose.TextSize = 11
SearchClose.Font = Enum.Font.Gotham
SearchClose.TextXAlignment = Enum.TextXAlignment.Center
SearchClose.TextYAlignment = Enum.TextYAlignment.Center
SearchClose.Visible = false
SearchClose.Parent = SearchContainer

SearchClose.MouseButton1Click:Connect(function()
    SearchInput.Text = "Search..."
    SearchClose.Visible = false
    PlayClickSound()
end)

SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    if SearchInput.Text ~= "" and SearchInput.Text ~= "Search..." then
        SearchClose.Visible = true
    else
        SearchClose.Visible = false
    end
end)

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
local langButtonData = {}

-- ===== CHAMS (ТОЛЬКО ВРАГИ, ВКЛЮЧАЕТСЯ ПО КЛИКУ) =====
local ChamsConnections = {}
local ChamsTag = "EnemyHighlight_" .. tostring(math.random(1000, 9999))

local function GetPlayerTeam(player)
    if player.Team then
        if type(player.Team) == "string" then
            return player.Team
        elseif type(player.Team) == "Instance" and player.Team.Name then
            return player.Team.Name
        else
            return tostring(player.Team)
        end
    end
    
    if player:FindFirstChild("TeamName") then
        return player.TeamName.Value
    end
    
    if player.TeamColor then
        return tostring(player.TeamColor)
    end
    
    local char = player.Character
    if char then
        local teamObj = char:FindFirstChild("Team")
        if teamObj then
            return teamObj.Value or teamObj.Name
        end
    end
    
    return nil
end

local function IsEnemy(player)
    local myTeam = GetPlayerTeam(LocalPlayer)
    local theirTeam = GetPlayerTeam(player)
    
    if not myTeam or not theirTeam then
        return false
    end
    
    return myTeam ~= theirTeam
end

local function PaintCharacter(character, player)
    if not character then return end
    
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Highlight") and child.Name == ChamsTag then
            child:Destroy()
        end
    end
    
    if _G.ChamsEnabled and IsEnemy(player) then
        local highlight = Instance.new("Highlight")
        highlight.Name = ChamsTag
        highlight.FillColor = Color3.fromRGB(180, 40, 40)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0.1
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = character
        highlight.Parent = character
    end
end

local function SetupPlayer(player)
    if player == LocalPlayer then return end
    
    if ChamsConnections[player] then
        if ChamsConnections[player].CharacterAdded then
            ChamsConnections[player].CharacterAdded:Disconnect()
        end
        if ChamsConnections[player].TeamChanged then
            ChamsConnections[player].TeamChanged:Disconnect()
        end
    end
    
    ChamsConnections[player] = {}
    
    ChamsConnections[player].CharacterAdded = player.CharacterAdded:Connect(function(character)
        task.wait(0.1)
        PaintCharacter(character, player)
    end)
    
    ChamsConnections[player].TeamChanged = player:GetPropertyChangedSignal("Team"):Connect(function()
        if player.Character then
            PaintCharacter(player.Character, player)
        end
    end)
    
    if player.Character then
        PaintCharacter(player.Character, player)
    end
end

local function ApplyChams()
    if _G.UnloadChams then _G.UnloadChams() end
    _G.ChamsEnabled = true
    
    for _, player in ipairs(Players:GetPlayers()) do
        SetupPlayer(player)
    end
    
    ChamsConnections.PlayerAdded = Players.PlayerAdded:Connect(SetupPlayer)
    
    ChamsConnections.LocalTeamChanged = LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                PaintCharacter(player.Character, player)
            end
        end
    end)
    
    _G.UnloadChams = function()
        if ChamsConnections.PlayerAdded then
            ChamsConnections.PlayerAdded:Disconnect()
        end
        if ChamsConnections.LocalTeamChanged then
            ChamsConnections.LocalTeamChanged:Disconnect()
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if ChamsConnections[player] then
                if ChamsConnections[player].CharacterAdded then
                    ChamsConnections[player].CharacterAdded:Disconnect()
                end
                if ChamsConnections[player].TeamChanged then
                    ChamsConnections[player].TeamChanged:Disconnect()
                end
            end
            if player.Character then
                for _, child in ipairs(player.Character:GetChildren()) do
                    if child:IsA("Highlight") and child.Name == ChamsTag then
                        child:Destroy()
                    end
                end
            end
        end
        _G.UnloadChams = nil
        _G.ChamsEnabled = false
    end
end

local function RemoveChams()
    if _G.UnloadChams then
        _G.UnloadChams()
    end
end

-- ===== ИНДИКАТОР =====
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

-- ===== ФУНКЦИЯ ПОДСВЕТКИ =====
local function HighlightElement(element)
    if not element then return end
    
    local highlight = Instance.new("Frame")
    highlight.Size = UDim2.new(1, 10, 1, 6)
    highlight.Position = UDim2.new(0, -5, 0, -3)
    highlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    highlight.BackgroundTransparency = 0.85
    highlight.BorderSizePixel = 0
    highlight.ZIndex = 999
    highlight.Parent = element
    
    local highlightCorner = Instance.new("UICorner")
    highlightCorner.CornerRadius = UDim.new(0, 4)
    highlightCorner.Parent = highlight
    
    highlight.BackgroundTransparency = 1
    TweenService:Create(highlight, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.85
    }):Play()
    
    task.wait(1)
    TweenService:Create(highlight, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.15)
    highlight:Destroy()
end

-- ===== ПОИСК =====
local function SearchInMenu(query)
    query = string.lower(query)
    if not ContentPages then return end
    
    local foundElements = {}
    local foundTabName = nil
    
    for tabName, page in pairs(ContentPages) do
        if page then
            local function scanChildren(parent)
                for _, child in ipairs(parent:GetChildren()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        local text = string.lower(child.Text)
                        if string.find(text, query) then
                            table.insert(foundElements, {element = child, tab = tabName})
                            if not foundTabName then
                                foundTabName = tabName
                            end
                        end
                    end
                    if child:IsA("Frame") then
                        scanChildren(child)
                    end
                end
            end
            scanChildren(page)
        end
    end
    
    if #foundElements > 0 and foundTabName then
        for i, btn in ipairs(TabButtons) do
            if btn.Text == foundTabName then
                for _, b in ipairs(TabButtons) do
                    b.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
                    b.BackgroundTransparency = 0.2
                    b.TextColor3 = Color3.fromRGB(156, 163, 175)
                    TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0.12, 0, 0, 32)
                    }):Play()
                end
                
                btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
                btn.BackgroundTransparency = 0
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0.14, 0, 0, 36)
                }):Play()
                
                for _, page in pairs(ContentPages) do
                    page.Visible = false
                end
                local targetPage = ContentPages[foundTabName]
                if targetPage then targetPage.Visible = true end
                activeIndex = i
                
                UpdateIndicatorPosition(i)
                break
            end
        end
        
        for _, data in ipairs(foundElements) do
            HighlightElement(data.element)
        end
    end
end

SearchInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and SearchInput.Text ~= "" and SearchInput.Text ~= "Search..." then
        SearchInMenu(SearchInput.Text)
        PlayClickSound()
        SearchInput.Text = "Search..."
    end
end)

SearchInput.Focused:Connect(function()
    if SearchInput.Text == "Search..." then
        SearchInput.Text = ""
    end
    PlayClickSound()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        SearchInput:CaptureFocus()
        SearchInput.Text = ""
        PlayClickSound()
    end
    if input.KeyCode == Enum.KeyCode.Escape then
        if SearchInput:IsFocused() then
            SearchInput.Text = "Search..."
            SearchInput:ReleaseFocus()
            PlayClickSound()
        end
    end
end)

-- ===== СОЗДАНИЕ ВКЛАДОК =====
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

local function SwitchToTab(tabName)
    for i, btn in ipairs(TabButtons) do
        if btn.Text == tabName then
            for _, b in ipairs(TabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
                b.BackgroundTransparency = 0.2
                b.TextColor3 = Color3.fromRGB(156, 163, 175)
                TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0.12, 0, 0, 32)
                }):Play()
            end
            
            btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
            btn.BackgroundTransparency = 0
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0.14, 0, 0, 36)
            }):Play()
            
            for _, page in pairs(ContentPages) do
                page.Visible = false
            end
            local targetPage = ContentPages[tabName]
            if targetPage then targetPage.Visible = true end
            activeIndex = i
            
            UpdateIndicatorPosition(i)
            break
        end
    end
end

for i, name in ipairs(TabNames) do
    local btn = Instance.new("TextButton")
    local width = 0.12
    btn.Size = UDim2.new(width, 0, 0, 32)
    btn.Position = UDim2.new(0.02 + (i-1) * (width + 0.03), 0, 0.15, 0)
    btn.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
    btn.BackgroundTransparency = 0.2
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
        btn.BackgroundTransparency = 0
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Size = UDim2.new(width + 0.02, 0, 0, 36)
    end

    btn.MouseEnter:Connect(function()
        if activeIndex ~= i then
            btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
            btn.BackgroundTransparency = 0.1
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)

    btn.MouseLeave:Connect(function()
        if activeIndex ~= i then
            btn.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
            btn.BackgroundTransparency = 0.2
            btn.TextColor3 = Color3.fromRGB(156, 163, 175)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        PlayTabSound()
        SwitchToTab(name)
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
    visualsPage.CanvasSize = UDim2.new(0, 0, 0, 200)
    
    local visualsContainer = Instance.new("Frame")
    visualsContainer.Size = UDim2.new(1, 0, 0, 500)
    visualsContainer.Position = UDim2.new(0, 0, 0, 55)
    visualsContainer.BackgroundTransparency = 1
    visualsContainer.ClipsDescendants = true
    visualsContainer.Parent = visualsPage
    
    -- ===== CHAMS (ВИЗУАЛЬНЫЙ ТОГГЛ) =====
    local chamsFrame = Instance.new("Frame")
    chamsFrame.Size = UDim2.new(1, 0, 0, 45)
    chamsFrame.Position = UDim2.new(0, 0, 0, 10)
    chamsFrame.BackgroundTransparency = 1
    chamsFrame.Parent = visualsPage
    
    local chamsLabel = Instance.new("TextLabel")
    chamsLabel.Size = UDim2.new(0.6, 0, 0, 20)
    chamsLabel.Position = UDim2.new(0, 0, 0, 0)
    chamsLabel.BackgroundTransparency = 1
    chamsLabel.Text = "Chams"
    chamsLabel.TextColor3 = Color3.fromRGB(209, 213, 219)
    chamsLabel.TextSize = 13
    chamsLabel.Font = Enum.Font.GothamBold
    chamsLabel.TextXAlignment = Enum.TextXAlignment.Left
    chamsLabel.Parent = chamsFrame
    
    local chamsDesc = Instance.new("TextLabel")
    chamsDesc.Size = UDim2.new(0.7, 0, 0, 16)
    chamsDesc.Position = UDim2.new(0, 0, 0, 22)
    chamsDesc.BackgroundTransparency = 1
    chamsDesc.Text = "Highlight enemies"
    chamsDesc.TextColor3 = Color3.fromRGB(113, 113, 122)
    chamsDesc.TextSize = 11
    chamsDesc.Font = Enum.Font.Gotham
    chamsDesc.TextXAlignment = Enum.TextXAlignment.Left
    chamsDesc.Parent = chamsFrame
    
    local chamsToggleBg = Instance.new("Frame")
    chamsToggleBg.Size = UDim2.new(0, 44, 0, 24)
    chamsToggleBg.Position = UDim2.new(0.88, 0, 0.1, 0)
    chamsToggleBg.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    chamsToggleBg.BorderSizePixel = 0
    chamsToggleBg.Parent = chamsFrame
    
    local chamsToggleCorner = Instance.new("UICorner")
    chamsToggleCorner.CornerRadius = UDim.new(1, 0)
    chamsToggleCorner.Parent = chamsToggleBg
    
    local chamsHandle = Instance.new("Frame")
    chamsHandle.Size = UDim2.new(0, 18, 0, 18)
    chamsHandle.Position = UDim2.new(0, 3, 0.5, -9)
    chamsHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    chamsHandle.BorderSizePixel = 0
    chamsHandle.Parent = chamsToggleBg
    
    local chamsHandleCorner = Instance.new("UICorner")
    chamsHandleCorner.CornerRadius = UDim.new(1, 0)
    chamsHandleCorner.Parent = chamsHandle
    
    local chamsClickArea = Instance.new("TextButton")
    chamsClickArea.Size = UDim2.new(0, 44, 0, 24)
    chamsClickArea.Position = UDim2.new(0.88, 0, 0.1, 0)
    chamsClickArea.BackgroundTransparency = 1
    chamsClickArea.Text = ""
    chamsClickArea.ZIndex = 10
    chamsClickArea.Parent = chamsFrame
    
    local function SetChamsToggleState(value)
        if value then
            TweenService:Create(chamsToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(59, 130, 246)
            }):Play()
            TweenService:Create(chamsHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0, 23, 0.5, -9)
            }):Play()
            ApplyChams()
        else
            TweenService:Create(chamsToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(42, 47, 58)
            }):Play()
            TweenService:Create(chamsHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0, 3, 0.5, -9)
            }):Play()
            RemoveChams()
        end
        _G.ChamsEnabled = value
    end
    
    SetChamsToggleState(_G.ChamsEnabled)
    
    chamsClickArea.MouseButton1Click:Connect(function()
        PlayClickSound()
        SetChamsToggleState(not _G.ChamsEnabled)
    end)
    
    local function UpdateChamsText()
        local lang = GetLang()
        chamsLabel.Text = lang.Toggles.Chams[1]
        chamsDesc.Text = lang.Toggles.Chams[2]
    end
    table.insert(langUpdateCallbacks, UpdateChamsText)
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

    -- ===== UI Color =====
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
            SearchStroke.Color = pickedColor
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
            SearchStroke.Color = _G.MenuThemeColor
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

    -- ===== ЯЗЫКОВЫЕ ПАНЕЛИ =====
    local langFrame = Instance.new("Frame")
    langFrame.Size = UDim2.new(1, -20, 0, 42)
    langFrame.Position = UDim2.new(0, 10, 0, 10)
    langFrame.BackgroundTransparency = 1
    langFrame.Parent = settingsContainer

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

        local uiScale = Instance.new("UIScale")
        uiScale.Scale = 1
        uiScale.Parent = bg

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

        local function UpdateLangButton(animate)
            local isActive = (_G.CurrentLang == langCode)
            local targetScale = isActive and 1.1 or 1
            local targetBg = isActive and Color3.fromRGB(35, 40, 50) or Color3.fromRGB(26, 30, 38)
            local targetTransp = isActive and 0 or 0.5
            local targetTextColor = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(156, 163, 175)
            
            if animate then
                TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Scale = targetScale
                }):Play()
                TweenService:Create(bg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = targetBg,
                    BackgroundTransparency = targetTransp
                }):Play()
                TweenService:Create(txt, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    TextColor3 = targetTextColor
                }):Play()
            else
                uiScale.Scale = targetScale
                bg.BackgroundColor3 = targetBg
                bg.BackgroundTransparency = targetTransp
                txt.TextColor3 = targetTextColor
            end
        end

        UpdateLangButton(false)

        clickBtn.MouseButton1Click:Connect(function()
            PlayClickSound()
            if _G.CurrentLang == langCode then return end
            _G.CurrentLang = langCode
            for _, btn in ipairs(langButtonData) do
                pcall(btn.Update, true)
            end
            UpdateAllTexts()
        end)

        local btnData = {Update = UpdateLangButton}
        table.insert(langButtonData, btnData)
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
                SearchStroke.Color = color
            end)
        else
            if rainbowConnection then
                rainbowConnection:Disconnect()
                rainbowConnection = nil
                MainStroke.Color = _G.MenuThemeColor
                UpdateIndicatorColor(_G.MenuThemeColor)
                SearchStroke.Color = _G.MenuThemeColor
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
        _G.ChamsEnabled = false
        
        MainFrame.BackgroundTransparency = 0.12
        MainStroke.Color = _G.MenuThemeColor
        UpdateIndicatorColor(_G.MenuThemeColor)
        SearchStroke.Color = _G.MenuThemeColor
        
        RemoveChams()
        SetChamsToggleState(false)
        
        for _, btn in ipairs(langButtonData) do
            pcall(btn.Update, false)
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
    btn.BackgroundTransparency = 0
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Size = UDim2.new(0.14, 0, 0, 36)
    local firstPage = ContentPages["Aimbot"]
    if firstPage then firstPage.Visible = true end
end

-- ===== ВКЛЮЧЕНИЕ/ВЫКЛЮЧЕНИЕ ПО INSERT =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Чистка при выгрузке (без автоматического удаления)
-- Удаляем только если скрипт явно выгружен
local function Cleanup()
    RemoveChams()
    ScreenGui:Destroy()
end

-- Если скрипт будет перезагружен, чистим старые объекты
game:GetService("RunService").Heartbeat:Connect(function()
    -- Проверяем, существует ли ещё MainFrame (если нет — значит меню уничтожено)
    if not MainFrame or not MainFrame.Parent then
        Cleanup()
    end
end)
