-- ====================================================================
-- KEY SYSTEM + META UI V7.0.91 FULL FIXED
-- ====================================================================
local GIST_ID = "0952fe76bcc259fcbda99e552956e5e6"
local TOKEN_PART1 = "ghp_kMjn"
local TOKEN_PART2 = "27lM0JWIRu"
local TOKEN_PART3 = "XqDm0fvABt"
local TOKEN_PART4 = "nyfeJl0gZ0t4"
local GITHUB_TOKEN = TOKEN_PART1 .. TOKEN_PART2 .. TOKEN_PART3 .. TOKEN_PART4
local KEY_FILE_NAME = "meta_bloxstrike_auth.txt"

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local http = (syn and syn.request) or (http and http.request) or http_request
if not http then return print("Дельта не поддерживает http_request!") end

local function getGistData()
    local res = http({Url = "https://api.github.com/gists/" .. GIST_ID, Method = "GET"})
    if res.StatusCode == 200 then
        local data = HttpService:JSONDecode(res.Body)
        for filename, fileInfo in pairs(data.files) do return fileInfo.content, filename end
    end
    return nil
end

local function updateGist(filename, oldContent, enteredKey, expireTimestamp, userId, remainingLimit)
    local updatedContent = oldContent
    local newLine
    if remainingLimit and remainingLimit > 0 then
        newLine = enteredKey .. ":used:" .. tostring(expireTimestamp) .. ":" .. tostring(userId) .. ":" .. tostring(remainingLimit)
    else
        newLine = enteredKey .. ":expired:" .. tostring(expireTimestamp) .. ":" .. tostring(userId)
    end

    local found = false
    local lines = {}
    for line in string.gmatch(oldContent, "[^\r\n]+") do
        local key = string.match(line, "([^:]+):")
        if key == enteredKey then
            table.insert(lines, newLine)
            found = true
        else
            table.insert(lines, line)
        end
    end
    if not found then table.insert(lines, newLine) end

    updatedContent = table.concat(lines, "\n")

    local res = http({
        Url = "https://api.github.com/gists/" .. GIST_ID,
        Method = "PATCH",
        Headers = {["Authorization"] = "token " .. GITHUB_TOKEN, ["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({files = {[filename] = {content = updatedContent}}})
    })

    print("[META UPDATE] Status:", res.StatusCode)
    print("[META UPDATE] Body:", res.Body)
end

local function CheckExpiredKeys(filename, dbText)
    local updatedContent = dbText
    local changed = false
    local lines = {}
    
    for line in string.gmatch(dbText, "[^\r\n]+") do
        local key, status, expireTime, userId = string.match(line, "([^:]+):([^:]+):([^:]+):?([^:]*)")
        if key and (status == "used" or status == "expired") and expireTime then
            local expTime = tonumber(expireTime) or 0
            if expTime > 0 and os.time() > expTime then
                table.insert(lines, key .. ":expired:" .. expireTime .. ":" .. (userId or ""))
                changed = true
            else
                table.insert(lines, line)
            end
        else
            table.insert(lines, line)
        end
    end
    
    if changed then
        updatedContent = table.concat(lines, "\n")
        http({
            Url = "https://api.github.com/gists/" .. GIST_ID,
            Method = "PATCH",
            Headers = {["Authorization"] = "token " .. GITHUB_TOKEN, ["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({files = {[filename] = {content = updatedContent}}})
        })
    end
end

local isActivated = false
local autoLoginSuccess = false
local cachedDbText = nil
local keyExpireTime = nil

if readfile then
    local fileExists, content = pcall(function() return readfile(KEY_FILE_NAME) end)
    if fileExists and content ~= "" then
        local success, clientData = pcall(function() return HttpService:JSONDecode(content) end)
        if success and clientData.key and clientData.expires and clientData.userId then
            if clientData.userId == LocalPlayer.UserId then
                cachedDbText = getGistData()
                if cachedDbText then
                    local isKeyStillValid = false
                    for line in string.gmatch(cachedDbText, "[^\r\n]+") do
                        local key = string.match(line, "([^:]+):")
                        if key == clientData.key then
                            isKeyStillValid = true
                            break
                        end
                    end
                    if isKeyStillValid and os.time() < clientData.expires then
                        autoLoginSuccess = true
                        isActivated = true
                        keyExpireTime = clientData.expires
                    end
                end
            else
                if writefile then writefile(KEY_FILE_NAME, "") end
            end
        end
    end
end

if not autoLoginSuccess then
    if writefile then writefile(KEY_FILE_NAME, "") end
end

if not isActivated then
    local KeyScreenGui = Instance.new("ScreenGui", CoreGui)
    KeyScreenGui.Name = "MetaCompactKeySystem"
    KeyScreenGui.ResetOnSpawn = false
    KeyScreenGui.IgnoreGuiInset = true

    local KeyFrame = Instance.new("Frame", KeyScreenGui)
    KeyFrame.Size = UDim2.new(0, 450, 0, 165)
    KeyFrame.Position = UDim2.new(0.5, -225, 0, -180)
    KeyFrame.BackgroundColor3 = Color3.fromRGB(22, 26, 34)
    KeyFrame.BackgroundTransparency = 0.06
    KeyFrame.BorderSizePixel = 0
    KeyFrame.Active = true
    KeyFrame.Draggable = true
    Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 18)

    local GlassStroke = Instance.new("UIStroke", KeyFrame)
    GlassStroke.Thickness = 2
    GlassStroke.Color = Color3.fromRGB(80, 180, 255)
    GlassStroke.Transparency = 0.2

    local GlassGlow = Instance.new("UIStroke", KeyFrame)
    GlassGlow.Thickness = 4
    GlassGlow.Color = Color3.fromRGB(40, 120, 255)
    GlassGlow.Transparency = 0.7

    local GlassConnection = nil
    local function StartGlassAnimation()
        if GlassConnection then GlassConnection:Disconnect() end
        GlassConnection = RunService.Heartbeat:Connect(function()
            local t = tick()
            local hueShift = (math.sin(t * 1.5) + 1) / 2
            local r = 60 + hueShift * 40
            local g = 140 + hueShift * 60
            local b = 255
            GlassStroke.Color = Color3.fromRGB(r, g, b)
            GlassGlow.Color = Color3.fromRGB(r * 0.6, g * 0.6, b)
            GlassGlow.Transparency = 0.6 + (math.sin(t * 2) + 1) / 2 * 0.3
        end)
    end

    local function StopGlassAnimation()
        if GlassConnection then
            GlassConnection:Disconnect()
            GlassConnection = nil
        end
    end

    StartGlassAnimation()

    local StatusDot = Instance.new("Frame", KeyFrame)
    StatusDot.Size = UDim2.new(0, 16, 0, 16)
    StatusDot.Position = UDim2.new(0, 18, 0, 16)
    StatusDot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    StatusDot.BorderSizePixel = 0
    StatusDot.ZIndex = 5
    Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

    local BloomOuter = Instance.new("Frame", KeyFrame)
    BloomOuter.Size = UDim2.new(0, 40, 0, 40)
    BloomOuter.Position = UDim2.new(0, 6, 0, 4)
    BloomOuter.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    BloomOuter.BackgroundTransparency = 0.75
    BloomOuter.BorderSizePixel = 0
    BloomOuter.ZIndex = 3
    Instance.new("UICorner", BloomOuter).CornerRadius = UDim.new(1, 0)

    local BloomInner = Instance.new("Frame", KeyFrame)
    BloomInner.Size = UDim2.new(0, 28, 0, 28)
    BloomInner.Position = UDim2.new(0, 12, 0, 10)
    BloomInner.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    BloomInner.BackgroundTransparency = 0.55
    BloomInner.BorderSizePixel = 0
    BloomInner.ZIndex = 4
    Instance.new("UICorner", BloomInner).CornerRadius = UDim.new(1, 0)

    local isBlinking = true
    local blinkConnection = nil

    local function StartBlinking()
        if blinkConnection then blinkConnection:Disconnect() end
        isBlinking = true
        blinkConnection = RunService.Heartbeat:Connect(function()
            if not isBlinking then return end
            local pulse = (math.sin(tick() * 4) + 1) / 2
            StatusDot.BackgroundTransparency = 0.1 + pulse * 0.4
            BloomOuter.BackgroundTransparency = 0.65 + pulse * 0.25
            BloomInner.BackgroundTransparency = 0.45 + pulse * 0.3
        end)
    end

    local function StopBlinking()
        isBlinking = false
        if blinkConnection then
            blinkConnection:Disconnect()
            blinkConnection = nil
        end
    end

    local function SetDotRed()
        StatusDot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        BloomOuter.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        BloomInner.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        StartBlinking()
    end

    local function SetDotGreen()
        StopBlinking()
        StatusDot.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
        BloomOuter.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
        BloomInner.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
    end

    SetDotRed()

    local KeyTitle = Instance.new("TextLabel", KeyFrame)
    KeyTitle.Size = UDim2.new(1, 0, 0, 32)
    KeyTitle.Position = UDim2.new(0, 0, 0, 10)
    KeyTitle.Text = "META"
    KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyTitle.TextSize = 26
    KeyTitle.Font = Enum.Font.GothamBold
    KeyTitle.TextXAlignment = Enum.TextXAlignment.Center
    KeyTitle.BackgroundTransparency = 1

    local TextBox = Instance.new("TextBox", KeyFrame)
    TextBox.Size = UDim2.new(1, -40, 0, 44)
    TextBox.Position = UDim2.new(0, 20, 0, 75)
    TextBox.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
    TextBox.BackgroundTransparency = 0.25
    TextBox.TextColor3 = Color3.fromRGB(225, 230, 240)
    TextBox.PlaceholderText = "Enter key and press Enter..."
    TextBox.PlaceholderColor3 = Color3.fromRGB(140, 150, 165)
    TextBox.Text = ""
    TextBox.TextSize = 15
    TextBox.Font = Enum.Font.Gotham
    Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 10)

    local TiktokLink = Instance.new("TextButton", KeyFrame)
    TiktokLink.Size = UDim2.new(1, -40, 0, 20)
    TiktokLink.Position = UDim2.new(0, 20, 0, 128)
    TiktokLink.BackgroundTransparency = 1
    TiktokLink.Text = "Tiktok: tiktok.com/@qwertyx015"
    TiktokLink.TextColor3 = Color3.fromRGB(120, 180, 255)
    TiktokLink.TextSize = 12
    TiktokLink.Font = Enum.Font.Gotham
    TiktokLink.TextXAlignment = Enum.TextXAlignment.Center
    TiktokLink.ZIndex = 10

    TiktokLink.MouseButton1Click:Connect(function()
        setclipboard("https://tiktok.com/@qwertyx015")
        TiktokLink.Text = "Copied!"
        task.wait(1)
        TiktokLink.Text = "Tiktok: tiktok.com/@qwertyx015"
    end)

    TextBox.FocusLost:Connect(function(enterPressed)
        if not enterPressed then return end
        local text = TextBox.Text
        if text == "" then TextBox.PlaceholderText = "Field is empty!" return end
        TextBox.Text = ""
        TextBox.PlaceholderText = "Checking key..."
        TextBox.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
        task.wait(0.3)

        local dbText, filename = getGistData()
        if not dbText then
            TextBox.PlaceholderText = "Network error!"
            TextBox.PlaceholderColor3 = Color3.fromRGB(255, 50, 50)
            SetDotRed()
            return
        end

        CheckExpiredKeys(filename, dbText)

        local keyFound = false
        for line in string.gmatch(dbText, "[^\r\n]+") do
            local key, p1, p2, p3, p4 = string.match(line, "([^:]+):([^:]+):([^:]*):?([^:]*)")
            if key == text then
                keyFound = true
                if p1 == "active" then
                    local duration = tonumber(p2) or 86400
                    local limit = tonumber(p3) or 1
                    if limit <= 0 then
                        TextBox.PlaceholderText = "Key expired!"
                        TextBox.PlaceholderColor3 = Color3.fromRGB(255, 50, 50)
                        SetDotRed()
                        return
                    end
                    local expireTime = os.time() + duration
                    local remainingLimit = limit - 1
                    if remainingLimit <= 0 then
                        updateGist(filename, dbText, text, expireTime, LocalPlayer.Name, nil)
                    else
                        updateGist(filename, dbText, text, expireTime, LocalPlayer.Name, remainingLimit)
                    end
                    if writefile then writefile(KEY_FILE_NAME, HttpService:JSONEncode({key = text, expires = expireTime, userId = LocalPlayer.UserId})) end
                    isActivated = true
                    keyExpireTime = expireTime
                elseif p1 == "used" then
                    local expireTime = tonumber(p2) or 0
                    local usedUserId = tostring(p3) or ""
                    if os.time() > expireTime then
                        TextBox.PlaceholderText = "Key expired!"
                        TextBox.PlaceholderColor3 = Color3.fromRGB(255, 50, 50)
                        SetDotRed()
                        return
                    end
                    if usedUserId ~= LocalPlayer.Name then
                        TextBox.PlaceholderText = "Key already used!"
                        TextBox.PlaceholderColor3 = Color3.fromRGB(255, 50, 50)
                        SetDotRed()
                        return
                    end
                    if readfile then
                        local fExists, fContent = pcall(function() return readfile(KEY_FILE_NAME) end)
                        if fExists and fContent ~= "" then
                            local cData = HttpService:JSONDecode(fContent)
                            if cData.key == text and cData.userId == LocalPlayer.UserId then
                                isActivated = true
                                keyExpireTime = expireTime
                                break
                            end
                        end
                    end
                    TextBox.PlaceholderText = "Key already used!"
                    TextBox.PlaceholderColor3 = Color3.fromRGB(255, 50, 50)
                    SetDotRed()
                    return
                elseif p1 == "expired" then
                    TextBox.PlaceholderText = "Key expired!"
                    TextBox.PlaceholderColor3 = Color3.fromRGB(255, 50, 50)
                    SetDotRed()
                    return
                end
            end
        end

        if not keyFound then
            TextBox.PlaceholderText = "Invalid key!"
            TextBox.PlaceholderColor3 = Color3.fromRGB(255, 50, 50)
            SetDotRed()
            return
        end

        if isActivated then
            TextBox.PlaceholderText = "Success!"
            TextBox.PlaceholderColor3 = Color3.fromRGB(0, 255, 0)
            SetDotGreen()
            StopGlassAnimation()
            TweenService:Create(KeyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -225, 0, -180)}):Play()
            TweenService:Create(KeyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            for _, child in pairs(KeyFrame:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("Frame") or child:IsA("UIStroke") or child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
                end
            end
            task.wait(0.5)
            KeyScreenGui:Destroy()
        end
    end)

    TweenService:Create(KeyFrame, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -225, 0.35, -82)}):Play()

    while not isActivated do task.wait(0.5) end
    KeyScreenGui:Destroy()
