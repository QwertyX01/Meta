-- ======================================================
-- НОВЫЙ GUI: META v4.0 — АКРИЛ/МАТОВОЕ СТЕКЛО
-- ======================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "META_GUI_V4"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Фоновое затемнение
local Blur = Instance.new("BlurEffect")
Blur.Size = 12
Blur.Parent = Lighting

-- Главное окно 640x470
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 640, 0, 470)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
MainFrame.BackgroundTransparency = 0.25
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Selectable = true

-- Скруглённые углы
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

-- Стеклянная обводка (акрил)
local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1.5
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.Transparency = 0.15
Stroke.Parent = MainFrame

-- ========== ХЕДЕР ==========
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.3, 0, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Meta"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 26
Title.Font = Enum.Font.Gotham
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextYAlignment = Enum.TextYAlignment.Center
Title.Parent = Header

-- Линия-разделитель
local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, -32, 0, 1)
Separator.Position = UDim2.new(0, 16, 0, 52)
Separator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Separator.BackgroundTransparency = 0.2
Separator.BorderSizePixel = 0
Separator.Parent = MainFrame

-- ========== НАВИГАЦИЯ (ТАБЫ) ==========
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -32, 0, 40)
TabContainer.Position = UDim2.new(0, 16, 0, 56)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local Tabs = {"Aimbot", "Visuals", "Movement", "Radar", "Misc", "Config"}
local TabButtons = {}

for i, name in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.14, 0, 1, 0)
    btn.Position = UDim2.new((i - 1) * 0.15 + 0.005, 0, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 185, 195)
    btn.TextSize = 15
    btn.Font = Enum.Font.Gotham
    btn.Parent = TabContainer
    
    btn.MouseEnter:Connect(function()
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    btn.MouseLeave:Connect(function()
        btn.TextColor3 = Color3.fromRGB(180, 185, 195)
    end)
    
    -- Индикатор активной вкладки
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0.6, 0, 0, 2)
    indicator.Position = UDim2.new(0.2, 0, 1, -2)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    indicator.BackgroundTransparency = 0.6
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(TabButtons) do
            local ind = b:FindFirstChild("Indicator")
            if ind then ind.Visible = false end
            b.TextColor3 = Color3.fromRGB(180, 185, 195)
        end
        indicator.Visible = true
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    table.insert(TabButtons, btn)
end

-- ========== ПУСТАЯ ОБЛАСТЬ КОНТЕНТА ==========
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -32, 1, -110)
ContentArea.Position = UDim2.new(0, 16, 0, 100)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- Активировать первую вкладку по умолчанию
if TabButtons[1] then
    TabButtons[1].MouseButton1Click:Fire()
end

-- Настройки меню: Insert для скрытия/показа
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
        Blur.Enabled = MainFrame.Visible
    end
end)

print("[META V4] Acrylic GUI loaded — clean, empty, minimalist.")
