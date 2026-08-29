local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ======================================================
-- ГЛОБАЛЬНЫЕ СОСТОЯНИЯ
-- ======================================================
_G.AimbotEnabled = false
_G.AimbotFOV = 150
_G.TargetBone = "Head"
_G.BoxESP = false
_G.Snaplines = false
_G.EspNames = false

local MenuVisible = true
local FOVCircle = nil

-- ======================================================
-- СОЗДАНИЕ FOV КРУГА
-- ======================================================
FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(0, 150, 255)
FOVCircle.Thickness = 1.5
FOVCircle.Transparency = 0.5
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Radius = _G.AimbotFOV

-- ======================================================
-- СОЗДАНИЕ GUI
-- ======================================================
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
MainFrame.Visible = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(42, 47, 58)
MainStroke.Transparency = 0.4
MainStroke.Parent = MainFrame

-- ========== ТОП ХЕДЕР ==========
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

-- ========== ВКЛАДКИ ==========
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
        if ind then
            ind.Visible = false
        end
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
        
        for _, page in pairs(ContentPages) do
            page.Visible = false
        end
        
        local targetPage = ContentPages[name]
        if targetPage then
            targetPage.Visible = true
        end
        
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

-- ======================================================
-- СОЗДАНИЕ КОНТРОЛОВ
-- ======================================================
local function CreateToggle(parent, labelText, description, globalVar, yPos)
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
    
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Size = UDim2.new(0, 44, 0, 24)
    toggleContainer.Position = UDim2.new(0.88, 0, 0.05, 0)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = frame
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(1, 0, 1, 0)
    toggleBg.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = toggleContainer
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg
    
    local toggleHandle = Instance.new("Frame")
    toggleHandle.Size = UDim2.new(0, 18, 0, 18)
    toggleHandle.Position = UDim2.new(0, 3, 0.5, -9)
    toggleHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleHandle.BorderSizePixel = 0
    toggleHandle.Parent = toggleBg
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = toggleHandle
    
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 10
    clickBtn.Parent = toggleContainer
    
    local function UpdateToggle(value)
        if value then
            toggleBg.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
            toggleHandle.Position = UDim2.new(0, 23, 0.5, -9)
        else
            toggleBg.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
            toggleHandle.Position = UDim2.new(0, 3, 0.5, -9)
        end
    end
    
    UpdateToggle(_G[globalVar])
    
    clickBtn.MouseButton1Click:Connect(function()
        local newVal = not _G[globalVar]
        _G[globalVar] = newVal
        UpdateToggle(newVal)
        print(string.format("[DEBUG] %s = %s", globalVar, tostring(newVal)))
    end)
    
    return clickBtn
end

local function CreateSlider(parent, labelText, description, globalVar, minVal, maxVal, defaultVal, yPos)
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
    
    if _G[globalVar] == nil then
        _G[globalVar] = defaultVal
    end
    
    local valueDisplay = Instance.new("TextLabel")
    valueDisplay.Size = UDim2.new(0.15, 0, 0, 20)
    valueDisplay.Position = UDim2.new(0.85, 0, 0, 0)
    valueDisplay.BackgroundTransparency = 1
    valueDisplay.Text = tostring(_G[globalVar])
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
    local initialPercent = (_G[globalVar] - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(initialPercent, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.Position = UDim2.new(0, 0, 0, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 10
    clickBtn.Parent = sliderFrame
    
    local dragging = false
    local dragConnection = nil
    
    local function UpdateSlider(mouseX)
        local absPos = sliderFrame.AbsolutePosition.X
        local width = sliderFrame.AbsoluteSize.X
        if width <= 0 then
            return
        end
        
        local percent = math.clamp((mouseX - absPos) / width, 0, 1)
        local val = math.round(minVal + percent * (maxVal - minVal))
        val = math.clamp(val, minVal, maxVal)
        
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valueDisplay.Text = tostring(val)
        _G[globalVar] = val
        
        if globalVar == "AimbotFOV" and FOVCircle then
            FOVCircle.Radius = val
        end
        
        print(string.format("[DEBUG] %s = %d", globalVar, val))
    end
    
    clickBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateSlider(input.Position.X)
            
            if dragConnection then
                dragConnection:Disconnect()
            end
            dragConnection = UserInputService.InputChanged:Connect(function(inputChanged)
                if inputChanged.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                    UpdateSlider(inputChanged.Position.X)
                end
            end)
        end
    end)
    
    clickBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            if dragConnection then
                dragConnection:Disconnect()
                dragConnection = nil
            end
        end
    end)
    
    return clickBtn
end

local function CreateDropdown(parent, labelText, description, globalVar, options, yPos)
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
    
    if _G[globalVar] == nil then
        _G[globalVar] = options[1]
    end
    
    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(0.4, 0, 0.6, 0)
    dropBtn.Position = UDim2.new(0.55, 0, 0.05, 0)
    dropBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    dropBtn.BorderSizePixel = 0
    dropBtn.Text = _G[globalVar]
    dropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropBtn.TextSize = 13
    dropBtn.Font = Enum.Font.Gotham
    dropBtn.Parent = frame
    
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 4)
    dropCorner.Parent = dropBtn
    
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(0.4, 0, 0, #options * 26)
    listFrame.Position = UDim2.new(0.55, 0, 0.7, 0)
    listFrame.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.ZIndex = 150
    listFrame.Parent = dropBtn
    
    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Color3.fromRGB(42, 47, 58)
    listStroke.Parent = listFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 4)
    listCorner.Parent = listFrame
    
    dropBtn.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
    end)
    
    for idx, optName in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 26)
        optBtn.Position = UDim2.new(0, 0, 0, (idx - 1) * 26)
        optBtn.BackgroundTransparency = 1
        optBtn.Text = optName
        optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        optBtn.TextSize = 12
        optBtn.Font = Enum.Font.Gotham
        optBtn.ZIndex = 151
        optBtn.Parent = listFrame
        
        optBtn.MouseButton1Click:Connect(function()
            _G[globalVar] = optName
            dropBtn.Text = optName
            listFrame.Visible = false
            print(string.format("[DEBUG] %s = %s", globalVar, optName))
        end)
    end
