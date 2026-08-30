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
_G.Box3D = false
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
-- ======================================================
-- CHAMS (С ПРАВИЛЬНЫМ ОПРЕДЕЛЕНИЕМ КОМАНД)
-- ======================================================
local Tag = "AdolfFX"
local ChamsData = {}

local function IsEnemy(Plr)
    local LP = Players.LocalPlayer
    
    -- 1. Проверка через Team
    if Plr.Team and LP.Team then
        if Plr.Team ~= LP.Team then
            return true
        end
    end
    
    -- 2. Проверка через TeamColor (если Team не работает)
    if Plr.TeamColor and LP.TeamColor then
        if Plr.TeamColor ~= LP.TeamColor then
            return true
        end
    end
    
    -- 3. Проверка через Neutral (если игрок без команды)
    if Plr.Team == Enum.Team.Neutral or LP.Team == Enum.Team.Neutral then
        return true
    end
    
    -- 4. Если у игрока нет команды — считаем врагом
    if Plr.Team == nil then
        return true
    end
    
    return false
end

local function Paint(Chr, Plr)
    if not Chr or Chr:FindFirstChild(Tag) then return end
    
    local H = Instance.new("Highlight")
    local enemy = IsEnemy(Plr)
    
    H.Name = Tag
    H.FillColor = enemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0) -- Красный/Зелёный
    H.OutlineColor = Color3.fromRGB(255, 255, 255)
    H.FillTransparency = 0.5
    H.OutlineTransparency = 0.1
    H.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    H.Adornee = Chr
    H.Parent = Chr
    H.Enabled = _G.BoxESP
    
    ChamsData[Chr] = H
end

local function Hook(Plr)
    if Plr == LocalPlayer then return end
    
    Plr.CharacterAdded:Connect(function(c)
        task.wait(0.1)
        if _G.BoxESP and c then
            Paint(c, Plr)
        end
    end)
    
    if Plr.Character and _G.BoxESP then
        Paint(Plr.Character, Plr)
    end
end

-- Инициализация
for _, v in pairs(Players:GetPlayers()) do
    Hook(v)
end

Players.PlayerAdded:Connect(Hook)

-- Обновление при переключении
local function UpdateChams()
    if _G.BoxESP then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local h = v.Character:FindFirstChild(Tag)
                if h then
                    h.Enabled = true
                    -- Обновляем цвет при каждом включении
                    local enemy = IsEnemy(v)
                    h.FillColor = enemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                else
                    Paint(v.Character, v)
                end
            end
        end
    else
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild(Tag) then
                v.Character[Tag].Enabled = false
            end
        end
    end
end
-- ======================================================
-- 3D BOX ESP (БЕЗ МЕРЦАНИЯ)
-- ======================================================
local Box3DActive = false
local Box3DLines = {}
local Box3DQuads = {}

