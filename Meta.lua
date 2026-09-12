-- META UI V7.9.1
local TweenService=game:GetService("TweenService")
local CoreGui=game:GetService("CoreGui")
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local SoundService=game:GetService("SoundService")
local Lighting=game:GetService("Lighting")
local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Camera=workspace.CurrentCamera
local LocalPlayer=Players.LocalPlayer
local AntiBanEnabled=true
local BlockedRemoteNames={"iac-respond","report","Memer","AC_Detect","AntiCheat","detect","suspicious","kick","ban"}
local SpoofedProperties={WalkSpeed=16,JumpPower=50,HipHeight=2}
local function HideGuiFromScanner(gui)
pcall(function()
sethiddenproperty(gui,"RobloxLocked",true)
sethiddenproperty(gui,"Archivable",false)
end)
end
pcall(function()
local gmt=getrawmetatable(game)
if gmt then
local oldIndex=gmt.__index
setreadonly(gmt,false)
gmt.__index=newcclosure(function(self,key)
if AntiBanEnabled and self==LocalPlayer and SpoofedProperties[key] then
return SpoofedProperties[key]
end
return oldIndex(self,key)
end)
setreadonly(gmt,true)
end
end)
local function BlockRemotes()
for _,obj in ipairs(ReplicatedStorage:GetDescendants()) do
if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
local n=obj.Name:lower()
for _,blocked in ipairs(BlockedRemoteNames) do
if n:find(blocked:lower()) then
pcall(function()
if obj.FireServer then hookfunction(obj.FireServer,function() end) end
end)
break
end
end
end
end
end
BlockRemotes()
local RateLimitCache={}
local function SafeRateLimit(key,maxPerSec,fn)
local now=tick()
if not RateLimitCache[key] then RateLimitCache[key]={} end
local valid={}
for _,t in ipairs(RateLimitCache[key]) do
if now-t<1 then table.insert(valid,t) end
end
RateLimitCache[key]=valid
if #valid>=maxPerSec then return nil end
table.insert(RateLimitCache[key],now)
return fn()
end
_G.CustomThemeEnabled=false
_G.MenuThemeColor=Color3.fromRGB(255,255,255)
_G.CurrentLang="EN"
_G.MenuOpacity=12
_G.RainbowEnabled=false
_G.MenuScale=45
_G.FlyingDots=false
_G.ChamsEnabled=false
_G.ESPEnabled=false
_G.HealthBarEnabled=false
_G.SkeletonEnabled=false
_G.ParticleEffectGuiEnabled=false
_G.ChamsColor=Color3.fromRGB(110,60,170)
_G.SkeletonColor=Color3.fromRGB(255,255,255)
_G.FpsBoostEnabled=false
_G.SilentAimEnabled=false
_G.OffCircleEnabled=false
_G.SilentAimFOV=200
_G.SelectedPart="Head"
_G.NoRecoilEnabled=false
_G.NoSpreadEnabled=false
_G.NoReloadEnabled=false
_G.SlowWeaponEnabled=false
_G.SlowWeaponSpeed=0.3
_G.InvisibleArmsEnabled=false
local Dots={}
local DotConnection=nil
local opacitySliderFill,opacitySliderHandle,opacityValue=nil,nil,nil
local scaleSliderFill,scaleSliderHandle,scaleValue=nil,nil,nil
local pickerDot,pickerContainer=nil,nil
local SetToggleState,ShiftContainer=nil,nil
local SetChamsToggleState,SetRainbowToggleState=nil,nil
local SetFlyingToggleState,SetESPToggleState=nil,nil
local SetHealthBarToggleState,SetSkeletonToggleState=nil,nil
local SetParticleGuiToggleState=nil
local SetFpsBoostState=nil
local SetSilentAimState=nil
local SetOffCircleState=nil
local skyStroke=nil
local soundStroke=nil
local skyConnection=nil
local fireInputBegan=nil
local fireInputEnded=nil
local muteConnection=nil
local guiMuteConnection=nil
local MainBorderFrame=nil
local MainBorderGradient=nil
local mainBorderConnection=nil
local LANG={
RU={
Tabs={"Аимбот","Визуал","Разное","Настройки","Скай","Звук"},
Toggles={
UI_Color={"Цвет интерфейса","Включить кастомизацию цвета интерфейса"},
Opacity={"Прозрачность","Регулировка прозрачности меню (0-50%)"},
Rainbow={"Разноцветная обводка","Включить радужную обводку меню"},
Scale={"Scaling the menu","Масштабирование меню (60-140%)"},
FlyingDots={"Летающие точки","Точки, летающие с верху меню"},
Chams={"Чамсы","Функция которая делает противников фиолетовым"},
ESP={"Линии и 3D Боксы","Линии с боксами которые ведут к противникам"},
Skeleton={"Скелетон","Скелетон для противников"},
HealthBar={"Здоровье противников","Полоска здоровья над головой"},
ParticleEffectGui={"Эффект частиц GUI","Добавляет эффект точек на GUI интерфейса"},
FpsBoost={"FPS Boost","Делает карту безлаганной"},
SilentAim={"Silent Aim","Автоматически целится во врагов в FOV"},
OffCircle={"Off Circle","Скрывает круг FOV но оставляет аим"},
Reset={"Сброс настроек","Вернуть все настройки к стандартным"}
}
},
EN={
Tabs={"Aimbot","Visuals","Misc","Settings","Sky","Sound"},
Toggles={
UI_Color={"UI Color","Enable interface color customization"},
Opacity={"Opacity","Adjust menu transparency (0-50%)"},
Rainbow={"UI Rainbow Color","Enable rainbow menu outline"},
Scale={"Scaling the menu","Menu scaling (60-140%)"},
FlyingDots={"Flying Dots","Floating dots from the top of the menu"},
Chams={"Chams","Makes enemies purple"},
ESP={"Tracers and 3D Box","Lines with boxes leading to enemies"},
Skeleton={"Skeleton","Skeleton for enemies"},
HealthBar={"Health Bar","Health bar above enemies"},
ParticleEffectGui={"Particle Effect GUI","Adds particle effect to GUI interface"},
FpsBoost={"FPS Boost (recommended for weak devices)","Makes the map lag-free"},
SilentAim={"Silent Aim","Automatically aims at enemies in FOV"},
OffCircle={"Off Circle","Hides the FOV circle but keeps aim"},
Reset={"Reset Settings","Return all settings to default"}
}
}
}
local function GetLang() return _G.CurrentLang=="RU" and LANG.RU or LANG.EN end
local function PlayTabSound()
local sound=Instance.new("Sound")
sound.SoundId="rbxassetid://88442833509532"
sound.Volume=0.5
sound.Parent=SoundService
sound:Play()
task.delay(sound.TimeLength+0.1,function() sound:Destroy() end)
end
local function PlayClickSound()
local sound=Instance.new("Sound")
sound.SoundId="rbxassetid://88442833509532"
sound.Volume=0.3
sound.Parent=SoundService
sound:Play()
task.delay(sound.TimeLength+0.1,function() sound:Destroy() end)
end
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="RobloxGui"
ScreenGui.ResetOnSpawn=false
ScreenGui.IgnoreGuiInset=true
ScreenGui.DisplayOrder=999999998
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.Parent=CoreGui
HideGuiFromScanner(ScreenGui)
local MainFrame=Instance.new("Frame")
MainFrame.Name="GameUI"
MainFrame.Size=UDim2.new(0,640*(_G.MenuScale/45),0,470*(_G.MenuScale/45))
MainFrame.AnchorPoint=Vector2.new(0.5,0.5)
MainFrame.Position=UDim2.new(0.5,0,0.5,0)
MainFrame.BackgroundColor3=Color3.fromRGB(17,20,26)
MainFrame.BackgroundTransparency=_G.MenuOpacity/100
MainFrame.ClipsDescendants=false
MainFrame.Parent=ScreenGui
MainFrame.Draggable=true
MainFrame.Active=true
MainFrame.Selectable=true
MainFrame.Visible=false
local MainCorner=Instance.new("UICorner")
MainCorner.CornerRadius=UDim.new(0,12)
MainCorner.Parent=MainFrame
MainBorderFrame=Instance.new("Frame",MainFrame)
MainBorderFrame.Name="MainBorderFrame"
MainBorderFrame.Size=UDim2.new(1,8,1,8)
MainBorderFrame.Position=UDim2.new(0,-4,0,-4)
MainBorderFrame.BackgroundColor3=Color3.fromRGB(255,255,255)
MainBorderFrame.BorderSizePixel=0
MainBorderFrame.BackgroundTransparency=_G.MenuOpacity/100
MainBorderFrame.ZIndex=1
Instance.new("UICorner",MainBorderFrame).CornerRadius=UDim.new(0,15)
MainBorderGradient=Instance.new("UIGradient",MainBorderFrame)
MainBorderGradient.Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,Color3.fromRGB(160,160,160)),
ColorSequenceKeypoint.new(0.25,Color3.fromRGB(200,200,200)),
ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(0.75,Color3.fromRGB(200,200,200)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(160,160,160))
})
MainBorderGradient.Rotation=0
mainBorderConnection=RunService.Heartbeat:Connect(function()
local t=tick()
MainBorderGradient.Rotation=(t*30)%360
end)
local MainScale=Instance.new("UIScale")
MainScale.Scale=1
MainScale.Parent=MainFrame
local MainStroke=Instance.new("UIStroke")
MainStroke.Thickness=2
MainStroke.Color=_G.MenuThemeColor
MainStroke.Transparency=0.4
MainStroke.Parent=MainFrame
local Header=Instance.new("Frame")
Header.Name="Topbar"
Header.Size=UDim2.new(1,0,0,38)
Header.BackgroundTransparency=1
Header.Parent=MainFrame
local MetaLabel=Instance.new("TextLabel")
MetaLabel.Size=UDim2.new(0.1,0,1,0)
MetaLabel.Position=UDim2.new(0,15,0,0)
MetaLabel.BackgroundTransparency=1
MetaLabel.Text="META"
MetaLabel.TextColor3=Color3.fromRGB(255,255,255)
MetaLabel.TextSize=20
MetaLabel.Font=Enum.Font.GothamBold
MetaLabel.TextXAlignment=Enum.TextXAlignment.Left
MetaLabel.TextYAlignment=Enum.TextYAlignment.Center
MetaLabel.Parent=Header
local BetaLabel=Instance.new("TextLabel")
BetaLabel.Size=UDim2.new(0,50,1,0)
BetaLabel.Position=UDim2.new(0,75,0,0)
BetaLabel.BackgroundTransparency=1
BetaLabel.Text="beta"
BetaLabel.TextColor3=Color3.fromRGB(120,120,120)
BetaLabel.TextSize=12
BetaLabel.Font=Enum.Font.Gotham
BetaLabel.TextXAlignment=Enum.TextXAlignment.Left
BetaLabel.TextYAlignment=Enum.TextYAlignment.Center
BetaLabel.Parent=Header
local GameNameLabel=Instance.new("TextLabel")
GameNameLabel.Size=UDim2.new(0.35,0,1,0)
GameNameLabel.Position=UDim2.new(0.32,0,0,0)
GameNameLabel.BackgroundTransparency=1
GameNameLabel.Text="Loading..."
GameNameLabel.TextColor3=Color3.fromRGB(156,163,175)
GameNameLabel.TextSize=13
GameNameLabel.Font=Enum.Font.Gotham
GameNameLabel.TextXAlignment=Enum.TextXAlignment.Left
GameNameLabel.TextYAlignment=Enum.TextYAlignment.Center
GameNameLabel.Parent=Header
pcall(function()
local MarketplaceService=game:GetService("MarketplaceService")
local info=MarketplaceService:GetProductInfo(game.PlaceId)
if info and info.Name then GameNameLabel.Text=info.Name end
end)
local SearchContainer=Instance.new("Frame")
SearchContainer.Size=UDim2.new(0.3,0,0.7,0)
SearchContainer.Position=UDim2.new(0.68,0,0.15,0)
SearchContainer.BackgroundColor3=Color3.fromRGB(42,47,58)
SearchContainer.BackgroundTransparency=0.5
SearchContainer.BorderSizePixel=0
SearchContainer.Parent=Header
Instance.new("UICorner",SearchContainer).CornerRadius=UDim.new(0,6)
local SearchStroke=Instance.new("UIStroke")
SearchStroke.Thickness=1
SearchStroke.Color=_G.MenuThemeColor
SearchStroke.Transparency=0.6
SearchStroke.Parent=SearchContainer
local SearchInput=Instance.new("TextBox")
SearchInput.Size=UDim2.new(1,-12,1,0)
SearchInput.Position=UDim2.new(0,8,0,0)
SearchInput.BackgroundTransparency=1
SearchInput.Text="Search..."
SearchInput.TextColor3=Color3.fromRGB(209,213,219)
SearchInput.TextSize=13
SearchInput.Font=Enum.Font.Gotham
SearchInput.TextXAlignment=Enum.TextXAlignment.Left
SearchInput.TextYAlignment=Enum.TextYAlignment.Center
SearchInput.ClearTextOnFocus=false
SearchInput.Parent=SearchContainer
local SearchClose=Instance.new("TextButton")
SearchClose.Size=UDim2.new(0,16,1,0)
SearchClose.Position=UDim2.new(1,-20,0,0)
SearchClose.BackgroundTransparency=1
SearchClose.Text="✕"
SearchClose.TextColor3=Color3.fromRGB(156,163,175)
SearchClose.TextSize=11
SearchClose.Font=Enum.Font.Gotham
SearchClose.Visible=false
SearchClose.Parent=SearchContainer
SearchClose.MouseButton1Click:Connect(function()
SearchInput.Text="Search..."
SearchClose.Visible=false
PlayClickSound()
end)
local Separator=Instance.new("Frame")
Separator.Size=UDim2.new(1,-20,0,1)
Separator.Position=UDim2.new(0,10,0,38)
Separator.BackgroundColor3=Color3.fromRGB(42,47,58)
Separator.BorderSizePixel=0
Separator.Parent=MainFrame
local TabContainer=Instance.new("Frame")
TabContainer.Size=UDim2.new(1,0,0,48)
TabContainer.Position=UDim2.new(0,0,0,39)
TabContainer.BackgroundTransparency=1
TabContainer.Parent=MainFrame
local TabNames={"Aimbot","Visuals","Misc","Settings","Sky","Sound"}
local TabButtons={}
local ContentPages={}
local activeIndex=1
local langUpdateCallbacks={}
local rainbowConnection=nil
local langButtonData={}
local function IsEnemy(p)
if not p or p==LocalPlayer then return false end
if p.Team and LocalPlayer.Team then
if p.Team~=LocalPlayer.Team then return true end
if p.Team.Name~=LocalPlayer.Team.Name then return true end
end
if p.TeamColor and LocalPlayer.TeamColor then
if p.TeamColor~=LocalPlayer.TeamColor then return true end
end
local mySide=LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("Side") or ""
local enemySide=p:GetAttribute("Team") or p:GetAttribute("Side") or ""
if mySide~="" and enemySide~="" then return mySide~=enemySide end
return false
end
local ChamsConnections={}
local function PaintCharacter(character,p)
if not character or not p then return end
for _,child in ipairs(character:GetChildren()) do
if child:IsA("Highlight") and child:GetAttribute("META_Chams") then child:Destroy() end
end
if IsEnemy(p) then
local highlight=Instance.new("Highlight")
highlight.Name="Highlight"
highlight:SetAttribute("META_Chams",true)
highlight.FillColor=_G.ChamsColor
highlight.OutlineColor=_G.ChamsColor
highlight.FillTransparency=0.65
highlight.OutlineTransparency=0.5
highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
highlight.Adornee=character
highlight.Parent=character
HideGuiFromScanner(highlight)
end
end
local function SetupPlayer(p)
if p==LocalPlayer then return end
if ChamsConnections[p] then ChamsConnections[p]:Disconnect() end
ChamsConnections[p]=p.CharacterAdded:Connect(function(char)
task.wait(0.1)
PaintCharacter(char,p)
end)
if p.Character then PaintCharacter(p.Character,p) end
end
local function ApplyChams()
if _G.UnloadChams then _G.UnloadChams() end
_G.ChamsEnabled=true
for _,p in ipairs(Players:GetPlayers()) do SetupPlayer(p) end
ChamsConnections.PlayerAdded=Players.PlayerAdded:Connect(SetupPlayer)
_G.UnloadChams=function()
_G.ChamsEnabled=false
if ChamsConnections.PlayerAdded then ChamsConnections.PlayerAdded:Disconnect() end
for _,p in ipairs(Players:GetPlayers()) do
if ChamsConnections[p] then ChamsConnections[p]:Disconnect() end
if p.Character then
for _,child in ipairs(p.Character:GetChildren()) do
if child:IsA("Highlight") and child:GetAttribute("META_Chams") then child:Destroy() end
end
end
end
end
end
local function RemoveChams()
if _G.UnloadChams then _G.UnloadChams() end
end
local ESPConnections={}
local function SetupESP()
local function NewLine()
local line=Drawing.new("Line")
line.Visible=false
line.From=Vector2.new(0,0)
line.To=Vector2.new(1,1)
line.Color=Color3.fromRGB(255,255,255)
line.Thickness=1.4
line.Transparency=1
return line
end
local function CreateESP(target)
local lines={}
for i=1,12 do lines[i]=NewLine() end
lines.Tracer=NewLine()
local conn=RunService.RenderStepped:Connect(function()
if not _G.ESPEnabled then for _,l in pairs(lines) do l.Visible=false end return end
local char=target.Character
if not char then for _,l in pairs(lines) do l.Visible=false end return end
local hrp=char:FindFirstChild("HumanoidRootPart")
local head=char:FindFirstChild("Head")
local hum=char:FindFirstChild("Humanoid")
if not hrp or not head or not hum or hum.Health<=0 then for _,l in pairs(lines) do l.Visible=false end return end
if target==LocalPlayer or not IsEnemy(target) then for _,l in pairs(lines) do l.Visible=false end return end
local rootVisible=Camera:WorldToViewportPoint(hrp.Position)
if not rootVisible then for _,l in pairs(lines) do l.Visible=false end return end
local scale=head.Size.Y/2
local boxSize=Vector3.new(2,3,1.5)*(scale*2)
local cf=hrp.CFrame
local c={}
c[1]=Camera:WorldToViewportPoint((cf*CFrame.new(-boxSize.X,boxSize.Y,-boxSize.Z)).Position)
c[2]=Camera:WorldToViewportPoint((cf*CFrame.new(-boxSize.X,boxSize.Y,boxSize.Z)).Position)
c[3]=Camera:WorldToViewportPoint((cf*CFrame.new(boxSize.X,boxSize.Y,boxSize.Z)).Position)
c[4]=Camera:WorldToViewportPoint((cf*CFrame.new(boxSize.X,boxSize.Y,-boxSize.Z)).Position)
c[5]=Camera:WorldToViewportPoint((cf*CFrame.new(-boxSize.X,-boxSize.Y,-boxSize.Z)).Position)
c[6]=Camera:WorldToViewportPoint((cf*CFrame.new(-boxSize.X,-boxSize.Y,boxSize.Z)).Position)
c[7]=Camera:WorldToViewportPoint((cf*CFrame.new(boxSize.X,-boxSize.Y,boxSize.Z)).Position)
c[8]=Camera:WorldToViewportPoint((cf*CFrame.new(boxSize.X,-boxSize.Y,-boxSize.Z)).Position)
local edges={{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}
for i,e in ipairs(edges) do
lines[i].From=Vector2.new(c[e[1]].X,c[e[1]].Y)
lines[i].To=Vector2.new(c[e[2]].X,c[e[2]].Y)
lines[i].Visible=true
end
local bottomPos=Camera:WorldToViewportPoint((cf*CFrame.new(0,-boxSize.Y,0)).Position)
lines.Tracer.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
lines.Tracer.To=Vector2.new(bottomPos.X,bottomPos.Y)
lines.Tracer.Visible=true
end)
ESPConnections[target]=conn
end
local function ApplyESP()
if _G.UnloadESP then _G.UnloadESP() end
_G.ESPEnabled=true
for _,p in ipairs(Players:GetPlayers()) do
if p~=LocalPlayer then CreateESP(p) end
end
ESPConnections.PlayerAdded=Players.PlayerAdded:Connect(function(p)
task.wait(1)
if p~=LocalPlayer and _G.ESPEnabled then CreateESP(p) end
end)
_G.UnloadESP=function()
_G.ESPEnabled=false
if ESPConnections.PlayerAdded then ESPConnections.PlayerAdded:Disconnect() end
for _,conn in pairs(ESPConnections) do
if typeof(conn)=="RBXScriptConnection" then conn:Disconnect() end
end
ESPConnections={}
end
end
local function RemoveESP()
if _G.UnloadESP then _G.UnloadESP() end
end
return ApplyESP,RemoveESP
end
local ApplyESP,RemoveESP=SetupESP()
task.spawn(function()
while true do
task.wait(1)
if _G.ESPEnabled then RemoveESP() ApplyESP() end
end
end)
local SkeletonLines={}
local SkeletonEnemiesList={}
local SkeletonCacheTime=0
local function CreateSkeletonLine()
local line=Drawing.new("Line")
line.Thickness=2
line.Visible=false
line.Color=_G.SkeletonColor or Color3.fromRGB(255,255,255)
line.Transparency=1
return line
end
local function GetSkeletonPos(part)
if not part or not part:IsA("BasePart") then return nil end
local pos=Camera:WorldToViewportPoint(part.Position)
if pos.Z>0 then return Vector2.new(pos.X,pos.Y) end
return nil
end
local function RemoveSkeletonData(target)
local data=SkeletonLines[target]
if data then
pcall(function()
for _,line in pairs(data) do
line.Visible=false
line:Remove()
end
end)
SkeletonLines[target]=nil
end
end
local function GetSkeletonHealth(character)
if not character then return nil,nil end
local humanoid=character:FindFirstChild("Humanoid")
if humanoid and humanoid.Health and humanoid.MaxHealth then
if humanoid.Health>0 then return humanoid.Health,humanoid.MaxHealth end
return nil,nil
end
local healthAttr=character:GetAttribute("Health")
local maxHealthAttr=character:GetAttribute("MaxHealth")
if healthAttr and maxHealthAttr and healthAttr>0 then return healthAttr,maxHealthAttr end
return nil,nil
end
local function UpdateSkeletonEnemies()
if tick()-SkeletonCacheTime<0.5 then return end
SkeletonCacheTime=tick()
SkeletonEnemiesList={}
for _,player in pairs(Players:GetPlayers()) do
if player~=LocalPlayer and player.Character and player.Character.Parent then
if IsEnemy(player) then
local health,maxHealth=GetSkeletonHealth(player.Character)
if health and health>0 then
SkeletonEnemiesList[player]={char=player.Character,health=health,maxHealth=maxHealth}
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
RunService.RenderStepped:Connect(function()
if not _G.SkeletonEnabled then
for _,data in pairs(SkeletonLines) do
for _,line in pairs(data) do line.Visible=false end
end
return
end
UpdateSkeletonEnemies()
for player,data in pairs(SkeletonEnemiesList) do
if not player or not player.Character or not player.Character.Parent then
RemoveSkeletonData(player)
continue
end
local char=player.Character
local health,maxHealth=GetSkeletonHealth(char)
if not health or health<=0 then
RemoveSkeletonData(player)
continue
end
local head=char:FindFirstChild("Head")
local upperTorso=char:FindFirstChild("UpperTorso")
local lowerTorso=char:FindFirstChild("LowerTorso")
local hrp=char:FindFirstChild("HumanoidRootPart")
local torso=char:FindFirstChild("Torso")
if not head or (not upperTorso and not torso) then
RemoveSkeletonData(player)
continue
end
local headPos=GetSkeletonPos(head)
local upperTorsoPos=GetSkeletonPos(upperTorso or torso)
local lowerTorsoPos=GetSkeletonPos(lowerTorso)
local hrpPos=GetSkeletonPos(hrp)
if not headPos or not upperTorsoPos then
RemoveSkeletonData(player)
continue
end
if not SkeletonLines[player] then
SkeletonLines[player]={}
for i=1,15 do table.insert(SkeletonLines[player],CreateSkeletonLine()) end
end
local lines=SkeletonLines[player]
local idx=1
local function setLine(from,to,show)
if from and to and show then
lines[idx].From=from
lines[idx].To=to
lines[idx].Visible=true
lines[idx].Thickness=2
lines[idx].Color=_G.SkeletonColor or Color3.fromRGB(255,255,255)
else
lines[idx].Visible=false
end
idx=idx+1
end
local leftUpperArm=char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
local leftLowerArm=char:FindFirstChild("LeftLowerArm")
local leftHand=char:FindFirstChild("LeftHand")
local rightUpperArm=char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
local rightLowerArm=char:FindFirstChild("RightLowerArm")
local rightHand=char:FindFirstChild("RightHand")
local leftUpperLeg=char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
local leftLowerLeg=char:FindFirstChild("LeftLowerLeg")
local leftFoot=char:FindFirstChild("LeftFoot")
local rightUpperLeg=char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")
local rightLowerLeg=char:FindFirstChild("RightLowerLeg")
local rightFoot=char:FindFirstChild("RightFoot")
setLine(headPos,upperTorsoPos,true)
setLine(upperTorsoPos,lowerTorsoPos,lowerTorsoPos~=nil)
setLine(upperTorsoPos,hrpPos,hrpPos~=nil)
setLine(upperTorsoPos,leftUpperArm and GetSkeletonPos(leftUpperArm),leftUpperArm~=nil)
setLine(leftUpperArm and GetSkeletonPos(leftUpperArm),leftLowerArm and GetSkeletonPos(leftLowerArm),leftUpperArm~=nil and leftLowerArm~=nil)
setLine(leftLowerArm and GetSkeletonPos(leftLowerArm),leftHand and GetSkeletonPos(leftHand),leftLowerArm~=nil and leftHand~=nil)
setLine(upperTorsoPos,rightUpperArm and GetSkeletonPos(rightUpperArm),rightUpperArm~=nil)
setLine(rightUpperArm and GetSkeletonPos(rightUpperArm),rightLowerArm and GetSkeletonPos(rightLowerArm),rightUpperArm~=nil and rightLowerArm~=nil)
setLine(rightLowerArm and GetSkeletonPos(rightLowerArm),rightHand and GetSkeletonPos(rightHand),rightLowerArm~=nil and rightHand~=nil)
if lowerTorsoPos then
setLine(lowerTorsoPos,leftUpperLeg and GetSkeletonPos(leftUpperLeg),leftUpperLeg~=nil)
setLine(lowerTorsoPos,rightUpperLeg and GetSkeletonPos(rightUpperLeg),rightUpperLeg~=nil)
elseif hrpPos then
setLine(hrpPos,leftUpperLeg and GetSkeletonPos(leftUpperLeg),leftUpperLeg~=nil)
setLine(hrpPos,rightUpperLeg and GetSkeletonPos(rightUpperLeg),rightUpperLeg~=nil)
else
setLine(upperTorsoPos,leftUpperLeg and GetSkeletonPos(leftUpperLeg),leftUpperLeg~=nil)
setLine(upperTorsoPos,rightUpperLeg and GetSkeletonPos(rightUpperLeg),rightUpperLeg~=nil)
end
setLine(leftUpperLeg and GetSkeletonPos(leftUpperLeg),leftLowerLeg and GetSkeletonPos(leftLowerLeg),leftUpperLeg~=nil and leftLowerLeg~=nil)
setLine(rightUpperLeg and GetSkeletonPos(rightUpperLeg),rightLowerLeg and GetSkeletonPos(rightLowerLeg),rightUpperLeg~=nil and rightLowerLeg~=nil)
setLine(leftLowerLeg and GetSkeletonPos(leftLowerLeg),leftFoot and GetSkeletonPos(leftFoot),leftLowerLeg~=nil and leftFoot~=nil)
setLine(rightLowerLeg and GetSkeletonPos(rightLowerLeg),rightFoot and GetSkeletonPos(rightFoot),rightLowerLeg~=nil and rightFoot~=nil)
while idx<=#lines do
lines[idx].Visible=false
idx=idx+1
end
end
for player,_ in pairs(SkeletonLines) do
if not SkeletonEnemiesList[player] then RemoveSkeletonData(player) end
end
end)
local function ApplySkeleton() _G.SkeletonEnabled=true end
local function RemoveSkeleton()
_G.SkeletonEnabled=false
for player,_ in pairs(SkeletonLines) do RemoveSkeletonData(player) end
SkeletonEnemiesList={}
end
local HealthBars={}
local HealthEnemiesList={}
local HealthCacheTime=0
local HealthHistoryData={}
local function CreateHealthBar()
local bg=Drawing.new("Square")
bg.Thickness=0
bg.Filled=true
bg.Visible=false
bg.Color=Color3.fromRGB(15,17,25)
bg.Transparency=0.7
bg.ZIndex=0
local bar=Drawing.new("Square")
bar.Thickness=0
bar.Filled=true
bar.Visible=false
bar.Transparency=0.85
bar.ZIndex=1
local border=Drawing.new("Square")
border.Thickness=1.2
border.Filled=false
border.Visible=false
border.Color=Color3.fromRGB(80,90,120)
border.Transparency=0.5
border.ZIndex=2
return {Bg=bg,Bar=bar,Border=border}
end
local function GetHealthValue(character)
if not character then return nil,nil end
local humanoid=character:FindFirstChild("Humanoid")
if humanoid and humanoid.Health and humanoid.MaxHealth then
if humanoid.Health>0 then return humanoid.Health,humanoid.MaxHealth end
return nil,nil
end
local healthAttr=character:GetAttribute("Health")
local maxHealthAttr=character:GetAttribute("MaxHealth")
if healthAttr and maxHealthAttr and healthAttr>0 then return healthAttr,maxHealthAttr end
return nil,nil
end
local function GetHealthBarColor(health,maxHealth,prevHealth)
local percent=health/maxHealth
local isDamaged=prevHealth and prevHealth>health and (prevHealth-health)>5
if isDamaged then return Color3.fromRGB(255,255,255) end
if percent<=0.20 then return Color3.fromRGB(255,50,50)
elseif percent<=0.40 then return Color3.fromRGB(255,170,50)
elseif percent<=0.60 then return Color3.fromRGB(255,220,50)
elseif percent<=0.80 then return Color3.fromRGB(150,255,50)
else return Color3.fromRGB(50,255,150) end
end
local function RemoveHealthBarData(target)
local data=HealthBars[target]
if data then
pcall(function()
data.Bg.Visible=false
data.Bar.Visible=false
data.Border.Visible=false
data.Bg:Remove()
data.Bar:Remove()
data.Border:Remove()
end)
HealthBars[target]=nil
end
HealthHistoryData[target]=nil
end
local function UpdateHealthEnemiesList()
if tick()-HealthCacheTime<0.5 then return end
HealthCacheTime=tick()
HealthEnemiesList={}
for _,player in pairs(Players:GetPlayers()) do
if player~=LocalPlayer and player.Character and player.Character.Parent then
if IsEnemy(player) then
local health,maxHealth=GetHealthValue(player.Character)
if health and health>0 then
HealthEnemiesList[player]={char=player.Character,health=health,maxHealth=maxHealth}
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
RunService.RenderStepped:Connect(function()
if not _G.HealthBarEnabled then
for _,data in pairs(HealthBars) do
data.Bg.Visible=false
data.Bar.Visible=false
data.Border.Visible=false
end
return
end
UpdateHealthEnemiesList()
for player,data in pairs(HealthEnemiesList) do
if not player or not player.Character or not player.Character.Parent then
RemoveHealthBarData(player)
continue
end
local char=player.Character
local health,maxHealth=GetHealthValue(char)
if not health or health<=0 then
RemoveHealthBarData(player)
continue
end
local prevHealth=HealthHistoryData[player]
HealthHistoryData[player]=health
local head=char:FindFirstChild("Head")
if not head then
RemoveHealthBarData(player)
continue
end
local headPos,headVis=Camera:WorldToViewportPoint(head.Position)
local distance=(Camera.CFrame.Position-head.Position).Magnitude
if headVis and headPos.Z>0 and distance<=1000 then
local barWidth=50
local barHeight=5
local scale=1/(headPos.Z*0.015+0.5)
if scale>1.5 then scale=1.5 end
if scale<0.4 then scale=0.4 end
local finalWidth=barWidth*scale
local finalHeight=barHeight*scale
local offsetY=4*scale
local barX=headPos.X-finalWidth/2
local barY=headPos.Y-finalHeight-offsetY
if barX<5 then barX=5 end
if barX+finalWidth>Camera.ViewportSize.X-5 then barX=Camera.ViewportSize.X-finalWidth-5 end
if barY<5 then barY=5 end
if not HealthBars[player] then HealthBars[player]=CreateHealthBar() end
local barData=HealthBars[player]
local hpPercent=health/maxHealth
local filledWidth=finalWidth*hpPercent
barData.Bg.Size=Vector2.new(finalWidth,finalHeight)
barData.Bg.Position=Vector2.new(barX,barY)
barData.Bg.Visible=true
barData.Bg.Transparency=0.7
barData.Bg.Color=Color3.fromRGB(15,17,25)
barData.Bg.Thickness=0
barData.Bar.Size=Vector2.new(math.max(filledWidth,0.5),finalHeight)
barData.Bar.Position=Vector2.new(barX,barY)
barData.Bar.Visible=true
barData.Bar.Transparency=0.85
barData.Bar.Thickness=0
barData.Bar.Color=GetHealthBarColor(health,maxHealth,prevHealth)
if prevHealth and prevHealth>health and (prevHealth-health)>5 then
barData.Bar.Color=Color3.fromRGB(255,255,255)
barData.Bar.Transparency=0.7
end
barData.Border.Size=Vector2.new(finalWidth,finalHeight)
barData.Border.Position=Vector2.new(barX,barY)
barData.Border.Visible=true
barData.Border.Transparency=0.5
barData.Border.Color=Color3.fromRGB(80,90,120)
barData.Border.Thickness=1.2
else
if HealthBars[player] then
HealthBars[player].Bg.Visible=false
HealthBars[player].Bar.Visible=false
HealthBars[player].Border.Visible=false
end
end
end
for player,_ in pairs(HealthBars) do
if not HealthEnemiesList[player] then RemoveHealthBarData(player) end
end
end)
local function ApplyHealthBar() _G.HealthBarEnabled=true end
local function RemoveHealthBar()
_G.HealthBarEnabled=false
for player,_ in pairs(HealthBars) do RemoveHealthBarData(player) end
HealthEnemiesList={}
HealthHistoryData={}
end
local ParticleGuiContainer=nil
local ParticleGuiConnection=nil
local function CreateParticleGui()
if ParticleGuiContainer then ParticleGuiContainer:Destroy() end
if ParticleGuiConnection then ParticleGuiConnection:Disconnect() end
local PlayerGui=LocalPlayer:WaitForChild("PlayerGui")
ParticleGuiContainer=Instance.new("ScreenGui")
ParticleGuiContainer.Name="META_ParticleEffectGui"
ParticleGuiContainer.ResetOnSpawn=false
ParticleGuiContainer.IgnoreGuiInset=true
ParticleGuiContainer.DisplayOrder=999999
ParticleGuiContainer.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ParticleGuiContainer.Parent=PlayerGui
HideGuiFromScanner(ParticleGuiContainer)
local particles={}
local lastSpawnTime=tick()
local function SpawnParticle()
local dot=Instance.new("Frame",ParticleGuiContainer)
local size=math.random(2,5)
dot.Size=UDim2.new(0,size,0,size)
local startX=math.random(0,100)/100
dot.Position=UDim2.new(startX,0,1,10)
dot.BackgroundColor3=Color3.fromRGB(255,255,255)
dot.BackgroundTransparency=0.3
dot.BorderSizePixel=0
dot.ZIndex=999999
Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
local data={Frame=dot,SpeedY=math.random(20,50)/10,SpeedX=(math.random()-0.5)*2,Angle=math.random()*math.pi*2,RotSpeed=(math.random()-0.5)*2,PosX=startX,PosY=1}
table.insert(particles,data)
task.delay(5,function()
if dot and dot.Parent then dot:Destroy() end
for i,p in pairs(particles) do
if p==data then
table.remove(particles,i)
break
end
end
end)
end
for i=1,50 do
task.delay(math.random(0,50)/10,function()
if ParticleGuiContainer then SpawnParticle() end
end)
end
ParticleGuiConnection=RunService.Heartbeat:Connect(function()
if not ParticleGuiContainer then return end
for _,data in pairs(particles) do
if data and data.Frame and data.Frame.Parent then
data.PosY=data.PosY-data.SpeedY/200
data.PosX=data.PosX+data.SpeedX/200
data.Angle=data.Angle+data.RotSpeed/30
if data.PosY<-0.05 then
data.PosY=1
data.PosX=math.random(0,100)/100
end
if data.PosX<-0.05 then data.PosX=1.05 end
if data.PosX>1.05 then data.PosX=-0.05 end
data.Frame.Position=UDim2.new(data.PosX,0,data.PosY,0)
data.Frame.Rotation=math.deg(data.Angle)
end
end
if tick()-lastSpawnTime>0.3 then
lastSpawnTime=tick()
SpawnParticle()
end
end)
end
local function ApplyParticleGui()
_G.ParticleEffectGuiEnabled=true
CreateParticleGui()
end
local function RemoveParticleGui()
_G.ParticleEffectGuiEnabled=false
if ParticleGuiConnection then
ParticleGuiConnection:Disconnect()
ParticleGuiConnection=nil
end
if ParticleGuiContainer then
ParticleGuiContainer:Destroy()
ParticleGuiContainer=nil
end
end
local IndicatorLine=nil
local IndicatorColor=_G.MenuThemeColor
local function CreateIndicatorLine()
if IndicatorLine then IndicatorLine:Destroy() end
IndicatorLine=Instance.new("Frame")
IndicatorLine.Name="SelectionIndicator"
IndicatorLine.Size=UDim2.new(0.055,0,0,2)
IndicatorLine.Position=UDim2.new(0.015,0,1,-2)
IndicatorLine.BackgroundColor3=IndicatorColor
IndicatorLine.BorderSizePixel=0
IndicatorLine.Parent=TabContainer
IndicatorLine.ZIndex=10
local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(1,0)
corner.Parent=IndicatorLine
end
local function UpdateIndicatorPosition(index)
if not IndicatorLine then return end
local width=0.055
local xPos=0.015+(index-1)*(width+0.012)
TweenService:Create(IndicatorLine,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Position=UDim2.new(xPos,0,1,-2),Size=UDim2.new(width+0.012,0,0,2)}):Play()
end
local function UpdateIndicatorColor(color)
IndicatorColor=color
if IndicatorLine then
TweenService:Create(IndicatorLine,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{BackgroundColor3=color}):Play()
end
end
local function SwitchToTab(index)
if index<1 or index>#TabButtons then return end
for i,b in ipairs(TabButtons) do
b.BackgroundColor3=Color3.fromRGB(26,30,38)
b.TextColor3=Color3.fromRGB(156,163,175)
TweenService:Create(b,TweenInfo.new(0.15,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0.055,0,0,32)}):Play()
end
local btn=TabButtons[index]
btn.BackgroundColor3=Color3.fromRGB(35,40,50)
btn.TextColor3=Color3.fromRGB(255,255,255)
TweenService:Create(btn,TweenInfo.new(0.15,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0.067,0,0,36)}):Play()
for name,page in pairs(ContentPages) do page.Visible=false end
local targetPage=ContentPages[TabNames[index]]
if targetPage then targetPage.Visible=true end
activeIndex=index
UpdateIndicatorPosition(index)
end
local function SearchInMenu(query)
query=string.lower(query)
if not ContentPages then return end
local foundElements={}
local foundTabName=nil
for tabName,page in pairs(ContentPages) do
if page then
local function scanChildren(parent)
for _,child in ipairs(parent:GetChildren()) do
if child:IsA("TextLabel") or child:IsA("TextButton") then
local text=string.lower(child.Text)
if text~="" and string.find(text,query) then
table.insert(foundElements,{element=child,tab=tabName})
if not foundTabName then foundTabName=tabName end
end
end
if child:IsA("Frame") then scanChildren(child) end
end
end
scanChildren(page)
end
end
if #foundElements>0 and foundTabName then
for idx,tabName in ipairs(TabNames) do
if tabName==foundTabName then SwitchToTab(idx) break end
end
end
end
local function UpdateTabsLanguage()
local lang=GetLang()
for i,btn in ipairs(TabButtons) do btn.Text=lang.Tabs[i] end
end
local function UpdateAllTexts()
UpdateTabsLanguage()
for _,cb in ipairs(langUpdateCallbacks) do pcall(cb) end
end
for i,name in ipairs(TabNames) do
local btn=Instance.new("TextButton")
btn.Name="Tab"..i
local width=0.055
btn.Size=UDim2.new(width,0,0,32)
btn.Position=UDim2.new(0.015+(i-1)*(width+0.012),0,0.15,0)
btn.BackgroundColor3=Color3.fromRGB(26,30,38)
btn.Text=name
btn.TextColor3=Color3.fromRGB(156,163,175)
btn.TextSize=13
btn.Font=Enum.Font.GothamBold
btn.AutoButtonColor=false
btn.Parent=TabContainer
local btnCorner=Instance.new("UICorner")
btnCorner.CornerRadius=UDim.new(0,6)
btnCorner.Parent=btn
if i==1 then
btn.BackgroundColor3=Color3.fromRGB(35,40,50)
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Size=UDim2.new(width+0.012,0,0,36)
end
btn.MouseEnter:Connect(function()
if activeIndex~=i then btn.BackgroundColor3=Color3.fromRGB(35,40,50) btn.TextColor3=Color3.fromRGB(255,255,255) end
end)
btn.MouseLeave:Connect(function()
if activeIndex~=i then btn.BackgroundColor3=Color3.fromRGB(26,30,38) btn.TextColor3=Color3.fromRGB(156,163,175) end
end)
btn.MouseButton1Click:Connect(function() PlayTabSound() SwitchToTab(i) end)
table.insert(TabButtons,btn)
local page=Instance.new("ScrollingFrame")
page.Name="Content"..i
page.Size=UDim2.new(1,-20,1,-96)
page.Position=UDim2.new(0,10,0,87)
page.BackgroundTransparency=1
page.BorderSizePixel=0
page.CanvasSize=UDim2.new(0,0,0,0)
page.ScrollBarThickness=4
page.Visible=(i==1)
page.ZIndex=5
page.Parent=MainFrame
ContentPages[name]=page
end
CreateIndicatorLine()
UpdateIndicatorPosition(1)
SearchInput.FocusLost:Connect(function(enterPressed)
if enterPressed and SearchInput.Text~="" and SearchInput.Text~="Search..." then
SearchInMenu(SearchInput.Text)
PlayClickSound()
SearchInput.Text="Search..."
end
end)
-- AIMBOT
local aimbotPage=ContentPages["Aimbot"]
if aimbotPage then
local function CreateToggle(name,descText,yPos,toggleFunc,frameName)
local frame=Instance.new("Frame")
frame.Name=frameName or name
frame.Size=UDim2.new(1,0,0,45)
frame.Position=UDim2.new(0,0,0,yPos)
frame.BackgroundTransparency=1
frame.Parent=aimbotPage
local label=Instance.new("TextLabel")
label.Size=UDim2.new(0.6,0,0,20)
label.BackgroundTransparency=1
label.Text=name
label.TextColor3=Color3.fromRGB(209,213,219)
label.TextSize=13
label.Font=Enum.Font.GothamBold
label.TextXAlignment=Enum.TextXAlignment.Left
label.Parent=frame
local desc=Instance.new("TextLabel")
desc.Size=UDim2.new(0.7,0,0,16)
desc.Position=UDim2.new(0,0,0,22)
desc.BackgroundTransparency=1
desc.Text=descText
desc.TextColor3=Color3.fromRGB(113,113,122)
desc.TextSize=11
desc.Font=Enum.Font.Gotham
desc.TextXAlignment=Enum.TextXAlignment.Left
desc.Parent=frame
local toggleBg=Instance.new("Frame")
toggleBg.Size=UDim2.new(0,44,0,24)
toggleBg.Position=UDim2.new(0.88,0,0.1,0)
toggleBg.BackgroundColor3=Color3.fromRGB(42,47,58)
toggleBg.BorderSizePixel=0
toggleBg.Parent=frame
Instance.new("UICorner",toggleBg).CornerRadius=UDim.new(1,0)
local handle=Instance.new("Frame")
handle.Size=UDim2.new(0,18,0,18)
handle.Position=UDim2.new(0,3,0.5,-9)
handle.BackgroundColor3=Color3.fromRGB(255,255,255)
handle.BorderSizePixel=0
handle.Parent=toggleBg
Instance.new("UICorner",handle).CornerRadius=UDim.new(1,0)
local clickArea=Instance.new("TextButton")
clickArea.Size=UDim2.new(0,44,0,24)
clickArea.Position=UDim2.new(0.88,0,0.1,0)
clickArea.BackgroundTransparency=1
clickArea.Text=""
clickArea.ZIndex=10
clickArea.Parent=frame
local state=false
local function SetState(value)
state=value
if value then
TweenService:Create(toggleBg,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{BackgroundColor3=Color3.fromRGB(59,130,246)}):Play()
TweenService:Create(handle,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Position=UDim2.new(0,23,0.5,-9)}):Play()
else
TweenService:Create(toggleBg,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{BackgroundColor3=Color3.fromRGB(42,47,58)}):Play()
TweenService:Create(handle,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Position=UDim2.new(0,3,0.5,-9)}):Play()
end
toggleFunc(value)
end
clickArea.MouseButton1Click:Connect(function() PlayClickSound() SetState(not state) end)
return SetState,label,desc,frame
end
local function SetupAimbot()
local SilentAimEnabled=false
local OffCircleEnabled=false
local MaxFOV=200
local NoReloadEnabled=false
local FOVCircle=Drawing.new("Circle")
FOVCircle.Thickness=2.5
FOVCircle.Filled=false
FOVCircle.Transparency=1
FOVCircle.NumSides=64
FOVCircle.Visible=false
local CurrentTarget=nil
local function GetTargetPart(character)
if not character then return nil end
if _G.SelectedPart=="Torso" then
return character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
elseif _G.SelectedPart=="HumanoidRootPart" then
return character:FindFirstChild("HumanoidRootPart")
end
return character:FindFirstChild("Head")
end
local function UpdateClosestTarget()
if not SilentAimEnabled then CurrentTarget=nil return end
local closestTarget=nil
local shortestDistance=MaxFOV
for _,player in ipairs(Players:GetPlayers()) do
if player~=LocalPlayer then
local character=player.Character
if character then
local targetPart=GetTargetPart(character)
if targetPart then
local humanoid=character:FindFirstChildOfClass("Humanoid")
if (humanoid and humanoid.Health>0) or not humanoid then
local pos,onScreen=Camera:WorldToViewportPoint(targetPart.Position)
if onScreen then
local distance=(Vector2.new(pos.X,pos.Y)-Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)).Magnitude
if distance<shortestDistance then
closestTarget=targetPart
shortestDistance=distance
end
end
end
end
end
end
end
end
CurrentTarget=closestTarget
end
RunService.RenderStepped:Connect(function()
UpdateClosestTarget()
if FOVCircle then
if OffCircleEnabled then
FOVCircle.Visible=false
else
FOVCircle.Visible=SilentAimEnabled
end
FOVCircle.Radius=MaxFOV
FOVCircle.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
FOVCircle.Color=CurrentTarget and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
end
end)
local gmt=getrawmetatable(game)
setreadonly(gmt,false)
local oldIndex=gmt.__index
local oldNamecall=gmt.__namecall
gmt.__index=newcclosure(function(self,key)
if SilentAimEnabled and CurrentTarget then
if key=="Hit" then return CurrentTarget.CFrame
elseif key=="Target" then return CurrentTarget end
end
return oldIndex(self,key)
end)
gmt.__namecall=newcclosure(function(self,...)
local method=getnamecallmethod()
local args={...}
if SilentAimEnabled and CurrentTarget then
if method=="Raycast" and self==workspace then
local origin=args[1]
if typeof(origin)=="Vector3" then
args[2]=(CurrentTarget.Position-origin).Unit*5000
return oldNamecall(self,unpack(args))
end
end
end
return oldNamecall(self,...)
end)
setreadonly(gmt,true)
task.spawn(function()
local NetworkPath=ReplicatedStorage:WaitForChild("Database",5)
if NetworkPath then NetworkPath=NetworkPath:WaitForChild("Security",5) end
if NetworkPath then NetworkPath=NetworkPath:WaitForChild("Network",5) end
if NetworkPath then
local Network=require(NetworkPath)
if Network and Network.CreatePacket then
local oldCreatePacket=Network.CreatePacket
Network.CreatePacket=newcclosure(function(p6,p7,p_u_3,v_u_5)
if SilentAimEnabled and CurrentTarget then
local function modifyTable(t)
for k,v in pairs(t) do
if typeof(v)=="Vector3" then
t[k]=CurrentTarget.Position
elseif type(v)=="table" then
modifyTable(v)
end
end
end
if type(p6)=="table" then modifyTable(p6) end
if type(p7)=="table" then modifyTable(p7) end
end
return oldCreatePacket(p6,p7,p_u_3,v_u_5)
end)
end
end
end)
task.spawn(function()
local Remotes
pcall(function()
Remotes=require(ReplicatedStorage.Database.Security.Remotes)
end)
if Remotes then
local ReloadPacket=Remotes.Inventory and Remotes.Inventory.ReloadWeapon
if ReloadPacket and ReloadPacket.Send and not ReloadPacket.__META_NoReloadHooked then
ReloadPacket.__META_NoReloadHooked=true
local oldReloadSend=ReloadPacket.Send
ReloadPacket.Send=function(self,data)
if NoReloadEnabled then
if data and data.Value then
data.Value.Rounds=data.Value.Capacity
data.Value.IsReloading=false
data.Value.ReloadTime=0
end
return nil
end
return oldReloadSend(self,data)
end
end
end
end)
task.spawn(function()
while true do
task.wait(0.3)
if NoReloadEnabled then
pcall(function()
for _,v in pairs(getgc(true)) do
if type(v)=="table" then
if rawget(v,"IsReloading")~=nil then v.IsReloading=false end
if rawget(v,"Rounds") and rawget(v,"Capacity") then v.Rounds=v.Capacity end
if rawget(v,"ReloadTime") then v.ReloadTime=0 end
end
end
end)
end
end
end)
local SetSilentAimState,silentLabel,silentDesc=CreateToggle("Silent Aim","Automatically aims at enemies in FOV",10,function(v)
SilentAimEnabled=v
_G.SilentAimEnabled=v
if not v then CurrentTarget=nil end
end,"SilentAimFrame")
_G.SetSilentAimState=SetSilentAimState
local SetOffCircleState,offCircleLabel,offCircleDesc=CreateToggle("Off Circle","Hides the FOV circle but keeps aim",65,function(v)
OffCircleEnabled=v
_G.OffCircleEnabled=v
end,"OffCircleFrame")
_G.SetOffCircleState=SetOffCircleState
CreateToggle("No Reload","Бесконечные патроны",120,function(v)
NoReloadEnabled=v
_G.NoReloadEnabled=v
end,"NoReloadFrame")
local fovSliderFrame=Instance.new("Frame")
fovSliderFrame.Size=UDim2.new(1,-20,0,55)
fovSliderFrame.Position=UDim2.new(0,10,0,175)
fovSliderFrame.BackgroundTransparency=1
fovSliderFrame.Parent=aimbotPage
local fovLabel=Instance.new("TextLabel")
fovLabel.Size=UDim2.new(0.5,0,0,20)
fovLabel.BackgroundTransparency=1
fovLabel.Text="FOV Size"
fovLabel.TextColor3=Color3.fromRGB(209,213,219)
fovLabel.TextSize=13
fovLabel.Font=Enum.Font.GothamBold
fovLabel.TextXAlignment=Enum.TextXAlignment.Left
fovLabel.Parent=fovSliderFrame
local fovValue=Instance.new("TextLabel")
fovValue.Size=UDim2.new(0.15,0,0,20)
fovValue.Position=UDim2.new(0.85,0,0,0)
fovValue.BackgroundTransparency=1
fovValue.Text="200"
fovValue.TextColor3=Color3.fromRGB(255,255,255)
fovValue.TextSize=14
fovValue.Font=Enum.Font.GothamBold
fovValue.TextXAlignment=Enum.TextXAlignment.Right
fovValue.Parent=fovSliderFrame
local fovSliderBg=Instance.new("Frame")
fovSliderBg.Size=UDim2.new(0.5,0,0,6)
fovSliderBg.Position=UDim2.new(0,0,0,30)
fovSliderBg.BackgroundColor3=Color3.fromRGB(42,47,58)
fovSliderBg.BorderSizePixel=0
fovSliderBg.Parent=fovSliderFrame
Instance.new("UICorner",fovSliderBg).CornerRadius=UDim.new(1,0)
local fovSliderFill=Instance.new("Frame")
fovSliderFill.Size=UDim2.new(0.33,0,1,0)
fovSliderFill.BackgroundColor3=Color3.fromRGB(59,130,246)
fovSliderFill.BorderSizePixel=0
fovSliderFill.Parent=fovSliderBg
Instance.new("UICorner",fovSliderFill).CornerRadius=UDim.new(1,0)
local fovSliderHandle=Instance.new("Frame")
fovSliderHandle.Size=UDim2.new(0,16,0,16)
fovSliderHandle.Position=UDim2.new(0.33,-8,0.5,-8)
fovSliderHandle.BackgroundColor3=Color3.fromRGB(255,255,255)
fovSliderHandle.BorderSizePixel=0
fovSliderHandle.Parent=fovSliderBg
Instance.new("UICorner",fovSliderHandle).CornerRadius=UDim.new(1,0)
local isDraggingFOV=false
local function UpdateFOV(mouseX)
local absPos=fovSliderBg.AbsolutePosition.X
local width=fovSliderBg.AbsoluteSize.X
if width<=0 then return end
local percent=math.clamp((mouseX-absPos)/width,0,1)
local val=math.round(50+percent*450)
val=math.clamp(val,50,500)
local p=(val-50)/450
fovSliderFill.Size=UDim2.new(p,0,1,0)
fovSliderHandle.Position=UDim2.new(p,-8,0.5,-8)
fovValue.Text=tostring(val)
MaxFOV=val
_G.SilentAimFOV=val
end
fovSliderHandle.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
isDraggingFOV=true
UpdateFOV(input.Position.X)
end
end)
fovSliderBg.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
isDraggingFOV=true
UpdateFOV(input.Position.X)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
isDraggingFOV=false
end
end)
UserInputService.InputChanged:Connect(function(input)
if isDraggingFOV and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
UpdateFOV(input.Position.X)
end
end)
local SelectedPart="Head"
_G.SelectedPart="Head"
local partButton=Instance.new("TextButton")
partButton.Size=UDim2.new(0.3,0,0,30)
partButton.Position=UDim2.new(0,10,0,235)
partButton.BackgroundColor3=Color3.fromRGB(26,30,38)
partButton.BackgroundTransparency=0.3
partButton.BorderSizePixel=0
partButton.Text="Part: Head"
partButton.TextColor3=Color3.fromRGB(209,213,219)
partButton.TextSize=12
partButton.Font=Enum.Font.GothamBold
partButton.ZIndex=5
partButton.Parent=aimbotPage
Instance.new("UICorner",partButton).CornerRadius=UDim.new(0,6)
local partPanel=Instance.new("Frame")
partPanel.Size=UDim2.new(0.4,0,0,120)
partPanel.Position=UDim2.new(0.35,0,0,235)
partPanel.BackgroundColor3=Color3.fromRGB(20,24,32)
partPanel.BackgroundTransparency=0.1
partPanel.BorderSizePixel=0
partPanel.Visible=false
partPanel.ZIndex=10
partPanel.Parent=aimbotPage
Instance.new("UICorner",partPanel).CornerRadius=UDim.new(0,8)
local partPanelScale=Instance.new("UIScale")
partPanelScale.Scale=0.8
partPanelScale.Parent=partPanel
local partButtons={}
local partNames={"Head","Torso","HumanoidRootPart"}
local function AnimatePartPanel(show)
if show then
partPanel.Visible=true
partPanelScale.Scale=0.7
TweenService:Create(partPanelScale,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
TweenService:Create(partPanel,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=0.1}):Play()
else
TweenService:Create(partPanelScale,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Scale=0.8}):Play()
TweenService:Create(partPanel,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{BackgroundTransparency=1}):Play()
task.wait(0.15)
partPanel.Visible=false
end
end
local function UpdatePartButtons(animate)
for i,partName in ipairs(partNames) do
local btn=partButtons[i]
local btnScale=btn and btn:FindFirstChild("UIScale")
if btn and btnScale then
local isActive=(SelectedPart==partName)
local targetBg=isActive and Color3.fromRGB(59,130,246) or Color3.fromRGB(35,40,50)
local targetText=isActive and Color3.fromRGB(255,255,255) or Color3.fromRGB(156,163,175)
local targetScale=isActive and 1.05 or 1
if animate then
TweenService:Create(btn,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{BackgroundColor3=targetBg}):Play()
TweenService:Create(btn,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{TextColor3=targetText}):Play()
TweenService:Create(btnScale,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=targetScale}):Play()
else
btn.BackgroundColor3=targetBg
btn.TextColor3=targetText
btnScale.Scale=targetScale
end
end
end
partButton.Text="Part: "..SelectedPart
end
for i,partName in ipairs(partNames) do
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(1,-20,0,30)
btn.Position=UDim2.new(0,10,0,10+(i-1)*35)
btn.BackgroundColor3=Color3.fromRGB(35,40,50)
btn.BorderSizePixel=0
btn.Text=partName
btn.TextColor3=Color3.fromRGB(156,163,175)
btn.TextSize=12
btn.Font=Enum.Font.GothamBold
btn.ZIndex=11
btn.Parent=partPanel
local btnScale=Instance.new("UIScale")
btnScale.Name="UIScale"
btnScale.Scale=1
btnScale.Parent=btn
Instance.new("UICorner",btn).CornerRadius=UDim.new(0,4)
btn.MouseButton1Click:Connect(function()
if SelectedPart~=partName then
SelectedPart=partName
_G.SelectedPart=partName
UpdatePartButtons(true)
task.wait(0.1)
AnimatePartPanel(false)
end
end)
partButtons[i]=btn
end
partButton.MouseButton1Click:Connect(function()
if partPanel.Visible then
AnimatePartPanel(false)
else
AnimatePartPanel(true)
end
end)
UpdatePartButtons(false)
end
SetupAimbot()
end
-- VISUALS PAGE
local visualsPage=ContentPages["Visuals"]
if visualsPage then
local function CreateToggle(name,descText,yPos,toggleFunc,frameName)
local frame=Instance.new("Frame")
frame.Name=frameName or name
frame.Size=UDim2.new(1,0,0,45)
frame.Position=UDim2.new(0,0,0,yPos)
frame.BackgroundTransparency=1
frame.Parent=visualsPage
local label=Instance.new("TextLabel")
label.Size=UDim2.new(0.6,0,0,20)
label.BackgroundTransparency=1
label.Text=name
label.TextColor3=Color3.fromRGB(209,213,219)
label.TextSize=13
label.Font=Enum.Font.GothamBold
label.TextXAlignment=Enum.TextXAlignment.Left
label.Parent=frame
local desc=Instance.new("TextLabel")
desc.Size=UDim2.new(0.7,0,0,16)
desc.Position=UDim2.new(0,0,0,22)
desc.BackgroundTransparency=1
desc.Text=descText
desc.TextColor3=Color3.fromRGB(113,113,122)
desc.TextSize=11
desc.Font=Enum.Font.Gotham
desc.TextXAlignment=Enum.TextXAlignment.Left
desc.Parent=frame
local toggleBg=Instance.new("Frame")
toggleBg.Size=UDim2.new(0,44,0,24)
toggleBg.Position=UDim2.new(0.88,0,0.1,0)
toggleBg.BackgroundColor3=Color3.fromRGB(42,47,58)
toggleBg.BorderSizePixel=0
toggleBg.Parent=frame
Instance.new("UICorner",toggleBg).CornerRadius=UDim.new(1,0)
local handle=Instance.new("Frame")
handle.Size=UDim2.new(0,18,0,18)
handle.Position=UDim2.new(0,3,0.5,-9)
handle.BackgroundColor3=Color3.fromRGB(255,255,255)
handle.BorderSizePixel=0
handle.Parent=toggleBg
Instance.new("UICorner",handle).CornerRadius=UDim.new(1,0)
local clickArea=Instance.new("TextButton")
clickArea.Size=UDim2.new(0,44,0,24)
clickArea.Position=UDim2.new(0.88,0,0.1,0)
clickArea.BackgroundTransparency=1
clickArea.Text=""
clickArea.ZIndex=10
clickArea.Parent=frame
local state=false
local function SetState(value)
state=value
if value then
TweenService:Create(toggleBg,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{BackgroundColor3=Color3.fromRGB(59,130,246)}):Play()
TweenService:Create(handle,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Position=UDim2.new(0,23,0.5,-9)}):Play()
else
TweenService:Create(toggleBg,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{BackgroundColor3=Color3.fromRGB(42,47,58)}):Play()
TweenService:Create(handle,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Position=UDim2.new(0,3,0.5,-9)}):Play()
end
toggleFunc(value)
end
clickArea.MouseButton1Click:Connect(function() PlayClickSound() SetState(not state) end)
return SetState,label,desc,frame
end
visualsPage.CanvasSize=UDim2.new(0,0,0,800)
visualsPage.ScrollBarThickness=3
local chamsColorPicker=Instance.new("Frame")
chamsColorPicker.Name="ChamsColorPicker"
chamsColorPicker.Size=UDim2.new(1,-30,0,140)
chamsColorPicker.Position=UDim2.new(0,15,0,55)
chamsColorPicker.BackgroundTransparency=1
chamsColorPicker.Visible=false
chamsColorPicker.ZIndex=30
chamsColorPicker.Parent=visualsPage
local chamsWheel=Instance.new("ImageLabel")
chamsWheel.Size=UDim2.new(0,120,0,120)
chamsWheel.Position=UDim2.new(0.15,0,0.5,-60)
chamsWheel.BackgroundTransparency=1
chamsWheel.Image="rbxassetid://7393858625"
chamsWheel.ZIndex=31
chamsWheel.Parent=chamsColorPicker
local chamsPickerDot=Instance.new("Frame")
chamsPickerDot.Size=UDim2.new(0,10,0,10)
chamsPickerDot.Position=UDim2.new(0.5,-5,0.5,-5)
chamsPickerDot.BackgroundColor3=Color3.fromRGB(255,255,255)
chamsPickerDot.ZIndex=32
chamsPickerDot.Parent=chamsWheel
Instance.new("UICorner",chamsPickerDot).CornerRadius=UDim.new(1,0)
local chamsDragArea=Instance.new("TextButton")
chamsDragArea.Size=UDim2.new(1,0,1,0)
chamsDragArea.BackgroundTransparency=1
chamsDragArea.Text=""
chamsDragArea.ZIndex=33
chamsDragArea.Parent=chamsWheel
local isDraggingChamsColor=false
local function UpdateChamsWheelColor(inputPosition)
local wheelCenter=chamsWheel.AbsolutePosition+(chamsWheel.AbsoluteSize/2)
local delta=Vector2.new(inputPosition.X,inputPosition.Y)-wheelCenter
local distance=delta.Magnitude
local radius=chamsWheel.AbsoluteSize.X/2
local clampedDistance=math.clamp(distance,0,radius)
local angle=math.atan2(delta.Y,delta.X)
local xPos=clampedDistance*math.cos(angle)
local yPos=clampedDistance*math.sin(angle)
chamsPickerDot.Position=UDim2.new(0,xPos+radius-5,0,yPos+radius-5)
if angle<0 then angle=angle+(math.pi*2) end
local hue=angle/(math.pi*2)
local saturation=clampedDistance/radius
local pickedColor=Color3.fromHSV(hue,saturation,1)
_G.ChamsColor=pickedColor
for _,p in ipairs(Players:GetPlayers()) do
if p.Character then
for _,child in ipairs(p.Character:GetChildren()) do
if child:IsA("Highlight") and child:GetAttribute("META_Chams") then
child.FillColor=pickedColor
child.OutlineColor=pickedColor
end
end
end
end
end
chamsDragArea.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
isDraggingChamsColor=true
visualsPage.ScrollingEnabled=false
UpdateChamsWheelColor(input.Position)
end
end)
UserInputService.InputChanged:Connect(function(input)
if isDraggingChamsColor and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement) then
UpdateChamsWheelColor(input.Position)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
isDraggingChamsColor=false
visualsPage.ScrollingEnabled=true
end
end)
local skeletonColorPicker=Instance.new("Frame")
skeletonColorPicker.Size=UDim2.new(1,-30,0,140)
skeletonColorPicker.Position=UDim2.new(0,15,0,55)
skeletonColorPicker.BackgroundTransparency=1
skeletonColorPicker.Visible=false
skeletonColorPicker.ZIndex=30
skeletonColorPicker.Parent=visualsPage
local skeletonWheel=Instance.new("ImageLabel")
skeletonWheel.Size=UDim2.new(0,120,0,120)
skeletonWheel.Position=UDim2.new(0.65,0,0.5,-60)
skeletonWheel.BackgroundTransparency=1
skeletonWheel.Image="rbxassetid://7393858625"
skeletonWheel.ZIndex=31
skeletonWheel.Parent=skeletonColorPicker
local skeletonPickerDot=Instance.new("Frame")
skeletonPickerDot.Size=UDim2.new(0,10,0,10)
skeletonPickerDot.Position=UDim2.new(0.5,-5,0.5,-5)
skeletonPickerDot.BackgroundColor3=Color3.fromRGB(255,255,255)
skeletonPickerDot.ZIndex=32
skeletonPickerDot.Parent=skeletonWheel
Instance.new("UICorner",skeletonPickerDot).CornerRadius=UDim.new(1,0)
local skeletonDragArea=Instance.new("TextButton")
skeletonDragArea.Size=UDim2.new(1,0,1,0)
skeletonDragArea.BackgroundTransparency=1
skeletonDragArea.Text=""
skeletonDragArea.ZIndex=33
skeletonDragArea.Parent=skeletonWheel
local isDraggingSkeletonColor=false
local function UpdateSkeletonWheelColor(inputPosition)
local wheelCenter=skeletonWheel.AbsolutePosition+(skeletonWheel.AbsoluteSize/2)
local delta=Vector2.new(inputPosition.X,inputPosition.Y)-wheelCenter
local distance=delta.Magnitude
local radius=skeletonWheel.AbsoluteSize.X/2
local clampedDistance=math.clamp(distance,0,radius)
local angle=math.atan2(delta.Y,delta.X)
local xPos=clampedDistance*math.cos(angle)
local yPos=clampedDistance*math.sin(angle)
skeletonPickerDot.Position=UDim2.new(0,xPos+radius-5,0,yPos+radius-5)
if angle<0 then angle=angle+(math.pi*2) end
local hue=angle/(math.pi*2)
local saturation=clampedDistance/radius
local pickedColor=Color3.fromHSV(hue,saturation,1)
_G.SkeletonColor=pickedColor
for _,player in ipairs(Players:GetPlayers()) do
if SkeletonLines[player] then
for _,line in pairs(SkeletonLines[player]) do
line.Color=pickedColor
end
end
end
end
skeletonDragArea.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
isDraggingSkeletonColor=true
visualsPage.ScrollingEnabled=false
UpdateSkeletonWheelColor(input.Position)
end
end)
UserInputService.InputChanged:Connect(function(input)
if isDraggingSkeletonColor and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement) then
UpdateSkeletonWheelColor(input.Position)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
isDraggingSkeletonColor=false
visualsPage.ScrollingEnabled=true
end
end)
local function ShiftChamsElements(shiftDown)
local targetY=shiftDown and 150 or 0
local espFrame=visualsPage:FindFirstChild("ESPFrame")
local skeletonFrame=visualsPage:FindFirstChild("SkeletonFrame")
local healthFrame=visualsPage:FindFirstChild("HealthFrame")
local fpsBoostFrame=visualsPage:FindFirstChild("FPSBoostFrame")
local particleFrame=visualsPage:FindFirstChild("ParticleGuiFrame")
if espFrame then TweenService:Create(espFrame,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Position=UDim2.new(0,0,0,65+targetY)}):Play() end
if skeletonFrame then TweenService:Create(skeletonFrame,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Position=UDim2.new(0,0,0,120+targetY)}):Play() end
if healthFrame then TweenService:Create(healthFrame,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Position=UDim2.new(0,0,0,175+targetY)}):Play() end
if fpsBoostFrame then TweenService:Create(fpsBoostFrame,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Position=UDim2.new(0,0,0,230+targetY)}):Play() end
if particleFrame then TweenService:Create(particleFrame,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Position=UDim2.new(0,0,0,285+targetY)}):Play() end
end
local SetChamsState,chamsLabel,chamsDesc=CreateToggle("Chams","Makes enemies purple",10,function(v)
if v then
ApplyChams()
chamsColorPicker.Visible=true
skeletonColorPicker.Visible=true
ShiftChamsElements(true)
else
RemoveChams()
chamsColorPicker.Visible=false
skeletonColorPicker.Visible=false
ShiftChamsElements(false)
end
_G.ChamsEnabled=v
end,"ChamsFrame")
SetChamsToggleState=SetChamsState
SetChamsToggleState(_G.ChamsEnabled)
local SetESPState,espLabel,espDesc=CreateToggle("Tracers and 3D Box","Lines with boxes leading to enemies",65,function(v) if v then ApplyESP() else RemoveESP() end _G.ESPEnabled=v end,"ESPFrame")
SetESPToggleState=SetESPState
SetESPToggleState(_G.ESPEnabled)
local SetSkeletonState,skeletonLabel,skeletonDesc=CreateToggle("Skeleton","Skeleton for enemies",120,function(v)
if v then ApplySkeleton() else RemoveSkeleton() end
_G.SkeletonEnabled=v
end,"SkeletonFrame")
SetSkeletonToggleState=SetSkeletonState
SetSkeletonToggleState(_G.SkeletonEnabled)
local SetHealthState,healthLabel,healthDesc=CreateToggle("Health Bar","Health bar above enemies",175,function(v) if v then ApplyHealthBar() else RemoveHealthBar() end _G.HealthBarEnabled=v end,"HealthFrame")
SetHealthBarToggleState=SetHealthState
SetHealthBarToggleState(_G.HealthBarEnabled)
local SetFpsBoostState,fpsBoostLabel,fpsBoostDesc=CreateToggle("FPS Boost","Makes the map lag-free",230,function(v)
if v then
for _,obj in ipairs(game:GetDescendants()) do
if obj:IsA("Texture") or obj:IsA("Decal") then obj:Destroy()
elseif obj:IsA("ParticleEmitter") then obj:Destroy()
elseif obj:IsA("Trail") then obj:Destroy()
elseif obj:IsA("Smoke") or obj:IsA("Fire") then obj:Destroy()
elseif obj:IsA("BasePart") then obj.CastShadow=false obj.Material=Enum.Material.Plastic
elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then obj.Shadows=false end
end
end
_G.FpsBoostEnabled=v
end,"FPSBoostFrame")
SetFpsBoostState=SetFpsBoostState
local SetParticleGuiState,particleLabel,particleDesc=CreateToggle("Particle Effect GUI","Adds particle effect to GUI interface",285,function(v) if v then ApplyParticleGui() else RemoveParticleGui() end _G.ParticleEffectGuiEnabled=v end,"ParticleGuiFrame")
SetParticleGuiToggleState=SetParticleGuiState
SetParticleGuiToggleState(_G.ParticleEffectGuiEnabled)
table.insert(langUpdateCallbacks,function()
local lang=GetLang()
chamsLabel.Text=lang.Toggles.Chams[1]
chamsDesc.Text=lang.Toggles.Chams[2]
espLabel.Text=lang.Toggles.ESP[1]
espDesc.Text=lang.Toggles.ESP[2]
skeletonLabel.Text=lang.Toggles.Skeleton[1]
skeletonDesc.Text=lang.Toggles.Skeleton[2]
healthLabel.Text=lang.Toggles.HealthBar[1]
healthDesc.Text=lang.Toggles.HealthBar[2]
fpsBoostLabel.Text=lang.Toggles.FpsBoost[1]
fpsBoostDesc.Text=lang.Toggles.FpsBoost[2]
particleLabel.Text=lang.Toggles.ParticleEffectGui[1]
particleDesc.Text=lang.Toggles.ParticleEffectGui[2]
end)
end
SetupVisuals()
end

