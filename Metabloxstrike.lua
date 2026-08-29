local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

_G.AimbotEnabled = false
_G.AimbotFOV = 100
_G.TargetBone = "Head"
_G.BoxESP = false
_G.Snaplines = false
_G.EspNames = false

local ESP_Cache = {Boxes = {}, Lines = {}, Texts = {}, FOVCircle = nil}

local function SafeRemove(obj)
    if obj then pcall(function() obj:Remove() end) end
end

ESP_Cache.FOVCircle = Drawing.new("Circle")
ESP_Cache.FOVCircle.Visible = false
ESP_Cache.FOVCircle.Color = Color3.fromRGB(0, 150, 255)
ESP_Cache.FOVCircle.Thickness = 1
ESP_Cache.FOVCircle.Transparency = 0.6
ESP_Cache.FOVCircle.NumSides = 64
ESP_Cache.FOVCircle.Filled = false

local function InitPlayerESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(0, 255, 0)
    box.Thickness = 1.5
    box.Transparency = 0.8
    ESP_Cache.Boxes[player] = box
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.fromRGB(255, 0, 0)
    line.Thickness = 1.5
    line.Transparency = 0.7
    ESP_Cache.Lines[player] = line
    local text = Drawing.new("Text")
    text.Visible = false
    text.Color = Color3.fromRGB(255, 255, 255)
    text.Size = 14
    text.Font = 3
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.fromRGB(0, 0, 0)
    ESP_Cache.Texts[player] = text
end

local function RemovePlayerESP(player)
    if player == LocalPlayer then return end
    SafeRemove(ESP_Cache.Boxes[player])
    SafeRemove(ESP_Cache.Lines[player])
    SafeRemove(ESP_Cache.Texts[player])
    ESP_Cache.Boxes[player] = nil
    ESP_Cache.Lines[player] = nil
    ESP_Cache.Texts[player] = nil
end

for _, player in ipairs(Players:GetPlayers()) do InitPlayerESP(player) end
Players.PlayerAdded:Connect(InitPlayerESP)
Players.PlayerRemoving:Connect(RemovePlayerESP)

RunService.RenderStepped:Connect(function()
    local viewportSize = Camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    if _G.AimbotEnabled and ESP_Cache.FOVCircle then
        ESP_Cache.FOVCircle.Visible = true
        ESP_Cache.FOVCircle.Position = screenCenter
        ESP_Cache.FOVCircle.Radius = _G.AimbotFOV
    elseif ESP_Cache.FOVCircle then
        ESP_Cache.FOVCircle.Visible = false
    end
    if not LocalPlayer.Character then return end
    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    local players = Players:GetPlayers()
    for _, player in ipairs(players) do
        if player == LocalPlayer then continue end
        local box = ESP_Cache.Boxes[player]
        local line = ESP_Cache.Lines[player]
        local text = ESP_Cache.Texts[player]
        if not box or not line or not text then continue end
        if not player.Character then
            box.Visible = false
            line.Visible = false
            text.Visible = false
            continue
        end
        local char = player.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            box.Visible = false
            line.Visible = false
            text.Visible = false
            continue
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            box.Visible = false
            line.Visible = false
            text.Visible = false
            continue
        end
        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if _G.BoxESP and onScreen then
            local size = 3
            local extents = char:GetExtentsSize()
            if extents and extents.Magnitude > 0 then size = extents.X / 2 end
            local topPos = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, size, 0))
            local bottomPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, size, 0))
            local height = math.abs(bottomPos.Y - topPos.Y) * 2.5
            local width = height / 1.5
            local centerX = pos.X
            local topY = topPos.Y - (height - (bottomPos.Y - topPos.Y)) / 2
            box.Visible = true
            box.Size = Vector2.new(width, height)
            box.Position = Vector2.new(centerX - width/2, topY)
        else
            box.Visible = false
        end
        if _G.Snaplines and onScreen then
            line.Visible = true
            line.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
            line.To = Vector2.new(pos.X, pos.Y)
        else
            line.Visible = false
        end
        if _G.EspNames and onScreen then
            local dist = (hrp.Position - localRoot.Position).Magnitude
            text.Visible = true
            text.Position = Vector2.new(pos.X, pos.Y - 30)
            text.Text = string.format("%s [%.0fm]", player.Name, dist / 10)
        else
            text.Visible = false
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "META_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 640, 0, 470)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(17, 20, 26)
MainFrame.BackgroundTransparency = 0.12
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(42, 47, 58)
MainStroke.Transparency = 0.4
MainStroke.Parent = MainFrame

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
Version.Text = "v3.0"
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

local TabNames = {"Aimbot", "Visuals"}
local TabButtons = {}
local ContentPages = {}

