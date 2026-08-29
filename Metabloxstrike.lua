
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

-- ======================================================
-- ГЛОБАЛЬНЫЕ СОСТОЯНИЯ
-- ======================================================
_G.AimbotEnabled = false
_G.AimbotFOV = 150
_G.TargetBone = "Head"
_G.BoxESP = false
_G.Snaplines = false
_G.EspNames = false
_G.Box2D = false
_G.FullBrightEnabled = false

local MenuVisible = true
local FOVCircle = nil
local BlissfulActive = false
local BlissfulConnections = {}
local BlendValue = 1
local BlendTarget = 1

-- ======================================================
-- FULLBRIGHT (ПОЛНАЯ ЯРКОСТЬ)
-- ======================================================
if not _G.FullBrightExecuted then
    _G.NormalLightingSettings = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
        Ambient = Lighting.Ambient
    }

    Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
        if Lighting.Brightness ~= 1 and Lighting.Brightness ~= _G.NormalLightingSettings.Brightness then
            _G.NormalLightingSettings.Brightness = Lighting.Brightness
            if not _G.FullBrightEnabled then
                repeat task.wait() until _G.FullBrightEnabled
            end
            Lighting.Brightness = 1
        end
    end)

    Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
        if Lighting.ClockTime ~= 12 and Lighting.ClockTime ~= _G.NormalLightingSettings.ClockTime then
            _G.NormalLightingSettings.ClockTime = Lighting.ClockTime
            if not _G.FullBrightEnabled then
                repeat task.wait() until _G.FullBrightEnabled
            end
            Lighting.ClockTime = 12
        end
    end)

    Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
        if Lighting.FogEnd ~= 786543 and Lighting.FogEnd ~= _G.NormalLightingSettings.FogEnd then
            _G.NormalLightingSettings.FogEnd = Lighting.FogEnd
            if not _G.FullBrightEnabled then
                repeat task.wait() until _G.FullBrightEnabled
            end
            Lighting.FogEnd = 786543
        end
    end)

    Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
        if Lighting.GlobalShadows ~= false and Lighting.GlobalShadows ~= _G.NormalLightingSettings.GlobalShadows then
            _G.NormalLightingSettings.GlobalShadows = Lighting.GlobalShadows
            if not _G.FullBrightEnabled then
                repeat task.wait() until _G.FullBrightEnabled
            end
            Lighting.GlobalShadows = false
        end
    end)

    Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
        if Lighting.Ambient ~= Color3.fromRGB(178, 178, 178) and Lighting.Ambient ~= _G.NormalLightingSettings.Ambient then
            _G.NormalLightingSettings.Ambient = Lighting.Ambient
            if not _G.FullBrightEnabled then
                repeat task.wait() until _G.FullBrightEnabled
            end
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        end
    end)

    Lighting.Brightness = 1
    Lighting.ClockTime = 12
    Lighting.FogEnd = 786543
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(178, 178, 178)

    local LatestValue = true
    task.spawn(function()
        repeat task.wait() until _G.FullBrightEnabled
        while task.wait() do
            if _G.FullBrightEnabled ~= LatestValue then
                if not _G.FullBrightEnabled then
                    Lighting.Brightness = _G.NormalLightingSettings.Brightness
                    Lighting.ClockTime = _G.NormalLightingSettings.ClockTime
                    Lighting.FogEnd = _G.NormalLightingSettings.FogEnd
                    Lighting.GlobalShadows = _G.NormalLightingSettings.GlobalShadows
                    Lighting.Ambient = _G.NormalLightingSettings.Ambient
                else
                    Lighting.Brightness = 1
                    Lighting.ClockTime = 12
                    Lighting.FogEnd = 786543
                    Lighting.GlobalShadows = false
                    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
                end
                LatestValue = not LatestValue
            end
        end
    end)
end

_G.FullBrightExecuted = true