-- MISC PAGE
local miscPage=ContentPages["Misc"]
if miscPage then
local function SetupMisc()
miscPage.CanvasSize=UDim2.new(0,0,0,600)
miscPage.ScrollBarThickness=3
local function CreateToggle(name,descText,yPos,toggleFunc,frameName)
local frame=Instance.new("Frame")
frame.Name=frameName or name
frame.Size=UDim2.new(1,0,0,45)
frame.Position=UDim2.new(0,0,0,yPos)
frame.BackgroundTransparency=1
frame.Parent=miscPage
local label=Instance.new("TextLabel")
label.Size=UDim2.new(0.6,0,0,20)
label.BackgroundTransparency=1
label.Text=name
label.TextColor3=Color3.fromRGB(209,213,219)
label.TextSize=13
label.Font=Enum.Font.GothamBold
label.TextXAlignment=Enum.TextXAlignment.Left
label.Parent=frame
local desc=Instance.new("TextLabel")
desc.Size=UDim2.new(0.7,0,0,16)
desc.Position=UDim2.new(0,0,0,22)
desc.BackgroundTransparency=1
desc.Text=descText
desc.TextColor3=Color3.fromRGB(113,113,122)
desc.TextSize=11
desc.Font=Enum.Font.Gotham
desc.TextXAlignment=Enum.TextXAlignment.Left
desc.Parent=frame
local toggleBg=Instance.new("Frame")
toggleBg.Size=UDim2.new(0,44,0,24)
toggleBg.Position=UDim2.new(0.88,0,0.1,0)
toggleBg.BackgroundColor3=Color3.fromRGB(42,47,58)
toggleBg.BorderSizePixel=0
toggleBg.Parent=frame
Instance.new("UICorner",toggleBg).CornerRadius=UDim.new(1,0)
local handle=Instance.new("Frame")
handle.Size=UDim2.new(0,18,0,18)
handle.Position=UDim2.new(0,3,0.5,-9)
handle.BackgroundColor3=Color3.fromRGB(255,255,255)
handle.BorderSizePixel=0
handle.Parent=toggleBg
Instance.new("UICorner",handle).CornerRadius=UDim.new(1,0)
local clickArea=Instance.new("TextButton")
clickArea.Size=UDim2.new(0,44,0,24)
clickArea.Position=UDim2.new(0.88,0,0.1,0)
clickArea.BackgroundTransparency=1
clickArea.Text=""
clickArea.ZIndex=10
clickArea.Parent=frame
local state=false
local function SetState(value)
state=value
if value then
TweenService:Create(toggleBg,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{BackgroundColor3=Color3.fromRGB(59,130,246)}):Play()
TweenService:Create(handle,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Position=UDim2.new(0,23,0.5,-9)}):Play()
else
TweenService:Create(toggleBg,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{BackgroundColor3=Color3.fromRGB(42,47,58)}):Play()
TweenService:Create(handle,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Position=UDim2.new(0,3,0.5,-9)}):Play()
end
toggleFunc(value)
end
clickArea.MouseButton1Click:Connect(function() PlayClickSound() SetState(not state) end)
return SetState,label,desc,frame
end
CreateToggle("No Recoil","Антиотдача",10,function(v)
_G.NoRecoilEnabled=v
if v then
pcall(function()
local CameraController=require(game:GetService("ReplicatedStorage").Controllers.CameraController)
CameraController.weaponKick=function() end
CameraController.setWeaponRecoil=function() end
end)
end
end,"NoRecoilFrame")
CreateToggle("No Spread","Анти разброс пуль",65,function(v)
_G.NoSpreadEnabled=v
if v then
pcall(function()
local Bullet=require(game:GetService("ReplicatedStorage").Components.Weapon.Classes.Bullet)
Bullet.getTrueSpread=function() return 0 end
Bullet.getBaseSpread=function() return 0 end
Bullet.getSpreadForConfig=function() return 0 end
local OldCreate=Bullet.create
Bullet.create=function(self,aimingOptions,isAiming)
if self.Spread then
self.Spread:setPosition(0)
self.Spread:setGoal(0)
end
return OldCreate(self,aimingOptions,isAiming)
end
end)
end
end,"NoSpreadFrame")
CreateToggle("Slow Weapon","Замедляет анимации рук и оружия",120,function(v)
_G.SlowWeaponEnabled=v
if v then
task.spawn(function()
while _G.SlowWeaponEnabled do
task.wait(0.05)
local cam=workspace.CurrentCamera
if cam then
for _,obj in ipairs(cam:GetDescendants()) do
local animator
if obj:IsA("Animator") then animator=obj
elseif obj:IsA("AnimationController") then animator=obj:FindFirstChildOfClass("Animator")
end
if animator then
for _,track in ipairs(animator:GetPlayingAnimationTracks()) do
pcall(function() track:AdjustSpeed(_G.SlowWeaponSpeed) end)
end
end
end
end
end
end)
end
end,"SlowWeaponFrame")
local ArmsHidden={}
local function IsArmPart(part)
local n=part.Name:lower()
if n=="lefthand" or n=="righthand" then return true end
if n=="leftlowerarm" or n=="rightlowerarm" then return true end
if n=="leftupperarm" or n=="rightupperarm" then return true end
if n=="left arm" or n=="right arm" then return true end
if n:find("sleeve") then return true end
if n:find("glove") then return true end
if n:find("finger") then return true end
if n:find("shoulder") then return true end
return false
end
CreateToggle("No Arms","Скрывает руки, оружие видно",175,function(v)
_G.InvisibleArmsEnabled=v
if not v then
for part,orig in pairs(ArmsHidden) do
pcall(function() if part and part.Parent then part.Transparency=orig end end)
end
ArmsHidden={}
end
end,"NoArmsFrame")
RunService.RenderStepped:Connect(function()
if not _G.InvisibleArmsEnabled then return end
local cam=workspace.CurrentCamera
if not cam then return end
for _,child in ipairs(cam:GetChildren()) do
if child:IsA("Model") then
for _,part in ipairs(child:GetDescendants()) do
if (part:IsA("BasePart") or part:IsA("MeshPart")) and IsArmPart(part) then
if ArmsHidden[part]==nil then ArmsHidden[part]=part.Transparency end
if part.Transparency~=1 then pcall(function() part.Transparency=1 end) end
end
end
end
end
end)
end
SetupMisc()
end

