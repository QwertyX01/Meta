-- ROCKET::META_UI_V7.0.47

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

-- SKELETON ESP (LOADSTRING ИСПРАВЛЕННЫЙ)
local SkeletonLoaded = false
local function ApplySkeleton()
    _G.SkeletonEnabled = true
    getgenv().SkeletonEnabled = true
    if not SkeletonLoaded then
        SkeletonLoaded = true
        local skeletonScript = [[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local skeletons = {}
local enemiesCache = {}
local cacheTime = 0

local function IsEnemy(player)
    if not player or player == LocalPlayer then return false end
    if player.Team and LocalPlayer.Team then
        if player.Team ~= LocalPlayer.Team then return true end
        if player.Team.Name ~= LocalPlayer.Team.Name then return true end
    end
    if player.TeamColor and LocalPlayer.TeamColor then
        if player.TeamColor ~= LocalPlayer.TeamColor then return true end
    end
    local mySide = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("Side") or ""
    local enemySide = player:GetAttribute("Team") or player:GetAttribute("Side") or ""
    if mySide ~= "" and enemySide ~= "" then return mySide ~= enemySide end
    return false
end

local function getPlayerHealth(character)
    if not character then return nil, nil end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health and humanoid.MaxHealth then
        if humanoid.Health > 0 then return humanoid.Health, humanoid.MaxHealth end
        return nil, nil
    end
    return nil, nil
end

local function createLine()
    local line = Drawing.new("Line")
    line.Thickness = 2
    line.Visible = false
    line.Color = Color3.fromRGB(255, 255, 255)
    line.Transparency = 1
    return line
end

local function getPos(part)
    if not part or not part:IsA("BasePart") then return nil end
    local pos = Camera:WorldToViewportPoint(part.Position)
    if pos.Z > 0 then return Vector2.new(pos.X, pos.Y) end
    return nil
end

local function removeSkeleton(target)
    local data = skeletons[target]
    if data then
        pcall(function()
            for _, line in pairs(data) do
                line.Visible = false
                line:Remove()
            end
        end)
        skeletons[target] = nil
    end
end

local function updateEnemiesCache()
    if tick() - cacheTime < 0.5 then return end
    cacheTime = tick()
    enemiesCache = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character.Parent then
            if IsEnemy(player) then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    enemiesCache[player] = {char = player.Character}
                else
                    removeSkeleton(player)
                end
            else
                removeSkeleton(player)
            end
        else
            removeSkeleton(player)
        end
    end
end

local skeletonConnection = RunService.RenderStepped:Connect(function()
    if not _G.SkeletonEnabled then
        for _, data in pairs(skeletons) do
            for _, line in pairs(data) do line.Visible = false end
        end
        return
    end

    updateEnemiesCache()

    for player, data in pairs(enemiesCache) do
        if not player or not player.Character or not player.Character.Parent then
            removeSkeleton(player)
            continue
        end

        local char = player.Character
        local head = char:FindFirstChild("Head")
        local upperTorso = char:FindFirstChild("UpperTorso")
        local lowerTorso = char:FindFirstChild("LowerTorso")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if not head or not upperTorso then
            removeSkeleton(player)
            continue
        end

        local headPos = getPos(head)
        local upperTorsoPos = getPos(upperTorso)
        local lowerTorsoPos = getPos(lowerTorso)
        local hrpPos = getPos(hrp)

        if not headPos or not upperTorsoPos then
            removeSkeleton(player)
            continue
        end

        if not skeletons[player] then
            skeletons[player] = {}
            for i = 1, 15 do table.insert(skeletons[player], createLine()) end
        end

        local lines = skeletons[player]
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

        local leftUpperArmPos = getPos(leftUpperArm)
        local leftLowerArmPos = getPos(leftLowerArm)
        local leftHandPos = getPos(leftHand)
        local rightUpperArmPos = getPos(rightUpperArm)
        local rightLowerArmPos = getPos(rightLowerArm)
        local rightHandPos = getPos(rightHand)
        local leftUpperLegPos = getPos(leftUpperLeg)
        local leftLowerLegPos = getPos(leftLowerLeg)
        local leftFootPos = getPos(leftFoot)
        local rightUpperLegPos = getPos(rightUpperLeg)
        local rightLowerLegPos = getPos(rightLowerLeg)
        local rightFootPos = getPos(rightFoot)

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

    for player, _ in pairs(skeletons) do
        if not enemiesCache[player] then removeSkeleton(player) end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeSkeleton(player)
    enemiesCache[player] = nil
end)

getgenv().UnloadSkeletonFunc = function()
    _G.SkeletonEnabled = false
    if skeletonConnection then skeletonConnection:Disconnect() end
    for player, _ in pairs(skeletons) do removeSkeleton(player) end
    skeletons = {}
    enemiesCache = {}
end
]]
        local skeletonFunc = loadstring(skeletonScript)
        if skeletonFunc then
            skeletonFunc()
        end
    else
        _G.SkeletonEnabled = true
        getgenv().SkeletonEnabled = true
    end
end

local function RemoveSkeleton()
    _G.SkeletonEnabled = false
    getgenv().SkeletonEnabled = false
    if getgenv().UnloadSkeletonFunc then
        getgenv().UnloadSkeletonFunc()
    end
end

-- HEALTH BAR ESP
local healthBars = {}
local enemiesCache = {}
local cacheTime = 0
local healthHistory = {}

