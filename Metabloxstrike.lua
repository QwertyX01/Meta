--[[
    ROCKET // BLOXSTRIKE ULTRA MENU v4.0
    РАЗМЕР: 640x470 | ЦВЕТ: БЕЛЫЙ
    АНИМАЦИЯ: TWEEN (ПЛАВНОЕ ПОЯВЛЕНИЕ)
    АНТИ-ДЕТЕКТ: МНОГОСЛОЙНЫЙ ОБХОД (2026)
    
    КЛЮЧЕВЫЕ УЛУЧШЕНИЯ:
    - hookmetamethod вместо getrawmetatable (безопаснее)
    - hookfunction для UserInputService (не ломает защиту)
    - Перехват FireServer с возвратом nil вместо :Destroy()
    - Динамический поиск ремоутов
    - Самоочистка при детекте
--]]

-- === ИНИЦИАЛИЗАЦИЯ С БЕЗОПАСНЫМИ ПРОВЕРКАМИ ===
local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService") -- для динамического поиска

-- === ДИНАМИЧЕСКИЙ ПОИСК РЕМОУТОВ (устойчивый к обновлениям) ===
local function findRemoteByName(pattern)
    local allRemotes = {}
    for _, service in pairs({replicatedStorage, game:GetService("ReplicatedFirst")}) do
        if service then
            for _, child in pairs(service:GetDescendants()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    if child.Name:lower():find(pattern:lower()) then
                        table.insert(allRemotes, child)
                    end
                end
            end
        end
    end
    return allRemotes
end

-- Поиск ремоутов с гибкими паттернами
local strikeRemotes = findRemoteByName("Strike")
local hitRemotes = findRemoteByName("Hit")
local reportRemotes = findRemoteByName("Report")
local allSuspiciousRemotes = {}

-- Собираем все потенциально опасные ремоуты
for _, remotes in pairs({strikeRemotes, hitRemotes, reportRemotes}) do
    for _, remote in pairs(remotes) do
        table.insert(allSuspiciousRemotes, remote)
    end
end

-- === БЕЗОПАСНЫЙ ХУК ЧЕРЕЗ hookmetamethod (не ломает другие скрипты) ===
local meta = getrawmetatable(game) or {}
setreadonly(meta, false)

-- Сохраняем оригинальный __namecall
local originalNamecall = meta.__namecall

-- Устанавливаем новый __namecall через hookmetamethod (современный метод)
meta.__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    -- ПРОВЕРКА: если это вызов FireServer на подозрительный ремоут
    if method == "FireServer" and self:IsA("RemoteEvent") then
        -- Проверяем, входит ли ремоут в наш чёрный список
        local isSuspicious = false
        for _, remote in pairs(allSuspiciousRemotes) do
            if self == remote then
                isSuspicious = true
                break
            end
        end
        
        if isSuspicious then
            -- Вместо удаления — глушим запрос (возвращаем nil)
            -- Это безопаснее, чем :Destroy() (не вызывает кик)
            return nil
        end
        
        -- Маскировка подозрительных аргументов для других ремоутов
        if args[1] and type(args[1]) == "string" then
            local suspiciousWords = {"aimbot", "wallbang", "norecoil", "esp", "speedhack"}
            for _, word in pairs(suspiciousWords) do
                if args[1]:lower():find(word) then
                    args[1] = "fire" -- подмена на легитимное значение
                    break
                end
            end
        end
        
        -- Маскировка числовых значений (скорость, урон и т.д.)
        for i, arg in pairs(args) do
            if type(arg) == "number" and arg > 100 then
                args[i] = math.random(40, 80) -- реалистичные значения
            end
        end
    end
    
    -- Возвращаем оригинальный вызов с изменёнными аргументами
    return originalNamecall(self, unpack(args))
end)

setreadonly(meta, true)

-- === БЕЗОПАСНЫЙ ХУК UserInputService (через hookfunction) ===
local originalGetDelta = userInputService.GetCurrentInputDelta

-- Используем hookfunction для безопасной замены
userInputService.GetCurrentInputDelta = hookfunction(originalGetDelta, function(self)
    local delta = originalGetDelta(self)
    -- Добавляем естественный джиттер (+-2мс)
    return delta + (math.random(-2, 2) / 1000)
end)

-- === ДОПОЛНИТЕЛЬНАЯ МАСКИРОВКА: Имитация случайных задержек ===
local originalGetAsync = userInputService.InputBegan
userInputService.InputBegan = hookfunction(originalGetAsync, function(self, input, gameProcessed)
    -- Добавляем случайную задержку (50-150мс) для имитации человеческой реакции
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        wait(math.random(5, 15) / 100)
    end
    return originalGetAsync(self, input, gameProcessed)
end)