-- SKY PAGE
local skyPage=ContentPages["Sky"]
if skyPage then
skyPage.CanvasSize=UDim2.new(0,0,0,0)
skyPage.ScrollBarThickness=0
local skyBlock=Instance.new("Frame")
skyBlock.Name="SkyBlock"
skyBlock.Size=UDim2.new(1,-10,1,-10)
skyBlock.Position=UDim2.new(0,5,0,5)
skyBlock.BackgroundColor3=Color3.fromRGB(20,24,32)
skyBlock.BackgroundTransparency=0.15
skyBlock.BorderSizePixel=0
skyBlock.ClipsDescendants=true
skyBlock.Parent=skyPage
Instance.new("UICorner",skyBlock).CornerRadius=UDim.new(0,8)
skyStroke=Instance.new("UIStroke",skyBlock)
skyStroke.Thickness=2
skyStroke.Color=_G.MenuThemeColor
skyStroke.Transparency=0.3
local skyScroll=Instance.new("ScrollingFrame")
skyScroll.Size=UDim2.new(1,-10,1,-10)
skyScroll.Position=UDim2.new(0,5,0,5)
skyScroll.BackgroundTransparency=1
skyScroll.BorderSizePixel=0
skyScroll.CanvasSize=UDim2.new(0,0,0,250)
skyScroll.ScrollBarThickness=3
skyScroll.ZIndex=5
skyScroll.Parent=skyBlock
local modeButtons={}
local greenConnection=nil
local pinkConnection=nil
local function ResetSky()
if skyConnection then skyConnection:Disconnect() skyConnection=nil end
if greenConnection then greenConnection:Disconnect() greenConnection=nil end
if pinkConnection then pinkConnection:Disconnect() pinkConnection=nil end
for _,obj in ipairs(Lighting:GetChildren()) do
if obj.Name=="DeltaPurpleFilter" or obj.Name=="DeltaOrangeFilter" or obj.Name=="DeltaBlackSkyFilter" or obj.Name=="DeltaVibeBloom" or obj.Name=="DeltaVibeAtmosphere" or obj.Name:match("^META_Green") or obj.Name:match("^META_Pink") then obj:Destroy() end
end
Lighting.TimeOfDay="14:00:00"
Lighting.Brightness=1
Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127)
Lighting.Ambient=Color3.fromRGB(70,70,70)
Lighting.GlobalShadows=false
Lighting.ExposureCompensation=0
Lighting.FogEnd=100000
Lighting.FogStart=0
end
local function StartPurpleSky()
ResetSky()
local cc=Instance.new("ColorCorrectionEffect")
cc.Name="DeltaPurpleFilter"
cc.TintColor=Color3.fromRGB(190,130,255)
cc.Parent=Lighting
local atm=Instance.new("Atmosphere")
atm.Name="DeltaVibeAtmosphere"
atm.Color=Color3.fromRGB(140,70,200)
atm.Decay=Color3.fromRGB(80,30,120)
atm.Parent=Lighting
skyConnection=RunService.RenderStepped:Connect(function()
if not cc or not cc.Parent then skyConnection:Disconnect() return end
Lighting.TimeOfDay="19:10:00"
Lighting.Brightness=1.0
end)
end
local function StartNightSky()
ResetSky()
local cc=Instance.new("ColorCorrectionEffect")
cc.Name="DeltaBlackSkyFilter"
cc.TintColor=Color3.fromRGB(220,225,245)
cc.Parent=Lighting
local bloom=Instance.new("BloomEffect")
bloom.Name="DeltaVibeBloom"
bloom.Intensity=1.4
bloom.Size=22
bloom.Parent=Lighting
skyConnection=RunService.RenderStepped:Connect(function()
if not cc or not cc.Parent then skyConnection:Disconnect() return end
Lighting.TimeOfDay="00:00:00"
Lighting.Brightness=1.0
Lighting.GlobalShadows=true
end)
end
local function StartEveningSky()
ResetSky()
local cc=Instance.new("ColorCorrectionEffect")
cc.Name="DeltaOrangeFilter"
cc.TintColor=Color3.fromRGB(245,195,150)
cc.Parent=Lighting
skyConnection=RunService.RenderStepped:Connect(function()
if not cc or not cc.Parent then skyConnection:Disconnect() return end
Lighting.TimeOfDay="17:45:00"
Lighting.Brightness=1.4
end)
end
local function StartGreenSky()
ResetSky()
local sky=Instance.new("Sky")
sky.Name="META_GreenSky"
sky.SkyboxBk="rbxassetid://159454299"
sky.SkyboxDn="rbxassetid://159454296"
sky.SkyboxFt="rbxassetid://159454293"
sky.SkyboxLf="rbxassetid://159454286"
sky.SkyboxRt="rbxassetid://159454300"
sky.SkyboxUp="rbxassetid://159454288"
sky.Parent=Lighting
local atm=Instance.new("Atmosphere")
atm.Name="META_GreenAtmosphere"
atm.Color=Color3.fromRGB(120,255,160)
atm.Decay=Color3.fromRGB(40,120,60)
atm.Density=0.38
atm.Haze=2.2
atm.Parent=Lighting
local cc=Instance.new("ColorCorrectionEffect")
cc.Name="META_GreenFilter"
cc.TintColor=Color3.fromRGB(170,255,190)
cc.Saturation=0.55
cc.Parent=Lighting
local bloom=Instance.new("BloomEffect")
bloom.Name="META_GreenBloom"
bloom.Intensity=0.65
bloom.Size=18
bloom.Threshold=0.25
bloom.Parent=Lighting
Instance.new("SunRaysEffect",Lighting).Name="META_GreenRays"
Lighting.Brightness=1.6
Lighting.ClockTime=15.5
greenConnection=RunService.Heartbeat:Connect(function()
if not cc or not cc.Parent then greenConnection:Disconnect() return end
local w=(math.sin(tick()*0.6)+1)/2
cc.TintColor=Color3.fromRGB(150+w*40,240+w*15,170+w*40)
end)
end
local function StartPinkSky()
ResetSky()
local sky=Instance.new("Sky")
sky.Name="META_PinkSky"
sky.SkyboxBk="rbxassetid://159454299"
sky.SkyboxDn="rbxassetid://159454296"
sky.SkyboxFt="rbxassetid://159454293"
sky.SkyboxLf="rbxassetid://159454286"
sky.SkyboxRt="rbxassetid://159454300"
sky.SkyboxUp="rbxassetid://159454288"
sky.Parent=Lighting
local atm=Instance.new("Atmosphere")
atm.Name="META_PinkAtmosphere"
atm.Color=Color3.fromRGB(255,180,220)
atm.Decay=Color3.fromRGB(180,90,150)
atm.Density=0.4
atm.Haze=2.5
atm.Parent=Lighting
local cc=Instance.new("ColorCorrectionEffect")
cc.Name="META_PinkFilter"
cc.TintColor=Color3.fromRGB(255,200,230)
cc.Saturation=0.6
cc.Parent=Lighting
local bloom=Instance.new("BloomEffect")
bloom.Name="META_PinkBloom"
bloom.Intensity=0.75
bloom.Size=22
bloom.Threshold=0.2
bloom.Parent=Lighting
Instance.new("SunRaysEffect",Lighting).Name="META_PinkRays"
Lighting.Brightness=1.8
pinkConnection=RunService.Heartbeat:Connect(function()
if not cc or not cc.Parent then pinkConnection:Disconnect() return end
local w=(math.sin(tick()*0.5)+1)/2
cc.TintColor=Color3.fromRGB(240+w*15,190+w*20,220+w*25)
end)
end
local function CreateModeButton(text,yPos,skyFunc)
local btnFrame=Instance.new("Frame",skyScroll)
btnFrame.Size=UDim2.new(0.85,0,0,36)
btnFrame.Position=UDim2.new(0.075,0,0,yPos)
btnFrame.BackgroundColor3=Color3.fromRGB(26,30,38)
btnFrame.BackgroundTransparency=0.4
btnFrame.BorderSizePixel=0
Instance.new("UICorner",btnFrame).CornerRadius=UDim.new(0,6)
local uiScale=Instance.new("UIScale",btnFrame)
uiScale.Scale=1
local txt=Instance.new("TextLabel",btnFrame)
txt.Size=UDim2.new(1,0,1,0)
txt.BackgroundTransparency=1
txt.Text=text
txt.TextColor3=Color3.fromRGB(156,163,175)
txt.TextSize=12
txt.Font=Enum.Font.GothamBold
local clickBtn=Instance.new("TextButton",btnFrame)
clickBtn.Size=UDim2.new(1,0,1,0)
clickBtn.BackgroundTransparency=1
clickBtn.Text=""
clickBtn.MouseButton1Click:Connect(function()
PlayClickSound()
for _,other in pairs(modeButtons) do
if other~=btnFrame then
other:SetAttribute("Active",false)
TweenService:Create(other.UIScale,TweenInfo.new(0.25),{Scale=1}):Play()
end
end
if btnFrame:GetAttribute("Active") then
btnFrame:SetAttribute("Active",false)
ResetSky()
else
btnFrame:SetAttribute("Active",true)
skyFunc()
end
end)
btnFrame:SetAttribute("Active",false)
table.insert(modeButtons,btnFrame)
end
CreateModeButton("Night Sky",15,StartNightSky)
CreateModeButton("Evening Sky",60,StartEveningSky)
CreateModeButton("Purple Sky",105,StartPurpleSky)
CreateModeButton("Green Vibe",150,StartGreenSky)
CreateModeButton("Pink Vibe",195,StartPinkSky)
local rsb=Instance.new("TextButton",skyBlock)
rsb.Size=UDim2.new(0,60,0,22)
rsb.Position=UDim2.new(1,-65,1,-27)
rsb.BackgroundColor3=Color3.fromRGB(60,65,75)
rsb.BackgroundTransparency=0.75
rsb.Text="Reset"
rsb.TextColor3=Color3.fromRGB(200,205,215)
rsb.TextSize=11
rsb.Font=Enum.Font.Gotham
Instance.new("UICorner",rsb).CornerRadius=UDim.new(0,4)
rsb.MouseButton1Click:Connect(function()
PlayClickSound()
ResetSky()
for _,b in pairs(modeButtons) do b:SetAttribute("Active",false) end
end)
end