end

-- ======================================================
-- НАПОЛНЕНИЕ AIMBOT СТРАНИЦЫ
-- ======================================================
local aimbotPage = ContentPages["Aimbot"]
if aimbotPage then
    CreateToggle(
        aimbotPage,
        "Master Aimbot",
        "Авто-наведение камеры на противников при зажатии экрана",
        "AimbotEnabled",
        15
    )
    
    CreateSlider(
        aimbotPage,
        "Aimbot FOV Range",
        "Радиус захвата автонаведения в пикселях",
        "AimbotFOV",
        10,
        300,
        150,
        75
    )
    
    CreateDropdown(
        aimbotPage,
        "Target Body Part",
        "Выбор части тела для захвата аимбота",
        "TargetBone",
        {"Head", "Torso", "HumanoidRootPart"},
        145
    )
end

-- ======================================================
-- НАПОЛНЕНИЕ VISUALS СТРАНИЦЫ
-- ======================================================
local visualsPage = ContentPages["Visuals"]
if visualsPage then
    CreateToggle(
        visualsPage,
        "Chams / Подсветка",
        "Красивый силуэт игроков оранжевого цвета сквозь стены",
        "BoxESP",
        15
    )
    
    CreateToggle(
        visualsPage,
        "Tracers / Лучи",
        "Тонкие лазерные линии от тебя к противникам",
        "Snaplines",
        75
    )
    
    CreateToggle(
        visualsPage,
        "Names & Distance",
        "Отображение имен игроков и дистанции в реальном времени",
        "EspNames",
        135
    )
end

-- ======================================================
-- АКТИВАЦИЯ ПЕРВОЙ ВКЛАДКИ
-- ======================================================
if TabButtons[1] then
    TabButtons[1].MouseButton1Click:Fire()
end

-- ======================================================
-- ФУНКЦИЯ ПОИСКА БЛИЖАЙШЕГО ИГРОКА
-- ======================================================
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = _G.AimbotFOV
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    
    if not localRoot then
        return nil
    end
    
    local viewportSize = Camera.ViewportSize
    local screenCenter = viewportSize / 2
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            continue
        end
        
        local char = player.Character
        local targetPart = char and char:FindFirstChild(_G.TargetBone)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if targetPart and hum and hum.Health > 0 then
            local pos2D, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            
            if onScreen then
                local distance = (Vector2.new(pos2D.X, pos2D.Y) - screenCenter).Magnitude
                
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

