--!strict
-- PetService.luau: Quản lý toàn bộ vòng đời thú cưng đồng hành của người chơi
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ConfigFolder = Modules:FindFirstChild("Config") or Modules
local PetConfig = require(ConfigFolder:WaitForChild("PetConfig"))

local PetModels = ReplicatedStorage:WaitForChild("PetModels")
local PetsFolder = workspace:FindFirstChild("Pets") or Instance.new("Folder", workspace)
PetsFolder.Name = "Pets"

local PetService = {}

export type PlayerPetData = {
    assignedPlot: number,
    currentPetId: string,
    level: number,
    exp: number,
    maxExp: number,
    power: number,
    isLeashed: boolean,
    model: Model?,
}

local playerData: {[Player]: PlayerPetData} = {}

-- Tạo hiệu ứng thức ăn Particle khi cho ăn
function PetService.SpawnFoodEffect(petModel: Model)
    local snout = petModel:FindFirstChild("Snout") or petModel.PrimaryPart
    if not snout then return end

    local pe = Instance.new("ParticleEmitter")
    pe.Rate = 25
    pe.Speed = NumberRange.new(2, 4)
    pe.Lifetime = NumberRange.new(0.4, 0.7)
    pe.SpreadAngle = Vector2.new(60, 60)
    pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0.1)})
    pe.Color = ColorSequence.new(Color3.fromRGB(180, 110, 50), Color3.fromRGB(255, 200, 100))
    pe.Parent = snout
    
    task.delay(0.3, function()
        pe.Enabled = false
        task.wait(1)
        pe:Destroy()
    end)
end

-- Tạo hiệu ứng cột sáng Neon và Particle khi thăng cấp (Level Up)
function PetService.SpawnLevelUpEffect(petModel: Model)
    local body = petModel.PrimaryPart
    if not body then return end

    local beam = Instance.new("Part")
    beam.Name = "LevelUpBeam"
    beam.Shape = Enum.PartType.Cylinder
    beam.Size = Vector3.new(22, 5, 5)
    beam.CFrame = body.CFrame * CFrame.Angles(0, 0, math.rad(90))
    beam.Color = Color3.fromRGB(255, 235, 90)
    beam.Material = Enum.Material.Neon
    beam.Transparency = 0.3
    beam.Anchored = true
    beam.CanCollide = false
    beam.Parent = petModel

    local pe = Instance.new("ParticleEmitter")
    pe.Rate = 50
    pe.Speed = NumberRange.new(6, 14)
    pe.Lifetime = NumberRange.new(0.8, 1.5)
    pe.SpreadAngle = Vector2.new(180, 180)
    pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(1, 0)})
    pe.Color = ColorSequence.new(Color3.fromRGB(255, 255, 160), Color3.fromRGB(255, 140, 40))
    pe.LightEmission = 1
    pe.Parent = body

    task.delay(1.2, function()
        pe.Enabled = false
        for i = 0.3, 1, 0.1 do
            beam.Transparency = i
            task.wait(0.05)
        end
        beam:Destroy()
        pe:Destroy()
    end)
end