-- SOUND PAGE
local soundPage=ContentPages["Sound"]
if soundPage then
local function SetupSound()
soundPage.CanvasSize=UDim2.new(0,0,0,0)
soundPage.ScrollBarThickness=0
local soundBlock=Instance.new("Frame",soundPage)
soundBlock.Size=UDim2.new(1,-10,1,-10)
soundBlock.Position=UDim2.new(0,5,0,5)
soundBlock.BackgroundColor3=Color3.fromRGB(20,24,32)
soundBlock.BackgroundTransparency=0.15
soundBlock.ClipsDescendants=true
Instance.new("UICorner",soundBlock).CornerRadius=UDim.new(0,8)
soundStroke=Instance.new("UIStroke",soundBlock)
soundStroke.Thickness=2
soundStroke.Color=_G.MenuThemeColor
soundStroke.Transparency=0.3
local soundScroll=Instance.new("ScrollingFrame",soundBlock)
soundScroll.Size=UDim2.new(1,-10,1,-10)
soundScroll.Position=UDim2.new(0,5,0,5)
soundScroll.BackgroundTransparency=1
soundScroll.BorderSizePixel=0
soundScroll.CanvasSize=UDim2.new(0,0,0,150)
soundScroll.ScrollBarThickness=3
local soundButtons={}
local function StopSoundSystem()
if fireInputBegan then fireInputBegan:Disconnect() fireInputBegan=nil end
if fireInputEnded then fireInputEnded:Disconnect() fireInputEnded=nil end
if muteConnection then muteConnection:Disconnect() muteConnection=nil end
if guiMuteConnection then guiMuteConnection:Disconnect() guiMuteConnection=nil end
end
local function StartSoundSystem(soundId,volume)
StopSoundSystem()
local MY_SOUND="rbxassetid://"..soundId
muteConnection=Workspace.DescendantAdded:Connect(function(c)
if c:IsA("Sound") then c.Volume=0 c:Stop() end
end)
guiMuteConnection=LocalPlayer:WaitForChild("PlayerGui").DescendantAdded:Connect(function(c)
if c:IsA("Sound") then c.Volume=0 c:Stop() end
end)
end
local function CreateSoundButton(text,yPos,soundId,volume)
local btnFrame=Instance.new("Frame",soundScroll)
btnFrame.Size=UDim2.new(0.85,0,0,36)
btnFrame.Position=UDim2.new(0.075,0,0,yPos)
btnFrame.BackgroundColor3=Color3.fromRGB(26,30,38)
btnFrame.BackgroundTransparency=0.4
Instance.new("UICorner",btnFrame).CornerRadius=UDim.new(0,6)
local txt=Instance.new("TextLabel",btnFrame)
txt.Size=UDim2.new(1,0,1,0)
txt.BackgroundTransparency=1
txt.Text=text
txt.TextColor3=Color3.fromRGB(156,163,175)
txt.TextSize=12
txt.Font=Enum.Font.GothamBold
local clickBtn=Instance.new("TextButton",btnFrame)
clickBtn.Size=UDim2.new(1,0,1,0)
clickBtn.BackgroundTransparency=1
clickBtn.Text=""
clickBtn.MouseButton1Click:Connect(function()
PlayClickSound()
StartSoundSystem(soundId,volume)
end)
table.insert(soundButtons,btnFrame)
end
CreateSoundButton("Sound N1",15,"135201580846609",3)
CreateSoundButton("Sound N2",60,"93446662377809",10)
local rsb=Instance.new("TextButton",soundBlock)
rsb.Size=UDim2.new(0,60,0,22)
rsb.Position=UDim2.new(1,-65,1,-27)
rsb.BackgroundColor3=Color3.fromRGB(60,65,75)
rsb.BackgroundTransparency=0.75
rsb.Text="Reset"
rsb.TextColor3=Color3.fromRGB(200,205,215)
rsb.TextSize=11
rsb.Font=Enum.Font.Gotham
Instance.new("UICorner",rsb).CornerRadius=UDim.new(0,4)
rsb.MouseButton1Click:Connect(function() PlayClickSound() StopSoundSystem() end)
end
SetupSound()
end

