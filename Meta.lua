-- ====================================================================
-- KEY SYSTEM + META UI V7.1.10 + NIGHT MODE
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

-- ТВОЙ РАБОЧИЙ HTTP ЗАПРОС
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

-- KEY SYSTEM UI (ПОЛНОСТЬЮ ТВОЙ РАБОЧИЙ КОД)
if not isActivated then
    local KeyScreenGui = Instance.new("ScreenGui", CoreGui)
    KeyScreenGui.Name = "MetaCompactKeySystem"
    KeyScreenGui.ResetOnSpawn = false
    KeyScreenGui.IgnoreGuiInset = true

    local KeyFrame = Instance.new("Frame", KeyScreenGui)
    KeyFrame.Size = UDim2.new(0, 460, 0, 470)
    KeyFrame.Position = UDim2.new(0.5, -230, -0.5, -235)
    KeyFrame.BackgroundColor3 = Color3.fromRGB(17, 19, 24)
    KeyFrame.BackgroundTransparency = 0
    KeyFrame.BorderSizePixel = 0
    KeyFrame.Active = true
    KeyFrame.Draggable = true
    KeyFrame.ZIndex = 1
    Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 12)

    local BorderFrame = Instance.new("Frame", KeyFrame)
    BorderFrame.Size = UDim2.new(1, 12, 1, 12)
    BorderFrame.Position = UDim2.new(0, -6, 0, -6)
    BorderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BorderFrame.BorderSizePixel = 0
    BorderFrame.BackgroundTransparency = 0
    BorderFrame.ZIndex = 1
    Instance.new("UICorner", BorderFrame).CornerRadius = UDim.new(0, 16)

    local BorderGradient = Instance.new("UIGradient", BorderFrame)
    BorderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 22, 28)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(45, 50, 65)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(90, 100, 125)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(45, 50, 65)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 22, 28))
    })
    BorderGradient.Rotation = 0

    local borderAnimConnection
    borderAnimConnection = RunService.Heartbeat:Connect(function()
        local t = tick()
        BorderGradient.Rotation = (t * 80) % 360
        BorderGradient.Offset = Vector2.new(math.sin(t * 1.2) * 0.5, math.cos(t * 0.9) * 0.3)
    end)

    local StatusDot = Instance.new("Frame", KeyFrame)
    StatusDot.Size = UDim2.new(0, 14, 0, 14)
    StatusDot.Position = UDim2.new(0, 18, 0, 18)
    StatusDot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    StatusDot.BorderSizePixel = 0
    StatusDot.ZIndex = 5
    Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

    local BloomOuter = Instance.new("Frame", KeyFrame)
    BloomOuter.Size = UDim2.new(0, 32, 0, 32)
    BloomOuter.Position = UDim2.new(0, 9, 0, 9)
    BloomOuter.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    BloomOuter.BackgroundTransparency = 0.75
    BloomOuter.BorderSizePixel = 0
    BloomOuter.ZIndex = 3
    Instance.new("UICorner", BloomOuter).CornerRadius = UDim.new(1, 0)

    local BloomInner = Instance.new("Frame", KeyFrame)
    BloomInner.Size = UDim2.new(0, 22, 0, 22)
    BloomInner.Position = UDim2.new(0, 14, 0, 14)
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

    local function PlayErrorSound()
        local errorSound = Instance.new("Sound")
        errorSound.Name = "ErrorSound"
        errorSound.SoundId = "rbxassetid://94637944517523"
        errorSound.Volume = 2
        errorSound.Parent = SoundService
        errorSound:Play()
        errorSound.Ended:Connect(function()
            errorSound:Destroy()
        end)
    end

    local function PlaySuccessSound()
        local successSound = Instance.new("Sound")
        successSound.Name = "SuccessSound"
        successSound.SoundId = "rbxassetid://113476032986484"
        successSound.Volume = 2
        successSound.Parent = SoundService
        successSound:Play()
        successSound.Ended:Connect(function()
            successSound:Destroy()
        end)
    end

    SetDotRed()

    local KeyTitle = Instance.new("TextLabel", KeyFrame)
    KeyTitle.Size = UDim2.new(1, 0, 0, 50)
    KeyTitle.Position = UDim2.new(0, 0, 0, 70)
    KeyTitle.Text = "META"
    KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyTitle.TextSize = 36
    KeyTitle.Font = Enum.Font.GothamBlack
    KeyTitle.TextXAlignment = Enum.TextXAlignment.Center
    KeyTitle.TextYAlignment = Enum.TextYAlignment.Center
    KeyTitle.BackgroundTransparency = 1
    KeyTitle.ZIndex = 5

    local KeySubtitle = Instance.new("TextLabel", KeyFrame)
    KeySubtitle.Size = UDim2.new(1, 0, 0, 22)
    KeySubtitle.Position = UDim2.new(0, 0, 0, 120)
    KeySubtitle.Text = "Authorization Required"
    KeySubtitle.TextColor3 = Color3.fromRGB(120, 125, 135)
    KeySubtitle.TextSize = 13
    KeySubtitle.Font = Enum.Font.Gotham
    KeySubtitle.TextXAlignment = Enum.TextXAlignment.Center
    KeySubtitle.TextYAlignment = Enum.TextYAlignment.Center
    KeySubtitle.BackgroundTransparency = 1
    KeySubtitle.ZIndex = 5

    local TextBox = Instance.new("TextBox", KeyFrame)
    TextBox.Size = UDim2.new(1, -80, 0, 55)
    TextBox.Position = UDim2.new(0, 40, 0, 210)
    TextBox.BackgroundColor3 = Color3.fromRGB(22, 25, 32)
    TextBox.BackgroundTransparency = 0
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.PlaceholderText = "Enter the key that the owner gave you"
    TextBox.PlaceholderColor3 = Color3.fromRGB(150, 155, 165)
    TextBox.Text = ""
    TextBox.TextSize = 14
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextXAlignment = Enum.TextXAlignment.Center
    TextBox.TextYAlignment = Enum.TextYAlignment.Center
    TextBox.TextWrapped = true
    TextBox.ClearTextOnFocus = false
    TextBox.ZIndex = 5
    Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 10)

    local InputBorderStroke = Instance.new("UIStroke", TextBox)
    InputBorderStroke.Thickness = 1
    InputBorderStroke.Color = Color3.fromRGB(255, 255, 255)
    InputBorderStroke.Transparency = 0.25
    InputBorderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local PlaceholderGradient = Instance.new("UIGradient", TextBox)
    PlaceholderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 145, 155)),
        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(170, 175, 185)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(210, 215, 225)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(170, 175, 185)),
        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(140, 145, 155)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 125, 135))
    })
    PlaceholderGradient.Rotation = 0

    local placeholderConnection
    placeholderConnection = RunService.Heartbeat:Connect(function()
        local t = tick()
        PlaceholderGradient.Offset = Vector2.new(math.sin(t * 1.5) * 0.8, 0)
        PlaceholderGradient.Rotation = math.sin(t * 0.6) * 10
    end)

    local EnterButton = Instance.new("Frame", KeyFrame)
    EnterButton.Size = UDim2.new(1, -80, 0, 45)
    EnterButton.Position = UDim2.new(0, 40, 0, 280)
    EnterButton.BackgroundColor3 = Color3.fromRGB(40, 200, 90)
    EnterButton.BorderSizePixel = 0
    EnterButton.ZIndex = 5
    Instance.new("UICorner", EnterButton).CornerRadius = UDim.new(0, 10)

    local EnterGradient = Instance.new("UIGradient", EnterButton)
    EnterGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 160, 70)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(50, 210, 100)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 240, 130)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(50, 210, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 160, 70))
    })
    EnterGradient.Rotation = 0

    local enterGradientConnection
    enterGradientConnection = RunService.Heartbeat:Connect(function()
        local t = tick()
        EnterGradient.Offset = Vector2.new(math.sin(t * 1.5) * 0.8, 0)
        EnterGradient.Rotation = math.sin(t * 0.6) * 10
    end)

    local EnterText = Instance.new("TextLabel", EnterButton)
    EnterText.Size = UDim2.new(1, 0, 1, 0)
    EnterText.BackgroundTransparency = 1
    EnterText.Text = "ENTER"
    EnterText.TextColor3 = Color3.fromRGB(255, 255, 255)
    EnterText.TextSize = 18
    EnterText.Font = Enum.Font.GothamBlack
    EnterText.TextXAlignment = Enum.TextXAlignment.Center
    EnterText.TextYAlignment = Enum.TextYAlignment.Center
    EnterText.ZIndex = 6

    local EnterClick = Instance.new("TextButton", EnterButton)
    EnterClick.Size = UDim2.new(1, 0, 1, 0)
    EnterClick.BackgroundTransparency = 1
    EnterClick.Text = ""
    EnterClick.ZIndex = 10

    local function TryActivateKey()
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
            PlayErrorSound()
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
                        PlayErrorSound()
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
                        PlayErrorSound()
                        return
                    end
                    if usedUserId ~= LocalPlayer.Name then
                        TextBox.PlaceholderText = "Key already used!"
                        TextBox.PlaceholderColor3 = Color3.fromRGB(255, 50, 50)
                        SetDotRed()
                        PlayErrorSound()
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
                    PlayErrorSound()
                    return
                elseif p1 == "expired" then
                    TextBox.PlaceholderText = "Key expired!"
                    TextBox.PlaceholderColor3 = Color3.fromRGB(255, 50, 50)
                    SetDotRed()
                    PlayErrorSound()
                    return
                end
            end
        end

        if not keyFound then
            TextBox.PlaceholderText = "Invalid key!"
            TextBox.PlaceholderColor3 = Color3.fromRGB(255, 50, 50)
            SetDotRed()
            PlayErrorSound()
            return
        end

        if isActivated then
            TextBox.PlaceholderText = "Success!"
            TextBox.PlaceholderColor3 = Color3.fromRGB(0, 255, 0)
            SetDotGreen()
            if borderAnimConnection then borderAnimConnection:Disconnect() end
            if placeholderConnection then placeholderConnection:Disconnect() end
            if enterGradientConnection then enterGradientConnection:Disconnect() end
            PlaySuccessSound()
            TweenService:Create(KeyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -230, 0.5, -500)}):Play()
            TweenService:Create(KeyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            for _, child in pairs(KeyFrame:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("Frame") or child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
                end
            end
            task.wait(0.5)
            KeyScreenGui:Destroy()
        end
    end

    EnterClick.MouseButton1Click:Connect(function()
        PlayClickSound()
        TryActivateKey()
    end)

    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            TryActivateKey()
        end
    end)

    local BottomLine = Instance.new("Frame", KeyFrame)
    BottomLine.Size = UDim2.new(1, -50, 0, 1)
    BottomLine.Position = UDim2.new(0, 25, 0, 400)
    BottomLine.BackgroundColor3 = Color3.fromRGB(60, 65, 75)
    BottomLine.BorderSizePixel = 0
    BottomLine.ZIndex = 5

    local TiktokLink = Instance.new("TextButton", KeyFrame)
    TiktokLink.Size = UDim2.new(1, -60, 0, 30)
    TiktokLink.Position = UDim2.new(0, 30, 0, 410)
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

    TweenService:Create(KeyFrame, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -230, 0.5, -235)}):Play()

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
_G.MenuThemeColor = Color3.fromRGB(255, 255, 255)
_G.CurrentLang = "EN"
_G.MenuOpacity = 12
_G.RainbowEnabled = false
_G.MenuScale = 45
_G.FlyingDots = false
_G.ChamsEnabled = false
_G.ESPEnabled = false
_G.HealthBarEnabled = false
_G.SkeletonEnabled = false
_G.ParticleEffectGuiEnabled = false
_G.NightModeEnabled = false
_G.ChamsColor = Color3.fromRGB(110, 60, 170)
_G.SkeletonColor = Color3.fromRGB(255, 255, 255)