-- Cập nhật biển tên BillboardGui trên đầu cún cưng
function PetService.UpdatePetTag(petModel: Model, pData: PlayerPetData)
    local head = petModel:FindFirstChild("Head") or petModel.PrimaryPart
    if not head then return end

    local bb = head:FindFirstChild("PetTag")
    if not bb then
        local newBb = Instance.new("BillboardGui")
        newBb.Name = "PetTag"
        newBb.Size = UDim2.new(0, 130, 0, 40)
        newBb.StudsOffset = Vector3.new(0, 2.5, 0)
        newBb.AlwaysOnTop = true
        newBb.Adornee = head
        newBb.Parent = head

        local bg = Instance.new("Frame")
        bg.Name = "Frame"
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
        bg.BackgroundTransparency = 0.2
        bg.Parent = newBb
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = bg

        local nLbl = Instance.new("TextLabel")
        nLbl.Name = "NameLabel"
        nLbl.Size = UDim2.new(1, 0, 0.5, 0)
        nLbl.BackgroundTransparency = 1
        nLbl.TextColor3 = Color3.fromRGB(255, 215, 60)
        nLbl.Font = Enum.Font.FredokaOne
        nLbl.TextSize = 13
        nLbl.Parent = bg

        local lLbl = Instance.new("TextLabel")
        lLbl.Name = "LevelLabel"
        lLbl.Size = UDim2.new(1, 0, 0.5, 0)
        lLbl.Position = UDim2.new(0, 0, 0.5, 0)
        lLbl.BackgroundTransparency = 1
        lLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lLbl.Font = Enum.Font.GothamBold
        lLbl.TextSize = 11
        lLbl.Parent = bg
        bb = newBb
    end

    local f = bb:FindFirstChild("Frame")
    if f then
        local petDef = PetConfig.Pets[pData.currentPetId] or PetConfig.Pets.Shiba
        local rarityDef = PetConfig.Rarities[petDef.Rarity] or PetConfig.Rarities.Common
        
        local nLbl = f:FindFirstChild("NameLabel")
        if nLbl and nLbl:IsA("TextLabel") then
            nLbl.Text = petDef.Icon .. " " .. petDef.DisplayName
            nLbl.TextColor3 = rarityDef.Color
        end
        local lLbl = f:FindFirstChild("LevelLabel")
        if lLbl and lLbl:IsA("TextLabel") then
            lLbl.Text = string.format("Lv.%d • ⚔️ %d", pData.level, pData.power)
        end
    end
end

-- Bật/tắt dây dắt thú cưng (Leash Beam)
function PetService.SetPetLeash(player: Player, isEnabled: boolean)
    local pData = playerData[player]
    if not pData or not pData.model then return end
    
    local pet = pData.model
    local char = player.Character
    if not char then return end

    local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") or char:FindFirstChild("HumanoidRootPart")
    local collar = pet:FindFirstChild("Collar") or pet.PrimaryPart

    local existingBeam = pet:FindFirstChild("LeashBeam")
    if existingBeam then existingBeam:Destroy() end

    if isEnabled and hand and collar and hand:IsA("BasePart") and collar:IsA("BasePart") then
        local att0 = hand:FindFirstChild("LeashAttachment") or Instance.new("Attachment")
        att0.Name = "LeashAttachment"
        att0.Parent = hand

        local att1 = collar:FindFirstChild("LeashAttachment") or Instance.new("Attachment")
        att1.Name = "LeashAttachment"
        att1.Parent = collar

        local beam = Instance.new("Beam")
        beam.Name = "LeashBeam"
        beam.Attachment0 = att0 :: Attachment
        beam.Attachment1 = att1 :: Attachment
        beam.Width0 = 0.18
        beam.Width1 = 0.14
        beam.Color = ColorSequence.new(Color3.fromRGB(255, 85, 45), Color3.fromRGB(255, 180, 60))
        beam.Texture = "rbxassetid://1310706822"
        beam.TextureMode = Enum.TextureMode.Wrap
        beam.TextureLength = 2
        beam.TextureSpeed = 0
        beam.CurveSize0 = -1.2
        beam.CurveSize1 = 1.2
        beam.Parent = pet
        pData.isLeashed = true
    else
        pData.isLeashed = false
    end
end

-- Sinh thú cưng đi theo chủ (AlignPosition + AlignOrientation)
function PetService.SpawnPlayerPet(player: Player, petId: string?): Model?
    local pData = playerData[player]
    local targetId = petId or (pData and pData.currentPetId) or "Shiba"
    local template = PetModels:FindFirstChild(targetId) or PetModels:FindFirstChild("Shiba")
    if not template or not template:IsA("Model") then return nil end

    local pet = template:Clone()
    pet.Name = player.Name .. "_Pet"
    
    local body = pet.PrimaryPart
    if not body then return nil end
    
    body.Anchored = false
    body.CanCollide = false
    pet.Parent = PetsFolder

    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    pet:PivotTo(root.CFrame * CFrame.new(3.5, 0.5, 3.5))

    local a0 = Instance.new("Attachment")
    a0.Parent = body

    local a1 = root:FindFirstChild("PetTargetAttachment") or Instance.new("Attachment")
    a1.Name = "PetTargetAttachment"
    if a1:IsA("Attachment") then
        a1.Position = Vector3.new(3.5, 0.4, 3.5)
    end
    a1.Parent = root

    local alignPos = Instance.new("AlignPosition")
    alignPos.Attachment0 = a0
    alignPos.Attachment1 = a1 :: Attachment
    alignPos.MaxForce = 35000
    alignPos.Responsiveness = 22
    alignPos.Parent = pet

    local alignRot = Instance.new("AlignOrientation")
    alignRot.Attachment0 = a0
    alignRot.Attachment1 = a1 :: Attachment
    alignRot.MaxTorque = 35000
    alignRot.Responsiveness = 22
    alignRot.Parent = pet

    return pet