local function ToggleFullBright()
    _G.FullBrightEnabled = not _G.FullBrightEnabled
    if _G.FullBrightEnabled then
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 786543
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        print("[FULLBRIGHT] ON")
    else
        Lighting.Brightness = _G.NormalLightingSettings.Brightness
        Lighting.ClockTime = _G.NormalLightingSettings.ClockTime
        Lighting.FogEnd = _G.NormalLightingSettings.FogEnd
        Lighting.GlobalShadows = _G.NormalLightingSettings.GlobalShadows
        Lighting.Ambient = _G.NormalLightingSettings.Ambient
        print("[FULLBRIGHT] OFF")
    end
end

-- ======================================================
-- CHAMS (ADOLFFX СТИЛЬ)
-- ======================================================
local S, P, C3 = setmetatable({}, {__index = function(_,k) return game:GetService(k) end}), game:GetService("Players"), Color3.fromRGB
local LP, Tag, Cons = P.LocalPlayer, "AdolfFX", {}

if _G.UnloadChams then _G.UnloadChams() end

local Cfg = {
    Enemy = C3(180, 40, 40),
    Ally = C3(40, 180, 80),
    FillTr = 0.5,
    OutTr = 0.1,
    TeamCheck = true
}

local function Paint(Chr, Plr)
    if not Chr or Chr:FindFirstChild(Tag) then return end
    local H = Instance.new("Highlight")
    local IsEnemy = (Cfg.TeamCheck and Plr.Team ~= LP.Team) or not Cfg.TeamCheck
    
    H.Name = Tag
    H.FillColor = IsEnemy and Cfg.Enemy or Cfg.Ally
    H.OutlineColor = C3(255, 255, 255)
    H.FillTransparency = Cfg.FillTr
    H.OutlineTransparency = Cfg.OutTr
    H.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    H.Adornee = Chr
    H.Parent = Chr
    H.Enabled = _G.BoxESP
end

local function Hook(Plr)
    if Plr == LP then return end
    Cons[Plr] = Plr.CharacterAdded:Connect(function(c)
        task.wait(0.1)
        if _G.BoxESP then
            Paint(c, Plr)
        end
    end)
    if Plr.Character and _G.BoxESP then
        Paint(Plr.Character, Plr)
    end
end

for _, v in next, P:GetPlayers() do
    Hook(v)
end

Cons.Add = P.PlayerAdded:Connect(Hook)

_G.UnloadChams = function()
    if Cons.Add then Cons.Add:Disconnect() end
    for _, c in next, Cons do
        if c and c.Disconnect then
            c:Disconnect()
        end
    end
    for _, v in next, P:GetPlayers() do
        if v.Character and v.Character:FindFirstChild(Tag) then
            v.Character[Tag]:Destroy()
        end
    end
    _G.UnloadChams = nil
end

local function UpdateChams()
    if _G.BoxESP then
        for _, v in next, P:GetPlayers() do
            if v ~= LP and v.Character then
                local h = v.Character:FindFirstChild(Tag)
                if h then
                    h.Enabled = true
                else
                    Paint(v.Character, v)
                end
            end
        end
    else
        for _, v in next, P:GetPlayers() do
            if v.Character and v.Character:FindFirstChild(Tag) then
                v.Character[Tag].Enabled = false
            end
        end
    end
end

-- ======================================================
-- 2D BOX ESP 
-- =====================================================
-- ======================================================
-- 2D BOX ESP - ИСПРАВЛЕННАЯ ВЕРСИЯ (БЕЗ ПРИЗРАКОВ)
-- ======================================================
local Box2DData = {}
local Box2DConnections = {}