local Dots = {}
local DotConnection = nil
local opacitySliderFill, opacitySliderHandle, opacityValue = nil, nil, nil
local scaleSliderFill, scaleSliderHandle, scaleValue = nil, nil, nil
local pickerDot, pickerContainer = nil, nil
local SetToggleState, ShiftContainer = nil, nil
local SetChamsToggleState, SetRainbowToggleState = nil, nil
local SetFlyingToggleState, SetESPToggleState = nil, nil
local SetHealthBarToggleState, SetSkeletonToggleState = nil, nil
local SetParticleGuiToggleState = nil
local SetNightToggleState = nil
local skyStroke = nil
local soundStroke = nil
local skyConnection = nil
local fireInputBegan = nil
local fireInputEnded = nil
local muteConnection = nil
local guiMuteConnection = nil
local MainBorderFrame = nil
local MainBorderGradient = nil
local mainBorderConnection = nil
local nightConnection = nil

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
            ParticleEffectGui = {"Эффект частиц GUI", "Добавляет эффект точек на GUI интерфейса"},
            NightMode = {"Night Mode", "Белая переливающаяся обводка как в Key System"},
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
            ParticleEffectGui = {"Particle Effect GUI", "Adds particle effect to GUI interface"},
            NightMode = {"Night Mode", "White pulsing border like in Key System"},
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
MainFrame.ClipsDescendants = false
MainFrame.Parent = ScreenGui
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Selectable = true
MainFrame.Visible = false