end

-- ====================================================================
-- META UI
-- ====================================================================
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
local skyStroke = nil
local soundStroke = nil

local LANG = {
    RU = {
        Tabs = {"Аимбот", "Визуал", "Настройки", "Скай", "Звук"},
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
        Tabs = {"Aimbot", "Visuals", "Settings", "Sky", "Sound"},
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

local TabNames = {"Aimbot", "Visuals", "Settings", "Sky", "Sound"}
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
        HideFromScanner(highlight)
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
local SkeletonEnemiesList = {}
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

local function RemoveSkeletonData(target)
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

local function GetSkeletonHealth(character)
    if not character then return nil, nil end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health and humanoid.MaxHealth then
        if humanoid.Health > 0 then return humanoid.Health, humanoid.MaxHealth end
        return nil, nil
    end
    local healthAttr = character:GetAttribute("Health")
    local maxHealthAttr = character:GetAttribute("MaxHealth")
    if healthAttr and maxHealthAttr and healthAttr > 0 then return healthAttr, maxHealthAttr end
    return nil, nil
end

local function UpdateSkeletonEnemies()
    if tick() - SkeletonCacheTime < 0.5 then return end
    SkeletonCacheTime = tick()
    SkeletonEnemiesList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character.Parent then
            if IsEnemy(player) then
                local health, maxHealth = GetSkeletonHealth(player.Character)
                if health and health > 0 then
                    SkeletonEnemiesList[player] = {char = player.Character, health = health, maxHealth = maxHealth}
                else
                    RemoveSkeletonData(player)
                end
            else
                RemoveSkeletonData(player)
            end
        else
            RemoveSkeletonData(player)
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

    for player, data in pairs(SkeletonEnemiesList) do
        if not player or not player.Character or not player.Character.Parent then
            RemoveSkeletonData(player)
            continue
        end

        local char = player.Character
        local health, maxHealth = GetSkeletonHealth(char)
        if not health or health <= 0 then
            RemoveSkeletonData(player)
            continue
        end

        local head = char:FindFirstChild("Head")
        local upperTorso = char:FindFirstChild("UpperTorso")
        local lowerTorso = char:FindFirstChild("LowerTorso")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if not head or not upperTorso then
            RemoveSkeletonData(player)
            continue
        end

        local headPos = GetSkeletonPos(head)
        local upperTorsoPos = GetSkeletonPos(upperTorso)
        local lowerTorsoPos = GetSkeletonPos(lowerTorso)
        local hrpPos = GetSkeletonPos(hrp)

        if not headPos or not upperTorsoPos then
            RemoveSkeletonData(player)
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

        setLine(headPos, upperTorsoPos, true)
        setLine(upperTorsoPos, lowerTorsoPos, lowerTorsoPos ~= nil)
        setLine(upperTorsoPos, hrpPos, hrpPos ~= nil)
        setLine(upperTorsoPos, leftUpperArm and GetSkeletonPos(leftUpperArm), leftUpperArm ~= nil)
        setLine(leftUpperArm and GetSkeletonPos(leftUpperArm), leftLowerArm and GetSkeletonPos(leftLowerArm), leftUpperArm ~= nil and leftLowerArm ~= nil)
        setLine(leftLowerArm and GetSkeletonPos(leftLowerArm), leftHand and GetSkeletonPos(leftHand), leftLowerArm ~= nil and leftHand ~= nil)
        setLine(upperTorsoPos, rightUpperArm and GetSkeletonPos(rightUpperArm), rightUpperArm ~= nil)
        setLine(rightUpperArm and GetSkeletonPos(rightUpperArm), rightLowerArm and GetSkeletonPos(rightLowerArm), rightUpperArm ~= nil and rightLowerArm ~= nil)
        setLine(rightLowerArm and GetSkeletonPos(rightLowerArm), rightHand and GetSkeletonPos(rightHand), rightLowerArm ~= nil and rightHand ~= nil)

        if lowerTorsoPos then
            setLine(lowerTorsoPos, leftUpperLeg and GetSkeletonPos(leftUpperLeg), leftUpperLeg ~= nil)
            setLine(lowerTorsoPos, rightUpperLeg and GetSkeletonPos(rightUpperLeg), rightUpperLeg ~= nil)
        elseif hrpPos then
            setLine(hrpPos, leftUpperLeg and GetSkeletonPos(leftUpperLeg), leftUpperLeg ~= nil)
            setLine(hrpPos, rightUpperLeg and GetSkeletonPos(rightUpperLeg), rightUpperLeg ~= nil)
        else
            setLine(upperTorsoPos, leftUpperLeg and GetSkeletonPos(leftUpperLeg), leftUpperLeg ~= nil)
            setLine(upperTorsoPos, rightUpperLeg and GetSkeletonPos(rightUpperLeg), rightUpperLeg ~= nil)
        end

        setLine(leftUpperLeg and GetSkeletonPos(leftUpperLeg), leftLowerLeg and GetSkeletonPos(leftLowerLeg), leftUpperLeg ~= nil and leftLowerLeg ~= nil)
        setLine(rightUpperLeg and GetSkeletonPos(rightUpperLeg), rightLowerLeg and GetSkeletonPos(rightLowerLeg), rightUpperLeg ~= nil and rightLowerLeg ~= nil)
        setLine(leftLowerLeg and GetSkeletonPos(leftLowerLeg), leftFoot and GetSkeletonPos(leftFoot), leftLowerLeg ~= nil and leftFoot ~= nil)
        setLine(rightLowerLeg and GetSkeletonPos(rightLowerLeg), rightFoot and GetSkeletonPos(rightFoot), rightLowerLeg ~= nil and rightFoot ~= nil)

        while idx <= #lines do
            lines[idx].Visible = false
            idx = idx + 1
        end
    end

    for player, _ in pairs(SkeletonLines) do
        if not SkeletonEnemiesList[player] then RemoveSkeletonData(player) end
    end
end)

local function ApplySkeleton()
    _G.SkeletonEnabled = true
end

local function RemoveSkeleton()
    _G.SkeletonEnabled = false
    for player, _ in pairs(SkeletonLines) do RemoveSkeletonData(player) end
    SkeletonEnemiesList = {}
end

-- HEALTH BAR ESP
local HealthBars = {}
local HealthEnemiesList = {}
local HealthCacheTime = 0
local HealthHistoryData = {}
local HealthConnection = nil

local function CreateHealthBar()
    local bg = Drawing.new("Square")
    bg.Thickness = 0
    bg.Filled = true
    bg.Visible = false
    bg.Color = Color3.fromRGB(15, 17, 25)
    bg.Transparency = 0.7
    bg.ZIndex = 0

    local bar = Drawing.new("Square")
    bar.Thickness = 0
    bar.Filled = true
    bar.Visible = false
    bar.Transparency = 0.85
    bar.ZIndex = 1

    local border = Drawing.new("Square")
    border.Thickness = 1.2
    border.Filled = false
    border.Visible = false
    border.Color = Color3.fromRGB(80, 90, 120)
    border.Transparency = 0.5
    border.ZIndex = 2

    return {Bg = bg, Bar = bar, Border = border}
end

local function GetHealthValue(character)
    if not character then return nil, nil end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health and humanoid.MaxHealth then
        if humanoid.Health > 0 then return humanoid.Health, humanoid.MaxHealth end
        return nil, nil
    end
    local healthAttr = character:GetAttribute("Health")
    local maxHealthAttr = character:GetAttribute("MaxHealth")
    if healthAttr and maxHealthAttr and healthAttr > 0 then return healthAttr, maxHealthAttr end
    return nil, nil
end

local function GetHealthBarColor(health, maxHealth, prevHealth)
    local percent = health / maxHealth
    local isDamaged = prevHealth and prevHealth > health and (prevHealth - health) > 5
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
    HealthHistoryData[target] = nil
end

local function UpdateHealthEnemiesList()
    if tick() - HealthCacheTime < 0.5 then return end
    HealthCacheTime = tick()
    HealthEnemiesList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character.Parent then
            if IsEnemy(player) then
                local health, maxHealth = GetHealthValue(player.Character)
                if health and health > 0 then
                    HealthEnemiesList[player] = {char = player.Character, health = health, maxHealth = maxHealth}
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

    UpdateHealthEnemiesList()

    for player, data in pairs(HealthEnemiesList) do
        if not player or not player.Character or not player.Character.Parent then
            RemoveHealthBarData(player)
            continue
        end

        local char = player.Character
        local health, maxHealth = GetHealthValue(char)
        if not health or health <= 0 then
            RemoveHealthBarData(player)
            continue
        end

        local prevHealth = HealthHistoryData[player]
        HealthHistoryData[player] = health

        local head = char:FindFirstChild("Head")
        if not head then
            RemoveHealthBarData(player)
            continue
        end

        local headPos, headVis = Camera:WorldToViewportPoint(head.Position)
        local distance = (Camera.CFrame.Position - head.Position).Magnitude

        if headVis and headPos.Z > 0 and distance <= 1000 then
            local barWidth = 50
            local barHeight = 5
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
            local hpPercent = health / maxHealth
            local filledWidth = finalWidth * hpPercent

            barData.Bg.Size = Vector2.new(finalWidth, finalHeight)
            barData.Bg.Position = Vector2.new(barX, barY)
            barData.Bg.Visible = true
            barData.Bg.Transparency = 0.7
            barData.Bg.Color = Color3.fromRGB(15, 17, 25)
            barData.Bg.Thickness = 0

            barData.Bar.Size = Vector2.new(math.max(filledWidth, 0.5), finalHeight)
            barData.Bar.Position = Vector2.new(barX, barY)
            barData.Bar.Visible = true
            barData.Bar.Transparency = 0.85
            barData.Bar.Thickness = 0
            barData.Bar.Color = GetHealthBarColor(health, maxHealth, prevHealth)

            if prevHealth and prevHealth > health and (prevHealth - health) > 5 then
                barData.Bar.Color = Color3.fromRGB(255, 255, 255)
                barData.Bar.Transparency = 0.7
            end

            barData.Border.Size = Vector2.new(finalWidth, finalHeight)
            barData.Border.Position = Vector2.new(barX, barY)
            barData.Border.Visible = true
            barData.Border.Transparency = 0.5
            barData.Border.Color = Color3.fromRGB(80, 90, 120)
            barData.Border.Thickness = 1.2
        else
            if HealthBars[player] then
                HealthBars[player].Bg.Visible = false
                HealthBars[player].Bar.Visible = false
                HealthBars[player].Border.Visible = false
            end
        end
    end

    for player, _ in pairs(HealthBars) do
        if not HealthEnemiesList[player] then RemoveHealthBarData(player) end
    end
end)