local function SetupHealthBar()
    local function createBarPair()
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

    local function getPlayerHealth(character)
        if not character then return nil, nil end
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health and humanoid.MaxHealth then
            if humanoid.Health > 0 then return humanoid.Health, humanoid.MaxHealth end
            return nil, nil
        end
        return nil, nil
    end

    local function getHealthColor(health, maxHealth, prevHealth)
        local percent = health / maxHealth
        local isDamaged = prevHealth and prevHealth > health and (prevHealth - health) > 5
        if isDamaged then return Color3.fromRGB(255, 255, 255) end
        if percent <= 0.20 then return Color3.fromRGB(255, 50, 50)
        elseif percent <= 0.40 then return Color3.fromRGB(255, 170, 50)
        elseif percent <= 0.60 then return Color3.fromRGB(255, 220, 50)
        elseif percent <= 0.80 then return Color3.fromRGB(150, 255, 50)
        else return Color3.fromRGB(50, 255, 150) end
    end

    local function removeHealthBar(target)
        local data = healthBars[target]
        if data then
            pcall(function()
                data.Bg.Visible = false
                data.Bar.Visible = false
                data.Border.Visible = false
                data.Bg:Remove()
                data.Bar:Remove()
                data.Border:Remove()
            end)
            healthBars[target] = nil
        end
        healthHistory[target] = nil
    end

    local function updateEnemiesCache()
        if tick() - cacheTime < 0.5 then return end
        cacheTime = tick()
        enemiesCache = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character.Parent then
                if IsEnemy(player) then
                    local health, maxHealth = getPlayerHealth(player.Character)
                    if health and health > 0 then
                        enemiesCache[player] = {char = player.Character, health = health, maxHealth = maxHealth}
                    else
                        removeHealthBar(player)
                    end
                else
                    removeHealthBar(player)
                end
            else
                removeHealthBar(player)
            end
        end
    end

    local healthConnection = RunService.RenderStepped:Connect(function()
        if not _G.HealthBarEnabled then
            for _, data in pairs(healthBars) do
                data.Bg.Visible = false
                data.Bar.Visible = false
                data.Border.Visible = false
            end
            return
        end

        updateEnemiesCache()

        for player, data in pairs(enemiesCache) do
            if not player or not player.Character or not player.Character.Parent then
                removeHealthBar(player)
                continue
            end

            local char = player.Character
            local health, maxHealth = getPlayerHealth(char)
            if not health or health <= 0 then
                removeHealthBar(player)
                continue
            end

            local prevHealth = healthHistory[player]
            healthHistory[player] = health

            local head = char:FindFirstChild("Head")
            if not head then
                removeHealthBar(player)
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

                if not healthBars[player] then healthBars[player] = createBarPair() end

                local barData = healthBars[player]
                local hpPercent = health / maxHealth
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
                barData.Bar.Color = getHealthColor(health, maxHealth, prevHealth)

                if prevHealth and prevHealth > health and (prevHealth - health) > 5 then
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
                if healthBars[player] then
                    healthBars[player].Bg.Visible = false
                    healthBars[player].Bar.Visible = false
                    healthBars[player].Border.Visible = false
                end
            end
        end

        for player, barData in pairs(healthBars) do
            if not enemiesCache[player] then removeHealthBar(player) end
        end
    end)

    local function ApplyHealthBar() _G.HealthBarEnabled = true end
    local function RemoveHealthBar()
        _G.HealthBarEnabled = false
        for player, _ in pairs(healthBars) do removeHealthBar(player) end
        enemiesCache = {}
        healthHistory = {}
    end
    return ApplyHealthBar, RemoveHealthBar
end

local ApplyHealthBar, RemoveHealthBar = SetupHealthBar()

local IndicatorLine = nil
local IndicatorColor = _G.MenuThemeColor

local function CreateIndicatorLine()
    if IndicatorLine then IndicatorLine:Destroy() end
    IndicatorLine = Instance.new("Frame")
    IndicatorLine.Name = "SelectionIndicator"
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
    local width = 0.12
    local xPos = 0.02 + (index - 1) * (width + 0.03)
    TweenService:Create(IndicatorLine, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(xPos, 0, 1, -2), Size = UDim2.new(width + 0.02, 0, 0, 2)}):Play()
end

local function UpdateIndicatorColor(color)
    IndicatorColor = color
    if IndicatorLine then
        TweenService:Create(IndicatorLine, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = color}):Play()
    end
end

local function SwitchToTab(index)
    if index < 1 or index > #TabButtons then return end
    for i, b in ipairs(TabButtons) do
        b.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
        b.TextColor3 = Color3.fromRGB(156, 163, 175)
        TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0.12, 0, 0, 32)}):Play()
    end
    local btn = TabButtons[index]
    btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0.14, 0, 0, 36)}):Play()
    for name, page in pairs(ContentPages) do page.Visible = false end
    local targetPage = ContentPages[TabNames[index]]
    if targetPage then targetPage.Visible = true end
    activeIndex = index
    UpdateIndicatorPosition(index)
end

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
                        if text ~= "" and string.find(text, query) then
                            table.insert(foundElements, {element = child, tab = tabName})
                            if not foundTabName then foundTabName = tabName end
                        end
                    end
                    if child:IsA("Frame") then scanChildren(child) end
                end
            end
            scanChildren(page)
        end
    end
    if #foundElements > 0 and foundTabName then
        for idx, tabName in ipairs(TabNames) do
            if tabName == foundTabName then SwitchToTab(idx) break end
        end
    end
end

local function UpdateTabsLanguage()
    local lang = GetLang()
    for i, btn in ipairs(TabButtons) do btn.Text = lang.Tabs[i] end
end

local function UpdateAllTexts()
    UpdateTabsLanguage()
    for _, cb in ipairs(langUpdateCallbacks) do pcall(cb) end
end