local function ResetTabs()
    for _, btn in ipairs(TabButtons) do
        local ind = btn:FindFirstChild("Indicator")
        if ind then ind.Visible = false end
        btn.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
        btn.TextColor3 = Color3.fromRGB(156, 163, 175)
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0.15, 0, 0, 32)
        }):Play()
    end
end

for i, name in ipairs(TabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.15, 0, 0, 32)
    btn.Position = UDim2.new(0.02 + (i - 1) * 0.17, 0, 0.15, 0)
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
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0.8, 0, 0, 2)
    indicator.Position = UDim2.new(0.1, 0, 1, -2)
    indicator.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = btn
    btn.MouseEnter:Connect(function()
        if not indicator.Visible then
            btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
    btn.MouseLeave:Connect(function()
        if not indicator.Visible then
            btn.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
            btn.TextColor3 = Color3.fromRGB(156, 163, 175)
        end
    end)
    btn.MouseButton1Click:Connect(function()
        ResetTabs()
        indicator.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0.17, 0, 0, 36)
        }):Play()
        for _, page in pairs(ContentPages) do page.Visible = false end
        local targetPage = ContentPages[name]
        if targetPage then targetPage.Visible = true end
        print(string.format("[META] Switched to: %s", name))
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
    page.Visible = false
    page.ZIndex = 5
    page.Parent = MainFrame
    ContentPages[name] = page
end

local function CreateToggle(parent, yPos, labelText, getter, setter, description)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(209, 213, 219)
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    if description then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(0.7, 0, 0, 16)
        desc.Position = UDim2.new(0, 0, 0, 22)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Color3.fromRGB(113, 113, 122)
        desc.TextSize = 11
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = frame
    end
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 44, 0, 24)
    toggle.Position = UDim2.new(0.88, 0, 0.05, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.Parent = frame
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    local function UpdateToggle(value)
        if value then toggle.BackgroundColor3 = Color3.fromRGB(59, 130, 246) else toggle.BackgroundColor3 = Color3.fromRGB(42, 47, 58) end
    end
    UpdateToggle(getter())
    toggle.MouseButton1Click:Connect(function()
        local newVal = not getter()
        setter(newVal)
        UpdateToggle(newVal)
        print(string.format("[DEBUG] %s = %s", labelText, tostring(newVal)))
    end)
    return toggle
end

local function CreateSlider(parent, yPos, labelText, minVal, maxVal, getter, setter, description)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 58)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(209, 213, 219)
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    if description then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(0.5, 0, 0, 16)
        desc.Position = UDim2.new(0, 0, 0, 22)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Color3.fromRGB(113, 113, 122)
        desc.TextSize = 11
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = frame
    end
    local valueDisplay = Instance.new("TextLabel")
    valueDisplay.Size = UDim2.new(0.15, 0, 0, 20)
    valueDisplay.Position = UDim2.new(0.85, 0, 0, 0)
    valueDisplay.BackgroundTransparency = 1
    valueDisplay.Text = tostring(getter())
    valueDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueDisplay.TextSize = 14
    valueDisplay.Font = Enum.Font.GothamBold
    valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
    valueDisplay.Parent = frame
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.5, 0, 0, 6)
    sliderFrame.Position = UDim2.new(0, 0, 0, 38)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = frame
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderFrame
    local fill = Instance.new("Frame")
    local initialPercent = (getter() - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(initialPercent, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    local function UpdateSlider(mouseX)
        local absPos = sliderFrame.AbsolutePosition.X
        local width = sliderFrame.AbsoluteSize.X
        if width <= 0 then return end
        local percent = math.clamp((mouseX - absPos) / width, 0, 1)
        local val = math.round(minVal + percent * (maxVal - minVal))
        val = math.clamp(val, minVal, maxVal)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valueDisplay.Text = tostring(val)
        setter(val)
        print(string.format("[DEBUG] %s = %d", labelText, val))
    end
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            UpdateSlider(input.Position.X)
        end
    end)
    sliderFrame.MouseButton1Click:Connect(function()
        UpdateSlider(Mouse.X)
    end)
    return sliderFrame
end

local function CreateDropdown(parent, yPos, labelText, options, getter, setter, description)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 56)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(209, 213, 219)
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    if description then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(0.4, 0, 0, 16)
        desc.Position = UDim2.new(0, 0, 0, 22)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Color3.fromRGB(113, 113, 122)
        desc.TextSize = 11
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = frame
    end
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.4, 0, 0.6, 0)
    dropdown.Position = UDim2.new(0.55, 0, 0.05, 0)
    dropdown.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    dropdown.BorderSizePixel = 0
    dropdown.Text = getter()
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.TextSize = 13
    dropdown.Font = Enum.Font.Gotham
    dropdown.Parent = frame
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 4)
    dropdownCorner.Parent = dropdown
    local list = Instance.new("Frame")
    list.Size = UDim2.new(0.4, 0, 0, #options * 28)
    list.Position = UDim2.new(0.55, 0, 0.7, 0)
    list.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
    list.BorderSizePixel = 0
    list.Visible = false
    list.ZIndex = 10
    list.Parent = frame
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 4)
    listCorner.Parent = list
    for _, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.BackgroundTransparency = 1
        btn.Text = opt
        btn.TextColor3 = Color3.fromRGB(209, 213, 219)
        btn.TextSize = 13
        btn.Font = Enum.Font.Gotham
        btn.Parent = list
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(20, 23, 30) end)
        btn.MouseButton1Click:Connect(function()
            setter(opt)
            dropdown.Text = opt
            list.Visible = false
            print(string.format("[DEBUG] %s = %s", labelText, opt))
        end)
    end
    dropdown.MouseButton1Click:Connect(function() list.Visible = not list.Visible end)
    return dropdown