-- SETTINGS PAGE
local settingsPage=ContentPages["Settings"]
if settingsPage then
local function SetupSettings()
settingsPage.CanvasSize=UDim2.new(0,0,0,700)
local settingsContainer=Instance.new("Frame",settingsPage)
settingsContainer.Size=UDim2.new(1,0,0,600)
settingsContainer.Position=UDim2.new(0,0,0,55)
settingsContainer.BackgroundTransparency=1
settingsContainer.ClipsDescendants=true
local langFrame=Instance.new("Frame",settingsContainer)
langFrame.Size=UDim2.new(1,-20,0,42)
langFrame.Position=UDim2.new(0,10,0,10)
langFrame.BackgroundTransparency=1
local function CreateLangButton(text,langCode,xPos)
local bg=Instance.new("Frame",langFrame)
bg.Size=UDim2.new(0.42,0,0,32)
bg.Position=UDim2.new(xPos,0,0,0)
bg.BackgroundColor3=Color3.fromRGB(26,30,38)
bg.BackgroundTransparency=0.5
Instance.new("UICorner",bg).CornerRadius=UDim.new(0,6)
local txt=Instance.new("TextLabel",bg)
txt.Size=UDim2.new(1,0,1,0)
txt.BackgroundTransparency=1
txt.Text=text
txt.TextColor3=Color3.fromRGB(156,163,175)
txt.TextSize=14
txt.Font=Enum.Font.GothamBold
local clickBtn=Instance.new("TextButton",bg)
clickBtn.Size=UDim2.new(1,0,1,0)
clickBtn.BackgroundTransparency=1
clickBtn.Text=""
clickBtn.MouseButton1Click:Connect(function()
PlayClickSound()
if _G.CurrentLang==langCode then return end
_G.CurrentLang=langCode
UpdateAllTexts()
end)
end
CreateLangButton("Русский","RU",0.03)
CreateLangButton("English","EN",0.55)
-- ANTI-BAN TOGGLE
local abFrame=Instance.new("Frame",settingsContainer)
abFrame.Size=UDim2.new(1,0,0,45)
abFrame.Position=UDim2.new(0,0,0,60)
abFrame.BackgroundTransparency=1
local abL=Instance.new("TextLabel",abFrame)
abL.Size=UDim2.new(0.6,0,0,20)
abL.BackgroundTransparency=1
abL.Text="Anti-Ban"
abL.TextColor3=Color3.fromRGB(209,213,219)
abL.TextSize=13
abL.Font=Enum.Font.GothamBold
abL.TextXAlignment=Enum.TextXAlignment.Left
local abTgb=Instance.new("Frame",abFrame)
abTgb.Size=UDim2.new(0,44,0,24)
abTgb.Position=UDim2.new(0.88,0,0.1,0)
abTgb.BackgroundColor3=Color3.fromRGB(59,130,246)
Instance.new("UICorner",abTgb).CornerRadius=UDim.new(1,0)
local abH=Instance.new("Frame",abTgb)
abH.Size=UDim2.new(0,18,0,18)
abH.Position=UDim2.new(0,23,0.5,-9)
abH.BackgroundColor3=Color3.fromRGB(255,255,255)
Instance.new("UICorner",abH).CornerRadius=UDim.new(1,0)
local abClk=Instance.new("TextButton",abFrame)
abClk.Size=UDim2.new(0,44,0,24)
abClk.Position=UDim2.new(0.88,0,0.1,0)
abClk.BackgroundTransparency=1
abClk.Text=""
abClk.MouseButton1Click:Connect(function()
PlayClickSound()
AntiBanEnabled=not AntiBanEnabled
if AntiBanEnabled then
BlockRemotes()
HideGuiFromScanner(ScreenGui)
end
_G.AntiBanEnabled=AntiBanEnabled
end)
end
SetupSettings()
end