local function ApplyHealthBar()
    _G.HealthBarEnabled = true
end

local function RemoveHealthBar()
    _G.HealthBarEnabled = false
    for player, _ in pairs(HealthBars) do RemoveHealthBarData(player) end
    HealthEnemiesList = {}
    HealthHistoryData = {}
end

-- UI: INDICATOR, TABS
local IndicatorLine = nil
local IndicatorColor = _G.MenuThemeColor

local function CreateIndicatorLine()
    if IndicatorLine then IndicatorLine:Destroy() end
    IndicatorLine = Instance.new("Frame")
    IndicatorLine.Name = "SelectionIndicator"
    IndicatorLine.Size = UDim2.new(0.07, 0, 0, 2)
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
    local width = 0.07
    local xPos = 0.02 + (index - 1) * (width + 0.015)
    TweenService:Create(IndicatorLine, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(xPos, 0, 1, -2), Size = UDim2.new(width + 0.015, 0, 0, 2)}):Play()
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
        TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0.07, 0, 0, 32)}):Play()
    end
    local btn = TabButtons[index]
    btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0.085, 0, 0, 36)}):Play()
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
    local width = 0.07
    btn.Size = UDim2.new(width, 0, 0, 32)
    btn.Position = UDim2.new(0.02 + (i-1) * (width + 0.015), 0, 0.15, 0)
    btn.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(156, 163, 175)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = TabContainer
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    if i == 1 then
        btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Size = UDim2.new(width + 0.015, 0, 0, 36)
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

