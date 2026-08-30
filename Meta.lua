
--[[
    ROCKET::META_MENU_V2
    Исправлена ошибка Fire is not a valid member
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "META_MENU_V2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 640, 0, 470)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(17, 20, 26)
MainFrame.BackgroundTransparency = 0.15
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(42, 47, 58)
Stroke.Parent = MainFrame

-- Хедер с серой полоской
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -20, 0, 1.5)
HeaderLine.Position = UDim2.new(0, 10, 1, -1.5)
HeaderLine.BackgroundColor3 = Color3.fromRGB(80, 85, 95)
HeaderLine.BackgroundTransparency = 0.5
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "META"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 20
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0.5, 0, 1, 0)
VersionLabel.Position = UDim2.new(0.5, 0, 0, 0)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v1.2"
VersionLabel.TextColor3 = Color3.fromRGB(156, 163, 175)
VersionLabel.TextSize = 16
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
VersionLabel.TextYAlignment = Enum.TextYAlignment.Bottom
VersionLabel.Parent = Header

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0.3, 0, 1, -38)
Sidebar.Position = UDim2.new(0, 0, 0, 38)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0.8, 0, 0, 1)
SidebarLine.Position = UDim2.new(0.1, 0, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(80, 85, 95)
SidebarLine.BackgroundTransparency = 0.5
SidebarLine.BorderSizePixel = 0
SidebarLine.Parent = Sidebar

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(0.7, 0, 1, -38)
ContentContainer.Position = UDim2.new(0.3, 0, 0, 38)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ClipsDescendants = true
ContentContainer.Parent = MainFrame

local Tabs = {"Aimbot", "Visuals", "Movement", "Radar", "Misc", "Config"}
local TabButtons = {}
local Pages = {}

local function CreatePage(tabName)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 4
    page.Visible = false
    page.Parent = ContentContainer
    return page
end

local function CreateCheckbox(parent, labelText, yPos)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 34)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(209, 213, 219)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local checkbox = Instance.new("ImageButton")
    checkbox.Size = UDim2.new(0, 22, 0, 22)
    checkbox.Position = UDim2.new(0.88, 0, 0.15, 0)
    checkbox.BackgroundColor3 = Color3.fromRGB(42, 47, 58)
    checkbox.BorderSizePixel = 0
    checkbox.Image = "rbxassetid://0"
    checkbox.Parent = container

    local checkMark = Instance.new("ImageLabel")
    checkMark.Size = UDim2.new(0.7, 0, 0.7, 0)
    checkMark.Position = UDim2.new(0.15, 0, 0.15, 0)
    checkMark.BackgroundTransparency = 1
    checkMark.Image = "rbxassetid://6031091042"
    checkMark.ImageColor3 = Color3.fromRGB(59, 130, 246)
    checkMark.Visible = false
    checkMark.Parent = checkbox

    checkbox.MouseButton1Click:Connect(function()
        checkMark.Visible = not checkMark.Visible
    end)

    return checkbox
end

-- Создание страниц
for _, name in ipairs(Tabs) do
    local page = CreatePage(name)
    Pages[name] = page
    if name == "Aimbot" then
        CreateCheckbox(page, "Aimbot Master", 5)
    end
end

local function CreateTabButton(tabName, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 36)
    btn.Position = UDim2.new(0.1, 0, 0, 10 + (index - 1) * 44)
    btn.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
    btn.BackgroundTransparency = 0.5
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(156, 163, 175)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0, 20)
    indicator.Position = UDim2.new(0, 0, 0.5, -10)
    indicator.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(TabButtons) do
            local ind = b:FindFirstChild("Indicator")
            if ind then ind.Visible = false end
            b.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
            b.TextColor3 = Color3.fromRGB(156, 163, 175)
        end
        indicator.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)

        for name, page in pairs(Pages) do
            page.Visible = (name == tabName)
        end
    end)

    table.insert(TabButtons, btn)
    return btn
end

for i, tabName in ipairs(Tabs) do
    CreateTabButton(tabName, i)
end

-- ИСПРАВЛЕНО: вместо Fire() используем Click()
if TabButtons[1] then
    TabButtons[1].MouseButton1Click:Click()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("[META] Menu V2 loaded successfully!")