end

function PetService.InitPlayerData(player: Player, assignedPlot: number): PlayerPetData
    local data: PlayerPetData = {
        assignedPlot = assignedPlot,
        currentPetId = "Shiba",
        level = 1,
        exp = 0,
        maxExp = PetConfig.GetMaxExp(1),
        power = 10,
        isLeashed = true,
        model = nil
    }
    playerData[player] = data
    return data
end

function PetService.GetPlayerData(player: Player): PlayerPetData?
    return playerData[player]
end

function PetService.AddExp(player: Player, amount: number): boolean
    local pData = playerData[player]
    if not pData then return false end

    local petDef = PetConfig.Pets[pData.currentPetId] or PetConfig.Pets.Shiba
    pData.exp = pData.exp + amount

    local leveledUp = false
    while pData.exp >= pData.maxExp do
        pData.exp = pData.exp - pData.maxExp
        pData.level = pData.level + 1
        pData.maxExp = PetConfig.GetMaxExp(pData.level)
        pData.power = pData.power + (petDef.PowerPerLevel or 5)
        leveledUp = true
    end

    if leveledUp and pData.model then
        PetService.SpawnLevelUpEffect(pData.model)
    end
    if pData.model then
        PetService.UpdatePetTag(pData.model, pData)
    end

    return leveledUp
end

function PetService.EquipPet(player: Player, petId: string): boolean
    local pData = playerData[player]
    if not pData then return false end

    local petDef = PetConfig.Pets[petId]
    if not petDef then return false end

    pData.currentPetId = petId
    pData.power = petDef.BasePower + (pData.level - 1) * petDef.PowerPerLevel

    if pData.model then
        pData.model:Destroy()
    end

    local newModel = PetService.SpawnPlayerPet(player, petId)
    pData.model = newModel
    if newModel then
        PetService.UpdatePetTag(newModel, pData)
    end
    PetService.SetPetLeash(player, pData.isLeashed)
    return true
end

function PetService.GetPetPayload(player: Player)
    local pData = playerData[player]
    if not pData then return nil end
    local petDef = PetConfig.Pets[pData.currentPetId] or PetConfig.Pets.Shiba
    return {
        name = petDef.DisplayName,
        level = pData.level,
        exp = pData.exp,
        maxExp = pData.maxExp,
        power = pData.power,
        rarity = petDef.Rarity,
        icon = petDef.Icon
    }
end

function PetService.CleanPlayer(player: Player)
    local pData = playerData[player]
    if pData and pData.model then
        pData.model:Destroy()
    end
    playerData[player] = nil
end

-- Vòng lặp dắt chó đi dạo: tích lũy EXP khi di chuyển
function PetService.StartWalkingLoop(onUpdateCallback: (Player, any) -> ())
    task.spawn(function()
        while true do
            task.wait(3.5)
            for player, pData in pairs(playerData) do
                if player.Character and pData.model and pData.model.PrimaryPart then
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    if hum and root and hum.MoveDirection.Magnitude > 0.1 then
                        local bonusExp = pData.isLeashed and 15 or 8
                        local leveledUp = PetService.AddExp(player, bonusExp)
                        if onUpdateCallback then
                            onUpdateCallback(player, PetService.GetPetPayload(player))
                        end
                    end
                end
            end
        end
    end)
end

return PetService
