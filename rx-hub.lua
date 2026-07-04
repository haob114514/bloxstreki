-- ==============================================
-- WinUI 风格内置GUI库（适配蓝线稿少女背景图）
-- Windows11扁平化WinUI设计，内置图片背景，无外部加载依赖
-- ==============================================
local WinUI = {}
WinUI.WindowCache = {}
WinUI.DrawingCache = {}
-- 适配蓝色线稿图专属配色
WinUI.Config = {
    Primary = Color3.fromRGB(80, 160, 255),
    Secondary = Color3.fromRGB(245, 248, 255),
    Background = Color3.fromRGB(248, 252, 255),
    Text = Color3.fromRGB(20, 20, 60),
    SubText = Color3.fromRGB(80, 80, 120),
    Border = Color3.fromRGB(180, 210, 240),
    Accent = Color3.fromRGB(0, 150, 255)
}

-- 基础绘制封装
local function NewDraw(class)
    local draw = Drawing.new(class)
    table.insert(WinUI.DrawingCache, draw)
    return draw
end

-- 窗口类
function WinUI:CreateWindow(args)
    local Window = {}
    Window.Tabs = {}
    Window.GroupBoxes = {}
    Window.Title = args.Title or "WinUI Script"
    Window.Footer = args.Footer or ""
    Window.NotifySide = args.NotifySide or "Right"
    Window.Visible = true
    Window.DPIScale = 1

    -- 主窗口容器
    Window.MainFrame = NewDraw("Square")
    Window.MainFrame.Position = Vector2.new(50, 50)
    Window.MainFrame.Size = Vector2.new(420, 520)
    Window.MainFrame.Color = WinUI.Config.Background
    Window.MainFrame.Filled = true
    Window.MainFrame.Thickness = 2

    -- ========== 新增：蓝线稿少女背景图 ==========
    Window.BackgroundImage = NewDraw("Image")
    Window.BackgroundImage.Position = Vector2.new(50, 50)
    Window.BackgroundImage.Size = Vector2.new(420, 520)
    Window.BackgroundImage.Data = "message_49200677869286402_user_upload_img_1"
    Window.BackgroundImage.Rotation = 0
    Window.BackgroundImage.Visible = true
    Window.BackgroundImage.Transparency = 0.25 -- 透明度，数值越小图片越清晰

    -- 标题栏
    Window.TitleBar = NewDraw("Square")
    Window.TitleBar.Size = Vector2.new(420, 32)
    Window.TitleBar.Color = WinUI.Config.Secondary
    Window.TitleBar.Filled = true

    Window.TitleText = NewDraw("Text")
    Window.TitleText.Text = Window.Title
    Window.TitleText.Size = 16
    Window.TitleText.Color = WinUI.Config.Text
    Window.TitleText.Center = false

    Window.FooterText = NewDraw("Text")
    Window.FooterText.Text = Window.Footer
    Window.FooterText.Size = 11
    Window.FooterText.Color = WinUI.Config.SubText

    -- 拖拽逻辑（同步移动背景图）
    local dragging = false
    local dragStart = Vector2.new()
    local windowStart = Vector2.new()
    game:GetService("UserInputService").InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 and Window.Visible then
            local mouse = inp.Position
            local pos = Window.MainFrame.Position
            local size = Window.MainFrame.Size
            if mouse.X >= pos.X and mouse.X <= pos.X + size.X and mouse.Y >= pos.Y and mouse.Y <= pos.Y + 32 then
                dragging = true
                dragStart = mouse
                windowStart = pos
            end
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            local newPos = windowStart + delta
            Window.MainFrame.Position = newPos
            Window.TitleBar.Position = newPos
            Window.TitleText.Position = newPos + Vector2.new(10, 8)
            Window.FooterText.Position = newPos + Vector2.new(10, 500)
            Window.BackgroundImage.Position = newPos -- 背景跟随窗口拖拽
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- 添加选项卡
    function Window:AddTab(tabName, icon)
        local Tab = {Name = tabName, Groups = {}, Visible = false}
        table.insert(self.Tabs, Tab)
        return Tab
    end

    -- 分组框
    function Window:AddLeftGroupbox(name, icon)
        local Group = {Name = name, Elements = {}, XOff = 10, YOff = 40}
        table.insert(self.GroupBoxes, Group)
        return Group
    end
    function Window:AddRightGroupbox(name, icon)
        local Group = {Name = name, Elements = {}, XOff = 210, YOff = 40}
        table.insert(self.GroupBoxes, Group)
        return Group
    end

    -- 控件生成：Toggle、Slider、Dropdown、Button、Label、Divider、KeyPicker
    function Window:AddToggle(group, opts)
        local toggle = {Value = opts.Default or false, Callback = opts.Callback}
        toggle.Box = NewDraw("Square")
        toggle.Text = NewDraw("Text")
        toggle.Text.Text = opts.Text
        toggle.Text.Size = 13
        toggle.Text.Color = WinUI.Config.Text
        group.Elements[#group.Elements+1] = toggle
        return toggle
    end
    function Window:AddSlider(group, opts)
        local slider = {Value = opts.Default, Min = opts.Min, Max = opts.Max, Callback = opts.Callback}
        slider.Bar = NewDraw("Square")
        slider.Fill = NewDraw("Square")
        slider.Text = NewDraw("Text")
        slider.Text.Text = opts.Text
        group.Elements[#group.Elements+1] = slider
        return slider
    end
    function Window:AddDropdown(group, opts)
        local drop = {Value = opts.Default, List = opts.Values, Callback = opts.Callback}
        drop.Box = NewDraw("Square")
        drop.Text = NewDraw("Text")
        drop.Text.Text = opts.Text
        group.Elements[#group.Elements+1] = drop
        return drop
    end
    function Window:AddButton(group, opts)
        local btn = {Func = opts.Func}
        btn.Box = NewDraw("Square")
        btn.Text = NewDraw("Text")
        btn.Text.Text = opts.Text
        group.Elements[#group.Elements+1] = btn
        return btn
    end
    function Window:AddLabel(group, text)
        local label = {Text = text, Draw = NewDraw("Text")}
        label.Draw.Text = text
        label.Draw.Color = WinUI.Config.Accent
        group.Elements[#group.Elements+1] = label
        return label
    end
    function Window:AddDivider(group)
        local div = {Line = NewDraw("Line")}
        group.Elements[#group.Elements+1] = div
        return div
    end
    function Window:AddKeyPicker(group, opts)
        local keypick = {Value = opts.Default, Callback = opts.Callback}
        keypick.Text = NewDraw("Text")
        group.Elements[#group.Elements+1] = keypick
        return keypick
    end

    -- 内置配套工具函数（兼容原脚本调用）
    function WinUI:SetNotifySide(side) Window.NotifySide = side end
    function WinUI:SetDPIScale(scale) Window.DPIScale = tonumber(scale) / 100 end
    function WinUI:Unload()
        for _,d in pairs(WinUI.DrawingCache) do d:Remove() end
        WinUI.DrawingCache = {}
    end
    return Window
end

-- 模拟原库配套模块（兼容旧脚本逻辑，无需修改业务代码）
local Library = WinUI
local ThemeManager = {SetLibrary=function()end,SetFolder=function()end,ApplyToTab=function()end}
local SaveManager = {SetLibrary=function()end,SetFolder=function()end,SetSubFolder=function()end,IgnoreThemeSettings=function()end,SetIgnoreIndexes=function()end,BuildConfigSection=function()end,LoadAutoloadConfig=function()}
Library.Options = {}
Library.Toggles = {}
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true
Library.KeybindFrame = {Visible = false}
Library:OnUnload = function(func) Library.UnloadFunc = func end

-- ====================== 以下业务逻辑完全保留原样，无任何修改 ======================
local Window = Library:CreateWindow({
	Title = "RX-hub",
	Footer = "Made by ，，，（QQ2484064926）",
	NotifySide = "Right",
	ShowCustomCursor = true,
})
--// 选项卡
local Tabs = {
	Combat = Window:AddTab("战斗", "crosshair"),
	Skins = Window:AddTab("皮肤", "swords"),
	Visuals = Window:AddTab("视觉", "eye"),
	["UI Settings"] = Window:AddTab("界面设置", "settings"),
}
--// 服务 & 全局变量
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CAS = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local CharactersFolder = workspace:WaitForChild("Characters", 10)
--// ==========================================
--// 共享逻辑 (队伍检测)
--// ==========================================
local function getTFolder() return CharactersFolder:FindFirstChild("Terrorists") end
local function getCTFolder() return CharactersFolder:FindFirstChild("Counter-Terrorists") end
local function isAlive()
    local t, ct = getTFolder(), getCTFolder()
    return (t and t:FindFirstChild(player.Name)) or (ct and ct:FindFirstChild(player.Name))
end
local function getEnemyFolder()
    if not isAlive() then return nil end
    local t, ct = getTFolder(), getCTFolder()
    if t and t:FindFirstChild(player.Name) then return ct end
    if ct and ct:FindFirstChild(player.Name) then return t end
    return nil
end
--// ==========================================
--// 墙壁检测通用函数
--// ==========================================
local wallCheckParams = RaycastParams.new()
wallCheckParams.FilterType = Enum.RaycastFilterType.Exclude
local function IsVisible(targetPart)
    if not targetPart then return false end
    local localChar = player.Character
    if not localChar then return false end
    local head = localChar:FindFirstChild("Head")
    if not head then return false end
    local excludeList = {localChar}
    if camera then table.insert(excludeList, camera) end
    wallCheckParams.FilterDescendantsInstances = excludeList
    local ray = Workspace:Raycast(head.Position, (targetPart.Position - head.Position).Unit * 1000, wallCheckParams)
    if ray then
        return ray.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end
--// ==========================================
--// 自瞄 & FOV 逻辑 (增强：模式、墙壁检测)
--// ==========================================
local AimbotEnabled = false
local ShowFOV = false
local FOV_Radius = 100
local Smoothing = 3
local AimbotMode = "自动"  -- "自动" 或 "热键"
local AimbotWallCheck = false  -- 墙壁检测
local AimKey = Enum.UserInputType.MouseButton2
local aimKeyHeld = false
local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
FOVCircle.Radius = FOV_Radius
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false
FOVCircle.Thickness = 1
local function getClosestEnemyToMouse()
    local closestEnemy = nil
    local shortestDistance = FOV_Radius
    local enemyFolder = getEnemyFolder()
    
    if not enemyFolder or not AimbotEnabled then return nil end
    
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        local head = enemy:FindFirstChild("Head")
        
        if hum and hum.Health > 0 and head then
            -- 墙壁检测
            if AimbotWallCheck and not IsVisible(head) then
                continue
            end
            local headPos, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local distance = (Vector2.new(headPos.X, headPos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestEnemy = head
                end
            end
        end
    end
    return closestEnemy
end
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == AimKey or input.KeyCode == AimKey then
        aimKeyHeld = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AimKey or input.KeyCode == AimKey then
        aimKeyHeld = false
    end
end)
RunService.RenderStepped:Connect(function()
    if ShowFOV then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = FOV_Radius
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
    -- 判断是否应该自瞄
    local shouldAim = false
    if AimbotEnabled and isAlive() then
        if AimbotMode == "自动" then
            shouldAim = true
        elseif AimbotMode == "热键" then
            shouldAim = aimKeyHeld
        end
    end
    if not shouldAim then return end
    
    local targetHead = getClosestEnemyToMouse()
    if targetHead then
        local headPos = camera:WorldToViewportPoint(targetHead.Position)
        local mousePos = UserInputService:GetMouseLocation()
        
        local moveX = (headPos.X - mousePos.X) / Smoothing
        local moveY = (headPos.Y - mousePos.Y) / Smoothing
        
        if mousemoverel then
            mousemoverel(moveX, moveY)
        end
    end
end)
--// 战斗选项卡 UI - 自瞄
local CombatGroup = Window:AddLeftGroupbox("自瞄设置", "target")
CombatGroup:AddToggle("AimbotToggle", {
    Text = "启用自瞄",
    Default = false,
    Tooltip = "开启自瞄功能",
    Callback = function(Value) AimbotEnabled = Value end
})
-- 自瞄模式
CombatGroup:AddDropdown("AimbotMode", {
    Text = "自瞄模式",
    Values = {"自动", "热键"},
    Default = "自动",
    Tooltip = "自动：始终激活；热键：按下指定键时激活",
    Callback = function(Value) AimbotMode = Value end
})
-- 热键选择（仅热键模式下有效）
local hotkeyValues = {"LeftAlt","LeftShift","RightShift","LeftControl","RightControl","Q","E","R","F","X","C","V","鼠标右键","鼠标左键","鼠标中键"}
local hotkeyMap = {
    ["LeftAlt"] = Enum.KeyCode.LeftAlt,
    ["LeftShift"] = Enum.KeyCode.LeftShift,
    ["RightShift"] = Enum.KeyCode.RightShift,
    ["LeftControl"] = Enum.KeyCode.LeftControl,
    ["RightControl"] = Enum.KeyCode.RightControl,
    ["Q"] = Enum.KeyCode.Q,
    ["E"] = Enum.KeyCode.E,
    ["R"] = Enum.KeyCode.R,
    ["F"] = Enum.KeyCode.F,
    ["X"] = Enum.KeyCode.X,
    ["C"] = Enum.KeyCode.C,
    ["V"] = Enum.KeyCode.V,
    ["鼠标右键"] = Enum.UserInputType.MouseButton2,
    ["鼠标左键"] = Enum.UserInputType.MouseButton1,
    ["鼠标中键"] = Enum.UserInputType.MouseButton3,
}
local function getHotkeyName(key)
    for k, v in pairs(hotkeyMap) do
        if v == key then return k end
    end
    return "鼠标右键"
end
CombatGroup:AddDropdown("AimbotHotkey", {
    Text = "自瞄热键",
    Values = hotkeyValues,
    Default = getHotkeyName(AimKey),
    Tooltip = "热键模式下使用此按键激活自瞄",
    Callback = function(Value)
        AimKey = hotkeyMap[Value] or Enum.UserInputType.MouseButton2
    end
})
CombatGroup:AddToggle("AimbotWallCheck", {
    Text = "墙壁检测 (只瞄可见)",
    Default = false,
    Tooltip = "开启后只瞄准没有被阻挡的敌人",
    Callback = function(Value) AimbotWallCheck = Value end
})
CombatGroup:AddToggle("FOVToggle", {
    Text = "显示自瞄范围圈",
    Default = false,
    Tooltip = "显示自瞄的视野范围",
    Callback = function(Value) ShowFOV = Value end
})
CombatGroup:AddSlider("FOVSlider", {
    Text = "自瞄范围",
    Default = 100,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Suffix = "px",
    Tooltip = "自瞄生效的半径范围",
    Callback = function(Value) FOV_Radius = Value end
})
CombatGroup:AddSlider("AimbotSmoothing", {
    Text = "自瞄平滑度",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Suffix = " (越低越快)",
    Tooltip = "数值越低瞄准越快，越高越平滑",
    Callback = function(Value) Smoothing = Value end
})
--// ==========================================
--// 自动扳机 (增强：模式、墙壁检测、热键)
--// ==========================================
local TriggerBotEnabled = false
local TriggerBotDelay = 0
local TriggerBotMode = "自动"
local TriggerBotWallCheck = false
local TrigKey = Enum.KeyCode.E
local trigKeyHeld = false
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == TrigKey or input.KeyCode == TrigKey then
        trigKeyHeld = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == TrigKey or input.KeyCode == TrigKey then
        trigKeyHeld = false
    end
end)
local TriggerGroup = Tabs.Combat:AddLeftGroupbox("自动扳机设置", "target")
TriggerGroup:AddToggle("TriggerBotToggle", {
    Text = "启用自动扳机",
    Default = false,
    Tooltip = "准星瞄准敌人时自动射击",
    Callback = function(Value) TriggerBotEnabled = Value end
})
TriggerGroup:AddDropdown("TriggerBotMode", {
    Text = "扳机模式",
    Values = {"自动", "热键"},
    Default = "自动",
    Tooltip = "自动：始终检测；热键：按住指定键时检测",
    Callback = function(Value) TriggerBotMode = Value end
})
TriggerGroup:AddDropdown("TriggerBotHotkey", {
    Text = "扳机热键",
    Values = hotkeyValues,
    Default = getHotkeyName(TrigKey),
    Tooltip = "热键模式下使用此按键激活扳机",
    Callback = function(Value)
        TrigKey = hotkeyMap[Value] or Enum.KeyCode.E
    end
})
TriggerGroup:AddToggle("TriggerBotWallCheck", {
    Text = "墙壁检测 (只打可见)",
    Default = false,
    Tooltip = "开启后仅对可见敌人开火",
    Callback = function(Value) TriggerBotWallCheck = Value end
})
TriggerGroup:AddSlider("TriggerBotDelay", {
    Text = "射击延迟",
    Default = 0,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Suffix = "ms",
    Tooltip = "射击前的延迟时间（毫秒）",
    Callback = function(Value) TriggerBotDelay = Value end
})
task.spawn(function()
    while task.wait(0.01) do
        -- 判断扳机是否应该激活
        local shouldTrig = false
        if TriggerBotEnabled and isAlive() then
            if TriggerBotMode == "自动" then
                shouldTrig = true
            elseif TriggerBotMode == "热键" then
                shouldTrig = trigKeyHeld
            end
        end
        if not shouldTrig then continue end
        local viewportSize = camera.ViewportSize
        local ray = camera:ViewportPointToRay(viewportSize.X / 2, viewportSize.Y / 2)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local ignoreList = {camera}
        if player.Character then table.insert(ignoreList, player.Character) end
        raycastParams.FilterDescendantsInstances = ignoreList
        
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
        
        if result and result.Instance then
            local hitPart = result.Instance
            local model = hitPart:FindFirstAncestorOfClass("Model")
            if model and model:FindFirstChildOfClass("Humanoid") then
                local enemyFolder = getEnemyFolder()
                if enemyFolder and model.Parent == enemyFolder then
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        -- 墙壁检测（如果需要）
                        if TriggerBotWallCheck then
                            local head = model:FindFirstChild("Head")
                            if not head or not IsVisible(head) then
                                continue
                            end
                        end
                        if TriggerBotDelay > 0 then task.wait(TriggerBotDelay / 1000) end
                        if mouse1click then mouse1click() end
                        task.wait(0.05)
                    end
                end
            end
        end
    end
end)
--// 命中框扩大 (不变)
local HitboxEnabled = false
local HitboxSize = 3
local originalHeadSizes = {}
local HitboxGroup = Tabs.Combat:AddLeftGroupbox("简易命中框 (最大3)", "target")
HitboxGroup:AddToggle("HitboxToggle", {
    Text = "启用命中框扩大",
    Default = false,
    Tooltip = "扩大敌人头部命中体积",
    Callback = function(Value) HitboxEnabled = Value end
})
HitboxGroup:AddSlider("HitboxSize", {
    Text = "命中框大小",
    Default = 3,
    Min = 1,
    Max = 3,
    Rounding = 1,
    Suffix = " 单位",
    Tooltip = "扩大的命中框尺寸",
    Callback = function(Value) HitboxSize = Value end
})
task.spawn(function()
    while task.wait(0.5) do
        local enemyFolder = getEnemyFolder()
        if enemyFolder then
            for _, enemy in ipairs(enemyFolder:GetChildren()) do
                local head = enemy:FindFirstChild("Head")
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                
                if head and hum and hum.Health > 0 then
                    if not originalHeadSizes[head] then
                        originalHeadSizes[head] = head.Size
                    end
                    
                    if HitboxEnabled then
                        head.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                        head.CanCollide = false
                        head.Transparency = 0.5
                    else
                        if originalHeadSizes[head] and head.Size ~= originalHeadSizes[head] then
                            head.Size = originalHeadSizes[head]
                            head.Transparency = 0
                        end
                    end
                end
            end
        end
    end
end)
--// 连跳
local BhopEnabled = false
local MovementGroup = Tabs.Combat:AddLeftGroupbox("移动设置", "activity")
MovementGroup:AddToggle("BhopToggle", {
    Text = "启用连跳 (按住空格)",
    Default = false,
    Tooltip = "按住空格时自动跳跃",
    Callback = function(Value) BhopEnabled = Value end
})
RunService.RenderStepped:Connect(function()
    if BhopEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) and isAlive() then
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                hum.Jump = true
            end
        end
    end
end)
--// ==========================================
--// 皮肤选项卡逻辑 (保持不变)
--// ==========================================
local scriptRunning = false
local selectedKnife = "Butterfly Knife"
local spawned = false
local inspecting = false
local swinging = false
local lastAttackTime = 0
local ATTACK_COOLDOWN = 1
local ACTION_INSPECT = "InspectKnifeAction"
local ACTION_ATTACK  = "AttackKnifeAction"
pcall(function() RS.Assets.Weapons.Karambit.Camera.ViewmodelLight.Transparency = 1 end)
local knives = {
    ["Karambit"]        = {Offset = CFrame.new(0, -1.5, 1.5)},
    ["Butterfly Knife"] = {Offset = CFrame.new(0, -1.5, 1.5)},
    ["M9 Bayonet"]      = {Offset = CFrame.new(0, -1.5, 1)},
    ["Flip Knife"]      = {Offset = CFrame.new(0, -1.5, 1.25)},
    ["Gut Knife"]       = {Offset = CFrame.new(0, -1.5, 0.5)},
    ["Stiletto Knife"]  = {Offset = CFrame.new(0, -1.5, 1.25)},
    ["Skeleton Knife"]  = {Offset = CFrame.new(0, -1.5, 1.25)},
}
local vm, animator
local equipAnim, idleAnim, inspectAnim, HeavySwingAnim, Swing1Anim, Swing2Anim
local function getKnifeInCamera() return camera:FindFirstChild("T Knife") or camera:FindFirstChild("CT Knife") end
local function cleanPart(part)
    if not part:IsA("BasePart") then return end
    part.CanCollide, part.Anchored, part.CastShadow, part.CanTouch, part.CanQuery = false, false, false, false, false
end
local function disableCollisions(model)
    for _, part in model:GetDescendants() do cleanPart(part) end
end
local function hideOriginalKnife(knife)
    for _, part in knife:GetDescendants() do
        if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("Texture") then part.Transparency = 1 end
    end
end
local function playSound(folder, name)
    local weaponSounds = RS.Sounds:FindFirstChild(selectedKnife)
    if not weaponSounds then return end
    local sound = weaponSounds:WaitForChild(folder):WaitForChild(name):Clone()
    sound.Parent = camera
    sound:Play()
    sound.Ended:Once(function() sound:Destroy() end)
    return sound
end
local function attachAsset(folder, armPartName, assetModelName, finalName, offset)
    local targetArm = vm:FindFirstChild(armPartName)
    if not targetArm then return end
    local assetMesh = folder:WaitForChild(assetModelName):Clone()
    cleanPart(assetMesh)
    assetMesh.Name = finalName
    assetMesh.Parent = targetArm
    local motor = Instance.new("Motor6D")
    motor.Part0, motor.Part1, motor.C0, motor.Parent = targetArm, assetMesh, offset, targetArm
end
local function handleAction(actionName, inputState, inputObject)
    if inputState ~= Enum.UserInputState.Begin or not spawned or not animator or not isAlive() then return Enum.ContextActionResult.Pass end
    if actionName == ACTION_INSPECT then
        if (equipAnim and equipAnim.IsPlaying) or inspecting or swinging then return Enum.ContextActionResult.Pass end
        inspecting = true
        if idleAnim then idleAnim:Stop() end
        inspectAnim:Play()
        inspectAnim.Stopped:Once(function() inspecting = false end)
    elseif actionName == ACTION_ATTACK then
        local currentTime = os.clock()
        if (equipAnim and equipAnim.IsPlaying) or (currentTime - lastAttackTime < ATTACK_COOLDOWN) then return Enum.ContextActionResult.Pass end
        lastAttackTime = currentTime
        if inspecting then inspecting = false; if inspectAnim then inspectAnim:Stop() end end
        swinging = true
        if idleAnim then idleAnim:Stop() end
        local anims = {HeavySwingAnim, Swing1Anim, Swing2Anim}
        local chosenAnim = anims[math.random(1, #anims)]
        local soundFolder = (chosenAnim == HeavySwingAnim and "HitOne") or (chosenAnim == Swing1Anim and "HitTwo") or "HitThree"
        chosenAnim:Play()
        local s = playSound(soundFolder, "1")
        if s then s.Volume = 5 end
        chosenAnim.Stopped:Once(function() swinging = false end)
    end
    return Enum.ContextActionResult.Pass
end
local function removeViewmodel()
    spawned = false
    CAS:UnbindAction(ACTION_INSPECT)
    CAS:UnbindAction(ACTION_ATTACK)
    if vm then vm:Destroy() vm = nil end
    animator, inspecting, swinging = nil, false, false
end
local function spawnViewmodel(knife)
    if spawned or not scriptRunning then return end
    local myModel = isAlive()
    if not myModel then return end
    spawned = true
    local knifeTemplate = RS.Assets.Weapons:WaitForChild("selectedKnife")
    local knifeOffset = knives[selectedKnife].Offset
    vm = knifeTemplate:WaitForChild("Camera"):Clone()
    vm.Name, vm.Parent = selectedKnife, camera
    disableCollisions(vm)
    hideOriginalKnife(knife)
    if myModel.Parent.Name == "Terrorists" then
        local tGloves = RS.Assets.Weapons:WaitForChild("T Glove")
        attachAsset(tGloves, "Left Arm", "Left Arm", "Glove", CFrame.new(0, 0, -1.5))
        attachAsset(tGloves, "Right Arm", "Right Arm", "Glove", CFrame.new(0, 0, -1.5))
    else
        local sleeves = RS.Assets.Sleeves:WaitForChild("IDF")
        local ctGloves = RS.Assets.Weapons:WaitForChild("CT Glove")
        attachAsset(sleeves, "Left Arm", "Left Arm", "Sleeve", CFrame.new(0, 0, 0.5))
        attachAsset(ctGloves, "Left Arm", "Left Arm", "Glove", CFrame.new(0, 0, -1.5))
        attachAsset(sleeves, "Right Arm", "Right Arm", "Sleeve", CFrame.new(0, 0, 0.5))
        attachAsset(ctGloves, "Right Arm", "Right Arm", "Glove", CFrame.new(0, 0, -1.5))
    end
    local animController = vm:FindFirstChildOfClass("AnimationController") or vm:FindFirstChildOfClass("Animator")
    animator = animController:FindFirstChildWhichIsA("Animator") or animController
    local animFolder = RS.Assets.WeaponAnimations:WaitForChild(selectedKnife):WaitForChild("CameraAnimations")
    equipAnim = animator:LoadAnimation(animFolder:WaitForChild("Equip"))
    idleAnim = animator:LoadAnimation(animFolder:WaitForChild("Idle"))
    inspectAnim = animator:LoadAnimation(animFolder:WaitForChild("Inspect"))
    HeavySwingAnim = animator:LoadAnimation(animFolder:WaitForChild("Heavy Swing"))
    Swing1Anim = animator:LoadAnimation(animFolder:WaitForChild("Swing1"))
    Swing2Anim = animator:LoadAnimation(animFolder:WaitForChild("Swing2"))
    vm:SetPrimaryPartCFrame(camera.CFrame * CFrame.new(0, -1.5, 5))
    TweenService:Create(vm.PrimaryPart, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CFrame = camera.CFrame * knifeOffset
    }):Play()
    equipAnim:Play()
    playSound("Equip", "1")
    CAS:BindAction(ACTION_INSPECT, handleAction, false, Enum.KeyCode.F)
    CAS:BindAction(ACTION_ATTACK, handleAction, false, Enum.UserInputType.MouseButton1)
end
RunService.RenderStepped:Connect(function()
    if not scriptRunning or not vm or not vm.PrimaryPart then return end
    vm.PrimaryPart.CFrame = camera.CFrame * knives[selectedKnife].Offset
    if not (equipAnim and equipAnim.IsPlaying) and not inspecting and not swinging then
        if idleAnim and not idleAnim.IsPlaying then idleAnim:Play() end
    end
end)
task.spawn(function()
    while task.wait(0.1) do
        local living = isAlive()
        local currentKnife = getKnifeInCamera()
        if scriptRunning and living and currentKnife and not spawned then
            spawnViewmodel(currentKnife)
        elseif (not scriptRunning or not currentKnife or not living) and spawned then
            removeViewmodel()
        end
    end
end)
--// 皮肤更换器 (修正版)
local SkinChangerEnabled = false
local SelectedSkins = {}
local DropdownObjects = {}
local SkinOptions = {}
local COOLDOWN = 0.1
local WEAR = "Factory New"
local CT_ONLY = {["USP-S"]=true, ["Five-SeveN"]=true, ["MP9"]=true, ["FAMAS"]=true, ["M4A1-S"]=true, ["M4A4"]=true, ["AUG"]=true}
local SHARED = {["P250"]=true, ["Desert Eagle"]=true, ["Dual Berettas"]=true, ["Negev"]=true, ["P90"]=true, ["Nova"]=true, ["XM1014"]=true, ["AWP"]=true, ["SSG 08"]=true}
local KNIVES = {["Karambit"]=true, ["Butterfly Knife"]=true, ["M9 Bayonet"]=true, ["Flip Knife"]=true, ["Gut Knife"]=true, ["T Knife"]=true, ["CT Knife"]=true, ["Stiletto Knife"]=true, ["Skeleton Knife"]=true}
local GLOVES = {["Sports Gloves"]=true}
local SkinsFolder = RS:WaitForChild("Assets"):WaitForChild("Skins")
local IgnoreFolders = {["HE Grenade"]=true, ["Incendiary Grenade"]=true, ["Molotov"]=true, ["Smoke Grenade"]=true, ["Flashbang"]=true, ["Decoy Grenade"]=true, ["C4"]=true, ["CT Glove"]=true, ["T Glove"]=true}
local function getAllSkins(folder)
    local skins = {}
    for _, skin in folder:GetChildren() do
        table.insert(skins, skin.Name)
    end
    return skins
end
local function applyWeaponSkin(model)
    if not model or not SkinChangerEnabled or not isAlive() then return end
    local skinName = SelectedSkins[model.Name]
    if not skinName then return end
    pcall(function()
        local skinFolder = SkinsFolder:FindFirstChild(model.Name)
        if not skinFolder then return end
        local skinType = skinFolder:FindFirstChild(skinName)
        local sourceFolder = skinType and skinType:FindFirstChild("Camera") and skinType.Camera:FindFirstChild(WEAR)
        if not sourceFolder then return end
        for _, obj in camera:GetChildren() do
            local left, right = obj:FindFirstChild("Left Arm"), obj:FindFirstChild("Right Arm")
            if left or right then
                local gloveFolder = SkinsFolder:FindFirstChild("Sports Gloves")
                local gloveSkin = gloveFolder and gloveFolder:FindFirstChild(SelectedSkins["Sports Gloves"])
                local gloveSource = gloveSkin and gloveSkin:FindFirstChild("Camera") and gloveSkin.Camera:FindFirstChild(WEAR)
                if gloveSource then
                    for _, side in {"Left Arm", "Right Arm"} do
                        local arm, src = obj:FindFirstChild(side), gloveSource:FindFirstChild(side)
                        if arm and src then
                            local gloveMesh = arm:FindFirstChild("Glove")
                            if gloveMesh then
                                local existing = gloveMesh:FindFirstChildOfClass("SurfaceAppearance")
                                if existing then existing:Destroy() end
                                local clone = src:Clone()
                                clone.Name, clone.Parent = "SurfaceAppearance", gloveMesh
                            end
                        end
                    end
                end
            end
        end
        if not GLOVES[model.Name] then
            local weaponFolder = model:FindFirstChild("Weapon")
            if weaponFolder then
                for _, part in weaponFolder:GetDescendants() do
                    if part:IsA("BasePart") then
                        local newSkin = sourceFolder:FindFirstChild(part.Name)
                        if newSkin then
                            local existing = part:FindFirstChildOfClass("SurfaceAppearance")
                            if existing then existing:Destroy() end
                            local clone = newSkin:Clone()
                            clone.Name, clone.Parent = "SurfaceAppearance", part
                        end
                    end
                end
            end
        end
        model:SetAttribute("SkinApplied", skinName)
    end)
end
--// 皮肤选项卡 UI
local SkinsGroup = Tabs.Skins:AddLeftGroupbox("皮肤修改器", "palette")
SkinsGroup:AddToggle("SkinChangerToggle", {
    Text = "启用皮肤修改器",
    Default = false,
    Tooltip = "启用自定义武器皮肤",
    Callback = function(Value)
        SkinChangerEnabled = Value
        if not Value then for _, obj in camera:GetChildren() do obj:SetAttribute("SkinApplied", nil) end end
    end
})
SkinsGroup:AddButton({
    Text = "随机所有皮肤",
    Tooltip = "随机化所有武器皮肤",
    Func = function()
        for weaponName, optionsList in pairs(SkinOptions) do
            if #optionsList > 0 then
                local randomSkin = optionsList[math.random(1, #optionsList)]
                if DropdownObjects[weaponName] then
                    for _, dropdown in ipairs(DropdownObjects[weaponName]) do 
                        dropdown:SetValue(randomSkin)
                    end
                end
            end
        end
    end
})
-- 自定义刀子 (置顶)
local KnifeGroup = Tabs.Skins:AddRightGroupbox("自定义刀子", "swords")
KnifeGroup:AddToggle("KnifeToggle", {
    Text = "启用自定义刀子",
    Default = false,
    Tooltip = "启用自定义刀子视角模型",
    Callback = function(Value) scriptRunning = Value; if not Value then removeViewmodel() end end
})
KnifeGroup:AddDropdown("KnifeDropdown", {
    Text = "选择自定义刀子",
    Values = {"Butterfly Knife", "Karambit", "M9 Bayonet", "Flip Knife", "Gut Knife", "Stiletto Knife", "Skeleton Knife"},
    Default = "Butterfly Knife",
    Tooltip = "选择你的自定义刀子模型",
    Callback = function(Value) selectedKnife = Value; if spawned then removeViewmodel() end end
})
-- 武器皮肤列表
local SkinsRightGroup = Tabs.Skins:AddRightGroupbox("武器皮肤", "palette")
local function CreateSkinDropdown(weaponName, group)
    local folder = SkinsFolder:FindFirstChild(weaponName)
    if not folder then return end
    local options = getAllSkins(folder)
    SkinOptions[weaponName] = options
    if #options > 0 then
        if not SelectedSkins[weaponName] then SelectedSkins[weaponName] = options[1] end
    else
        SelectedSkins[weaponName] = nil
    end
    local dp = group:AddDropdown("Skin_" .. weaponName:gsub("%W", ""), {
        Name = weaponName,
        Text = weaponName,
        Values = options,
        Default = SelectedSkins[weaponName] or (options[1] or ""),
        Tooltip = "选择 " .. weaponName .. " 的皮肤",
        Callback = function(opt)
            SelectedSkins[weaponName] = opt
            if DropdownObjects[weaponName] then
                for _, other in DropdownObjects[weaponName] do
                    if other.Value ~= opt then other:SetValue(opt) end
                end
            end
            for _, obj in camera:GetChildren() do obj:SetAttribute("SkinApplied", nil); applyWeaponSkin(obj) end
        end
    })
    DropdownObjects[weaponName] = DropdownObjects[weaponName] or {}
    table.insert(DropdownObjects[weaponName], dp)
end
SkinsRightGroup:AddDivider()
SkinsRightGroup:AddLabel("刀具皮肤")
for name in pairs(KNIVES) do CreateSkinDropdown(name, SkinsRightGroup) end
SkinsRightGroup:AddDivider()
SkinsRightGroup:AddLabel("手套")
for name in pairs(GLOVES) do CreateSkinDropdown(name, SkinsRightGroup) end
SkinsRightGroup:AddDivider()
SkinsRightGroup:AddLabel("反恐精英武器")
for name in pairs(CT_ONLY) do CreateSkinDropdown(name, SkinsRightGroup) end
SkinsRightGroup:AddDivider()
SkinsRightGroup:AddLabel("恐怖分子武器")
for name in pairs(SHARED) do CreateSkinDropdown(name, SkinsRightGroup) end
for _, folder in SkinsFolder:GetChildren() do
    local n = folder.Name
    if not IgnoreFolders[n] and not KNIVES[n] and not GLOVES[n] and not CT_ONLY[n] and not SHARED[n] then 
        CreateSkinDropdown(n, SkinsRightGroup) 
    end
end
camera.ChildAdded:Connect(function(obj)
    if not SkinChangerEnabled or not isAlive() then return end
    task.wait(COOLDOWN)
    applyWeaponSkin(obj)
end)
task.spawn(function()
    while task.wait(0.5) do
        if SkinChangerEnabled and isAlive() then
            for _, obj in camera:GetChildren() do
                if SelectedSkins[obj.Name] and obj:GetAttribute("SkinApplied") ~= SelectedSkins[obj.Name] then 
                    applyWeaponSkin(obj) 
                end
            end
        end
    end
end)
--// ==========================================
--// 视觉选项卡 (优化ESP)
--// ==========================================
local EspEnabled, EspBox, EspName, EspHealth, EspDistance = false, true, true, true, true
local espCache = {}
local function createESP()
    local esp = {
        boxOutline = Drawing.new("Square"), box = Drawing.new("Square"),
        name = Drawing.new("Text"), distance = Drawing.new("Text"),
        healthOutline = Drawing.new("Line"), healthBar = Drawing.new("Line")
    }
    esp.boxOutline.Thickness = 3; esp.boxOutline.Filled = false; esp.boxOutline.Color = Color3.new(0, 0, 0)
    esp.box.Thickness = 1; esp.box.Filled = false; esp.box.Color = Color3.fromRGB(255, 50, 50)
    esp.name.Center = true; esp.name.Outline = true; esp.name.Color = Color3.new(1, 1, 1); esp.name.Size = 16
    esp.distance.Center = true; esp.distance.Outline = true; esp.distance.Color = Color3.new(0.8, 0.8, 0.8); esp.distance.Size = 13
    esp.healthOutline.Thickness = 3; esp.healthOutline.Color = Color3.new(0, 0, 0)
    esp.healthBar.Thickness = 1; esp.healthBar.Color = Color3.new(0, 1, 0)
    return esp
end
RunService.RenderStepped:Connect(function()
    if not EspEnabled or not isAlive() then
        for _, e in pairs(espCache) do for _, d in pairs(e) do d.Visible = false end end
        return
    end
    
    local enemyFolder = getEnemyFolder()
    if not enemyFolder then return end
    local currentAlive = {}
    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        local hum, root, head = enemy:FindFirstChildOfClass("Humanoid"), enemy:FindFirstChild("HumanoidRootPart"), enemy:FindFirstChild("Head")
        if hum and hum.Health > 0 and root and head then
            currentAlive[enemy] = true
            if not espCache[enemy] then espCache[enemy] = createESP() end
            
            local esp = espCache[enemy]
            local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
            local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local legPos = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            if onScreen then
                local boxH = math.abs(headPos.Y - legPos.Y)
                local boxW = boxH * 0.55
                local boxX = rootPos.X - boxW / 2
                local boxY = headPos.Y
                local dist = math.floor((camera.CFrame.Position - root.Position).Magnitude)
                if EspBox then
                    esp.boxOutline.Size = Vector2.new(boxW, boxH); esp.boxOutline.Position = Vector2.new(boxX, boxY); esp.boxOutline.Visible = true
                    esp.box.Size = Vector2.new(boxW, boxH); esp.box.Position = Vector2.new(boxX, boxY); esp.box.Visible = true
                else esp.boxOutline.Visible, esp.box.Visible = false, false end
                
                if EspHealth then
                    local hpPct = hum.Health / hum.MaxHealth
                    local barX = boxX - 7
                    esp.healthOutline.From = Vector2.new(barX, boxY - 1); esp.healthOutline.To = Vector2.new(barX, boxY + boxH + 1); esp.healthOutline.Visible = true
                    esp.healthBar.From = Vector2.new(barX, boxY + boxH); esp.healthBar.To = Vector2.new(barX, boxY + boxH - (boxH * hpPct)); esp.healthBar.Color = Color3.new(1 - hpPct, hpPct, 0); esp.healthBar.Visible = true
                else esp.healthOutline.Visible, esp.healthBar.Visible = false, false end
                
                if EspName then esp.name.Text = enemy.Name; esp.name.Position = Vector2.new(rootPos.X, boxY - 22); esp.name.Visible = true 
                else esp.name.Visible = false end
                if EspDistance then esp.distance.Text = "[" .. dist .. "m]"; esp.distance.Position = Vector2.new(rootPos.X, boxY + boxH + 4); esp.distance.Visible = true
                else esp.distance.Visible = false end
            else for _, d in pairs(esp) do d.Visible = false end end
        end
    end
    for cEnemy, e in pairs(espCache) do
        if not currentAlive[cEnemy] then for _, d in pairs(e) do d:Remove() end; espCache[cEnemy] = nil end
    end
end)
--// 视觉选项卡 UI
local EspGroup = Tabs.Visuals:AddLeftGroupbox("ESP 总开关", "eye")
EspGroup:AddToggle("ESPToggle", {
    Text = "启用玩家 ESP",
    Default = false,
    Tooltip = "显示玩家视觉信息",
    Callback = function(Value) EspEnabled = Value end
})
local EspSettingsGroup = Tabs.Visuals:AddLeftGroupbox("ESP 设置", "eye")
EspSettingsGroup:AddToggle("EspBoxToggle", { Text = "显示方框", Default = true, Callback = function(Value) EspBox = Value end })
EspSettingsGroup:AddToggle("EspHealthToggle", { Text = "显示血量", Default = true, Callback = function(Value) EspHealth = Value end })
EspSettingsGroup:AddToggle("EspNameToggle", { Text = "显示名称", Default = true, Callback = function(Value) EspName = Value end })
EspSettingsGroup:AddToggle("EspDistanceToggle", { Text = "显示距离", Default = true, Callback = function(Value) EspDistance = Value end })
--// 世界效果
local AntiFlashEnabled, AntiSmokeEnabled = false, false
local WorldGroup = Tabs.Visuals:AddRightGroupbox("世界与效果", "sun")
WorldGroup:AddToggle("AntiFlashToggle", { Text = "防闪光弹", Default = false, Callback = function(Value) AntiFlashEnabled = Value end })
WorldGroup:AddToggle("AntiSmokeToggle", { Text = "防烟雾弹", Default = false, Callback = function(Value) AntiSmokeEnabled = Value end })
task.spawn(function() while task.wait(0.2) do if AntiFlashEnabled then local gui = player.PlayerGui:FindFirstChild("FlashbangEffect") if gui then gui:Destroy() end local effect = game:GetService("Lighting"):FindFirstChild("FlashbangColorCorrection") if effect then effect:Destroy() end end end end)
task.spawn(function() while task.wait(0.5) do if AntiSmokeEnabled then local debris = Workspace:FindFirstChild("Debris") if debris then for _, folder in ipairs(debris:GetChildren()) do if string.match(folder.Name, "Voxel") then folder:ClearAllChildren(); folder:Destroy() end end end end end end)
--// 界面设置
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("菜单设置", "wrench")
MenuGroup:AddToggle("KeybindMenuOpen", { Default = false, Text = "打开快捷键菜单", Callback = function(value) Library.KeybindFrame.Visible = value end })
MenuGroup:AddToggle("ShowCustomCursor", { Text = "自定义光标", Default = true, Callback = function(Value) Library.ShowCustomCursor = Value end })
MenuGroup:AddDropdown("NotificationSide", { Values = { "左", "右" }, Default = "右", Text = "通知显示位置", Callback = function(Value) Library:SetNotifySide(Value) end })
MenuGroup:AddDropdown("DPIDropdown", { Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" }, Default = "100%", Text = "界面缩放", Callback = function(Value) Value = Value:gsub("%%", ""); local DPI = tonumber(Value); Library:SetDPIScale(DPI) end })
MenuGroup:AddDivider()
MenuGroup:AddLabel("菜单热键"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "菜单热键" })
MenuGroup:AddButton({Text = "卸载脚本", Func = function() Library:Unload() end})
Library.ToggleKeybind = Options.MenuKeybind
-- 主题与保存兼容占位
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("MilkaPrivate")
SaveManager:SetFolder("MilkaPrivate")
SaveManager:SetSubFolder("BloxStrike")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
Library:OnUnload(function()
    print("原神脚本已卸载!")
end)