for i, name in ipairs(TabNames) do
    local btn = Instance.new("TextButton")
    btn.Name = "Tab" .. i
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
        if activeIndex ~= i then btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50) btn.TextColor3 = Color3.fromRGB(255, 255, 255) end
    end)
    btn.MouseLeave:Connect(function()
        if activeIndex ~= i then btn.BackgroundColor3 = Color3.fromRGB(26, 30, 38) btn.TextColor3 = Color3.fromRGB(156, 163, 175) end
    end)
    btn.MouseButton1Click:Connect(function() PlayTabSound() SwitchToTab(i) end)
    table.insert(TabButtons, btn)
    local page = Instance.new("ScrollingFrame")
    page.Name = "Content" .. i
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
UpdateIndicatorPosition(1)

SearchInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and SearchInput.Text ~= "" and SearchInput.Text ~= "Search..." then
        SearchInMenu(SearchInput.Text)
        PlayClickSound()
        SearchInput.Text = "Search..."
    end
end)

local aimbotPage = ContentPages["Aimbot"]
if aimbotPage then aimbotPage.CanvasSize = UDim2.new(0, 0, 0, 10) end

local visualsPage = ContentPages["Visuals"]
if visualsPage then
    visualsPage.CanvasSize = UDim2.new(0, 0, 0, 350)

    -- CHAMS
    local chamsFrame = Instance.new("Frame")
    chamsFrame.Size = UDim2.new(1, 0, 0, 45)
    chamsFrame.Position = UDim2.new(0, 0, 0, 10)
    chamsFrame.BackgroundTransparency = 1
    chamsFrame.Parent = visualsPage
    local chamsLabel = Instance.new("TextLabel")
    chamsLabel.Size = UDim2.new(0.6, 0, 0, 20)
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
    chamsDesc.Text = "Makes enemies purple"
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
    SetChamsToggleState = function(value)
        if value then
            TweenService:Create(chamsToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(59, 130, 246)}):Play()
            TweenService:Create(chamsHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 23, 0.5, -9)}):Play()
            ApplyChams()
        else
            TweenService:Create(chamsToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(42, 47, 58)}):Play()
            TweenService:Create(chamsHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
            RemoveChams()
        end
        _G.ChamsEnabled = value
    end
    SetChamsToggleState(_G.ChamsEnabled)
    chamsClickArea.MouseButton1Click:Connect(function() PlayClickSound() SetChamsToggleState(not _G.ChamsEnabled) end)
    local function UpdateChamsText()
        local lang = GetLang()
        chamsLabel.Text = lang.Toggles.Chams[1]
        chamsDesc.Text = lang.Toggles.Chams[2]
    end
    table.insert(langUpdateCallbacks, UpdateChamsText)

    -- ESP
    local espFrame = Instance.new("Frame")
    espFrame.Size = UDim2.new(1, 0, 0, 45)
    espFrame.Position = UDim2.new(0, 0, 0, 65)
    espFrame.BackgroundTransparency = 1
    espFrame.Parent = visualsPage
    local espLabel = Instance.new("TextLabel")
    espLabel.Size = UDim2.new(0.6, 0, 0, 20)
    espLabel.BackgroundTransparency = 1
    espLabel.Text = "Tracers and 3D Box"
    espLabel.TextColor3 = Color3.fromRGB(209, 213, 219)
    espLabel.TextSize = 13
    espLabel.Font = Enum.Font.GothamBold
    espLabel.TextXAlignment = Enum.TextXAlignment.Left
    espLabel.Parent = espFrame
    local espDesc = Instance.new("TextLabel")
    espDesc.Size = UDim2.new(0.7, 0, 0, 16)
    espDesc.Position = UDim2.new(0, 0, 0, 22)
    espDesc.BackgroundTransparency = 1
    espDesc.Text = "Lines with boxes leading to enemies"
    espDesc.TextColor3 = Color3.fromRGB(113, 113, 122)
    espDesc.TextSize = 11
    espDesc.Font = Enum.Font.Gotham
    espDesc.TextXAlignment = Enum.TextXAlignment.Left
    espDesc.Parent = espFrame
    local espToggleBg = Instance.new("Frame")
    espToggleBg.Size = UDim2.new(0, 44, 0, 24)
    espToggleBg.Position = UDim2.new(0.88, 0, 0.1, 0)
    espToggleBg.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    espToggleBg.BorderSizePixel = 0
    espToggleBg.Parent = espFrame
    local espToggleCorner = Instance.new("UICorner")
    espToggleCorner.CornerRadius = UDim.new(1, 0)
    espToggleCorner.Parent = espToggleBg
    local espHandle = Instance.new("Frame")
    espHandle.Size = UDim2.new(0, 18, 0, 18)
    espHandle.Position = UDim2.new(0, 3, 0.5, -9)
    espHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    espHandle.BorderSizePixel = 0
    espHandle.Parent = espToggleBg
    local espHandleCorner = Instance.new("UICorner")
    espHandleCorner.CornerRadius = UDim.new(1, 0)
    espHandleCorner.Parent = espHandle
    local espClickArea = Instance.new("TextButton")
    espClickArea.Size = UDim2.new(0, 44, 0, 24)
    espClickArea.Position = UDim2.new(0.88, 0, 0.1, 0)
    espClickArea.BackgroundTransparency = 1
    espClickArea.Text = ""
    espClickArea.ZIndex = 10
    espClickArea.Parent = espFrame
    SetESPToggleState = function(value)
        if value then
            TweenService:Create(espToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(59, 130, 246)}):Play()
            TweenService:Create(espHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 23, 0.5, -9)}):Play()
            ApplyESP()
        else
            TweenService:Create(espToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(42, 47, 58)}):Play()
            TweenService:Create(espHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
            RemoveESP()
        end
        _G.ESPEnabled = value
    end
    SetESPToggleState(_G.ESPEnabled)
    espClickArea.MouseButton1Click:Connect(function() PlayClickSound() SetESPToggleState(not _G.ESPEnabled) end)
    local function UpdateESPText()
        local lang = GetLang()
        espLabel.Text = lang.Toggles.ESP[1]
        espDesc.Text = lang.Toggles.ESP[2]
    end
    table.insert(langUpdateCallbacks, UpdateESPText)

    -- SKELETON
    local skeletonFrame = Instance.new("Frame")
    skeletonFrame.Size = UDim2.new(1, 0, 0, 45)
    skeletonFrame.Position = UDim2.new(0, 0, 0, 120)
    skeletonFrame.BackgroundTransparency = 1
    skeletonFrame.Parent = visualsPage
    local skeletonLabel = Instance.new("TextLabel")
    skeletonLabel.Size = UDim2.new(0.6, 0, 0, 20)
    skeletonLabel.BackgroundTransparency = 1
    skeletonLabel.Text = "Skeleton"
    skeletonLabel.TextColor3 = Color3.fromRGB(209, 213, 219)
    skeletonLabel.TextSize = 13
    skeletonLabel.Font = Enum.Font.GothamBold
    skeletonLabel.TextXAlignment = Enum.TextXAlignment.Left
    skeletonLabel.Parent = skeletonFrame
    local skeletonDesc = Instance.new("TextLabel")
    skeletonDesc.Size = UDim2.new(0.7, 0, 0, 16)
    skeletonDesc.Position = UDim2.new(0, 0, 0, 22)
    skeletonDesc.BackgroundTransparency = 1
    skeletonDesc.Text = "Skeleton for enemies"
    skeletonDesc.TextColor3 = Color3.fromRGB(113, 113, 122)
    skeletonDesc.TextSize = 11
    skeletonDesc.Font = Enum.Font.Gotham
    skeletonDesc.TextXAlignment = Enum.TextXAlignment.Left
    skeletonDesc.Parent = skeletonFrame
    local skeletonToggleBg = Instance.new("Frame")
    skeletonToggleBg.Size = UDim2.new(0, 44, 0, 24)
    skeletonToggleBg.Position = UDim2.new(0.88, 0, 0.1, 0)
    skeletonToggleBg.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    skeletonToggleBg.BorderSizePixel = 0
    skeletonToggleBg.Parent = skeletonFrame
    local skeletonToggleCorner = Instance.new("UICorner")
    skeletonToggleCorner.CornerRadius = UDim.new(1, 0)
    skeletonToggleCorner.Parent = skeletonToggleBg
    local skeletonHandle = Instance.new("Frame")
    skeletonHandle.Size = UDim2.new(0, 18, 0, 18)
    skeletonHandle.Position = UDim2.new(0, 3, 0.5, -9)
    skeletonHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    skeletonHandle.BorderSizePixel = 0
    skeletonHandle.Parent = skeletonToggleBg
    local skeletonHandleCorner = Instance.new("UICorner")
    skeletonHandleCorner.CornerRadius = UDim.new(1, 0)
    skeletonHandleCorner.Parent = skeletonHandle
    local skeletonClickArea = Instance.new("TextButton")
    skeletonClickArea.Size = UDim2.new(0, 44, 0, 24)
    skeletonClickArea.Position = UDim2.new(0.88, 0, 0.1, 0)
    skeletonClickArea.BackgroundTransparency = 1
    skeletonClickArea.Text = ""
    skeletonClickArea.ZIndex = 10
    skeletonClickArea.Parent = skeletonFrame
    SetSkeletonToggleState = function(value)
        if value then
            TweenService:Create(skeletonToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(59, 130, 246)}):Play()
            TweenService:Create(skeletonHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 23, 0.5, -9)}):Play()
            ApplySkeleton()
        else
            TweenService:Create(skeletonToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(42, 47, 58)}):Play()
            TweenService:Create(skeletonHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
            RemoveSkeleton()
        end
        _G.SkeletonEnabled = value
    end
    SetSkeletonToggleState(_G.SkeletonEnabled)
    skeletonClickArea.MouseButton1Click:Connect(function() PlayClickSound() SetSkeletonToggleState(not _G.SkeletonEnabled) end)
    local function UpdateSkeletonText()
        local lang = GetLang()
        skeletonLabel.Text = lang.Toggles.Skeleton[1]
        skeletonDesc.Text = lang.Toggles.Skeleton[2]
    end
    table.insert(langUpdateCallbacks, UpdateSkeletonText)

    -- HEALTH BAR
    local healthFrame = Instance.new("Frame")
    healthFrame.Size = UDim2.new(1, 0, 0, 45)
    healthFrame.Position = UDim2.new(0, 0, 0, 175)
    healthFrame.BackgroundTransparency = 1
    healthFrame.Parent = visualsPage
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Size = UDim2.new(0.6, 0, 0, 20)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "Health Bar"
    healthLabel.TextColor3 = Color3.fromRGB(209, 213, 219)
    healthLabel.TextSize = 13
    healthLabel.Font = Enum.Font.GothamBold
    healthLabel.TextXAlignment = Enum.TextXAlignment.Left
    healthLabel.Parent = healthFrame
    local healthDesc = Instance.new("TextLabel")
    healthDesc.Size = UDim2.new(0.7, 0, 0, 16)
    healthDesc.Position = UDim2.new(0, 0, 0, 22)
    healthDesc.BackgroundTransparency = 1
    healthDesc.Text = "Health bar above enemies"
    healthDesc.TextColor3 = Color3.fromRGB(113, 113, 122)
    healthDesc.TextSize = 11
    healthDesc.Font = Enum.Font.Gotham
    healthDesc.TextXAlignment = Enum.TextXAlignment.Left
    healthDesc.Parent = healthFrame
    local healthToggleBg = Instance.new("Frame")
    healthToggleBg.Size = UDim2.new(0, 44, 0, 24)
    healthToggleBg.Position = UDim2.new(0.88, 0, 0.1, 0)
    healthToggleBg.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    healthToggleBg.BorderSizePixel = 0
    healthToggleBg.Parent = healthFrame
    local healthToggleCorner = Instance.new("UICorner")
    healthToggleCorner.CornerRadius = UDim.new(1, 0)
    healthToggleCorner.Parent = healthToggleBg
    local healthHandle = Instance.new("Frame")
    healthHandle.Size = UDim2.new(0, 18, 0, 18)
    healthHandle.Position = UDim2.new(0, 3, 0.5, -9)
    healthHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    healthHandle.BorderSizePixel = 0
    healthHandle.Parent = healthToggleBg
    local healthHandleCorner = Instance.new("UICorner")
    healthHandleCorner.CornerRadius = UDim.new(1, 0)
    healthHandleCorner.Parent = healthHandle
    local healthClickArea = Instance.new("TextButton")
    healthClickArea.Size = UDim2.new(0, 44, 0, 24)
    healthClickArea.Position = UDim2.new(0.88, 0, 0.1, 0)
    healthClickArea.BackgroundTransparency = 1
    healthClickArea.Text = ""
    healthClickArea.ZIndex = 10
    healthClickArea.Parent = healthFrame
    SetHealthBarToggleState = function(value)
        if value then
            TweenService:Create(healthToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(59, 130, 246)}):Play()
            TweenService:Create(healthHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 23, 0.5, -9)}):Play()
            ApplyHealthBar()
        else
            TweenService:Create(healthToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(42, 47, 58)}):Play()
            TweenService:Create(healthHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
            RemoveHealthBar()
        end
        _G.HealthBarEnabled = value
    end
    SetHealthBarToggleState(_G.HealthBarEnabled)
    healthClickArea.MouseButton1Click:Connect(function() PlayClickSound() SetHealthBarToggleState(not _G.HealthBarEnabled) end)
    local function UpdateHealthBarText()
        local lang = GetLang()
        healthLabel.Text = lang.Toggles.HealthBar[1]
        healthDesc.Text = lang.Toggles.HealthBar[2]
    end
    table.insert(langUpdateCallbacks, UpdateHealthBarText)
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
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 45)
    toggleFrame.Position = UDim2.new(0, 0, 0, 10)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = settingsPage
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 20)
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
    pickerContainer = Instance.new("Frame")
    pickerContainer.Name = "ColorPicker"
    pickerContainer.Size = UDim2.new(1, -30, 0, 140)
    pickerContainer.Position = UDim2.new(0, 15, 0, 55)
    pickerContainer.BackgroundTransparency = 1
    pickerContainer.Visible = false
    pickerContainer.ZIndex = 30
    pickerContainer.Parent = settingsPage
    local wheelImage = Instance.new("ImageLabel")
    wheelImage.Size = UDim2.new(0, 120, 0, 120)
    wheelImage.Position = UDim2.new(0.5, -60, 0.5, -60)
    wheelImage.BackgroundTransparency = 1
    wheelImage.Image = "rbxassetid://7393858625"
    wheelImage.ZIndex = 31
    wheelImage.Parent = pickerContainer
    pickerDot = Instance.new("Frame")
    pickerDot.Size = UDim2.new(0, 10, 0, 10)
    pickerDot.Position = UDim2.new(0.5, -5, 0.5, -5)
    pickerDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    pickerDot.ZIndex = 32
    pickerDot.Parent = wheelImage
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = pickerDot
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
            scrollFrame.ScrollingEnabled = false
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
            scrollFrame.ScrollingEnabled = true
        end
    end)
    ShiftContainer = function(shiftDown)
        local targetY = shiftDown and 150 or 0
        TweenService:Create(settingsContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 0, 0, 55 + targetY)}):Play()
    end
    SetToggleState = function(value)
        if value then
            TweenService:Create(toggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(59, 130, 246)}):Play()
            TweenService:Create(handle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 23, 0.5, -9)}):Play()
            pickerContainer.Visible = true
            ShiftContainer(true)
        else
            TweenService:Create(toggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(42, 47, 58)}):Play()
            TweenService:Create(handle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
            pickerContainer.Visible = false
            ShiftContainer(false)
        end
        _G.CustomThemeEnabled = value
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
    clickArea.MouseButton1Click:Connect(function() PlayClickSound() SetToggleState(not _G.CustomThemeEnabled) end)
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
                TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = targetScale}):Play()
                TweenService:Create(bg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetBg, BackgroundTransparency = targetTransp}):Play()
                TweenService:Create(txt, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextColor3 = targetTextColor}):Play()
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
            for _, btn in ipairs(langButtonData) do pcall(btn.Update, true) end
            UpdateAllTexts()
        end)
        local btnData = {Update = UpdateLangButton}
        table.insert(langButtonData, btnData)
        return btnData
    end
    CreateLangButton("Русский", "RU", 0.03)
    CreateLangButton("English", "EN", 0.55)
    local opacityFrame = Instance.new("Frame")
    opacityFrame.Size = UDim2.new(1, -20, 0, 55)
    opacityFrame.Position = UDim2.new(0, 10, 0, 60)
    opacityFrame.BackgroundTransparency = 1
    opacityFrame.Parent = settingsContainer
    local opacityLabel = Instance.new("TextLabel")
    opacityLabel.Size = UDim2.new(0.5, 0, 0, 20)
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
    opacityValue = Instance.new("TextLabel")
    opacityValue.Size = UDim2.new(0.15, 0, 0, 20)
    opacityValue.Position = UDim2.new(0.85, 0, 0, 0)
    opacityValue.BackgroundTransparency = 1
    opacityValue.Text = "12%"
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
    opacitySliderFill = Instance.new("Frame")
    opacitySliderFill.Size = UDim2.new(0.24, 0, 1, 0)
    opacitySliderFill.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    opacitySliderFill.BorderSizePixel = 0
    opacitySliderFill.Parent = opacitySliderBg
    local opacityFillCorner = Instance.new("UICorner")
    opacityFillCorner.CornerRadius = UDim.new(1, 0)
    opacityFillCorner.Parent = opacitySliderFill
    opacitySliderHandle = Instance.new("Frame")
    opacitySliderHandle.Size = UDim2.new(0, 16, 0, 16)
    opacitySliderHandle.Position = UDim2.new(0.24, -8, 0.5, -8)
    opacitySliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    opacitySliderHandle.BorderSizePixel = 0
    opacitySliderHandle.Parent = opacitySliderBg
    local opacityHandleCorner = Instance.new("UICorner")
    opacityHandleCorner.CornerRadius = UDim.new(1, 0)
    opacityHandleCorner.Parent = opacitySliderHandle
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
    local rainbowFrame = Instance.new("Frame")
    rainbowFrame.Size = UDim2.new(1, 0, 0, 45)
    rainbowFrame.Position = UDim2.new(0, 0, 0, 120)
    rainbowFrame.BackgroundTransparency = 1
    rainbowFrame.Parent = settingsContainer
    local rainbowLabel = Instance.new("TextLabel")
    rainbowLabel.Size = UDim2.new(0.6, 0, 0, 20)
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
    SetRainbowToggleState = function(value)
        if value then
            TweenService:Create(rainbowToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(59, 130, 246)}):Play()
            TweenService:Create(rainbowHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 23, 0.5, -9)}):Play()
        else
            TweenService:Create(rainbowToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(42, 47, 58)}):Play()
            TweenService:Create(rainbowHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
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
    rainbowClickArea.MouseButton1Click:Connect(function() PlayClickSound() SetRainbowToggleState(not _G.RainbowEnabled) end)
    local function UpdateRainbowText()
        local lang = GetLang()
        rainbowLabel.Text = lang.Toggles.Rainbow[1]
        rainbowDesc.Text = lang.Toggles.Rainbow[2]
    end
    table.insert(langUpdateCallbacks, UpdateRainbowText)
    local scaleFrame = Instance.new("Frame")
    scaleFrame.Size = UDim2.new(1, -20, 0, 55)
    scaleFrame.Position = UDim2.new(0, 10, 0, 170)
    scaleFrame.BackgroundTransparency = 1
    scaleFrame.Parent = settingsContainer
    local scaleLabel = Instance.new("TextLabel")
    scaleLabel.Size = UDim2.new(0.6, 0, 0, 20)
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
    scaleValue = Instance.new("TextLabel")
    scaleValue.Size = UDim2.new(0.15, 0, 0, 20)
    scaleValue.Position = UDim2.new(0.85, 0, 0, 0)
    scaleValue.BackgroundTransparency = 1
    scaleValue.Text = "100%"
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
    scaleSliderFill = Instance.new("Frame")
    scaleSliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    scaleSliderFill.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    scaleSliderFill.BorderSizePixel = 0
    scaleSliderFill.Parent = scaleSliderBg
    local scaleFillCorner = Instance.new("UICorner")
    scaleFillCorner.CornerRadius = UDim.new(1, 0)
    scaleFillCorner.Parent = scaleSliderFill
    scaleSliderHandle = Instance.new("Frame")
    scaleSliderHandle.Size = UDim2.new(0, 16, 0, 16)
    scaleSliderHandle.Position = UDim2.new(0.5, -8, 0.5, -8)
    scaleSliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    scaleSliderHandle.BorderSizePixel = 0
    scaleSliderHandle.Parent = scaleSliderBg
    local scaleHandleCorner = Instance.new("UICorner")
    scaleHandleCorner.CornerRadius = UDim.new(1, 0)
    scaleHandleCorner.Parent = scaleSliderHandle
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
        scaleValue.Text = tostring(math.round((val / 45) * 100)) .. "%"
        _G.MenuScale = val
        MainFrame.Size = UDim2.new(0, 640 * (val / 45), 0, 470 * (val / 45))
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
    local flyingFrame = Instance.new("Frame")
    flyingFrame.Name = "Effects"
    flyingFrame.Size = UDim2.new(1, 0, 1, 0)
    flyingFrame.BackgroundTransparency = 1
    flyingFrame.ZIndex = 100
    flyingFrame.Parent = MainFrame
    local dotContainer = Instance.new("Frame")
    dotContainer.Name = "Particles"
    dotContainer.Size = UDim2.new(1, 0, 1, 0)
    dotContainer.BackgroundTransparency = 1
    dotContainer.ClipsDescendants = true
    dotContainer.Parent = flyingFrame
    local function RebuildDots()
        for _, data in ipairs(Dots) do
            if data and data.Frame then data.Frame:Destroy() end
        end
        Dots = {}
        if not _G.FlyingDots then return end
        local w = MainFrame.AbsoluteSize.X
        local h = MainFrame.AbsoluteSize.Y
        if w <= 0 then w = 640 end
        if h <= 0 then h = 470 end
        local scale = _G.MenuScale / 45
        local count = math.floor(50 + scale * 30)
        for i = 1, count do
            local dot = Instance.new("Frame")
            dot.Name = "Particle"
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
            table.insert(Dots, {Frame = dot, SpeedX = speedX, SpeedY = speedY, RotSpeed = rotSpeed, Angle = math.random() * math.pi * 2, PosX = math.random(0, w), PosY = math.random(0, h)})
        end
    end
    local function UpdateDots()
        local w = MainFrame.AbsoluteSize.X
        local h = MainFrame.AbsoluteSize.Y
        if w <= 0 or h <= 0 then return end
        for _, data in ipairs(Dots) do
            if data and data.Frame then
                data.PosX = data.PosX + data.SpeedX
                data.PosY = data.PosY + data.SpeedY
                data.Angle = data.Angle + data.RotSpeed
                if data.PosX < 0 then data.PosX = w end
                if data.PosX > w then data.PosX = 0 end
                if data.PosY > h then data.PosY = 0 data.PosX = math.random(0, w) end
                data.Frame.Position = UDim2.new(0, data.PosX, 0, data.PosY)
                data.Frame.Rotation = math.deg(data.Angle)
            end
        end
    end
    MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if _G.FlyingDots then RebuildDots() end
    end)
    local function ToggleFlyingDots(state)
        _G.FlyingDots = state
        if state then
            RebuildDots()
            if DotConnection then DotConnection:Disconnect() end
            DotConnection = RunService.Heartbeat:Connect(UpdateDots)
        else
            if DotConnection then DotConnection:Disconnect() DotConnection = nil end
            for _, data in ipairs(Dots) do
                if data and data.Frame then data.Frame:Destroy() end
            end
            Dots = {}
        end
    end
    local flyingToggleFrame = Instance.new("Frame")
    flyingToggleFrame.Size = UDim2.new(1, 0, 0, 45)
    flyingToggleFrame.Position = UDim2.new(0, 0, 0, 230)
    flyingToggleFrame.BackgroundTransparency = 1
    flyingToggleFrame.Parent = settingsContainer
    local flyingLabel = Instance.new("TextLabel")
    flyingLabel.Size = UDim2.new(0.6, 0, 0, 20)
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
    SetFlyingToggleState = function(value)
        if value then
            TweenService:Create(flyingToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(59, 130, 246)}):Play()
            TweenService:Create(flyingHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 23, 0.5, -9)}):Play()
        else
            TweenService:Create(flyingToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(42, 47, 58)}):Play()
            TweenService:Create(flyingHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
        end
        ToggleFlyingDots(value)
    end
    SetFlyingToggleState(_G.FlyingDots)
    flyingClickArea.MouseButton1Click:Connect(function() PlayClickSound() SetFlyingToggleState(not _G.FlyingDots) end)
    local function UpdateFlyingText()
        local lang = GetLang()
        flyingLabel.Text = lang.Toggles.FlyingDots[1]
        flyingDesc.Text = lang.Toggles.FlyingDots[2]
    end
    table.insert(langUpdateCallbacks, UpdateFlyingText)
    local resetFrame = Instance.new("Frame")
    resetFrame.Size = UDim2.new(1, 0, 0, 45)
    resetFrame.Position = UDim2.new(0, 0, 0, 280)
    resetFrame.BackgroundTransparency = 1
    resetFrame.Parent = settingsContainer
    local resetLabel = Instance.new("TextLabel")
    resetLabel.Size = UDim2.new(0.6, 0, 0, 20)
    resetLabel.BackgroundTransparency = 1
    resetLabel.Text = "Reset Settings"
    resetLabel.TextColor3 = Color3.fromRGB(209, 213, 219)
    resetLabel.TextSize = 13
    resetLabel.Font = Enum.Font.GothamBold
    resetLabel.TextXAlignment = Enum.TextXAlignment.Left
    resetLabel.Parent = resetFrame
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
    local function PerformReset()
        _G.CustomThemeEnabled = false
        _G.MenuThemeColor = Color3.fromRGB(59, 130, 246)
        _G.CurrentLang = "EN"
        _G.MenuOpacity = 12
        _G.RainbowEnabled = false
        _G.MenuScale = 45
        _G.FlyingDots = false
        _G.ChamsEnabled = false
        _G.ESPEnabled = false
        _G.SkeletonEnabled = false
        _G.HealthBarEnabled = false
        MainFrame.BackgroundTransparency = 0.12
        MainFrame.Size = UDim2.new(0, 640, 0, 470)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        MainFrame.Rotation = 0
        MainScale.Scale = 1
        MainStroke.Color = _G.MenuThemeColor
        UpdateIndicatorColor(_G.MenuThemeColor)
        SearchStroke.Color = _G.MenuThemeColor
        RemoveChams()
        if SetChamsToggleState then SetChamsToggleState(false) end
        RemoveESP()
        if SetESPToggleState then SetESPToggleState(false) end
        RemoveSkeleton()
        if SetSkeletonToggleState then SetSkeletonToggleState(false) end
        RemoveHealthBar()
        if SetHealthBarToggleState then SetHealthBarToggleState(false) end
        for _, btn in ipairs(langButtonData) do pcall(btn.Update, false) end
        UpdateAllTexts()
        if rainbowConnection then rainbowConnection:Disconnect() rainbowConnection = nil end
        if SetRainbowToggleState then SetRainbowToggleState(false) end
        if DotConnection then DotConnection:Disconnect() DotConnection = nil end
        for _, data in ipairs(Dots) do if data and data.Frame then data.Frame:Destroy() end end
        Dots = {}
        _G.FlyingDots = false
        if SetFlyingToggleState then SetFlyingToggleState(false) end
        if SetToggleState then SetToggleState(false) end
        if pickerContainer then pickerContainer.Visible = false end
        if ShiftContainer then ShiftContainer(false) end
        if opacitySliderFill and opacitySliderHandle and opacityValue then
            opacitySliderFill.Size = UDim2.new(0.24, 0, 1, 0)
            opacitySliderHandle.Position = UDim2.new(0.24, -8, 0.5, -8)
            opacityValue.Text = "12%"
        end
        if scaleSliderFill and scaleSliderHandle and scaleValue then
            scaleSliderFill.Size = UDim2.new(0.5, 0, 1, 0)
            scaleSliderHandle.Position = UDim2.new(0.5, -8, 0.5, -8)
            scaleValue.Text = "100%"
        end
        if pickerDot then pickerDot.Position = UDim2.new(0.5, -5, 0.5, -5) end
        SwitchToTab(1)
        SearchInput.Text = "Search..."
        SearchClose.Visible = false
        print("[RESET] All settings restored")
        PlayClickSound()
    end
    resetClickArea.MouseButton1Click:Connect(function() PlayClickSound() PerformReset() end)
    local function UpdateResetText()
        local lang = GetLang()
        resetLabel.Text = lang.Toggles.Reset[1]
        resetDesc.Text = lang.Toggles.Reset[2]
    end
    table.insert(langUpdateCallbacks, UpdateResetText)
end

local IconButton = Instance.new("ImageButton")
IconButton.Name = "MetaIcon"
IconButton.Size = UDim2.new(0, 55, 0, 55)
IconButton.Position = UDim2.new(0.01, 0, 0.92, 0)
IconButton.AnchorPoint = Vector2.new(0, 1)
IconButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
IconButton.BackgroundTransparency = 0.2
IconButton.BorderSizePixel = 0
IconButton.Image = "https://i.ibb.co/1JTnNKw1/IMG-20260902-120719.png"
IconButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
IconButton.ZIndex = 999
IconButton.Parent = ScreenGui
IconButton.Draggable = true
IconButton.Active = true
IconButton.Selectable = true
HideFromScanner(IconButton)
local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(0, 12)
IconCorner.Parent = IconButton
IconButton.MouseButton1Click:Connect(function()
    PlayClickSound()
    if MainFrame.Visible then
        TweenService:Create(MainScale, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.7}):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Rotation = 10, BackgroundTransparency = 0.8}):Play()
        task.wait(0.25)
        TweenService:Create(MainScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.2}):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        task.wait(0.2)
        MainFrame.Visible = false
        MainScale.Scale = 1
        MainFrame.Rotation = 0
        MainFrame.BackgroundTransparency = _G.MenuOpacity / 100
    else
        MainFrame.Visible = true
        MainScale.Scale = 0.1
        MainFrame.Rotation = -10
        MainFrame.BackgroundTransparency = 1
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        task.wait(0.05)
        TweenService:Create(MainScale, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.7}):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = -3, BackgroundTransparency = 0.5}):Play()
        task.wait(0.5)
        TweenService:Create(MainScale, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = 0, BackgroundTransparency = _G.MenuOpacity / 100}):Play()
        task.wait(0.6)
        TweenService:Create(MainScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.98}):Play()
        task.wait(0.05)
        TweenService:Create(MainScale, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
        MainFrame.Rotation = 0
    end
end)
UpdateAllTexts()
if TabButtons[1] then
    TabButtons[1].BackgroundColor3 = Color3.fromRGB(35, 40, 50)
    TabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButtons[1].Size = UDim2.new(0.14, 0, 0, 36)