local function CreateBox2D(player)
    if player == LocalPlayer then return end

    local function onCharacterAdded(character)
        -- ✅ ПРИ РЕСПАВНЕ УДАЛЯЕМ СТАРЫЙ GUI
        if Box2DData[player] then
            pcall(function() 
                Box2DData[player]:Destroy() 
            end)
            Box2DData[player] = nil
        end
        
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not hrp or not humanoid then return end

        local gui = Instance.new("BillboardGui")
        gui.Name = "Box2D"
        gui.Adornee = hrp
        gui.Size = UDim2.fromScale(4, 6)
        gui.StudsOffset = Vector3.new(0, 0, 0)
        gui.AlwaysOnTop = true
        gui.Parent = character
        gui.Enabled = _G.Box2D

        local box = Instance.new("Frame")
        box.Size = UDim2.fromScale(1, 1)
        box.BackgroundTransparency = 1
        box.Parent = gui

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 2
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Parent = box

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.15, 0)
        nameLabel.Position = UDim2.new(0, 0, -0.18, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = box
        
        Box2DData[player] = gui
    end

    -- ✅ ЕСЛИ УЖЕ ЕСТЬ GUI ПРИ ПОДКЛЮЧЕНИИ - УДАЛЯЕМ
    if Box2DData[player] then
        pcall(function() Box2DData[player]:Destroy() end)
        Box2DData[player] = nil
    end

    if player.Character then
        onCharacterAdded(player.Character)
    end

    if Box2DConnections[player] then
        Box2DConnections[player]:Disconnect()
    end
    Box2DConnections[player] = player.CharacterAdded:Connect(onCharacterAdded)
end

local function RemoveBox2D(player)
    if Box2DConnections[player] then
        Box2DConnections[player]:Disconnect()
        Box2DConnections[player] = nil
    end
    
    if Box2DData[player] then
        pcall(function() Box2DData[player]:Destroy() end)
        Box2DData[player] = nil
    end
end

local function RemoveAllBox2D()
    for player, gui in pairs(Box2DData) do
        pcall(function() gui:Destroy() end)
    end
    Box2DData = {}
    
    for player, conn in pairs(Box2DConnections) do
        pcall(function() conn:Disconnect() end)
    end
    Box2DConnections = {}
end

local function UpdateBox2D()
    if _G.Box2D then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                -- ✅ ПРОВЕРЯЕМ, ЕСТЬ ЛИ У ИГРОКА GUI, И ОН ЛИ ПРИВЯЗАН К ТЕКУЩЕМУ ПЕРСОНАЖУ
                local currentGui = Box2DData[player]
                local shouldRecreate = false
                
                if currentGui then
                    -- Проверяем, существует ли ещё Adornee
                    local success, adornee = pcall(function()
                        return currentGui.Adornee
                    end)
                    if not success or not adornee or not adornee.Parent then
                        -- Adornee уничтожен — удаляем старый GUI
                        pcall(function() currentGui:Destroy() end)
                        Box2DData[player] = nil
                        shouldRecreate = true
                    end
                else
                    shouldRecreate = true
                end
                
                if shouldRecreate then
                    CreateBox2D(player)
                else
                    pcall(function() Box2DData[player].Enabled = true end)
                end
            end
        end
    else
        RemoveAllBox2D()
    end
end

-- Инициализация
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateBox2D(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateBox2D(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveBox2D(player)
end)

-- ЗВУК КЛИКА
-- ======================================================
local ClickSound = Instance.new("Sound")
ClickSound.SoundId = "rbxassetid://88442833509532"
ClickSound.Volume = 0.5
ClickSound.Parent = SoundService

local function PlayClickSound()
    local sound = ClickSound:Clone()
    sound.Parent = SoundService
    sound:Play()
    task.delay(sound.TimeLength + 0.1, function()
        sound:Destroy()
    end)
end

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
-- NAMES & DISTANCE
-- ======================================================
local playerBillboards = {}

local function createBillboardGui(player)
    if not player.Character or not player.Character:FindFirstChild("Head") then
        return nil, nil
    end
    
    local head = player.Character.Head
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "NameAndDistanceGui"
    billboardGui.AlwaysOnTop = true
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
    billboardGui.Parent = head
    billboardGui.Enabled = _G.EspNames

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Text = player.Name
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.2
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Parent = billboardGui

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Text = "0 studs"
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 13
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.TextStrokeTransparency = 0.3
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.Parent = billboardGui

    return billboardGui, distanceLabel
end

local function updateDistanceLabel(player, distanceLabel)
    if not player.Character then
        distanceLabel.Text = "0 studs"
        return
    end
    
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if hrp and localHrp then
        local distance = (hrp.Position - localHrp.Position).Magnitude
        distanceLabel.Text = math.floor(distance) .. " studs"
    else
        distanceLabel.Text = "0 studs"
    end
end

local function setupPlayerBillboard(player)
    if playerBillboards[player] then
        if playerBillboards[player][1] then
            playerBillboards[player][1]:Destroy()
        end
        playerBillboards[player] = nil
    end
    
    if _G.EspNames and player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
        local bgui, distLabel = createBillboardGui(player)
        if bgui and distLabel then
            playerBillboards[player] = {bgui, distLabel}
        end
    end
end

local function updateAllBillboards()
    if _G.EspNames then
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then
                continue
            end
            if player.Character and player.Character:FindFirstChild("Head") then
                if not playerBillboards[player] then
                    setupPlayerBillboard(player)
                else
                    local data = playerBillboards[player]
                    if data and data[1] then
                        data[1].Enabled = true
                        local nameLabel = data[1]:FindFirstChild("NameLabel")
                        if nameLabel then
                            nameLabel.Text = player.Name
                        end
                    end
                end
            end
        end
    else
        for player, data in pairs(playerBillboards) do
            if data and data[1] then
                data[1].Enabled = false
            end
        end
    end
end

local function removeAllBillboards()
    for player, data in pairs(playerBillboards) do
        if data and data[1] then
            data[1]:Destroy()
        end
    end
    playerBillboards = {}
end

task.spawn(function()
    while task.wait(0.5) do
        if _G.EspNames then
            for player, data in pairs(playerBillboards) do
                if data and data[2] then
                    updateDistanceLabel(player, data[2])
                end
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if _G.EspNames then
            setupPlayerBillboard(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if playerBillboards[player] then
        if playerBillboards[player][1] then
            playerBillboards[player][1]:Destroy()
        end
        playerBillboards[player] = nil
    end
end)

-- ======================================================
-- BLISSFUL ESP С ПЛАВНЫМ ИСЧЕЗНОВЕНИЕМ
-- ======================================================
local function NewLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(1, 1)
    line.Color = Color3.fromRGB(0, 255, 50)
    line.Thickness = 1.4
    line.Transparency = 1
    return line
end

local function StartBlissfulESP()
    if BlissfulActive then return end
    
    print("[BLISSFUL] Starting ESP...")
    BlissfulActive = true
    BlendTarget = 1
    
    local workspace = game:GetService("Workspace")
    local player = game:GetService("Players").LocalPlayer
    local camera = workspace.CurrentCamera

    local on = true
    local Box_Color = Color3.fromRGB(0, 255, 50)
    local Box_Thickness = 1.4
    local Box_Transparency = 1
    local Tracers = true
    local Tracer_Color = Color3.fromRGB(0, 255, 50)
    local Tracer_Thickness = 1.4
    local Tracer_Transparency = 1
    local Autothickness = false
    local Team_Check = false
    local red = Color3.fromRGB(227, 52, 52)
    local green = Color3.fromRGB(88, 217, 24)

    local function NewLine()
        local line = Drawing.new("Line")
        line.Visible = false
        line.From = Vector2.new(0, 0)
        line.To = Vector2.new(1, 1)
        line.Color = Box_Color
        line.Thickness = Box_Thickness
        line.Transparency = Box_Transparency
        return line
    end

    for i, v in pairs(game.Players:GetChildren()) do
        local lines = {
            line1 = NewLine(),
            line2 = NewLine(),
            line3 = NewLine(),
            line4 = NewLine(),
            line5 = NewLine(),
            line6 = NewLine(),
            line7 = NewLine(),
            line8 = NewLine(),
            line9 = NewLine(),
            line10 = NewLine(),
            line11 = NewLine(),
            line12 = NewLine(),
            Tracer = NewLine()
        }

        lines.Tracer.Color = Tracer_Color
        lines.Tracer.Thickness = Tracer_Thickness
        lines.Tracer.Transparency = Tracer_Transparency

        local function ESP()
            local connection
            connection = game:GetService("RunService").RenderStepped:Connect(function()
                if not BlissfulActive then
                    BlendValue = BlendValue + (BlendTarget - BlendValue) * 0.08
                    if BlendValue < 0.01 then
                        for _, line in pairs(lines) do
                            line.Visible = false
                        end
                        return
                    end
                else
                    BlendValue = BlendValue + (BlendTarget - BlendValue) * 0.08
                end
                
                if not BlissfulActive and BlendValue < 0.01 then
                    for _, line in pairs(lines) do
                        line.Visible = false
                    end
                    return
                end
                
                if on and v.Character ~= nil and v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("HumanoidRootPart") ~= nil and v.Name ~= player.Name and v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild("Head") ~= nil then
                    local pos, vis = camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                    if vis then
                        local Scale = v.Character.Head.Size.Y/2
                        local Size = Vector3.new(2, 3, 1.5) * (Scale * 2)

                        local Top1 = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, -Size.Z)).p)
                        local Top2 = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, Size.Z)).p)
                        local Top3 = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, Size.Z)).p)
                        local Top4 = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, -Size.Z)).p)

                        local Bottom1 = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, -Size.Z)).p)
                        local Bottom2 = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, Size.Z)).p)
                        local Bottom3 = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, Size.Z)).p)
                        local Bottom4 = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, -Size.Z)).p)

                        lines.line1.From = Vector2.new(Top1.X, Top1.Y)
                        lines.line1.To = Vector2.new(Top2.X, Top2.Y)
                        lines.line2.From = Vector2.new(Top2.X, Top2.Y)
                        lines.line2.To = Vector2.new(Top3.X, Top3.Y)
                        lines.line3.From = Vector2.new(Top3.X, Top3.Y)
                        lines.line3.To = Vector2.new(Top4.X, Top4.Y)
                        lines.line4.From = Vector2.new(Top4.X, Top4.Y)
                        lines.line4.To = Vector2.new(Top1.X, Top1.Y)

                        lines.line5.From = Vector2.new(Bottom1.X, Bottom1.Y)
                        lines.line5.To = Vector2.new(Bottom2.X, Bottom2.Y)
                        lines.line6.From = Vector2.new(Bottom2.X, Bottom2.Y)
                        lines.line6.To = Vector2.new(Bottom3.X, Bottom3.Y)
                        lines.line7.From = Vector2.new(Bottom3.X, Bottom3.Y)
                        lines.line7.To = Vector2.new(Bottom4.X, Bottom4.Y)
                        lines.line8.From = Vector2.new(Bottom4.X, Bottom4.Y)
                        lines.line8.To = Vector2.new(Bottom1.X, Bottom1.Y)

                        lines.line9.From = Vector2.new(Bottom1.X, Bottom1.Y)
                        lines.line9.To = Vector2.new(Top1.X, Top1.Y)
                        lines.line10.From = Vector2.new(Bottom2.X, Bottom2.Y)
                        lines.line10.To = Vector2.new(Top2.X, Top2.Y)
                        lines.line11.From = Vector2.new(Bottom3.X, Bottom3.Y)
                        lines.line11.To = Vector2.new(Top3.X, Top3.Y)
                        lines.line12.From = Vector2.new(Bottom4.X, Bottom4.Y)
                        lines.line12.To = Vector2.new(Top4.X, Top4.Y)

                        if Tracers then
                            local trace = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(0, -Size.Y, 0)).p)
                            lines.Tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                            lines.Tracer.To = Vector2.new(trace.X, trace.Y)
                        end

                        if Team_Check then
                            if v.TeamColor == player.TeamColor then
                                for _, x in pairs(lines) do
                                    x.Color = green
                                end
                            else 
                                for _, x in pairs(lines) do
                                    x.Color = red
                                end
                            end
                        end

                        if Autothickness then
                            local distance = (player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
                            local value = math.clamp(1/distance*100, 0.1, 4)
                            for _, x in pairs(lines) do
                                x.Thickness = value
                            end
                        else 
                            for _, x in pairs(lines) do
                                x.Thickness = Box_Thickness
                            end
                        end

                        for _, x in pairs(lines) do
                            if x ~= lines.Tracer then
                                x.Visible = true
                                x.Transparency = BlendValue
                            end
                        end
                        if Tracers then
                            lines.Tracer.Visible = true
                            lines.Tracer.Transparency = BlendValue
                        end
                    else 
                        for _, x in pairs(lines) do
                            x.Visible = false
                        end
                    end
                else 
                    for _, x in pairs(lines) do
                        x.Visible = false
                    end
                    if game.Players:FindFirstChild(v.Name) == nil then
                        connection:Disconnect()
                    end
                end
            end)
            table.insert(BlissfulConnections, connection)
        end
        coroutine.wrap(ESP)()
    end

    game.Players.PlayerAdded:Connect(function(newplr)
        local lines = {
            line1 = NewLine(),
            line2 = NewLine(),
            line3 = NewLine(),
            line4 = NewLine(),
            line5 = NewLine(),
            line6 = NewLine(),
            line7 = NewLine(),
            line8 = NewLine(),
            line9 = NewLine(),
            line10 = NewLine(),
            line11 = NewLine(),
            line12 = NewLine(),
            Tracer = NewLine()
        }

        lines.Tracer.Color = Tracer_Color
        lines.Tracer.Thickness = Tracer_Thickness
        lines.Tracer.Transparency = Tracer_Transparency

        local function ESP()
            local connection
            connection = game:GetService("RunService").RenderStepped:Connect(function()
                if not BlissfulActive then
                    BlendValue = BlendValue + (BlendTarget - BlendValue) * 0.08
                    if BlendValue < 0.01 then
                        for _, line in pairs(lines) do
                            line.Visible = false
                        end
                        return
                    end
                else
                    BlendValue = BlendValue + (BlendTarget - BlendValue) * 0.08
                end
                
                if not BlissfulActive and BlendValue < 0.01 then
                    for _, line in pairs(lines) do
                        line.Visible = false
                    end
                    return
                end
                
                if on and newplr.Character ~= nil and newplr.Character:FindFirstChild("Humanoid") ~= nil and newplr.Character:FindFirstChild("HumanoidRootPart") ~= nil and newplr.Name ~= player.Name and newplr.Character.Humanoid.Health > 0 and newplr.Character:FindFirstChild("Head") ~= nil then
                    local pos, vis = camera:WorldToViewportPoint(newplr.Character.HumanoidRootPart.Position)
                    if vis then
                        local Scale = newplr.Character.Head.Size.Y/2
                        local Size = Vector3.new(2, 3, 1.5) * (Scale * 2)

                        local Top1 = camera:WorldToViewportPoint((newplr.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, -Size.Z)).p)
                        local Top2 = camera:WorldToViewportPoint((newplr.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, Size.Z)).p)
                        local Top3 = camera:WorldToViewportPoint((newplr.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, Size.Z)).p)
                        local Top4 = camera:WorldToViewportPoint((newplr.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, -Size.Z)).p)

                        local Bottom1 = camera:WorldToViewportPoint((newplr.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, -Size.Z)).p)
                        local Bottom2 = camera:WorldToViewportPoint((newplr.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, Size.Z)).p)
                        local Bottom3 = camera:WorldToViewportPoint((newplr.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, Size.Z)).p)
                        local Bottom4 = camera:WorldToViewportPoint((newplr.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, -Size.Z)).p)

                        lines.line1.From = Vector2.new(Top1.X, Top1.Y)
                        lines.line1.To = Vector2.new(Top2.X, Top2.Y)
                        lines.line2.From = Vector2.new(Top2.X, Top2.Y)
                        lines.line2.To = Vector2.new(Top3.X, Top3.Y)
                        lines.line3.From = Vector2.new(Top3.X, Top3.Y)
                        lines.line3.To = Vector2.new(Top4.X, Top4.Y)
                        lines.line4.From = Vector2.new(Top4.X, Top4.Y)
                        lines.line4.To = Vector2.new(Top1.X, Top1.Y)

                        lines.line5.From = Vector2.new(Bottom1.X, Bottom1.Y)
                        lines.line5.To = Vector2.new(Bottom2.X, Bottom2.Y)
                        lines.line6.From = Vector2.new(Bottom2.X, Bottom2.Y)
                        lines.line6.To = Vector2.new(Bottom3.X, Bottom3.Y)
                        lines.line7.From = Vector2.new(Bottom3.X, Bottom3.Y)
                        lines.line7.To = Vector2.new(Bottom4.X, Bottom4.Y)
                        lines.line8.From = Vector2.new(Bottom4.X, Bottom4.Y)
                        lines.line8.To = Vector2.new(Bottom1.X, Bottom1.Y)

                        lines.line9.From = Vector2.new(Bottom1.X, Bottom1.Y)
                        lines.line9.To = Vector2.new(Top1.X, Top1.Y)
                        lines.line10.From = Vector2.new(Bottom2.X, Bottom2.Y)
                        lines.line10.To = Vector2.new(Top2.X, Top2.Y)
                        lines.line11.From = Vector2.new(Bottom3.X, Bottom3.Y)
                        lines.line11.To = Vector2.new(Top3.X, Top3.Y)
                        lines.line12.From = Vector2.new(Bottom4.X, Bottom4.Y)
                        lines.line12.To = Vector2.new(Top4.X, Top4.Y)

                        if Tracers then
                            local trace = camera:WorldToViewportPoint((newplr.Character.HumanoidRootPart.CFrame * CFrame.new(0, -Size.Y, 0)).p)
                            lines.Tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                            lines.Tracer.To = Vector2.new(trace.X, trace.Y)
                        end

                        if Team_Check then
                            if newplr.TeamColor == player.TeamColor then
                                for _, x in pairs(lines) do
                                    x.Color = green
                                end
                            else 
                                for _, x in pairs(lines) do
                                    x.Color = red
                                end
                            end
                        end

                        if Autothickness then
                            local distance = (player.Character.HumanoidRootPart.Position - newplr.Character.HumanoidRootPart.Position).magnitude
                            local value = math.clamp(1/distance*100, 0.1, 4)
                            for _, x in pairs(lines) do
                                x.Thickness = value
                            end
                        else 
                            for _, x in pairs(lines) do
                                x.Thickness = Box_Thickness
                            end
                        end

                        for _, x in pairs(lines) do
                            if x ~= lines.Tracer then
                                x.Visible = true
                                x.Transparency = BlendValue
                            end
                        end
                        if Tracers then
                            lines.Tracer.Visible = true
                            lines.Tracer.Transparency = BlendValue
                        end
                    else 
                        for _, x in pairs(lines) do
                            x.Visible = false
                        end
                    end
                else 
                    for _, x in pairs(lines) do
                        x.Visible = false
                    end
                    if game.Players:FindFirstChild(newplr.Name) == nil then
                        connection:Disconnect()
                    end
                end
            end)
            table.insert(BlissfulConnections, connection)
        end
        coroutine.wrap(ESP)()
    end)
    
    print("[BLISSFUL] ESP Started Successfully!")