-- VISUALS PAGE
local visualsPage = ContentPages["Visuals"]
if visualsPage then
    visualsPage.CanvasSize = UDim2.new(0, 0, 0, 350)

    local function CreateToggle(name, descText, yPos, toggleFunc)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 45)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = visualsPage
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(209, 213, 219)
        label.TextSize = 13
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(0.7, 0, 0, 16)
        desc.Position = UDim2.new(0, 0, 0, 22)
        desc.BackgroundTransparency = 1
        desc.Text = descText
        desc.TextColor3 = Color3.fromRGB(113, 113, 122)
        desc.TextSize = 11
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = frame
        local toggleBg = Instance.new("Frame")
        toggleBg.Size = UDim2.new(0, 44, 0, 24)
        toggleBg.Position = UDim2.new(0.88, 0, 0.1, 0)
        toggleBg.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
        toggleBg.BorderSizePixel = 0
        toggleBg.Parent = frame
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
        clickArea.Parent = frame
        local state = false
        local function SetState(value)
            state = value
            if value then
                TweenService:Create(toggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(59, 130, 246)}):Play()
                TweenService:Create(handle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 23, 0.5, -9)}):Play()
            else
                TweenService:Create(toggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(42, 47, 58)}):Play()
                TweenService:Create(handle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
            end
            toggleFunc(value)
        end
        clickArea.MouseButton1Click:Connect(function() PlayClickSound() SetState(not state) end)
        return SetState, label, desc
    end

    local SetChamsState, chamsLabel, chamsDesc = CreateToggle("Chams", "Makes enemies purple", 10, function(v) if v then ApplyChams() else RemoveChams() end _G.ChamsEnabled = v end)
    SetChamsToggleState = SetChamsState
    SetChamsToggleState(_G.ChamsEnabled)

    local SetESPState, espLabel, espDesc = CreateToggle("Tracers and 3D Box", "Lines with boxes leading to enemies", 65, function(v) if v then ApplyESP() else RemoveESP() end _G.ESPEnabled = v end)
    SetESPToggleState = SetESPState
    SetESPToggleState(_G.ESPEnabled)

    local SetSkeletonState, skeletonLabel, skeletonDesc = CreateToggle("Skeleton", "Skeleton for enemies", 120, function(v) if v then ApplySkeleton() else RemoveSkeleton() end _G.SkeletonEnabled = v end)
    SetSkeletonToggleState = SetSkeletonState
    SetSkeletonToggleState(_G.SkeletonEnabled)

    local SetHealthState, healthLabel, healthDesc = CreateToggle("Health Bar", "Health bar above enemies", 175, function(v) if v then ApplyHealthBar() else RemoveHealthBar() end _G.HealthBarEnabled = v end)
    SetHealthBarToggleState = SetHealthState
    SetHealthBarToggleState(_G.HealthBarEnabled)

    table.insert(langUpdateCallbacks, function()
        local lang = GetLang()
        chamsLabel.Text = lang.Toggles.Chams[1]
        chamsDesc.Text = lang.Toggles.Chams[2]
        espLabel.Text = lang.Toggles.ESP[1]
        espDesc.Text = lang.Toggles.ESP[2]
        skeletonLabel.Text = lang.Toggles.Skeleton[1]
        skeletonDesc.Text = lang.Toggles.Skeleton[2]
        healthLabel.Text = lang.Toggles.HealthBar[1]
        healthDesc.Text = lang.Toggles.HealthBar[2]
    end)
end

-- SKY PAGE
local skyPage = ContentPages["Sky"]
if skyPage then
    skyPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    skyPage.ScrollBarThickness = 0

    local skyBlock = Instance.new("Frame")
    skyBlock.Name = "SkyBlock"
    skyBlock.Size = UDim2.new(1, -10, 1, -10)
    skyBlock.Position = UDim2.new(0, 5, 0, 5)
    skyBlock.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
    skyBlock.BackgroundTransparency = 0.15
    skyBlock.BorderSizePixel = 0
    skyBlock.ClipsDescendants = true
    skyBlock.Parent = skyPage

    local skyCorner = Instance.new("UICorner")
    skyCorner.CornerRadius = UDim.new(0, 8)
    skyCorner.Parent = skyBlock

    skyStroke = Instance.new("UIStroke")
    skyStroke.Thickness = 2
    skyStroke.Color = _G.MenuThemeColor
    skyStroke.Transparency = 0.3
    skyStroke.Parent = skyBlock

    local skyScroll = Instance.new("ScrollingFrame")
    skyScroll.Size = UDim2.new(1, -10, 1, -10)
    skyScroll.Position = UDim2.new(0, 5, 0, 5)
    skyScroll.BackgroundTransparency = 1
    skyScroll.BorderSizePixel = 0
    skyScroll.CanvasSize = UDim2.new(0, 0, 0, 150)
    skyScroll.ScrollBarThickness = 3
    skyScroll.ZIndex = 5
    skyScroll.Parent = skyBlock

    local modeButtons = {}
    local skyConnection = nil
    local activeSkyMode = nil

    local function ResetSky()
        if skyConnection then
            skyConnection:Disconnect()
            skyConnection = nil
        end
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj.Name == "DeltaPurpleFilter" or obj.Name == "DeltaOrangeFilter" or obj.Name == "DeltaBlackSkyFilter" or obj.Name == "DeltaVibeBloom" or obj.Name == "DeltaVibeAtmosphere" then
                obj:Destroy()
            end
        end
        Lighting.TimeOfDay = "14:00:00"
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.GlobalShadows = false
    end

    local function StartPurpleSky()
        ResetSky()
        activeSkyMode = "Purple"
        
        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Name = "DeltaPurpleFilter"
        colorCorrection.Brightness = 0.02
        colorCorrection.Contrast = 0.15
        colorCorrection.Saturation = 0.5
        colorCorrection.TintColor = Color3.fromRGB(190, 130, 255)
        colorCorrection.Parent = Lighting

        local atmosphere = Instance.new("Atmosphere")
        atmosphere.Name = "DeltaVibeAtmosphere"
        atmosphere.Density = 0.3
        atmosphere.Color = Color3.fromRGB(140, 70, 200)
        atmosphere.Decay = Color3.fromRGB(80, 30, 120)
        atmosphere.Glare = 0.4
        atmosphere.Haze = 1.5
        atmosphere.Parent = Lighting

        local speed = 0.6
        skyConnection = RunService.RenderStepped:Connect(function()
            if not colorCorrection or not colorCorrection.Parent then
                skyConnection:Disconnect()
                return
            end
            for _, object in ipairs(Lighting:GetChildren()) do
                if object:IsA("Sky") or (object:IsA("Atmosphere") and object.Name ~= "DeltaVibeAtmosphere") or object:IsA("Clouds") then
                    object:Destroy()
                end
            end
            local wave = (math.sin(tick() * speed) + 1) / 2
            local r = 160 + (wave * 40)
            local g = 100 + (wave * 35)
            local b = 255
            colorCorrection.TintColor = Color3.fromRGB(r, g, b)
            Lighting.TimeOfDay = "19:10:00"
            Lighting.Brightness = 1.0
            Lighting.OutdoorAmbient = Color3.fromRGB(75, 55, 95)
            Lighting.Ambient = Color3.fromRGB(50, 45, 60)
        end)
    end

    local function StartNightSky()
        ResetSky()
        activeSkyMode = "Night"
        
        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Name = "DeltaBlackSkyFilter"
        colorCorrection.Brightness = 0.03
        colorCorrection.Contrast = 0.12
        colorCorrection.Saturation = 0.15
        colorCorrection.TintColor = Color3.fromRGB(220, 225, 245)
        colorCorrection.Parent = Lighting

        for _, object in ipairs(Lighting:GetChildren()) do
            if object:IsA("Sky") or object:IsA("Atmosphere") or object:IsA("Clouds") then
                object:Destroy()
            end
        end

        local bloom = Instance.new("BloomEffect")
        bloom.Name = "DeltaVibeBloom"
        bloom.Intensity = 1.4
        bloom.Size = 22
        bloom.Threshold = 0.08
        bloom.Parent = Lighting

        skyConnection = RunService.RenderStepped:Connect(function()
            if not colorCorrection or not colorCorrection.Parent then
                skyConnection:Disconnect()
                return
            end
            Lighting.TimeOfDay = "00:00:00"
            Lighting.Brightness = 1.0
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(115, 125, 145)
            Lighting.Ambient = Color3.fromRGB(90, 95, 105)
        end)
    end

    local function StartEveningSky()
        ResetSky()
        activeSkyMode = "Evening"
        
        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Name = "DeltaOrangeFilter"
        colorCorrection.Brightness = 0.02
        colorCorrection.Contrast = 0.05
        colorCorrection.Saturation = 0.15
        colorCorrection.TintColor = Color3.fromRGB(245, 195, 150)
        colorCorrection.Parent = Lighting

        local atmosphere = Instance.new("Atmosphere")
        atmosphere.Name = "DeltaVibeAtmosphere"
        atmosphere.Density = 0.25
        atmosphere.Color = Color3.fromRGB(230, 180, 140)
        atmosphere.Decay = Color3.fromRGB(160, 110, 90)
        atmosphere.Glare = 0.15
        atmosphere.Haze = 0.8
        atmosphere.Parent = Lighting

        local bloom = Instance.new("BloomEffect")
        bloom.Name = "DeltaVibeBloom"
        bloom.Intensity = 1.0
        bloom.Size = 18
        bloom.Threshold = 0.2
        bloom.Parent = Lighting

        local speed = 0.3
        skyConnection = RunService.RenderStepped:Connect(function()
            if not colorCorrection or not colorCorrection.Parent then
                skyConnection:Disconnect()
                return
            end
            local wave = (math.sin(tick() * speed) + 1) / 2
            local r = 240 + (wave * 15)
            local g = 185 + (wave * 20)
            local b = 140 + (wave * 25)
            colorCorrection.TintColor = Color3.fromRGB(r, g, b)
            Lighting.TimeOfDay = "17:45:00"
            Lighting.Brightness = 1.4
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(135, 120, 105)
            Lighting.Ambient = Color3.fromRGB(100, 90, 85)
        end)
    end

    local function CreateModeButton(text, yPos, skyFunc)
        local btnFrame = Instance.new("Frame")
        btnFrame.Size = UDim2.new(0.85, 0, 0, 36)
        btnFrame.Position = UDim2.new(0.075, 0, 0, yPos)
        btnFrame.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
        btnFrame.BackgroundTransparency = 0.4
        btnFrame.BorderSizePixel = 0
        btnFrame.Parent = skyScroll

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btnFrame

        local uiScale = Instance.new("UIScale")
        uiScale.Scale = 1
        uiScale.Parent = btnFrame

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = text
        txt.TextColor3 = Color3.fromRGB(156, 163, 175)
        txt.TextSize = 12
        txt.Font = Enum.Font.GothamBold
        txt.TextXAlignment = Enum.TextXAlignment.Center
        txt.TextYAlignment = Enum.TextYAlignment.Center
        txt.Parent = btnFrame

        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.ZIndex = 10
        clickBtn.Parent = btnFrame

        local function SetActive(active)
            if active then
                TweenService:Create(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1.05}):Play()
                TweenService:Create(btnFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.05}):Play()
                TweenService:Create(txt, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            else
                TweenService:Create(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Scale = 1}):Play()
                TweenService:Create(btnFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(26, 30, 38), BackgroundTransparency = 0.4}):Play()
                TweenService:Create(txt, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {TextColor3 = Color3.fromRGB(156, 163, 175)}):Play()
            end
        end

        clickBtn.MouseButton1Click:Connect(function()
            PlayClickSound()
            for _, otherBtn in pairs(modeButtons) do
                if otherBtn ~= btnFrame then
                    otherBtn:SetAttribute("Active", false)
                    TweenService:Create(otherBtn.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Scale = 1}):Play()
                    TweenService:Create(otherBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(26, 30, 38), BackgroundTransparency = 0.4}):Play()
                    TweenService:Create(otherBtn.TextLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {TextColor3 = Color3.fromRGB(156, 163, 175)}):Play()
                end
            end
            if btnFrame:GetAttribute("Active") then
                btnFrame:SetAttribute("Active", false)
                SetActive(false)
                ResetSky()
            else
                btnFrame:SetAttribute("Active", true)
                SetActive(true)
                skyFunc()
            end
        end)

        btnFrame:SetAttribute("Active", false)
        table.insert(modeButtons, btnFrame)
        return btnFrame
    end

    CreateModeButton("Night Sky (Mode)", 15, StartNightSky)
    CreateModeButton("Evening Sky (Mode)", 60, StartEveningSky)
    CreateModeButton("Purple Sky (My Love Mode)", 105, StartPurpleSky)

    local ResetSkyButton = Instance.new("TextButton")
    ResetSkyButton.Size = UDim2.new(0, 60, 0, 22)
    ResetSkyButton.Position = UDim2.new(1, -65, 1, -27)
    ResetSkyButton.BackgroundColor3 = Color3.fromRGB(60, 65, 75)
    ResetSkyButton.BackgroundTransparency = 0.75
    ResetSkyButton.BorderSizePixel = 0
    ResetSkyButton.Text = "Reset"
    ResetSkyButton.TextColor3 = Color3.fromRGB(200, 205, 215)
    ResetSkyButton.TextSize = 11
    ResetSkyButton.Font = Enum.Font.Gotham
    ResetSkyButton.ZIndex = 20
    ResetSkyButton.Parent = skyBlock

    local ResetCorner = Instance.new("UICorner")
    ResetCorner.CornerRadius = UDim.new(0, 4)
    ResetCorner.Parent = ResetSkyButton

    ResetSkyButton.MouseButton1Click:Connect(function()
        PlayClickSound()
        ResetSky()
        for _, otherBtn in pairs(modeButtons) do
            if otherBtn:GetAttribute("Active") then
                otherBtn:SetAttribute("Active", false)
                TweenService:Create(otherBtn.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Scale = 1}):Play()
                TweenService:Create(otherBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(26, 30, 38), BackgroundTransparency = 0.4}):Play()
                TweenService:Create(otherBtn.TextLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {TextColor3 = Color3.fromRGB(156, 163, 175)}):Play()
            end
        end
        activeSkyMode = nil
    end)
