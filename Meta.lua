
--[[
    ROCKET::META_MENU_V2
    Полностью переработанный GUI для Roblox.
    Исправлены все проблемы с наложением элементов.
    Каждая вкладка — отдельный независимый контейнер.
    Переключение через строгую логику Visible.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Глобальное состояние
local CheatState = {
    Aimbot = {Enabled = false, Target = "Crosshair", FOV = 90, Smoothness = 15, Hitbox = "Head"},
    Visuals = {Box = false, Name = false, Health = false, Snaplines = false},
    Movement = {Bunnyhop = false, Autostrafe = false, WalkSpeed = 16, InfiniteJump = false},
    Radar = {Enabled = false, Scale = 1.0, TrackEnemies = true},
    Misc = {AntiAim = false, Crosshair = false, Fullbright = 0},
    Config = {Preset = "Legit Preset"}
}

-- Создание главного ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "META_MENU_V2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 640, 0, 470)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(17, 20, 26)
MainFrame.BackgroundTransparency = 0.15
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Скругление углов (12px)
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Обводка (UIStroke, толщина 2px, цвет #2a2f3a)
local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(42, 47, 58)
Stroke.Parent = MainFrame

-- ========== ХЕДЕР С СЕРОЙ ПОЛОСКОЙ ==========
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

-- Серая полоска (Frame, не заливка)
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -20, 0, 1.5)
HeaderLine.Position = UDim2.new(0, 10, 1, -1.5)
HeaderLine.BackgroundColor3 = Color3.fromRGB(80, 85, 95)
HeaderLine.BackgroundTransparency = 0.5
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "META"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 20
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0.5, 0, 1, 0)
VersionLabel.Position = UDim2.new(0.5, 0, 0, 0)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v1.1"
VersionLabel.TextColor3 = Color3.fromRGB(156, 163, 175)
VersionLabel.TextSize = 16
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
VersionLabel.TextYAlignment = Enum.TextYAlignment.Bottom
VersionLabel.Parent = Header

-- Боковая панель (30%, 192px)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0.3, 0, 1, -38)
Sidebar.Position = UDim2.new(0, 0, 0, 38)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

-- Серая полоска в сайдбаре (сверху)
local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0.8, 0, 0, 1)
SidebarLine.Position = UDim2.new(0.1, 0, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(80, 85, 95)
SidebarLine.BackgroundTransparency = 0.5
SidebarLine.BorderSizePixel = 0
SidebarLine.Parent = Sidebar

-- Контентная область (70%, 448px)
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(0.7, 0, 1, -38)
ContentContainer.Position = UDim2.new(0.3, 0, 0, 38)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ClipsDescendants = true
ContentContainer.Parent = MainFrame

-- Список вкладок
local Tabs = {"Aimbot", "Visuals", "Movement", "Radar", "Misc", "Config"}
local TabButtons = {}
local Pages = {}

-- Функция создания страницы
local function CreatePage(tabName)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 4
    page.Visible = false
    page.Parent = ContentContainer
    return page
end

-- Вспомогательные функции
local function CreateCheckbox(parent, labelText, yPos, getter, setter)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 34)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(209, 213, 219)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local checkbox = Instance.new("ImageButton")
    checkbox.Size = UDim2.new(0, 22, 0, 22)
    checkbox.Position = UDim2.new(0.88, 0, 0.15, 0)
    checkbox.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    checkbox.BorderSizePixel = 0
    checkbox.Image = "rbxassetid://0"
    checkbox.Parent = container

    local checkMark = Instance.new("ImageLabel")
    checkMark.Size = UDim2.new(0.7, 0, 0.7, 0)
    checkMark.Position = UDim2.new(0.15, 0, 0.15, 0)
    checkMark.BackgroundTransparency = 1
    checkMark.Image = "rbxassetid://6031091042"
    checkMark.ImageColor3 = Color3.fromRGB(59, 130, 246)
    checkMark.Visible = getter()
    checkMark.Parent = checkbox

    checkbox.MouseButton1Click:Connect(function()
        local newVal = not getter()
        setter(newVal)
        checkMark.Visible = newVal
        print("[META] " .. labelText .. " = " .. tostring(newVal))
    end)

    return checkbox
end

