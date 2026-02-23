local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/lastest/download/main.lua"))()
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local Player = game.Players.LocalPlayer
local replitcated = game:GetService("ReplitcatedStorage")

local Window = Fluent:CreateWindow({
  Title = "Meow Hub"
  Subtitle = "by _problemm"
  TabWidth = 160,
  Size = UDim2.fromOffset(500, 340),
  Acrylic = false,
  Theme = "Dark"
  MinimizeKey = Erum.KeyCode.LeftControl
})
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Btn = Instance.new("ImageButton", ScreenGui)
Btn.Size, Btn.Position, Btn.BackgroundTransparency = UDim2.new(0,60,0,60), UDim2.new(0,15,0.02,0), 1
Btn.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=127470963031421&width=420&height=420&format=png"
Instance.new("UICorner", Btn).CornerRadius = UDim.new(1,0)
Btn.MouseButton1Click:Connect(function() Window:Minimize() end)

local Tabs = {
    HuntLeviathan = Window:AddTab({ Title = "Hunt Leviathan", Icon = "" }),
    SettingHunt = Window:AddTab({ Title = "Select And Hold Skill", Icon = "" })
}
local activeTween, freezeY = nil, nil
local function CheckFrozenDimension()
return workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations") and workspace._WorldOrigin.Locations:FindFirstChild("Frozen Dimension")
end
local function SetVelocity(part, enable)
    if not part then return end
    if part:FindFirstChild("CatV") then part.CatV:Destroy() end
    if part:FindFirstChild("CatA") then part.CatA:Destroy() end
    if enable then
        local att = Instance.new("Attachment", part); att.Name = "CatA"
        local lv = Instance.new("LinearVelocity", part)
        lv.Name = "CatV"
        lv.MaxForce = math.huge
        lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        lv.VectorVelocity = Vector3.zero
        lv.Attachment0 = att
    end
end
_G.MeleeSkills = {}
_G.FruitSkills = {}
_G.SwordSkills = {}
_G.GunSkills = {}

local VirtualInputManager = game:GetService("VirtualInputManager")

