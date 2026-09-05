-- ROCKET::META_UI_V7.0.49 FINAL

local function SetupAntiCheatBypass()
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Network = require(ReplicatedStorage.Database.Security.Network)
        local OriginalCreatePacket = Network.CreatePacket
        Network.CreatePacket = function(namespace, packetName, schema, options)
            local packet = OriginalCreatePacket(namespace, packetName, schema, options)
            if packet and packet.Send then
                local OriginalSend = packet.Send
                packet.Send = function(data)
                    local success, result = pcall(function()
                        local BufferCodec = require(ReplicatedStorage.Database.Security.Network.BufferCodec)
                        local encoded, instances = BufferCodec.Encode(data)
                        local remote = ReplicatedStorage:FindFirstChild("NetworkRemotes")
                        local folder = remote and remote:FindFirstChild(namespace)
                        local event = folder and folder:FindFirstChild(packetName)
                        if event then event:FireServer(encoded, instances) return true end
                        return false
                    end)
                    if success and result then return true end
                    return OriginalSend(data)
                end
            end
            return packet
        end
        Network.canPassRateLimit = function() task.wait(0.01) return true, nil end
    end)
end
SetupAntiCheatBypass()

local function HideFromScanner(gui)
    pcall(function() sethiddenproperty(gui, "RobloxLocked", true) sethiddenproperty(gui, "Archivable", false) end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

_G.CustomThemeEnabled = false
_G.MenuThemeColor = Color3.fromRGB(59, 130, 246)
_G.CurrentLang = "EN"
_G.MenuOpacity = 12
_G.RainbowEnabled = false
_G.MenuScale = 45
_G.FlyingDots = false
_G.ChamsEnabled = false
_G.ESPEnabled = false
_G.HealthBarEnabled = false
_G.SkeletonEnabled = false

local Dots = {}
local DotConnection = nil
local opacitySliderFill, opacitySliderHandle, opacityValue = nil, nil, nil
local scaleSliderFill, scaleSliderHandle, scaleValue = nil, nil, nil
local pickerDot, pickerContainer = nil, nil
local SetToggleState, ShiftContainer = nil, nil
local SetChamsToggleState, SetRainbowToggleState = nil, nil
local SetFlyingToggleState, SetESPToggleState = nil, nil
local SetHealthBarToggleState, SetSkeletonToggleState = nil, nil

local LANG = {
    RU = {
        Tabs = {"Аимбот", "Визуал", "Настройки"},
        Toggles = {
            UI_Color = {"Цвет интерфейса", "Включить кастомизацию цвета интерфейса"},
            Opacity = {"Прозрачность", "Регулировка прозрачности меню (0-50%)"},
            Rainbow = {"Разноцветная обводка", "Включить радужную обводку меню"},
            Scale = {"Scaling the menu", "Масштабирование меню (60-140%)"},
            FlyingDots = {"Летающие точки", "Точки, летающие с верху меню"},
            Chams = {"Чамсы", "Функция которая делает противников фиолетовым"},
            ESP = {"Линии и 3D Боксы", "Линии с боксами которые ведут к противникам"},
            Skeleton = {"Скелетон", "Скелетон для противников"},
            HealthBar = {"Здоровье противников", "Полоска здоровья над головой"},
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
            Chams = {"Chams", "Makes enemies purple"},
            ESP = {"Tracers and 3D Box", "Lines with boxes leading to enemies"},
            Skeleton = {"Skeleton", "Skeleton for enemies"},
            HealthBar = {"Health Bar", "Health bar above enemies"},
            Reset = {"Reset Settings", "Return all settings to default"}
        }
    }
}

local function GetLang() return _G.CurrentLang == "RU" and LANG.RU or LANG.EN end

local function PlayTabSound()
    local sound = Instance.new("Sound")
    sound.Name = "UISound"
    sound.SoundId = "rbxassetid://88442833509532"
    sound.Volume = 0.5
    sound.Parent = SoundService
    sound:Play()
    task.delay(sound.TimeLength + 0.1, function() sound:Destroy() end)
end

local function PlayClickSound()
    local sound = Instance.new("Sound")
    sound.Name = "UISound"
    sound.SoundId = "rbxassetid://88442833509532"
    sound.Volume = 0.3
    sound.Parent = SoundService
    sound:Play()
    task.delay(sound.TimeLength + 0.1, function() sound:Destroy() end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RobloxGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999998
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui
HideFromScanner(ScreenGui)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "GameUI"
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

local MainScale = Instance.new("UIScale")
MainScale.Scale = 1
MainScale.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = _G.MenuThemeColor
MainStroke.Transparency = 0.4
MainStroke.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Name = "Topbar"
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

local BetaLabel = Instance.new("TextLabel")
BetaLabel.Size = UDim2.new(0, 50, 1, 0)
BetaLabel.Position = UDim2.new(0, 75, 0, 0)
BetaLabel.BackgroundTransparency = 1
BetaLabel.Text = "beta"
BetaLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
BetaLabel.TextSize = 12
BetaLabel.Font = Enum.Font.Gotham
BetaLabel.TextXAlignment = Enum.TextXAlignment.Left
BetaLabel.TextYAlignment = Enum.TextYAlignment.Center
BetaLabel.Parent = Header

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
    if info and info.Name then GameNameLabel.Text = info.Name end
end)

local SearchContainer = Instance.new("Frame")
SearchContainer.Name = "SearchBar"
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
SearchClose.Visible = false
SearchClose.Parent = SearchContainer

SearchClose.MouseButton1Click:Connect(function()
    SearchInput.Text = "Search..."
    SearchClose.Visible = false
    PlayClickSound()
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

local function IsEnemy(p)
    if not p or p == LocalPlayer then return false end
    if p.Team and LocalPlayer.Team then
        if p.Team ~= LocalPlayer.Team then return true end
        if p.Team.Name ~= LocalPlayer.Team.Name then return true end
    end
    if p.TeamColor and LocalPlayer.TeamColor then
        if p.TeamColor ~= LocalPlayer.TeamColor then return true end
    end
    local mySide = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("Side") or ""
    local enemySide = p:GetAttribute("Team") or p:GetAttribute("Side") or ""
    if mySide ~= "" and enemySide ~= "" then return mySide ~= enemySide end
    return false
end

-- CHAMS
local ChamsConnections = {}
local function PaintCharacter(character, p)
    if not character or not p then return end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Highlight") and child:GetAttribute("META_Chams") then child:Destroy() end
    end
    if IsEnemy(p) then
        local highlight = Instance.new("Highlight")
        highlight.Name = "Highlight"
        highlight:SetAttribute("META_Chams", true)
        highlight.FillColor = Color3.fromRGB(110, 60, 170)
        highlight.OutlineColor = Color3.fromRGB(110, 60, 170)
        highlight.FillTransparency = 0.65
        highlight.OutlineTransparency = 0.5
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = character
        highlight.Parent = character
    end
end

local function SetupPlayer(p)
    if p == LocalPlayer then return end
    if ChamsConnections[p] then ChamsConnections[p]:Disconnect() end
    ChamsConnections[p] = p.CharacterAdded:Connect(function(char)
        task.wait(0.6)
        PaintCharacter(char, p)
    end)
    if p.Character then task.wait(0.2) PaintCharacter(p.Character, p) end
end

local function ApplyChams()
    if _G.UnloadChams then _G.UnloadChams() end
    _G.ChamsEnabled = true
    for _, p in ipairs(Players:GetPlayers()) do SetupPlayer(p) end
    ChamsConnections.PlayerAdded = Players.PlayerAdded:Connect(SetupPlayer)
    _G.UnloadChams = function()
        _G.ChamsEnabled = false
        if ChamsConnections.PlayerAdded then ChamsConnections.PlayerAdded:Disconnect() end
        for _, p in ipairs(Players:GetPlayers()) do
            if ChamsConnections[p] then ChamsConnections[p]:Disconnect() end
            if p.Character then
                for _, child in ipairs(p.Character:GetChildren()) do
                    if child:IsA("Highlight") and child:GetAttribute("META_Chams") then child:Destroy() end
                end
            end
        end
    end
end

local function RemoveChams()
    if _G.UnloadChams then _G.UnloadChams() end
end

-- ESP
local ESPConnections = {}
local function SetupESP()
    local function NewLine()
        local line = Drawing.new("Line")
        line.Visible = false
        line.From = Vector2.new(0, 0)
        line.To = Vector2.new(1, 1)
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Thickness = 1.4
        line.Transparency = 1
        return line
    end
    local function CreateESP(target)
        local lines = {}
        for i = 1, 12 do lines[i] = NewLine() end
        lines.Tracer = NewLine()
        local conn = RunService.RenderStepped:Connect(function()
            if not _G.ESPEnabled then for _, l in pairs(lines) do l.Visible = false end return end
            local char = target.Character
            if not char then for _, l in pairs(lines) do l.Visible = false end return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChild("Humanoid")
            if not hrp or not head or not hum or hum.Health <= 0 then for _, l in pairs(lines) do l.Visible = false end return end
            if target == LocalPlayer or not IsEnemy(target) then for _, l in pairs(lines) do l.Visible = false end return end
            local rootVisible = Camera:WorldToViewportPoint(hrp.Position)
            if not rootVisible then for _, l in pairs(lines) do l.Visible = false end return end
            local scale = head.Size.Y / 2
            local boxSize = Vector3.new(2, 3, 1.5) * (scale * 2)
            local cf = hrp.CFrame
            local c = {}
            c[1] = Camera:WorldToViewportPoint((cf * CFrame.new(-boxSize.X, boxSize.Y, -boxSize.Z)).Position)
            c[2] = Camera:WorldToViewportPoint((cf * CFrame.new(-boxSize.X, boxSize.Y, boxSize.Z)).Position)
            c[3] = Camera:WorldToViewportPoint((cf * CFrame.new(boxSize.X, boxSize.Y, boxSize.Z)).Position)
            c[4] = Camera:WorldToViewportPoint((cf * CFrame.new(boxSize.X, boxSize.Y, -boxSize.Z)).Position)
            c[5] = Camera:WorldToViewportPoint((cf * CFrame.new(-boxSize.X, -boxSize.Y, -boxSize.Z)).Position)
            c[6] = Camera:WorldToViewportPoint((cf * CFrame.new(-boxSize.X, -boxSize.Y, boxSize.Z)).Position)
            c[7] = Camera:WorldToViewportPoint((cf * CFrame.new(boxSize.X, -boxSize.Y, boxSize.Z)).Position)
            c[8] = Camera:WorldToViewportPoint((cf * CFrame.new(boxSize.X, -boxSize.Y, -boxSize.Z)).Position)
            local edges = {{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}
            for i, e in ipairs(edges) do
                lines[i].From = Vector2.new(c[e[1]].X, c[e[1]].Y)
                lines[i].To = Vector2.new(c[e[2]].X, c[e[2]].Y)
                lines[i].Visible = true
            end
            local bottomPos = Camera:WorldToViewportPoint((cf * CFrame.new(0, -boxSize.Y, 0)).Position)
            lines.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            lines.Tracer.To = Vector2.new(bottomPos.X, bottomPos.Y)
            lines.Tracer.Visible = true
        end)
        ESPConnections[target] = conn
    end
    local function ApplyESP()
        if _G.UnloadESP then _G.UnloadESP() end
        _G.ESPEnabled = true
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then CreateESP(p) end
        end
        ESPConnections.PlayerAdded = Players.PlayerAdded:Connect(function(p)
            task.wait(1)
            if p ~= LocalPlayer and _G.ESPEnabled then CreateESP(p) end
        end)
        _G.UnloadESP = function()
            _G.ESPEnabled = false
            if ESPConnections.PlayerAdded then ESPConnections.PlayerAdded:Disconnect() end
            for _, conn in pairs(ESPConnections) do
                if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
            end
            ESPConnections = {}
        end
    end
    local function RemoveESP()
        if _G.UnloadESP then _G.UnloadESP() end
    end
    return ApplyESP, RemoveESP
end
local ApplyESP, RemoveESP = SetupESP()

task.spawn(function()
    while true do
        task.wait(1)
        if _G.ESPEnabled then RemoveESP() ApplyESP() end
    end
end)

-- SKELETON ESP
local SkeletonLines = {}
local SkeletonEnemies = {}
local SkeletonCacheTime = 0
local SkeletonConnection = nil

local function CreateSkeletonLine()
    local line = Drawing.new("Line")
    line.Thickness = 2
    line.Visible = false
    line.Color = Color3.fromRGB(255, 255, 255)
    line.Transparency = 1
    return line
end

local function GetSkeletonPos(part)
    if not part or not part:IsA("BasePart") then return nil end
    local pos = Camera:WorldToViewportPoint(part.Position)
    if pos.Z > 0 then return Vector2.new(pos.X, pos.Y) end
    return nil
end

local function RemoveSkeletonLines(target)
    local data = SkeletonLines[target]
    if data then
        pcall(function()
            for _, line in pairs(data) do
                line.Visible = false
                line:Remove()
            end
        end)
        SkeletonLines[target] = nil
    end
end

local function UpdateSkeletonEnemies()
    if tick() - SkeletonCacheTime < 0.5 then return end
    SkeletonCacheTime = tick()
    SkeletonEnemies = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character.Parent then
            if IsEnemy(player) then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    SkeletonEnemies[player] = {char = player.Character}
                else
                    RemoveSkeletonLines(player)
                end
            else
                RemoveSkeletonLines(player)
            end
        else
            RemoveSkeletonLines(player)
        end
    end
end

SkeletonConnection = RunService.RenderStepped:Connect(function()
    if not _G.SkeletonEnabled then
        for _, data in pairs(SkeletonLines) do
            for _, line in pairs(data) do line.Visible = false end
        end
        return
    end

    UpdateSkeletonEnemies()

    for player, data in pairs(SkeletonEnemies) do
        if not player or not player.Character or not player.Character.Parent then
            RemoveSkeletonLines(player)
            continue
        end

        local char = player.Character
        local head = char:FindFirstChild("Head")
        local upperTorso = char:FindFirstChild("UpperTorso")
        local lowerTorso = char:FindFirstChild("LowerTorso")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if not head or not upperTorso then
            RemoveSkeletonLines(player)
            continue
        end

        local headPos = GetSkeletonPos(head)
        local upperTorsoPos = GetSkeletonPos(upperTorso)
        local lowerTorsoPos = GetSkeletonPos(lowerTorso)
        local hrpPos = GetSkeletonPos(hrp)

        if not headPos or not upperTorsoPos then
            RemoveSkeletonLines(player)
            continue
        end

        if not SkeletonLines[player] then
            SkeletonLines[player] = {}
            for i = 1, 15 do table.insert(SkeletonLines[player], CreateSkeletonLine()) end
        end

        local lines = SkeletonLines[player]
        local idx = 1

        local function setLine(from, to, show)
            if from and to and show then
                lines[idx].From = from
                lines[idx].To = to
                lines[idx].Visible = true
                lines[idx].Thickness = 2
                lines[idx].Color = Color3.fromRGB(255, 255, 255)
            else
                lines[idx].Visible = false
            end
            idx = idx + 1
        end

        local leftUpperArm = char:FindFirstChild("LeftUpperArm")
        local leftLowerArm = char:FindFirstChild("LeftLowerArm")
        local leftHand = char:FindFirstChild("LeftHand")
        local rightUpperArm = char:FindFirstChild("RightUpperArm")
        local rightLowerArm = char:FindFirstChild("RightLowerArm")
        local rightHand = char:FindFirstChild("RightHand")
        local leftUpperLeg = char:FindFirstChild("LeftUpperLeg")
        local leftLowerLeg = char:FindFirstChild("LeftLowerLeg")
        local leftFoot = char:FindFirstChild("LeftFoot")
        local rightUpperLeg = char:FindFirstChild("RightUpperLeg")
        local rightLowerLeg = char:FindFirstChild("RightLowerLeg")
        local rightFoot = char:FindFirstChild("RightFoot")

        local leftUpperArmPos = GetSkeletonPos(leftUpperArm)
        local leftLowerArmPos = GetSkeletonPos(leftLowerArm)
        local leftHandPos = GetSkeletonPos(leftHand)
        local rightUpperArmPos = GetSkeletonPos(rightUpperArm)
        local rightLowerArmPos = GetSkeletonPos(rightLowerArm)
        local rightHandPos = GetSkeletonPos(rightHand)
        local leftUpperLegPos = GetSkeletonPos(leftUpperLeg)
        local leftLowerLegPos = GetSkeletonPos(leftLowerLeg)
        local leftFootPos = GetSkeletonPos(leftFoot)
        local rightUpperLegPos = GetSkeletonPos(rightUpperLeg)
        local rightLowerLegPos = GetSkeletonPos(rightLowerLeg)
        local rightFootPos = GetSkeletonPos(rightFoot)

        setLine(headPos, upperTorsoPos, true)
        setLine(upperTorsoPos, lowerTorsoPos, lowerTorsoPos ~= nil)
        setLine(upperTorsoPos, hrpPos, hrpPos ~= nil)
        setLine(upperTorsoPos, leftUpperArmPos, leftUpperArmPos ~= nil)
        setLine(leftUpperArmPos, leftLowerArmPos, leftUpperArmPos ~= nil and leftLowerArmPos ~= nil)
        setLine(leftLowerArmPos, leftHandPos, leftLowerArmPos ~= nil and leftHandPos ~= nil)
        setLine(upperTorsoPos, rightUpperArmPos, rightUpperArmPos ~= nil)
        setLine(rightUpperArmPos, rightLowerArmPos, rightUpperArmPos ~= nil and rightLowerArmPos ~= nil)
        setLine(rightLowerArmPos, rightHandPos, rightLowerArmPos ~= nil and rightHandPos ~= nil)

        if lowerTorsoPos then
            setLine(lowerTorsoPos, leftUpperLegPos, leftUpperLegPos ~= nil)
            setLine(lowerTorsoPos, rightUpperLegPos, rightUpperLegPos ~= nil)
        elseif hrpPos then
            setLine(hrpPos, leftUpperLegPos, leftUpperLegPos ~= nil)
            setLine(hrpPos, rightUpperLegPos, rightUpperLegPos ~= nil)
        else
            setLine(upperTorsoPos, leftUpperLegPos, leftUpperLegPos ~= nil)
            setLine(upperTorsoPos, rightUpperLegPos, rightUpperLegPos ~= nil)
        end

        setLine(leftUpperLegPos, leftLowerLegPos, leftUpperLegPos ~= nil and leftLowerLegPos ~= nil)
        setLine(rightUpperLegPos, rightLowerLegPos, rightUpperLegPos ~= nil and rightLowerLegPos ~= nil)
        setLine(leftLowerLegPos, leftFootPos, leftLowerLegPos ~= nil and leftFootPos ~= nil)
        setLine(rightLowerLegPos, rightFootPos, rightLowerLegPos ~= nil and rightFootPos ~= nil)

        while idx <= #lines do
            lines[idx].Visible = false
            idx = idx + 1
        end
    end

    for player, _ in pairs(SkeletonLines) do
        if not SkeletonEnemies[player] then RemoveSkeletonLines(player) end
    end
end)

local function ApplySkeleton()
    _G.SkeletonEnabled = true
end

local function RemoveSkeleton()
    _G.SkeletonEnabled = false
    for player, _ in pairs(SkeletonLines) do RemoveSkeletonLines(player) end
    SkeletonEnemies = {}
end

-- HEALTH BAR ESP
local HealthBars = {}
local HealthEnemies = {}
local HealthCacheTime = 0
local HealthHistory = {}
local HealthConnection = nil

local function CreateHealthBar()
    local bg = Drawing.new("Square")
    bg.Thickness = 0
    bg.Filled = true
    bg.Visible = false
    bg.Color = Color3.fromRGB(20, 22, 30)
    bg.Transparency = 0.5
    bg.ZIndex = 0

    local bar = Drawing.new("Square")
    bar.Thickness = 0
    bar.Filled = true
    bar.Visible = false
    bar.Transparency = 0.35
    bar.ZIndex = 1

    local border = Drawing.new("Square")
    border.Thickness = 1
    border.Filled = false
    border.Visible = false
    border.Color = Color3.fromRGB(50, 55, 70)
    border.Transparency = 0.4
    border.ZIndex = 2

    return {Bg = bg, Bar = bar, Border = border}
end

local function GetPlayerHealth(char)
    if not char then return nil, nil end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health and humanoid.MaxHealth then
        if humanoid.Health > 0 then return humanoid.Health, humanoid.MaxHealth end
        return nil, nil
    end
    return nil, nil
end

local function GetHealthColor(hp, maxHp, prevHp)
    local percent = hp / maxHp
    local isDamaged = prevHp and prevHp > hp and (prevHp - hp) > 5
    if isDamaged then return Color3.fromRGB(255, 255, 255) end
    if percent <= 0.20 then return Color3.fromRGB(255, 50, 50)
    elseif percent <= 0.40 then return Color3.fromRGB(255, 170, 50)
    elseif percent <= 0.60 then return Color3.fromRGB(255, 220, 50)
    elseif percent <= 0.80 then return Color3.fromRGB(150, 255, 50)
    else return Color3.fromRGB(50, 255, 150) end
end

local function RemoveHealthBarData(target)
    local data = HealthBars[target]
    if data then
        pcall(function()
            data.Bg.Visible = false
            data.Bar.Visible = false
            data.Border.Visible = false
            data.Bg:Remove()
            data.Bar:Remove()
            data.Border:Remove()
        end)
        HealthBars[target] = nil
    end
    HealthHistory[target] = nil
end

local function UpdateHealthEnemies()
    if tick() - HealthCacheTime < 0.5 then return end
    HealthCacheTime = tick()
    HealthEnemies = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character.Parent then
            if IsEnemy(player) then
                local hp, maxHp = GetPlayerHealth(player.Character)
                if hp and hp > 0 then
                    HealthEnemies[player] = {char = player.Character, hp = hp, maxHp = maxHp}
                else
                    RemoveHealthBarData(player)
                end
            else
                RemoveHealthBarData(player)
            end
        else
            RemoveHealthBarData(player)
        end
    end
end

HealthConnection = RunService.RenderStepped:Connect(function()
    if not _G.HealthBarEnabled then
        for _, data in pairs(HealthBars) do
            data.Bg.Visible = false
            data.Bar.Visible = false
            data.Border.Visible = false
        end
        return
    end

    UpdateHealthEnemies()

    for player, data in pairs(HealthEnemies) do
        if not player or not player.Character or not player.Character.Parent then
            RemoveHealthBarData(player)
            continue
        end

        local char = player.Character
        local hp, maxHp = GetPlayerHealth(char)
        if not hp or hp <= 0 then
            RemoveHealthBarData(player)
            continue
        end

        local prevHp = HealthHistory[player]
        HealthHistory[player] = hp

        local head = char:FindFirstChild("Head")
        if not head then
            RemoveHealthBarData(player)
            continue
        end

        local headPos, headVis = Camera:WorldToViewportPoint(head.Position)
        local distance = (Camera.CFrame.Position - head.Position).Magnitude

        if headVis and headPos.Z > 0 and distance <= 1000 then
            local barWidth = 50
            local barHeight = 6
            local scale = 1 / (headPos.Z * 0.015 + 0.5)
            if scale > 1.5 then scale = 1.5 end
            if scale < 0.4 then scale = 0.4 end

            local finalWidth = barWidth * scale
            local finalHeight = barHeight * scale
            local offsetY = 4 * scale
            local barX = headPos.X - finalWidth / 2
            local barY = headPos.Y - finalHeight - offsetY

            if barX < 5 then barX = 5 end
            if barX + finalWidth > Camera.ViewportSize.X - 5 then barX = Camera.ViewportSize.X - finalWidth - 5 end
            if barY < 5 then barY = 5 end

            if not HealthBars[player] then HealthBars[player] = CreateHealthBar() end

            local barData = HealthBars[player]
            local hpPercent = hp / maxHp
            local filledWidth = finalWidth * hpPercent

            barData.Bg.Size = Vector2.new(finalWidth, finalHeight)
            barData.Bg.Position = Vector2.new(barX, barY)
            barData.Bg.Visible = true
            barData.Bg.Transparency = 0.5
            barData.Bg.Color = Color3.fromRGB(20, 22, 30)
            barData.Bg.Thickness = 0

            barData.Bar.Size = Vector2.new(math.max(filledWidth, 0.5), finalHeight)
            barData.Bar.Position = Vector2.new(barX, barY)
            barData.Bar.Visible = true
            barData.Bar.Transparency = 0.35
            barData.Bar.Thickness = 0
            barData.Bar.Color = GetHealthColor(hp, maxHp, prevHp)

            if prevHp and prevHp > hp and (prevHp - hp) > 5 then
                barData.Bar.Color = Color3.fromRGB(255, 255, 255)
                barData.Bar.Transparency = 0.5
            end

            barData.Border.Size = Vector2.new(finalWidth, finalHeight)
            barData.Border.Position = Vector2.new(barX, barY)
            barData.Border.Visible = true
            barData.Border.Transparency = 0.4
            barData.Border.Color = Color3.fromRGB(50, 55, 70)
            barData.Border.Thickness = 0.5
        else
            if HealthBars[player] then
                HealthBars[player].Bg.Visible = false
                HealthBars[player].Bar.Visible = false
                HealthBars[player].Border.Visible = false
            end
        end
    end

    for player, _ in pairs(HealthBars) do
        if not HealthEnemies[player] then RemoveHealthBarData(player) end
    end
end)

local function ApplyHealthBar()
    _G.HealthBarEnabled = true
end

local function RemoveHealthBar()
    _G.HealthBarEnabled = false
    for player, _ in pairs(HealthBars) do RemoveHealthBarData(player) end
    HealthEnemies = {}
    HealthHistory = {}
end

-- ДАЛЕЕ ВЕСЬ ОСТАЛЬНОЙ КОД UI (вкладки, настройки, иконка, очивка)
-- Этот код идентичен предыдущему, без изменений