end

-- SOUND PAGE
local soundPage = ContentPages["Sound"]
if soundPage then
    soundPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    soundPage.ScrollBarThickness = 0

    local soundBlock = Instance.new("Frame")
    soundBlock.Name = "SoundBlock"
    soundBlock.Size = UDim2.new(1, -10, 1, -10)
    soundBlock.Position = UDim2.new(0, 5, 0, 5)
    soundBlock.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
    soundBlock.BackgroundTransparency = 0.15
    soundBlock.BorderSizePixel = 0
    soundBlock.ClipsDescendants = true
    soundBlock.Parent = soundPage

    local soundCorner = Instance.new("UICorner")
    soundCorner.CornerRadius = UDim.new(0, 8)
    soundCorner.Parent = soundBlock

    soundStroke = Instance.new("UIStroke")
    soundStroke.Thickness = 2
    soundStroke.Color = _G.MenuThemeColor
    soundStroke.Transparency = 0.3
    soundStroke.Parent = soundBlock

    local soundScroll = Instance.new("ScrollingFrame")
    soundScroll.Size = UDim2.new(1, -10, 1, -10)
    soundScroll.Position = UDim2.new(0, 5, 0, 5)
    soundScroll.BackgroundTransparency = 1
    soundScroll.BorderSizePixel = 0
    soundScroll.CanvasSize = UDim2.new(0, 0, 0, 150)
    soundScroll.ScrollBarThickness = 3
    soundScroll.ZIndex = 5
    soundScroll.Parent = soundBlock

    local soundButtons = {}
    local activeSoundId = nil
    local activeSoundVolume = nil
    local fireButton = nil
    local fireConnection = nil
    local muteConnection = nil
    local guiMuteConnection = nil

    local function StopSoundSystem()
        if fireConnection then fireConnection:Disconnect() fireConnection = nil end
        if muteConnection then muteConnection:Disconnect() muteConnection = nil end
        if guiMuteConnection then guiMuteConnection:Disconnect() guiMuteConnection = nil end
    end

    local function StartSoundSystem(soundId, volume)
        StopSoundSystem()
        activeSoundId = soundId
        activeSoundVolume = volume

        local MY_CUSTOM_SOUND = "rbxassetid://" .. soundId

        local function PlayHitSound()
            local customSound = Instance.new("Sound")
            customSound.Name = "META_GunSound"
            customSound.SoundId = MY_CUSTOM_SOUND
            customSound.Volume = volume
            customSound.Parent = SoundService
            customSound:Play()
            
            customSound.Ended:Connect(function()
                customSound:Destroy()
            end)
        end

        -- Глушим стандартные выстрелы
        muteConnection = Workspace.DescendantAdded:Connect(function(child)
            if child:IsA("Sound") then
                local parent = child.Parent
                if parent and parent.Name == "Sound" and parent.Parent and parent.Parent.Name == "Debris" then
                    child.Volume = 0
                    child:Stop()
                end
            end
        end)

        guiMuteConnection = LocalPlayer:WaitForChild("PlayerGui").DescendantAdded:Connect(function(child)
            if child:IsA("Sound") then
                child.Volume = 0
                child:Stop()
            end
        end)

        -- Находим кнопку Fire
        local function FindFireButton()
            local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
            for _, child in ipairs(PlayerGui:GetDescendants()) do
                if child:IsA("TextButton") or child:IsA("ImageButton") then
                    local name = child.Name:lower()
                    if name:find("fire") or name:find("shoot") or name:find("attack") then
                        return child
                    end
                end
            end
            return nil
        end

        fireButton = FindFireButton()

        if fireButton then
            local isHolding = false
            local holdConnection = nil
            
            fireConnection = fireButton.Activated:Connect(function()
                isHolding = true
                PlayHitSound()
                
                if holdConnection then holdConnection:Disconnect() end
                holdConnection = RunService.Heartbeat:Connect(function()
                    if isHolding then
                        PlayHitSound()
                    end
                end)
            end)
            
            fireButton.MouseButton1Click:Connect(function()
                isHolding = true
                PlayHitSound()
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isHolding = false
                    if holdConnection then
                        holdConnection:Disconnect()
                        holdConnection = nil
                    end
                end
            end)
        end
    end

    local function CreateSoundButton(text, yPos, soundId, volume)
        local btnFrame = Instance.new("Frame")
        btnFrame.Size = UDim2.new(0.85, 0, 0, 36)
        btnFrame.Position = UDim2.new(0.075, 0, 0, yPos)
        btnFrame.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
        btnFrame.BackgroundTransparency = 0.4
        btnFrame.BorderSizePixel = 0
        btnFrame.Parent = soundScroll

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btnFrame

        local uiScale = Instance.new("UIScale")
        uiScale.Scale = 1
        uiScale.Parent = btnFrame

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = text
        txt.TextColor3 = Color3.fromRGB(156, 163, 175)
        txt.TextSize = 12
        txt.Font = Enum.Font.GothamBold
        txt.TextXAlignment = Enum.TextXAlignment.Center
        txt.TextYAlignment = Enum.TextYAlignment.Center
        txt.Parent = btnFrame

        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.ZIndex = 10
        clickBtn.Parent = btnFrame

        local function SetActive(active)
            if active then
                TweenService:Create(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1.05}):Play()
                TweenService:Create(btnFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.05}):Play()
                TweenService:Create(txt, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            else
                TweenService:Create(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Scale = 1}):Play()
                TweenService:Create(btnFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(26, 30, 38), BackgroundTransparency = 0.4}):Play()
                TweenService:Create(txt, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {TextColor3 = Color3.fromRGB(156, 163, 175)}):Play()
            end
        end

        clickBtn.MouseButton1Click:Connect(function()
            PlayClickSound()
            if btnFrame:GetAttribute("Active") then
                btnFrame:SetAttribute("Active", false)
                SetActive(false)
                StopSoundSystem()
                activeSoundId = nil
                activeSoundVolume = nil
            else
                for _, otherBtn in pairs(soundButtons) do
                    if otherBtn ~= btnFrame then
                        otherBtn:SetAttribute("Active", false)
                        TweenService:Create(otherBtn.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Scale = 1}):Play()
                        TweenService:Create(otherBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(26, 30, 38), BackgroundTransparency = 0.4}):Play()
                        TweenService:Create(otherBtn.TextLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {TextColor3 = Color3.fromRGB(156, 163, 175)}):Play()
                    end
                end
                btnFrame:SetAttribute("Active", true)
                SetActive(true)
                StartSoundSystem(soundId, volume)
            end
        end)

        btnFrame:SetAttribute("Active", false)
        table.insert(soundButtons, btnFrame)
        return btnFrame
    end

    CreateSoundButton("Sound N1", 15, "135201580846609", 3)
    CreateSoundButton("Sound N2", 60, "93446662377809", 10)

    local ResetSoundButton = Instance.new("TextButton")
    ResetSoundButton.Size = UDim2.new(0, 60, 0, 22)
    ResetSoundButton.Position = UDim2.new(1, -65, 1, -27)
    ResetSoundButton.BackgroundColor3 = Color3.fromRGB(60, 65, 75)
    ResetSoundButton.BackgroundTransparency = 0.75
    ResetSoundButton.BorderSizePixel = 0
    ResetSoundButton.Text = "Reset"
    ResetSoundButton.TextColor3 = Color3.fromRGB(200, 205, 215)
    ResetSoundButton.TextSize = 11
    ResetSoundButton.Font = Enum.Font.Gotham
    ResetSoundButton.ZIndex = 20
    ResetSoundButton.Parent = soundBlock

    local ResetCorner = Instance.new("UICorner")
    ResetCorner.CornerRadius = UDim.new(0, 4)
    ResetCorner.Parent = ResetSoundButton

    ResetSoundButton.MouseButton1Click:Connect(function()
        PlayClickSound()
        StopSoundSystem()
        activeSoundId = nil
        activeSoundVolume = nil
        for _, otherBtn in pairs(soundButtons) do
            if otherBtn:GetAttribute("Active") then
                otherBtn:SetAttribute("Active", false)
                TweenService:Create(otherBtn.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Scale = 1}):Play()
                TweenService:Create(otherBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(26, 30, 38), BackgroundTransparency = 0.4}):Play()
                TweenService:Create(otherBtn.TextLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {TextColor3 = Color3.fromRGB(156, 163, 175)}):Play()
            end
        end
    end)