local function EquipWeapon(WeaponType)
    local Character = game.Players.LocalPlayer.Character
    local Backpack = game.Players.LocalPlayer.Backpack
    if Character and Backpack then
        local currentTool = Character:FindFirstChildOfClass("Tool")
        if not currentTool or (currentTool and currentTool.ToolTip ~= WeaponType) then
            for _, tool in pairs(Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.ToolTip == WeaponType then
                    Character.Humanoid:EquipTool(tool)
                    break
                end
            end
        end
    end
end

local function ExecuteSkills(SkillTable, WeaponType)
    if _G.AutoLeviathan then
        EquipWeapon(WeaponType)
        task.wait(0.1)
        for skill, enabled in pairs(SkillTable) do
            if enabled then
                task.spawn(function()
                    VirtualInputManager:SendKeyEvent(true, skill, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, skill, false, game)
                end)
            end
        end
    end
end

_G.RunAllSkills = function()
    if _G.SelectedWeapons["Melee"] then
        ExecuteSkills(_G.MeleeSkills, "Melee")
    end
    if _G.SelectedWeapons["Blox Fruit"] then
        ExecuteSkills(_G.FruitSkills, "Blox Fruit")
    end
    if _G.SelectedWeapons["Sword"] then
        ExecuteSkills(_G.SwordSkills, "Sword")
    end
    if _G.SelectedWeapons["Gun"] then
        ExecuteSkills(_G.GunSkills, "Gun")
    end
end
_G.AutoLeviathan = false
local Speed = 350

local function StartLeviathanFix()
    task.spawn(function()
        local Character = game.Players.LocalPlayer.Character
        local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
        if not HRP then return end

        -- Khởi tạo lực di chuyển bền bỉ
        local BV = HRP:FindFirstChild("LeviVelocity") or Instance.new("BodyVelocity")
        BV.Name = "LeviVelocity"
        BV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.Parent = HRP
        
        local BG = HRP:FindFirstChild("LeviGyro") or Instance.new("BodyGyro")
        BG.Name = "LeviGyro"
        BG.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        BG.P = 10000
        BG.Parent = HRP

        while _G.AutoLeviathan do
            local Target = nil
            local SeaBeasts = workspace.SeaBeasts:GetChildren()
            
            -- Ưu tiên 1: Leviathan Segment
            for _, v in pairs(SeaBeasts) do
                if v.Name == "Leviathan Segment" then
                    Target = v:IsA("BasePart") and v or v:FindFirstChild("HumanoidRootPart")
                    if Target then break end
                end
            end
            
            -- Ưu tiên 2: Leviathan (Nếu không có Segment)
            if not Target then
                for _, v in pairs(SeaBeasts) do
                    if v.Name == "Leviathan" then
                        Target = v:IsA("BasePart") and v or v:FindFirstChild("HumanoidRootPart")
                        if Target then break end
                    end
                end
            end

            if Target then
                -- NoClip liên tục để không bị kẹt khi đang bay
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end

                local TargetPos = (Target.CFrame * CFrame.new(0, 45, 0)).Position 
                local Distance = (HRP.Position - TargetPos).Magnitude
                
                if Distance > 5 then
                    -- Bay liên tục với vận tốc Speed
                    BV.Velocity = (TargetPos - HRP.Position).Unit * Speed
                    BG.CFrame = CFrame.lookAt(HRP.Position, TargetPos)
                else
                    -- Dán chặt khi đã đến đích
                    BV.Velocity = Vector3.new(0, 0, 0)
                    HRP.CFrame = CFrame.new(TargetPos, Target.Position)
                end
                -- Tính khoảng cách thực tế đến vật thể (Target)
local CurrentDistance = (HRP.Position - Target.Position).Magnitude / 3.57
 local RealDistanceMetres = (HRP.Position - Target.Position).Magnitude / 3.57
                if RealDistanceMetres <= 20 and _G.RunAllSkills then
                    _G.RunAllSkills()
                end


            else
                -- Nếu mất dấu, giảm tốc từ từ để chờ quét lại (tránh dừng đột ngột)
                BV.Velocity = BV.Velocity * 0.8
                task.wait(0.1)
            end
            task.wait() 
        end
        
        -- Dọn dẹp sạch sẽ khi tắt
        if BV then BV:Destroy() end
        if BG then BG:Destroy() end
        if Character then
            for _, v in pairs(Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end)
end
do
    Tabs.HuntLeviathan:AddButton({
        Title = "Teleport To Your Boat",
        Description = "",
        Callback = function()
            local targetSeat = nil
            for _, b in pairs(workspace.Boats:GetChildren()) do
                if b:FindFirstChild("Owner") and (tostring(b.Owner.Value) == LP.Name or b.Owner.Value == LP.UserId) then
                    targetSeat = b:FindFirstChildWhichIsA("VehicleSeat", true)
                    break
                end
            end
            if targetSeat and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LP.Character.HumanoidRootPart
                local dist = (targetSeat.Position - hrp.Position).Magnitude
                local noclip = RS.Stepped:Connect(function()
                    for _, v in pairs(LP.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end)
                local tw = Tween:Create(hrp, TweenInfo.new(dist / 350, Enum.EasingStyle.Linear), {CFrame = targetSeat.CFrame + Vector3.new(0, 5, 0)})
                tw:Play()
                tw.Completed:Connect(function() noclip:Disconnect() end)
            end
        end
    })
  local StatusParagraph = Tabs.HuntLeviathan:AddParagraph({
    Title = "Frozen Dimension.",
    Content = ""
})

task.spawn(function()
    while task.wait(0.01) do
        if CheckFrozenDimension() then
            StatusParagraph:SetTitle("Frozen Dimension : ✅")
        else
            StatusParagraph:SetTitle("Frozen Dimension : Don't Spawn Yet")
        end
    end
end)
 local ToggleFind = Tabs.HuntLeviathan:AddToggle("Find", { Title = "Find Leviathan", Default = false })
    ToggleFind:OnChanged(function(Value)
        _G.Auto = Value
        if Value then
            task.spawn(function()
                while _G.Auto do
                    local hum = LP.Character:FindFirstChild("Humanoid")
                    local seat = hum and hum.SeatPart
                    if seat and seat:IsA("VehicleSeat") then
                        if GetFrozenDimension() then
                            if activeTween then activeTween:Cancel() end
                            Fluent:Notify({Title = "Banana Cat Hub", Content = "Frozen Dimension Spawned", Duration = 5})
                            repeat task.wait(1) until not GetFrozenDimension() or not _G.Auto
                        else
                            Fluent:Notify({Title = "Banana Cat Hub", Content = "Finding Leviathan", Duration = 3})
                            local boat = seat.Parent.PrimaryPart
                            SetVelocity(boat, true)
                            freezeY = 1000
                            boat.CFrame = CFrame.new(boat.Position.X, 1000, boat.Position.Z)
                            task.wait(1)
                            
                            if _G.Auto and not GetFrozenDimension() and hum.SeatPart == seat and boat.Position.Z < 14238 then
                                local dist = (Vector3.new(-13608, 1000, 14238) - boat.Position).Magnitude
                                activeTween = TS:Create(boat, TweenInfo.new(dist/350, Enum.EasingStyle.Linear), {CFrame = CFrame.new(-13608, 1000, 14238)})
                                activeTween:Play()
                                while _G.Auto and activeTween.PlaybackState == Enum.PlaybackState.Playing and hum.SeatPart == seat do
                                    if GetFrozenDimension() then break end
                                    task.wait(0.000001)
                                end
                            end
                            
                            if _G.Auto and not GetFrozenDimension() and hum.SeatPart == seat then
                                if activeTween then activeTween:Cancel() end
                                freezeY = 175
                                boat.CFrame = CFrame.new(boat.Position.X, 175, boat.Position.Z)
                                task.wait(1)
                                local targetCF = CFrame.new(boat.Position.X, 175, 1000000)
                                activeTween = TS:Create(boat, TweenInfo.new(4000, Enum.EasingStyle.Linear), {CFrame = targetCF})
                                activeTween:Play()
                                while _G.Auto and activeTween.PlaybackState == Enum.PlaybackState.Playing and hum.SeatPart == seat do
                                    if GetFrozenDimension() then break end
                                    pcall(function() boat.CatV.VectorVelocity = boat.CFrame.LookVector * 250 end)
                                    task.wait(0.0001)
                                end
                            end
                            
                            if activeTween then activeTween:Cancel() end
                            freezeY = nil
                            pcall(function()
                                SetVelocity(boat, false)
                                boat.CFrame = CFrame.new(boat.Position.X, 28, boat.Position.Z)
                            end)
                        end
                    end
                    task.wait(0.000001)
                end
            end)
        else
            if activeTween then activeTween:Cancel() end
            freezeY = nil
            pcall(function()
                local hum = LP.Character:FindFirstChild("Humanoid")
                if hum and hum.SeatPart then
                    local boat = hum.SeatPart.Parent.PrimaryPart
                    SetVelocity(boat, false)
                    boat.CFrame = CFrame.new(boat.Position.X, 28, boat.Position.Z)
                end
            end)
        end
    end)
end

RS.Stepped:Connect(function()
    if _G.Auto and freezeY and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.Velocity = Vector3.new(LP.Character.HumanoidRootPart.Velocity.X, 0, LP.Character.HumanoidRootPart.Velocity.Z)
        pcall(function()
            local boat = LP.Character.Humanoid.SeatPart.Parent.PrimaryPart
            boat.Velocity = Vector3.new(boat.Velocity.X, 0, boat.Velocity.Z)
        end)
    end
end)
Tabs.HuntLeviathan:AddToggle("LeviathanToggle", {
    Title = "Attack Leviathan",
    Default = false,
    Callback = function(Value)
        _G.AutoLeviathan = Value
        if Value then
            StartLeviathanFix()
        end
    end
})
Tabs.SettingHunt:AddDropdown("MeleeSkills", {
    Title = "Melee Skills",
    Values = {"Z", "X", "C", "V"},
    Default = {"Z", "X", "C", "V"},
    Multi = true,
    Callback = function(Value) _G.MeleeSkills = Value end
})

Tabs.SettingHunt:AddDropdown("FruitSkills", {
    Title = "Blox Fruit Skills",
    Values = {"Z", "X", "C", "V", "F"},
    Default = {"Z", "X", "C", "V", "F"},
    Multi = true,
    Callback = function(Value) _G.FruitSkills = Value end
})

Tabs.SettingHunt:AddDropdown("SwordSkills", {
    Title = "Sword Skills",
    Values = {"Z", "X"},
    Default = {"Z", "X"},
    Multi = true,
    Callback = function(Value) _G.SwordSkills = Value end
})

Tabs.SettingHunt:AddDropdown("GunSkills", {
    Title = "Gun Skills",
    Values = {"Z", "X"},
    Default = {"Z", "X"},
    Multi = true,
    Callback = function(Value) _G.GunSkills = Value end
})

Window:SelectTab(1)