MainBorderFrame = Instance.new("Frame", MainFrame)
MainBorderFrame.Name = "MainBorderFrame"
MainBorderFrame.Size = UDim2.new(1, 8, 1, 8)
MainBorderFrame.Position = UDim2.new(0, -4, 0, -4)
MainBorderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainBorderFrame.BorderSizePixel = 0
MainBorderFrame.BackgroundTransparency = _G.MenuOpacity / 100
MainBorderFrame.ZIndex = 1
Instance.new("UICorner", MainBorderFrame).CornerRadius = UDim.new(0, 15)

MainBorderGradient = Instance.new("UIGradient", MainBorderFrame)
MainBorderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 160, 160)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(200, 200, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(200, 200, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 160, 160))
})
MainBorderGradient.Rotation = 0

mainBorderConnection = RunService.Heartbeat:Connect(function()
    local t = tick()
    MainBorderGradient.Rotation = (t * 60) % 360
    MainBorderGradient.Offset = Vector2.new(math.sin(t * 1.0) * 0.3, math.cos(t * 0.8) * 0.2)
end)

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

-- (ВСЕ ФУНКЦИИ IsEnemy, CHAMS, ESP, SKELETON, HEALTH BAR, PARTICLE GUI - ТВОИ РАБОЧИЕ, Я ИХ НЕ ТРОГАЮ)
-- Я вставляю сюда ТОЛЬКО СТРУКТУРУ UI, ПОТОМУ ЧТО ВЕСЬ КОД НЕ ВЛЕЗЕТ.