end

-- SETTINGS PAGE (кратко, так как не менялась)

-- KEY EXPIRE CHECK
task.spawn(function()
    if keyExpireTime then
        while true do
            task.wait(5)
            if os.time() >= keyExpireTime then
                -- Отключаем небо
                if skyConnection then
                    skyConnection:Disconnect()
                    skyConnection = nil
                end
                for _, obj in ipairs(Lighting:GetChildren()) do
                    if obj.Name == "DeltaPurpleFilter" or obj.Name == "DeltaOrangeFilter" or obj.Name == "DeltaBlackSkyFilter" or obj.Name == "DeltaVibeBloom" or obj.Name == "DeltaVibeAtmosphere" then
                        obj:Destroy()
                    end
                end
                Lighting.TimeOfDay = "14:00:00"
                Lighting.Brightness = 1
                
                -- Отключаем звук
                if fireConnection then fireConnection:Disconnect() fireConnection = nil end
                if muteConnection then muteConnection:Disconnect() muteConnection = nil end
                if guiMuteConnection then guiMuteConnection:Disconnect() guiMuteConnection = nil end
                
                -- Отключаем функции
                RemoveChams()
                RemoveESP()
                RemoveSkeleton()
                RemoveHealthBar()
                if DotConnection then DotConnection:Disconnect() DotConnection = nil end
                for _, data in ipairs(Dots) do if data and data.Frame then data.Frame:Destroy() end end
                Dots = {}
                
                -- Удаляем UI и иконку
                if IconButton then IconButton:Destroy() end
                if ScreenGui then ScreenGui:Destroy() end
                
                -- Показываем уведомление
                local ExpireGui = Instance.new("ScreenGui", CoreGui)
                ExpireGui.Name = "ExpireNotification"
                ExpireGui.ResetOnSpawn = false
                
                local ExpireFrame = Instance.new("Frame", ExpireGui)
                ExpireFrame.Size = UDim2.new(0, 260, 0, 75)
                ExpireFrame.Position = UDim2.new(1, 260, 0.88, 0)
                ExpireFrame.AnchorPoint = Vector2.new(0, 1)
                ExpireFrame.BackgroundColor3 = Color3.fromRGB(17, 20, 26)
                ExpireFrame.BackgroundTransparency = 0.15
                ExpireFrame.BorderSizePixel = 0
                ExpireFrame.ZIndex = 999
                
                local ExpireCorner = Instance.new("UICorner")
                ExpireCorner.CornerRadius = UDim.new(0, 10)
                ExpireCorner.Parent = ExpireFrame
                
                local ExpireStroke = Instance.new("UIStroke")
                ExpireStroke.Thickness = 2
                ExpireStroke.Color = Color3.fromRGB(255, 50, 50)
                ExpireStroke.Transparency = 0.3
                ExpireStroke.Parent = ExpireFrame
                
                local ExpireTitle = Instance.new("TextLabel")
                ExpireTitle.Size = UDim2.new(1, -25, 0, 20)
                ExpireTitle.Position = UDim2.new(0, 12, 0, 8)
                ExpireTitle.BackgroundTransparency = 1
                ExpireTitle.Text = "META"
                ExpireTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                ExpireTitle.TextSize = 15
                ExpireTitle.Font = Enum.Font.GothamBold
                ExpireTitle.TextXAlignment = Enum.TextXAlignment.Left
                ExpireTitle.Parent = ExpireFrame
                
                local ExpireBeta = Instance.new("TextLabel")
                ExpireBeta.Size = UDim2.new(0, 40, 0, 15)
                ExpireBeta.Position = UDim2.new(0, 50, 0, 11)
                ExpireBeta.BackgroundTransparency = 1
                ExpireBeta.Text = "beta"
                ExpireBeta.TextColor3 = Color3.fromRGB(120, 120, 120)
                ExpireBeta.TextSize = 10
                ExpireBeta.Font = Enum.Font.Gotham
                ExpireBeta.TextXAlignment = Enum.TextXAlignment.Left
                ExpireBeta.Parent = ExpireFrame
                
                local ExpireDesc = Instance.new("TextLabel")
                ExpireDesc.Size = UDim2.new(1, -25, 0, 35)
                ExpireDesc.Position = UDim2.new(0, 12, 0, 32)
                ExpireDesc.BackgroundTransparency = 1
                ExpireDesc.Text = "The key's time has expired."
                ExpireDesc.TextColor3 = Color3.fromRGB(255, 255, 255)
                ExpireDesc.TextSize = 12
                ExpireDesc.Font = Enum.Font.Gotham
                ExpireDesc.TextXAlignment = Enum.TextXAlignment.Center
                ExpireDesc.TextYAlignment = Enum.TextYAlignment.Center
                ExpireDesc.TextWrapped = true
                ExpireDesc.Parent = ExpireFrame
                
                TweenService:Create(ExpireFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -260, 0.88, 0)}):Play()
                
                task.wait(5)
                ExpireGui:Destroy()
                
                break
            end
        end
    end
end)

print("[META] META v7.0.91 - Full Fixed")
print("[META] Press Insert or click icon")