end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ACHIEVEMENT OVERLAY (ПОЛНОСТЬЮ ВЫЕЗЖАЕТ)
local function ShowAchievement()
    local achievement = Instance.new("Frame")
    achievement.Name = "AchievementPopup"
    achievement.Size = UDim2.new(0, 340, 0, 100)
    achievement.Position = UDim2.new(1, 340, 0.85, 0)
    achievement.AnchorPoint = Vector2.new(0, 1)
    achievement.BackgroundColor3 = Color3.fromRGB(17, 20, 26)
    achievement.BackgroundTransparency = 0.15
    achievement.BorderSizePixel = 0
    achievement.ZIndex = 999
    achievement.Parent = ScreenGui
    HideFromScanner(achievement)

    local achievementCorner = Instance.new("UICorner")
    achievementCorner.CornerRadius = UDim.new(0, 12)
    achievementCorner.Parent = achievement

    local achievementStroke = Instance.new("UIStroke")
    achievementStroke.Thickness = 2
    achievementStroke.Color = Color3.fromRGB(59, 130, 246)
    achievementStroke.Transparency = 0.3
    achievementStroke.Parent = achievement

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -30, 0, 25)
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "META"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = achievement

    local betaAchieveLabel = Instance.new("TextLabel")
    betaAchieveLabel.Size = UDim2.new(0, 50, 0, 20)
    betaAchieveLabel.Position = UDim2.new(0, 60, 0, 15)
    betaAchieveLabel.BackgroundTransparency = 1
    betaAchieveLabel.Text = "beta"
    betaAchieveLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    betaAchieveLabel.TextSize = 11
    betaAchieveLabel.Font = Enum.Font.Gotham
    betaAchieveLabel.TextXAlignment = Enum.TextXAlignment.Left
    betaAchieveLabel.Parent = achievement

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -30, 0, 50)
    descLabel.Position = UDim2.new(0, 15, 0, 42)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = "Did you like the script? Follow the updates in my tiktok) I'm glad you're using this."
    descLabel.TextColor3 = Color3.fromRGB(156, 163, 175)
    descLabel.TextSize = 11
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.TextWrapped = true
    descLabel.Parent = achievement

    local function BounceIn()
        achievement.Position = UDim2.new(1, 340, 0.85, 0)
        TweenService:Create(achievement, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -340, 0.85, 0)}):Play()
        TweenService:Create(achievement, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15}):Play()
    end

    local function BounceOut()
        TweenService:Create(achievement, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 340, 0.85, 0)}):Play()
        TweenService:Create(achievement, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        achievement:Destroy()
    end

    BounceIn()
    task.wait(3)
    BounceOut()
end

task.spawn(function()
    task.wait(1)
    ShowAchievement()
end)

print("[META] META v7.0.47 - Skeleton Fixed + Achievement Full")
print("[META] Press Insert or click icon")