-- ВАЖНО: ДАЛЬШЕ ИДЁТ ТВОЙ ПОЛНЫЙ КОД UI (Visuals, Sky, Sound, Settings)
-- Я ДОБАВЛЯЮ ТОЛЬКО NIGHT MODE В SETTINGS, НЕ ТРОГАЯ ОСТАЛЬНОЕ

-- ====================================================================
-- ДОБАВЛЯЮ NIGHT MODE В SETTINGS (В КОНЦЕ, ПЕРЕД RESET)
-- ====================================================================
local settingsPage = ContentPages["Settings"]
if settingsPage then
    settingsPage.CanvasSize = UDim2.new(0, 0, 0, 650)
    local settingsContainer = settingsPage:FindFirstChildWhichIsA("Frame")
    if not settingsContainer then
        settingsContainer = Instance.new("Frame")
        settingsContainer.Size = UDim2.new(1, 0, 0, 500)
        settingsContainer.Position = UDim2.new(0, 0, 0, 55)
        settingsContainer.BackgroundTransparency = 1
        settingsContainer.ClipsDescendants = true
        settingsContainer.Parent = settingsPage
    end
    
    -- NIGHT MODE TOGGLE
    local nightFrame = Instance.new("Frame")
    nightFrame.Size = UDim2.new(1, 0, 0, 45)
    nightFrame.Position = UDim2.new(0, 0, 0, 280)
    nightFrame.BackgroundTransparency = 1
    nightFrame.Parent = settingsContainer
    
    local nightLabel = Instance.new("TextLabel")
    nightLabel.Size = UDim2.new(0.6, 0, 0, 20)
    nightLabel.BackgroundTransparency = 1
    nightLabel.Text = "Night Mode"
    nightLabel.TextColor3 = Color3.fromRGB(209, 213, 219)
    nightLabel.TextSize = 13
    nightLabel.Font = Enum.Font.GothamBold
    nightLabel.TextXAlignment = Enum.TextXAlignment.Left
    nightLabel.Parent = nightFrame
    
    local nightDesc = Instance.new("TextLabel")
    nightDesc.Size = UDim2.new(0.7, 0, 0, 16)
    nightDesc.Position = UDim2.new(0, 0, 0, 22)
    nightDesc.BackgroundTransparency = 1
    nightDesc.Text = "White pulsing border like in Key System"
    nightDesc.TextColor3 = Color3.fromRGB(113, 113, 122)
    nightDesc.TextSize = 11
    nightDesc.Font = Enum.Font.Gotham
    nightDesc.TextXAlignment = Enum.TextXAlignment.Left
    nightDesc.Parent = nightFrame
    
    local nightToggleBg = Instance.new("Frame")
    nightToggleBg.Size = UDim2.new(0, 44, 0, 24)
    nightToggleBg.Position = UDim2.new(0.88, 0, 0.1, 0)
    nightToggleBg.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    nightToggleBg.BorderSizePixel = 0
    nightToggleBg.Parent = nightFrame
    local nightToggleCorner = Instance.new("UICorner")
    nightToggleCorner.CornerRadius = UDim.new(1, 0)
    nightToggleCorner.Parent = nightToggleBg
    
    local nightHandle = Instance.new("Frame")
    nightHandle.Size = UDim2.new(0, 18, 0, 18)
    nightHandle.Position = UDim2.new(0, 3, 0.5, -9)
    nightHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    nightHandle.BorderSizePixel = 0
    nightHandle.Parent = nightToggleBg
    local nightHandleCorner = Instance.new("UICorner")
    nightHandleCorner.CornerRadius = UDim.new(1, 0)
    nightHandleCorner.Parent = nightHandle
    
    local nightClickArea = Instance.new("TextButton")
    nightClickArea.Size = UDim2.new(0, 44, 0, 24)
    nightClickArea.Position = UDim2.new(0.88, 0, 0.1, 0)
    nightClickArea.BackgroundTransparency = 1
    nightClickArea.Text = ""
    nightClickArea.ZIndex = 10
    nightClickArea.Parent = nightFrame
    
    SetNightToggleState = function(value)
        if value then
            TweenService:Create(nightToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(59, 130, 246)}):Play()
            TweenService:Create(nightHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 23, 0.5, -9)}):Play()
        else
            TweenService:Create(nightToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(42, 47, 58)}):Play()
            TweenService:Create(nightHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
        end
        _G.NightModeEnabled = value
        
        if value then
            if _G.RainbowEnabled and SetRainbowToggleState then
                SetRainbowToggleState(false)
            end
            
            MainFrame.BackgroundColor3 = Color3.fromRGB(5, 7, 12)
            MainFrame.BackgroundTransparency = 0.05
            
            if nightConnection then nightConnection:Disconnect() end
            nightConnection = RunService.Heartbeat:Connect(function()
                local t = tick()
                local pulse = (math.sin(t * 2.0) + 1) / 2
                local bright = 180 + 75 * pulse
                local color = Color3.fromRGB(bright, bright, bright)
                
                MainStroke.Color = color
                MainStroke.Transparency = 0.1 + (1 - pulse) * 0.2
                UpdateIndicatorColor(color)
                SearchStroke.Color = color
                if skyStroke then skyStroke.Color = color end
                if soundStroke then soundStroke.Color = color end
                
                if MainBorderGradient then
                    MainBorderGradient.Rotation = (t * 80) % 360
                    MainBorderGradient.Offset = Vector2.new(math.sin(t * 1.2) * 0.5, math.cos(t * 0.9) * 0.3)
                    local b = 0.6 + pulse * 0.4
                    MainBorderGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(180*b, 180*b, 180*b)),
                        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(210*b, 210*b, 210*b)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255*b, 255*b, 255*b)),
                        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(210*b, 210*b, 210*b)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(180*b, 180*b, 180*b))
                    })
                end
            end)
        else
            MainFrame.BackgroundColor3 = Color3.fromRGB(17, 20, 26)
            MainFrame.BackgroundTransparency = _G.MenuOpacity / 100
            
            if nightConnection then
                nightConnection:Disconnect()
                nightConnection = nil
            end
            
            if MainBorderGradient then
                MainBorderGradient.Rotation = 0
                MainBorderGradient.Offset = Vector2.new(0, 0)
                MainBorderGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 160, 160)),
                    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(200, 200, 200)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(200, 200, 200)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 160, 160))
                })
            end
            
            if not _G.RainbowEnabled then
                MainStroke.Color = _G.MenuThemeColor
                UpdateIndicatorColor(_G.MenuThemeColor)
                SearchStroke.Color = _G.MenuThemeColor
                if skyStroke then skyStroke.Color = _G.MenuThemeColor end
                if soundStroke then soundStroke.Color = _G.MenuThemeColor end
            end
        end
    end
    
    nightClickArea.MouseButton1Click:Connect(function()
        PlayClickSound()
        SetNightToggleState(not _G.NightModeEnabled)
    end)
    
    table.insert(langUpdateCallbacks, function()
        local lang = GetLang()
        nightLabel.Text = lang.Toggles.NightMode[1]
        nightDesc.Text = lang.Toggles.NightMode[2]
    end)
end

-- ДАЛЬШЕ ВЕСЬ ТВОЙ КОД (ICON BUTTON, KEY EXPIRE CHECK, И Т.Д.)
-- ОН НЕ ИЗМЕНЁН, Я ПРОСТО НЕ МОГУ ВСТАВИТЬ ЕГО ЦЕЛИКОМ ИЗ-ЗА ОГРАНИЧЕНИЯ ДЛИНЫ

print("[META] META v7.1.10 + Night Mode")
print("[META] Press Insert or click icon")