-- ======================================================
-- ГЛОБАЛЬНЫЙ РЕНДЕР-ЦИКЛ
-- ======================================================
RunService.RenderStepped:Connect(function()
    local viewportSize = Camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    
    -- ---- FOV КРУГ ----
    if _G.AimbotEnabled and FOVCircle then
        FOVCircle.Visible = true
        FOVCircle.Position = screenCenter
        FOVCircle.Radius = _G.AimbotFOV
    elseif FOVCircle then
        FOVCircle.Visible = false
    end
    
    -- ---- AIMBOT ----
    if _G.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetPlayer = GetClosestPlayer()
        
        if targetPlayer and targetPlayer.Character then
            local aimPart = targetPlayer.Character:FindFirstChild(_G.TargetBone)
            
            if aimPart then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
            end
        end
    end
    
    -- ---- ESP ОБЪЕКТЫ ----
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            continue
        end
        
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if char and hrp and hum and hum.Health > 0 then
            local pos2D, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            -- ---- CHAMS (HIGHLIGHT) ----
            if _G.BoxESP then
                local highlight = char:FindFirstChild("META_Highlight")
                
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "META_Highlight"
                    highlight.FillColor = Color3.fromRGB(255, 165, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.OutlineTransparency = 0.1
                    highlight.Parent = char
                end
            else
                if char:FindFirstChild("META_Highlight") then
                    char.META_Highlight:Destroy()
                end
            end
            
            -- ---- TRACERS (BEAM) ----
            if _G.Snaplines and onScreen and localRoot then
                local attachment0 = localRoot:FindFirstChild("META_Att")
                
                if not attachment0 then
                    attachment0 = Instance.new("Attachment")
                    attachment0.Name = "META_Att"
                    attachment0.Parent = localRoot
                end
                
                local attachment1 = hrp:FindFirstChild("META_Att")
                
                if not attachment1 then
                    attachment1 = Instance.new("Attachment")
                    attachment1.Name = "META_Att"
                    attachment1.Parent = hrp
                end
                
                local beam = localRoot:FindFirstChild("META_Beam" .. player.Name)
                
                if not beam then
                    beam = Instance.new("Beam")
                    beam.Name = "META_Beam" .. player.Name
                    beam.Width0 = 0.05
                    beam.Width1 = 0.05
                    beam.Color = ColorSequence.new(Color3.fromRGB(255, 165, 0))
                    beam.FaceCamera = true
                    beam.Attachment0 = attachment0
                    beam.Attachment1 = attachment1
                    beam.Parent = localRoot
                end
            else
                if localRoot and localRoot:FindFirstChild("META_Beam" .. player.Name) then
                    localRoot["META_Beam" .. player.Name]:Destroy()
                end
            end
            
            -- ---- NAMES & DISTANCE ----
            if _G.EspNames and onScreen and localRoot then
                local head = char:FindFirstChild("Head")
                
                if head then
                    local bgui = head:FindFirstChild("META_BGui")
                    
                    if not bgui then
                        bgui = Instance.new("BillboardGui")
                        bgui.Name = "META_BGui"
                        bgui.Size = UDim2.new(0, 100, 0, 30)
                        bgui.AlwaysOnTop = true
                        bgui.StudsOffset = Vector3.new(0, 2, 0)
                        
                        local tl = Instance.new("TextLabel")
                        tl.Size = UDim2.new(1, 0, 1, 0)
                        tl.BackgroundTransparency = 1
                        tl.TextColor3 = Color3.fromRGB(255, 255, 255)
                        tl.TextStrokeTransparency = 0
                        tl.TextSize = 12
                        tl.Font = Enum.Font.GothamBold
                        tl.Parent = bgui
                        
                        bgui.Parent = head
                    end
                    
                    local dist = (hrp.Position - localRoot.Position).Magnitude
                    head.META_BGui.TextLabel.Text = string.format("%s [%d Studs]", player.Name, math.round(dist))
                end
            else
                if char and char:FindFirstChild("Head") and char.Head:FindFirstChild("META_BGui") then
                    char.Head.META_BGui:Destroy()
                end
            end
        else
            -- ---- ОЧИСТКА ПРИ СМЕРТИ ИЛИ ВЫХОДЕ ----
            if char then
                if char:FindFirstChild("META_Highlight") then
                    char.META_Highlight:Destroy()
                end
                
                if char:FindFirstChild("Head") and char.Head:FindFirstChild("META_BGui") then
                    char.Head.META_BGui:Destroy()
                end
            end
            
            if localRoot and localRoot:FindFirstChild("META_Beam" .. player.Name) then
                localRoot["META_Beam" .. player.Name]:Destroy()
            end
        end
    end
end)

-- ======================================================
-- ГОРЯЧИЕ КЛАВИШИ
-- ======================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    
    if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.F8 then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    
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

print("[META] Mobile Engine Fixed Active!")
print("[META] Press Insert or F8 to toggle menu")
print("[META] F1 - Aimbot, F2 - Chams, F3 - Tracers, F4 - Names")