local function GetCorners(Part)
    local CF, Size, Corners = Part.CFrame, Part.Size / 2, {}
    for X = -1, 1, 2 do 
        for Y = -1, 1, 2 do 
            for Z = -1, 1, 2 do
                Corners[#Corners+1] = (CF * CFrame.new(Size * Vector3.new(X, Y, Z))).Position      
            end 
        end 
    end
    return Corners
end

local function UpdateLine(Line, From, To)
    local FromScreen, FromVisible = Camera:WorldToViewportPoint(From)
    local ToScreen, ToVisible = Camera:WorldToViewportPoint(To)

    if not FromVisible and not ToVisible then
        Line.Visible = false
        return
    end

    Line.Visible = true
    Line.From = Vector2.new(FromScreen.X, FromScreen.Y)
    Line.To = Vector2.new(ToScreen.X, ToScreen.Y)
end

local function UpdateQuad(Quad, PosA, PosB, PosC, PosD)
    local PosAScreen, PosAVisible = Camera:WorldToViewportPoint(PosA)
    local PosBScreen, PosBVisible = Camera:WorldToViewportPoint(PosB)
    local PosCScreen, PosCVisible = Camera:WorldToViewportPoint(PosC)
    local PosDScreen, PosDVisible = Camera:WorldToViewportPoint(PosD)

    if not PosAVisible and not PosBVisible and not PosCVisible and not PosDVisible then
        Quad.Visible = false
        return
    end

    Quad.Visible = true
    Quad.PointA = Vector2.new(PosAScreen.X, PosAScreen.Y)
    Quad.PointB = Vector2.new(PosBScreen.X, PosBScreen.Y)
    Quad.PointC = Vector2.new(PosCScreen.X, PosCScreen.Y)
    Quad.PointD = Vector2.new(PosDScreen.X, PosDScreen.Y)
end

local function CreateLine()
    local Line = Drawing.new("Line")
    Line.Thickness = 1
    Line.Color = Color3.fromRGB(255, 255, 255)
    Line.Transparency = 1
    Line.ZIndex = 1
    Line.Visible = false
    return Line
end

local function CreateQuad()
    local Quad = Drawing.new("Quad")
    Quad.Thickness = 0.5
    Quad.Color = Color3.fromRGB(255, 255, 255)
    Quad.Transparency = 0.25
    Quad.ZIndex = 1
    Quad.Filled = true
    Quad.Visible = false
    return Quad
end

local function InitBox3D()
    if #Box3DLines == 0 then
        for i = 1, 12 do
            table.insert(Box3DLines, CreateLine())
        end
    end
    
    if #Box3DQuads == 0 then
        for i = 1, 6 do
            table.insert(Box3DQuads, CreateQuad())
        end
    end
end

local function DrawBoxESP()
    if not Box3DActive then
        for _, line in pairs(Box3DLines) do
            line.Visible = false
        end
        for _, quad in pairs(Box3DQuads) do
            quad.Visible = false
        end
        return
    end

    InitBox3D()

    local lineIndex = 1
    local quadIndex = 1
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end

        local CubeVertices = GetCorners({CFrame = hrp.CFrame * CFrame.new(0, -0.5, 0), Size = Vector3.new(3, 5, 3)})

        while lineIndex + 12 > #Box3DLines do
            table.insert(Box3DLines, CreateLine())
        end
        while quadIndex + 6 > #Box3DQuads do
            table.insert(Box3DQuads, CreateQuad())
        end

        local L = Box3DLines
        local Q = Box3DQuads

        -- Bottom face
        UpdateLine(L[lineIndex], CubeVertices[1], CubeVertices[2]); lineIndex = lineIndex + 1
        UpdateLine(L[lineIndex], CubeVertices[2], CubeVertices[6]); lineIndex = lineIndex + 1
        UpdateLine(L[lineIndex], CubeVertices[6], CubeVertices[5]); lineIndex = lineIndex + 1
        UpdateLine(L[lineIndex], CubeVertices[5], CubeVertices[1]); lineIndex = lineIndex + 1
        UpdateQuad(Q[quadIndex], CubeVertices[1], CubeVertices[2], CubeVertices[6], CubeVertices[5]); quadIndex = quadIndex + 1

        -- Side faces
        UpdateLine(L[lineIndex], CubeVertices[1], CubeVertices[3]); lineIndex = lineIndex + 1
        UpdateLine(L[lineIndex], CubeVertices[2], CubeVertices[4]); lineIndex = lineIndex + 1
        UpdateLine(L[lineIndex], CubeVertices[6], CubeVertices[8]); lineIndex = lineIndex + 1
        UpdateLine(L[lineIndex], CubeVertices[5], CubeVertices[7]); lineIndex = lineIndex + 1
        UpdateQuad(Q[quadIndex], CubeVertices[2], CubeVertices[4], CubeVertices[8], CubeVertices[6]); quadIndex = quadIndex + 1
        UpdateQuad(Q[quadIndex], CubeVertices[1], CubeVertices[2], CubeVertices[4], CubeVertices[3]); quadIndex = quadIndex + 1
        UpdateQuad(Q[quadIndex], CubeVertices[1], CubeVertices[5], CubeVertices[7], CubeVertices[3]); quadIndex = quadIndex + 1
        UpdateQuad(Q[quadIndex], CubeVertices[5], CubeVertices[7], CubeVertices[8], CubeVertices[6]); quadIndex = quadIndex + 1

        -- Top face
        UpdateLine(L[lineIndex], CubeVertices[3], CubeVertices[4]); lineIndex = lineIndex + 1
        UpdateLine(L[lineIndex], CubeVertices[4], CubeVertices[8]); lineIndex = lineIndex + 1
        UpdateLine(L[lineIndex], CubeVertices[8], CubeVertices[7]); lineIndex = lineIndex + 1
        UpdateLine(L[lineIndex], CubeVertices[7], CubeVertices[3]); lineIndex = lineIndex + 1
        UpdateQuad(Q[quadIndex], CubeVertices[3], CubeVertices[4], CubeVertices[8], CubeVertices[7]); quadIndex = quadIndex + 1
    end

    for i = lineIndex, #Box3DLines do
        Box3DLines[i].Visible = false
    end
    for i = quadIndex, #Box3DQuads do
        Box3DQuads[i].Visible = false
    end
end

local function StartBox3D()
    if Box3DActive then return end
    Box3DActive = true
    InitBox3D()
    print("[3D BOX] Activated")
end

local function StopBox3D()
    if not Box3DActive then return end
    Box3DActive = false
    for _, line in pairs(Box3DLines) do
        line.Visible = false
    end
    for _, quad in pairs(Box3DQuads) do
        quad.Visible = false
    end
    print("[3D BOX] Deactivated")
end

RunService.RenderStepped:Connect(DrawBoxESP)

_G.ToggleBox3D = function(state)
    if state then
        StartBox3D()
    else
        StopBox3D()
    end
end

-- ======================================================
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
Title.Text = "META v3.13"
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
Version.Text = "v3.13"
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

local TabNames = {"Aimbot", "Visuals", "AI"}
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
        elseif globalVar == "Box3D" then
            _G.ToggleBox3D(newVal)
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
        "3D Box / 3Д Бокс",
        "Бокс который обводит игрока белым цветом, скоро будут добавлены другие.",
        "Box3D",
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
-- AI СТРАНИЦА (С РАБОТАЮЩЕЙ КЛАВИАТУРОЙ)
-- ======================================================
local aiPage = ContentPages["AI"]
if aiPage then
    for _, child in pairs(aiPage:GetChildren()) do
        child:Destroy()
    end
    
    local y = 10
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 35)
    titleLabel.Position = UDim2.new(0, 0, 0, y)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🤖 META AI"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 22
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = aiPage
    y = y + 45
    
    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, 0, 0, 20)
    subLabel.Position = UDim2.new(0, 0, 0, y)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = "Спроси меня о функциях чита"
    subLabel.TextColor3 = Color3.fromRGB(156, 163, 175)
    subLabel.TextSize = 13
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextXAlignment = Enum.TextXAlignment.Center
    subLabel.Parent = aiPage
    y = y + 30
    
    -- Контейнер для ввода
    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(0.9, 0, 0, 50)
    inputContainer.Position = UDim2.new(0.05, 0, 0, y)
    inputContainer.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    inputContainer.BorderSizePixel = 1
    inputContainer.BorderColor3 = Color3.fromRGB(42, 47, 58)
    inputContainer.Parent = aiPage
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 10)
    inputCorner.Parent = inputContainer
    
    -- Поле ввода (TextBox)
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -20, 1, 0)
    inputBox.Position = UDim2.new(0, 10, 0, 0)
    inputBox.BackgroundTransparency = 1
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.PlaceholderText = "Напиши вопрос..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(156, 163, 175)
    inputBox.ClearTextOnFocus = false
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 16
    inputBox.Selectable = true
    inputBox.Active = true
    inputBox.MultiLine = false
    inputBox.Parent = inputContainer
    
    -- ФИКС: Функция открытия клавиатуры
    local function OpenKeyboard()
        inputBox:CaptureFocus()
        task.wait(0.1)
        if not inputBox:IsFocused() then
            inputBox:Select()
        end
    end
    
    -- Все способы открытия клавиатуры
    inputBox.MouseButton1Click:Connect(OpenKeyboard)
    inputBox.TouchTap:Connect(OpenKeyboard)
    inputContainer.MouseButton1Click:Connect(OpenKeyboard)
    inputContainer.TouchTap:Connect(OpenKeyboard)
    
    y = y + 60
    
    -- Кнопка отправки
    local sendBtn = Instance.new("TextButton")
    sendBtn.Size = UDim2.new(0.25, 0, 0, 40)
    sendBtn.Position = UDim2.new(0.375, 0, 0, y)
    sendBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    sendBtn.Text = "💬 Спросить"
    sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendBtn.Font = Enum.Font.GothamBold
    sendBtn.TextSize = 14
    sendBtn.Parent = aiPage
    
    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(0, 8)
    sendCorner.Parent = sendBtn
    
    sendBtn.MouseEnter:Connect(function()
        sendBtn.BackgroundColor3 = Color3.fromRGB(79, 150, 255)
    end)
    sendBtn.MouseLeave:Connect(function()
        sendBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    end)
    
    y = y + 50
    
    -- Контейнер для сообщений
    local messagesContainer = Instance.new("ScrollingFrame")
    messagesContainer.Size = UDim2.new(0.9, 0, 0.45, 0)
    messagesContainer.Position = UDim2.new(0.05, 0, 0, y)
    messagesContainer.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
    messagesContainer.BackgroundTransparency = 0.3
    messagesContainer.BorderSizePixel = 0
    messagesContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    messagesContainer.ScrollBarThickness = 4
    messagesContainer.ClipsDescendants = true
    messagesContainer.Parent = aiPage
    
    local msgCorner = Instance.new("UICorner")
    msgCorner.CornerRadius = UDim.new(0, 10)
    msgCorner.Parent = messagesContainer
    
    -- Список сообщений
    local messages = {}
    
    local function AddMessage(text, isUser)
        local msgFrame = Instance.new("Frame")
        msgFrame.Size = UDim2.new(1, -10, 0, 0)
        msgFrame.Position = UDim2.new(0, 5, 0, #messages * 35 + 5)
        msgFrame.BackgroundTransparency = 1
        msgFrame.Parent = messagesContainer
        
        local msgLabel = Instance.new("TextLabel")
        msgLabel.Size = UDim2.new(1, 0, 0, 30)
        msgLabel.BackgroundTransparency = 1
        msgLabel.Text = (isUser and "👤 " or "🤖 ") .. text
        msgLabel.TextColor3 = isUser and Color3.fromRGB(200, 200, 255) or Color3.fromRGB(200, 255, 200)
        msgLabel.TextSize = 14
        msgLabel.Font = Enum.Font.Gotham
        msgLabel.TextXAlignment = Enum.TextXAlignment.Left
        msgLabel.TextWrapped = true
        msgLabel.TextYAlignment = Enum.TextYAlignment.Top
        msgLabel.Size = UDim2.new(1, 0, 0, 30)
        msgLabel.Parent = msgFrame
        
        local textBounds = msgLabel.TextBounds
        msgLabel.Size = UDim2.new(1, 0, 0, textBounds.Y + 10)
        msgFrame.Size = UDim2.new(1, -10, 0, textBounds.Y + 15)
        
        table.insert(messages, msgFrame)
        
        local totalHeight = 0
        for _, m in pairs(messages) do
            totalHeight = totalHeight + m.Size.Y.Offset + 5
        end
        messagesContainer.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
        messagesContainer.CanvasPosition = Vector2.new(0, totalHeight)
    end
    
    AddMessage("Задай вопрос о функциях чита...", false)
    
    -- ======================================================
    -- AI ЛОГИКА
    -- ======================================================
    local function GetAIResponse(question)
        local q = string.lower(question)
        
        local scriptKeywords = {
            "aimbot", "аимбот", "chams", "подсветк", "box", "бокс", "tracers", "лучи",
            "трассеры", "names", "имен", "fullbright", "яркост", "f1", "f2", "f3", "f4", "f5", "f6",
            "клавиш", "горяч", "статус", "включен", "настройк", "меню", "функци", "помощ",
            "обновл", "верси", "скачать", "insert", "f8", "скрипт", "чит", "meta", "куб",
            "коробк", "квадрат", "лини", "веер", "свет", "ночь", "темно", "солнце"
        }
        
        local isAboutScript = false
        for _, keyword in ipairs(scriptKeywords) do
            if string.find(q, keyword) then
                isAboutScript = true
                break
            end
        end
        
        if not isAboutScript then
            return ""
        end
        
        if string.find(q, "aimbot") or string.find(q, "аимбот") or string.find(q, "наведени") or 
           string.find(q, "прицел") or string.find(q, "авто") then
            return "Aimbot — автонаведение на противников при зажатии ПКМ.\nВключается: 'Master Aimbot' или F1.\nНастройки: FOV Range, Target Body Part."
        end
        
        if string.find(q, "chams") or string.find(q, "подсветк") or string.find(q, "силуэт") or 
           string.find(q, "обводк") or string.find(q, "цвет") or string.find(q, "контур") or
           string.find(q, "часы") or string.find(q, "сияни") then
            return "Chams — подсветка игроков сквозь стены.\nВраги — красные, союзники — зелёные.\nВключается: 'Chams' или F2."
        end
        
        if string.find(q, "3d box") or string.find(q, "3д бокс") or string.find(q, "куб") or 
           string.find(q, "коробк") or string.find(q, "квадрат") then
            return "3D Box — белый куб вокруг игрока.\nВключается: '3D Box' или F3.\nИсправлено мерцание в v3.12!"
        end
        
        if string.find(q, "tracers") or string.find(q, "лучи") or string.find(q, "трассеры") or 
           string.find(q, "лини") or string.find(q, "веер") then
            return "Tracers — линии от тебя к противникам.\nВключается: 'Tracers' или F4.\nПлавное исчезновение при выключении."
        end
        
        if string.find(q, "names") or string.find(q, "имен") or string.find(q, "дистанци") or 
           string.find(q, "ник") or string.find(q, "игрок") or string.find(q, "надпись") then
            return "Names & Distance — имена и дистанция над игроками.\nВключается: чекбокс или F5.\nИсправлен баг с респавном."
        end
        
        if string.find(q, "fullbright") or string.find(q, "яркост") or string.find(q, "освещени") or 
           string.find(q, "ночь") or string.find(q, "темно") or string.find(q, "свет") then
            return "Full Bright — делает карту светлее.\nВключается: чекбокс или F6."
        end
        
        if string.find(q, "горяч") or string.find(q, "клавиш") or string.find(q, "кнопк") or 
           string.find(q, "f1") or string.find(q, "f2") or string.find(q, "f3") or 
           string.find(q, "f4") or string.find(q, "f5") or string.find(q, "f6") then
            return "Горячие клавиши:\n• Insert/F8 — меню\n• F1 — Aimbot\n• F2 — Chams\n• F3 — 3D Box\n• F4 — Tracers\n• F5 — Names\n• F6 — FullBright"
        end
        
        if string.find(q, "статус") or string.find(q, "состояни") or string.find(q, "включен") or 
           string.find(q, "активи") or string.find(q, "работа") then
            return string.format(
                "Текущий статус:\n• Aimbot: %s\n• Chams: %s\n• 3D Box: %s\n• Tracers: %s\n• Names: %s\n• FullBright: %s",
                _G.AimbotEnabled and "✅ ВКЛ" or "❌ ВЫКЛ",
                _G.BoxESP and "✅ ВКЛ" or "❌ ВЫКЛ",
                _G.Box3D and "✅ ВКЛ" or "❌ ВЫКЛ",
                _G.Snaplines and "✅ ВКЛ" or "❌ ВЫКЛ",
                _G.EspNames and "✅ ВКЛ" or "❌ ВЫКЛ",
                _G.FullBrightEnabled and "✅ ВКЛ" or "❌ ВЫКЛ"
            )
        end
        
        if string.find(q, "обновл") or string.find(q, "верси") or string.find(q, "скачать") or 
           string.find(q, "github") or string.find(q, "v3") then
            return "Текущая версия: v3.13\nСкачать: loadstring(game:HttpGet('https://raw.githubusercontent.com/QwertyX01/Meta/main/Meta.lua', true))()"
        end
        
        if string.find(q, "помощ") or string.find(q, "помоги") or string.find(q, "функци") or 
           string.find(q, "что умее") or string.find(q, "список") then
            return "Я умею отвечать на вопросы о:\n• Aimbot\n• Chams (подсветка)\n• 3D Box\n• Tracers (лучи)\n• Names (имена)\n• FullBright (яркость)\n• Горячие клавиши\n• Статус"
        end
        
        return "❓ Не понял вопрос. Напиши 'помощь' для списка команд."
    end
    
    sendBtn.MouseButton1Click:Connect(function()
        local question = inputBox.Text
        if question == "" or question == "Напиши вопрос..." then
            AddMessage("⚠️ Напиши вопрос!", false)
            return
        end
        
        AddMessage(question, true)
        inputBox.Text = ""
        
        local response = GetAIResponse(question)
        if response == "" then
            return
        end
        
        AddMessage(response, false)
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            sendBtn.MouseButton1Click:Fire()
        end
    end)
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
        _G.Box3D = not _G.Box3D
        _G.ToggleBox3D(_G.Box3D)
        print(string.format("[DEBUG] Box3D: %s", tostring(_G.Box3D)))
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

print("[META] v3.13 Loaded Successfully!")
print("[META] Added: AI tab with chat assistant!")
print("[META] Chams: AdolfFX style (red enemies, green allies)")
print("[META] 3D Box: no flickering!")
print("[META] Names & Distance: fixed respawn bug!")
print("[META] F1 - Aimbot | F2 - Chams | F3 - 3D Box | F4 - Tracers | F5 - Names | F6 - FullBright")
print("[META] Press Insert or F8 to toggle menu")