local IconButton=Instance.new("ImageButton")
IconButton.Name="MetaIcon"
IconButton.Size=UDim2.new(0,55,0,55)
IconButton.Position=UDim2.new(0.01,0,0.92,0)
IconButton.AnchorPoint=Vector2.new(0,1)
IconButton.BackgroundColor3=Color3.fromRGB(30,30,30)
IconButton.BackgroundTransparency=0.2
IconButton.Image="https://i.ibb.co/1JTnNKw1/IMG-20260902-120719.png"
IconButton.ZIndex=999
IconButton.Parent=ScreenGui
IconButton.Draggable=true
IconButton.Active=true
HideGuiFromScanner(IconButton)
Instance.new("UICorner",IconButton).CornerRadius=UDim.new(0,12)
local IconLetter=Instance.new("TextLabel",IconButton)
IconLetter.Size=UDim2.new(1,0,1,0)
IconLetter.BackgroundTransparency=1
IconLetter.Text="M"
IconLetter.TextColor3=Color3.fromRGB(255,255,255)
IconLetter.TextSize=32
IconLetter.Font=Enum.Font.GothamBold
IconLetter.TextXAlignment=Enum.TextXAlignment.Center
IconLetter.TextYAlignment=Enum.TextYAlignment.Center
IconButton.MouseButton1Click:Connect(function()
PlayClickSound()
MainFrame.Visible=not MainFrame.Visible
end)

task.wait(0.5)
MainFrame.Visible=true
MainScale.Scale=1
UpdateAllTexts()
UserInputService.InputBegan:Connect(function(input,gp)
if gp then return end
if input.KeyCode==Enum.KeyCode.Insert then
MainFrame.Visible=not MainFrame.Visible
end
end)
print("[META] v7.9.1 loaded")