end

local aimbotPage = ContentPages["Aimbot"]
if aimbotPage then
    local y = 10
    CreateToggle(aimbotPage, y, "Aimbot Master",
        function() return _G.AimbotEnabled end,
        function(v) _G.AimbotEnabled = v print(string.format("[DEBUG] Aimbot: %s", tostring(v))) end,
        "Включить систему автоматического наведения"
    )
    y = y + 52
    CreateDropdown(aimbotPage, y, "Target Bone",
        {"Head", "Torso", "HumanoidRootPart"},
        function() return _G.TargetBone end,
        function(v) _G.TargetBone = v print(string.format("[DEBUG] Target Bone: %s", v)) end,
        "Выбор части тела для прицеливания"
    )
    y = y + 60
    CreateSlider(aimbotPage, y, "FOV Radius", 10, 300,
        function() return _G.AimbotFOV end,
        function(v) _G.AimbotFOV = v print(string.format("[DEBUG] Aimbot FOV: %d", v)) end,
        "Радиус зоны действия в пикселях"
    )
    y = y + 62
    aimbotPage.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

local visualsPage = ContentPages["Visuals"]
if visualsPage then
    local y = 10
    CreateToggle(visualsPage, y, "2D Box ESP",
        function() return _G.BoxESP end,
        function(v) _G.BoxESP = v print(string.format("[DEBUG] BoxESP: %s", tostring(v))) end,
        "Зеленые прямоугольники вокруг игроков"
    )
    y = y + 52
    CreateToggle(visualsPage, y, "Snaplines",
        function() return _G.Snaplines end,
        function(v) _G.Snaplines = v print(string.format("[DEBUG] Snaplines: %s", tostring(v))) end,
        "Линии от центра экрана к цели"
    )
    y = y + 52
    CreateToggle(visualsPage, y, "Name & Distance",
        function() return _G.EspNames end,
        function(v) _G.EspNames = v print(string.format("[DEBUG] EspNames: %s", tostring(v))) end,
        "Отображение имени и дистанции"
    )
    y = y + 52
    visualsPage.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

if TabButtons[1] then TabButtons[1].MouseButton1Click:Fire() end

-- ======================================================
-- АВТОМАТИЧЕСКОЕ ОТКРЫТИЕ МЕНЮ ПРИ ЗАПУСКЕ
-- ======================================================
MainFrame.Visible = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        _G.AimbotEnabled = not _G.AimbotEnabled
        print(string.format("[DEBUG] Aimbot: %s", tostring(_G.AimbotEnabled)))
    elseif input.KeyCode == Enum.KeyCode.F2 then
        _G.BoxESP = not _G.BoxESP
        print(string.format("[DEBUG] BoxESP: %s", tostring(_G.BoxESP)))
    elseif input.KeyCode == Enum.KeyCode.F3 then
        _G.Snaplines = not _G.Snaplines
        print(string.format("[DEBUG] Snaplines: %s", tostring(_G.Snaplines)))
    elseif input.KeyCode == Enum.KeyCode.F4 then
        _G.EspNames = not _G.EspNames
        print(string.format("[DEBUG] EspNames: %s", tostring(_G.EspNames)))
    end
end)

print("[META] META v3.0 loaded successfully!")
print("[META] Menu opened automatically!")
print("[META] Press Insert to toggle menu")
print("[META] F1 - Aimbot, F2 - BoxESP, F3 - Snaplines, F4 - NameESP")
print("[META] Current State: Aimbot=" .. tostring(_G.AimbotEnabled) .. ", BoxESP=" .. tostring(_G.BoxESP) .. ", Snaplines=" .. tostring(_G.Snaplines) .. ", EspNames=" .. tostring(_G.EspNames))
]])