end

local function StopBlissfulESP()
    if not BlissfulActive then return end
    
    print("[BLISSFUL] Stopping ESP with smooth fade...")
    BlissfulActive = false
    BlendTarget = 0
    
    task.delay(0.8, function()
        for _, conn in ipairs(BlissfulConnections) do
            pcall(function() conn:Disconnect() end)
        end
        BlissfulConnections = {}
        print("[BLISSFUL] ESP Stopped and cleaned!")
    end)
end

-- ======================================================
-- СОЗДАНИЕ GUI С DRAGGABLE
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
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Selectable = true

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
Title.Text = "META v3.11"
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
Version.Text = "v3.11"
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
        PlayClickSound()
        
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
            TweenService:Create(toggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(59, 130, 246)
            }):Play()
            TweenService:Create(toggleHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0, 23, 0.5, -9)
            }):Play()
        else
            TweenService:Create(toggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(42, 47, 58)
            }):Play()
            TweenService:Create(toggleHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0, 3, 0.5, -9)
            }):Play()
        end
    end
    
    UpdateToggle(_G[globalVar])
    
    clickBtn.MouseButton1Click:Connect(function()
        PlayClickSound()
        
        local newVal = not _G[globalVar]
        _G[globalVar] = newVal
        
        if globalVar == "BoxESP" then
            UpdateChams()
        elseif globalVar == "Snaplines" then
            if newVal then
                StartBlissfulESP()
            else
                StopBlissfulESP()
            end
        elseif globalVar == "EspNames" then
            if newVal then
                updateAllBillboards()
            else
                removeAllBillboards()
            end
        elseif globalVar == "Box2D" then
            UpdateBox2D()
        elseif globalVar == "FullBright" then
            ToggleFullBright()
        end
        
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
    
    local draggingSlider = false
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
            draggingSlider = true
            UpdateSlider(input.Position.X)
            
            if dragConnection then
                dragConnection:Disconnect()
            end
            dragConnection = UserInputService.InputChanged:Connect(function(inputChanged)
                if inputChanged.UserInputType == Enum.UserInputType.MouseMovement and draggingSlider then
                    UpdateSlider(inputChanged.Position.X)
                end
            end)
        end
    end)
    
    clickBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
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
        PlayClickSound()
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
            PlayClickSound()
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
        "Chams / Подсветка (AdolfFX)",
        "Красные/зеленые силуэты игроков в зависимости от команды",
        "BoxESP",
        15
    )
    
    CreateToggle(
        visualsPage,
        "2D Box / 2Д Бокс",
        "Бокс который обводит игрока белым цветом, скоро будут добавлены другие.",
        "Box2D",
        80
    )
    
    CreateToggle(
        visualsPage,
        "Tracers / Лучи (Blissful)",
        "Полный Blissful ESP: 3D Box + Tracers (плавное исчезновение)",
        "Snaplines",
        145
    )
    
    CreateToggle(
        visualsPage,
        "Names & Distance",
        "Отображение имен игроков и дистанции в реальном времени",
        "EspNames",
        205
    )
    
    CreateToggle(
        visualsPage,
        "Full Bright / Полная яркость",
        "Включая функцию карта становится намного светлее.",
        "FullBright",
        265
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
    
    for _, player in pairs(Players:GetPlayers()) do
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
    
    if _G.AimbotEnabled and FOVCircle then
        FOVCircle.Visible = true
        FOVCircle.Position = screenCenter
        FOVCircle.Radius = _G.AimbotFOV
    elseif FOVCircle then
        FOVCircle.Visible = false
    end
    
    if _G.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetPlayer = GetClosestPlayer()
        
        if targetPlayer and targetPlayer.Character then
            local aimPart = targetPlayer.Character:FindFirstChild(_G.TargetBone)
            
            if aimPart then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
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
        PlayClickSound()
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        PlayClickSound()
        _G.AimbotEnabled = not _G.AimbotEnabled
        print(string.format("[DEBUG] Aimbot: %s", tostring(_G.AimbotEnabled)))
    elseif input.KeyCode == Enum.KeyCode.F2 then
        PlayClickSound()
        _G.BoxESP = not _G.BoxESP
        UpdateChams()
        print(string.format("[DEBUG] BoxESP: %s", tostring(_G.BoxESP)))
    elseif input.KeyCode == Enum.KeyCode.F3 then
        PlayClickSound()
        _G.Box2D = not _G.Box2D
        UpdateBox2D()
        print(string.format("[DEBUG] Box2D: %s", tostring(_G.Box2D)))
    elseif input.KeyCode == Enum.KeyCode.F4 then
        PlayClickSound()
        _G.Snaplines = not _G.Snaplines
        if _G.Snaplines then
            StartBlissfulESP()
        else
            StopBlissfulESP()
        end
        print(string.format("[DEBUG] Snaplines: %s", tostring(_G.Snaplines)))
    elseif input.KeyCode == Enum.KeyCode.F5 then
        PlayClickSound()
        _G.EspNames = not _G.EspNames
        if _G.EspNames then
            updateAllBillboards()
        else
            removeAllBillboards()
        end
        print(string.format("[DEBUG] EspNames: %s", tostring(_G.EspNames)))
    elseif input.KeyCode == Enum.KeyCode.F6 then
        PlayClickSound()
        ToggleFullBright()
        print(string.format("[DEBUG] FullBright: %s", tostring(_G.FullBrightEnabled)))
    end
end)

print("[META] v3.11 Loaded Successfully!")
print("[META] Added: Full Bright (toggle with F6)")
print("[META] Chams: AdolfFX style (red enemies, green allies)")
print("[META] 2D Box: white box around players")
print("[META] Names & Distance: fixed respawn bug!")
print("[META] F1 - Aimbot | F2 - Chams | F3 - 2D Box | F4 - Tracers | F5 - Names | F6 - FullBright")
print("[META] Press Insert or F8 to toggle menu")