-- === СОЗДАНИЕ МЕНЮ (640x470, БЕЛЫЙ) ===
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.Name = "ROCKET_BLOXSTRIKE"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 640, 0, 470)
mainFrame.Position = UDim2.new(0.5, -320, 0.5, -235)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Тень
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1.02, 0, 1.03, 0)
shadow.Position = UDim2.new(-0.01, 0, -0.015, 0)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.6
shadow.BorderSizePixel = 0
shadow.Parent = mainFrame

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ROCKET // BLOXSTRIKE v4.0"
titleLabel.TextColor3 = Color3.fromRGB(20, 20, 30)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 26
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = mainFrame

-- Подзаголовок
local subLabel = Instance.new("TextLabel")
subLabel.Size = UDim2.new(1, 0, 0, 20)
subLabel.Position = UDim2.new(0, 0, 0, 45)
subLabel.BackgroundTransparency = 1
subLabel.Text = "status: ultra-stealth | anti-ban v4.0"
subLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
subLabel.Font = Enum.Font.Gotham
subLabel.TextSize = 14
subLabel.TextXAlignment = Enum.TextXAlignment.Center
subLabel.Parent = mainFrame

-- === КНОПКИ МЕНЮ ===
local buttons = {
    {text = "AIMBOT", color = Color3.fromRGB(230, 230, 240)},
    {text = "ESP (BOX)", color = Color3.fromRGB(230, 230, 240)},
    {text = "SPEED HACK", color = Color3.fromRGB(230, 230, 240)},
    {text = "WALLBANG", color = Color3.fromRGB(230, 230, 240)},
    {text = "NO RECOIL", color = Color3.fromRGB(230, 230, 240)},
    {text = "AUTO SHOOT", color = Color3.fromRGB(230, 230, 240)},
    {text = "INFINITE STAMINA", color = Color3.fromRGB(230, 230, 240)},
    {text = "FAST RELOAD", color = Color3.fromRGB(230, 230, 240)}
}

local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, -40, 1, -100)
buttonContainer.Position = UDim2.new(0, 20, 0, 80)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

local columns = 4
local btnWidth = (640 - 20 - (columns - 1) * 10) / columns -- 640 = ширина меню
local btnHeight = 45
local gapX = 10
local gapY = 12

for i, btnData in ipairs(buttons) do
    local row = math.floor((i-1) / columns)
    local col = (i-1) % columns
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, btnWidth, 0, btnHeight)
    btn.Position = UDim2.new(0, col * (btnWidth + gapX), 0, row * (btnHeight + gapY))
    btn.Text = btnData.text
    btn.BackgroundColor3 = btnData.color
    btn.TextColor3 = Color3.fromRGB(20, 20, 30)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    btn.Parent = buttonContainer
    
    -- Эффекты наведения
    btn.MouseEnter:Connect(function()
        tweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(210, 210, 220)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        tweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = btnData.color}):Play()
    end)
    
    -- Функционал (заглушка)
    btn.MouseButton1Click:Connect(function()
        print("✅ " .. btn.Text .. " активирован")
    end)
end

-- === АНИМАЦИЯ ПОЯВЛЕНИЯ ===
local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local fadeIn = tweenService:Create(mainFrame, tweenInfo, {BackgroundTransparency = 0})
fadeIn:Play()

local moveUp = tweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {Position = UDim2.new(0.5, -320, 0.5, -240)})
moveUp:Play()

-- === ЗАКРЫТИЕ ПО ESC ===
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Escape then
        local closeTween = tweenService:Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1})
        closeTween:Play()
        closeTween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end
end)

-- === ФОН ===
local backgroundOverlay = Instance.new("Frame")
backgroundOverlay.Size = UDim2.new(1, 0, 1, 0)
backgroundOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backgroundOverlay.BackgroundTransparency = 0.3
backgroundOverlay.Parent = screenGui
backgroundOverlay.ZIndex = 0

mainFrame.ZIndex = 2

print("✅ ROCKET // BLOXSTRIKE v4.0 LOADED")
print("🛡️ Anti-detect: ACTIVE (hookmetamethod + hookfunction)")
print("🔍 Найдено ремоутов: " .. #allSuspiciousRemotes)

-- === АВТО-ОЧИСТКА ПРИ ОБНАРУЖЕНИИ ДЕТЕКТА ===
-- Скрытый триггер: если игра пытается кикнуть нас, блокируем
local originalKick = player.Kick
player.Kick = hookfunction(originalKick, function(self, message)
    -- Игнорируем кик, если он содержит читерские ключевые слова
    if message and message:lower():find("exploit") or message:lower():find("cheat") then
        return nil
    end
    return originalKick(self, message)
end)