local function CreateSlider(parent, labelText, yPos, minVal, maxVal, getter, setter)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 48)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(209, 213, 219)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local valueDisplay = Instance.new("TextLabel")
    valueDisplay.Size = UDim2.new(0.3, 0, 0, 22)
    valueDisplay.Position = UDim2.new(0.7, 0, 0, 0)
    valueDisplay.BackgroundTransparency = 1
    valueDisplay.Text = tostring(getter())
    valueDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueDisplay.TextSize = 14
    valueDisplay.Font = Enum.Font.GothamBold
    valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
    valueDisplay.Parent = container

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, 0, 0, 8)
    slider.Position = UDim2.new(0, 0, 0, 30)
    slider.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    slider.BorderSizePixel = 0
    slider.Text = ""
    slider.Parent = container

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    fill.BorderSizePixel = 0
    fill.Parent = slider

    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local function updateSlider(mouseX)
        if not dragging then return end
        local absPos = slider.AbsolutePosition.X
        local width = slider.AbsoluteSize.X
        local percent = math.clamp((mouseX - absPos) / width, 0, 1)
        local val = math.round(minVal + percent * (maxVal - minVal))
        val = math.clamp(val, minVal, maxVal)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valueDisplay.Text = tostring(val)
        setter(val)
        print("[META] " .. labelText .. " = " .. tostring(val))
    end

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            updateSlider(input.Position.X)
        end
    end)

    return slider
end

local function CreateDropdown(parent, labelText, yPos, options, getter, setter)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 42)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(209, 213, 219)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(0.5, 0, 0.8, 0)
    dropdownBtn.Position = UDim2.new(0.5, 0, 0.1, 0)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    dropdownBtn.BorderSizePixel = 1
    dropdownBtn.BorderColor3 = Color3.fromRGB(42, 47, 58)
    dropdownBtn.Text = getter()
    dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownBtn.TextSize = 14
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.Parent = container

    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(0.5, 0, 0, #options * 30)
    dropdownList.Position = UDim2.new(0.5, 0, 0.9, 0)
    dropdownList.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
    dropdownList.BorderSizePixel = 1
    dropdownList.BorderColor3 = Color3.fromRGB(42, 47, 58)
    dropdownList.Visible = false
    dropdownList.ZIndex = 10
    dropdownList.Parent = container

    for i, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundTransparency = 1
        btn.Text = opt
        btn.TextColor3 = Color3.fromRGB(209, 213, 219)
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.Parent = dropdownList

        btn.MouseButton1Click:Connect(function()
            setter(opt)
            dropdownBtn.Text = opt
            dropdownList.Visible = false
            print("[META] " .. labelText .. " = " .. opt)
        end)
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
    end)

    return dropdownBtn
end

-- Создание всех страниц
local AimbotPage = CreatePage("Aimbot")
Pages.Aimbot = AimbotPage
local y = 5
CreateCheckbox(AimbotPage, "Aimbot Master", y, function() return CheatState.Aimbot.Enabled end, function(v) CheatState.Aimbot.Enabled = v end)
y = y + 40
CreateDropdown(AimbotPage, "Target Selection", y, {"Crosshair", "Distance", "Lowest HP"}, function() return CheatState.Aimbot.Target end, function(v) CheatState.Aimbot.Target = v end)
y = y + 48
CreateSlider(AimbotPage, "Field of View / FOV", y, 10, 300, function() return CheatState.Aimbot.FOV end, function(v) CheatState.Aimbot.FOV = v end)
y = y + 54
CreateSlider(AimbotPage, "Smoothness", y, 1, 30, function() return CheatState.Aimbot.Smoothness end, function(v) CheatState.Aimbot.Smoothness = v end)
y = y + 54
CreateDropdown(AimbotPage, "Hitbox", y, {"Head", "Upper Chest", "Lower Chest", "Random"}, function() return CheatState.Aimbot.Hitbox end, function(v) CheatState.Aimbot.Hitbox = v end)

local VisualsPage = CreatePage("Visuals")
Pages.Visuals = VisualsPage
y = 5
CreateCheckbox(VisualsPage, "Box ESP", y, function() return CheatState.Visuals.Box end, function(v) CheatState.Visuals.Box = v end)
y = y + 40
CreateCheckbox(VisualsPage, "Name ESP", y, function() return CheatState.Visuals.Name end, function(v) CheatState.Visuals.Name = v end)
y = y + 40
CreateCheckbox(VisualsPage, "Health Bar", y, function() return CheatState.Visuals.Health end, function(v) CheatState.Visuals.Health = v end)
y = y + 40
CreateCheckbox(VisualsPage, "Snaplines", y, function() return CheatState.Visuals.Snaplines end, function(v) CheatState.Visuals.Snaplines = v end)

local MovementPage = CreatePage("Movement")
Pages.Movement = MovementPage
y = 5
CreateCheckbox(MovementPage, "Bunnyhop", y, function() return CheatState.Movement.Bunnyhop end, function(v) CheatState.Movement.Bunnyhop = v end)
y = y + 40
CreateCheckbox(MovementPage, "Autostrafe", y, function() return CheatState.Movement.Autostrafe end, function(v) CheatState.Movement.Autostrafe = v end)
y = y + 40
CreateSlider(MovementPage, "Walk Speed", y, 16, 100, function() return CheatState.Movement.WalkSpeed end, function(v) CheatState.Movement.WalkSpeed = v end)
y = y + 54
CreateCheckbox(MovementPage, "Infinite Jump", y, function() return CheatState.Movement.InfiniteJump end, function(v) CheatState.Movement.InfiniteJump = v end)

local RadarPage = CreatePage("Radar")
Pages.Radar = RadarPage
y = 5
CreateCheckbox(RadarPage, "Radar Enabled", y, function() return CheatState.Radar.Enabled end, function(v) CheatState.Radar.Enabled = v end)
y = y + 40
CreateSlider(RadarPage, "Radar Scale", y, 0.5, 2.0, function() return CheatState.Radar.Scale end, function(v) CheatState.Radar.Scale = v end)
y = y + 54
CreateCheckbox(RadarPage, "Track Enemies Only", y, function() return CheatState.Radar.TrackEnemies end, function(v) CheatState.Radar.TrackEnemies = v end)

local MiscPage = CreatePage("Misc")
Pages.Misc = MiscPage
y = 5
CreateCheckbox(MiscPage, "Anti-Aim", y, function() return CheatState.Misc.AntiAim end, function(v) CheatState.Misc.AntiAim = v end)
y = y + 40
CreateCheckbox(MiscPage, "Crosshair", y, function() return CheatState.Misc.Crosshair end, function(v) CheatState.Misc.Crosshair = v end)
y = y + 40
CreateSlider(MiscPage, "Fullbright", y, 0, 100, function() return CheatState.Misc.Fullbright end, function(v) CheatState.Misc.Fullbright = v end)

local ConfigPage = CreatePage("Config")
Pages.Config = ConfigPage
y = 5
CreateDropdown(ConfigPage, "Preset", y, {"Legit Preset", "Rage Preset", "Semi-Rage"}, function() return CheatState.Config.Preset end, function(v) CheatState.Config.Preset = v end)

-- Создание кнопок в боковой панели
local function CreateTabButton(tabName, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 36)
    btn.Position = UDim2.new(0.1, 0, 0, 10 + (index - 1) * 44)
    btn.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
    btn.BackgroundTransparency = 0.5
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(156, 163, 175)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0, 20)
    indicator.Position = UDim2.new(0, 0, 0.5, -10)
    indicator.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    btn.MouseLeave:Connect(function()
        if not indicator.Visible then
            btn.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
            btn.TextColor3 = Color3.fromRGB(156, 163, 175)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(TabButtons) do
            local ind = b:FindFirstChild("Indicator")
            if ind then ind.Visible = false end
            b.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
            b.TextColor3 = Color3.fromRGB(156, 163, 175)
        end
        indicator.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)

        for name, page in pairs(Pages) do
            page.Visible = (name == tabName)
        end
        print("[META] Switched to: " .. tabName)
    end)

    table.insert(TabButtons, btn)
    return btn
end

for i, tabName in ipairs(Tabs) do
    CreateTabButton(tabName, i)
end

if TabButtons[1] then
    TabButtons[1].MouseButton1Click:Fire()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.F8 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("[META] Menu V2 loaded successfully!")
