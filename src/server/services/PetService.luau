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

PetService.MAX_EQUIPPED_PETS = 5
PetService.SLOT_UNLOCK_LEVELS = { 5, 10, 15, 20, 30 }

local FOLLOW_OFFSETS = {
    Vector3.new(3.5, 0.4, 3.5),
    Vector3.new(-3.5, 0.4, 3.5),
    Vector3.new(0, 0.4, 5.5),
    Vector3.new(5.2, 0.4, 6.0),
    Vector3.new(-5.2, 0.4, 6.0),
}

export type PlayerPetData = {
    assignedPlot: number,
    currentPetId: string,
    equippedPets: {string},
    equippedGearId: string?,
    gearPowerBonus: number,
    playerLevel: number,
    playerExp: number,
    playerMaxExp: number,
    level: number,
    exp: number,
    maxExp: number,
    power: number,
    isLeashed: boolean,
    model: Model?,
    models: {Model},
}

local playerData: {[Player]: PlayerPetData} = {}

function PetService.GetPlayerMaxExp(playerLevel: number): number
    return 80 + (math.max(1, playerLevel) - 1) * 40
end

-- Mốc Level Người Chơi mở khóa số Pet được dẫn (tối đa 5 Pet: Lv.5 -> 2, Lv.10 -> 3, Lv.15 -> 4, Lv.20 -> 5; Lv.30 -> Buff +25% Power)
function PetService.GetMaxPetSlots(playerLevel: number): number
    if playerLevel >= 20 then
        return 5
    elseif playerLevel >= 15 then
        return 4
    elseif playerLevel >= 10 then
        return 3
    elseif playerLevel >= 5 then
        return 2
    end
    return 1
end

function PetService.GetNextMilestoneLevel(playerLevel: number): number?
    for _, lv in ipairs(PetService.SLOT_UNLOCK_LEVELS) do
        if playerLevel < lv then
            return lv
        end
    end
    return nil
end

local function computeTeamPower(equippedPets: {string}, level: number, gearBonus: number?, playerLevel: number?): number
    local total = 0
    for _, petId in ipairs(equippedPets) do
        local def = PetConfig.Pets[petId] or PetConfig.Pets.Shiba
        total += (def.BasePower or 10) + (level - 1) * (def.PowerPerLevel or 5)
    end
    local withGear = total + (gearBonus or 0)
    -- Mốc Lv.30: Hào Quang Khuyển Vương +25% tổng Sức Mạnh
    if (playerLevel or 1) >= 30 then
        withGear = math.floor(withGear * 1.25)
    end
    return math.max(10, withGear)
end

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

-- Bật/tắt dây dắt thú cưng (Leash Beam cho cả đội tối đa 3 con)
function PetService.SetPetLeash(player: Player, isEnabled: boolean)
    local pData = playerData[player]
    if not pData then return end

    local activeModels = pData.models
    if (not activeModels or #activeModels == 0) and pData.model then
        activeModels = { pData.model }
    end
    if not activeModels or #activeModels == 0 then return end

    local char = player.Character
    if not char then return end

    local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") or char:FindFirstChild("HumanoidRootPart")

    for _, pet in ipairs(activeModels) do
        if pet and pet.Parent then
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
            end
        end
    end

    pData.isLeashed = isEnabled
end

-- Sinh 1 thú cưng đi theo chủ tại vị trí đội hình slotIndex (1..3)
function PetService.SpawnPlayerPet(player: Player, petId: string?, slotIndex: number?): Model?
    local pData = playerData[player]
    local targetId = petId or (pData and pData.currentPetId) or "Shiba"
    local slot = slotIndex or 1
    local offset = FOLLOW_OFFSETS[slot] or FOLLOW_OFFSETS[1]
    local petDef = PetConfig.Pets[targetId]
    local templateName = (petDef and petDef.ModelTemplate) or targetId
    local template = PetModels:FindFirstChild(templateName) or PetModels:FindFirstChild(targetId) or PetModels:FindFirstChild("Shiba")
    if not template or not template:IsA("Model") then return nil end

    local pet = template:Clone()
    pet.Name = string.format("%s_Pet_%d", player.Name, slot)
    
    local body = pet.PrimaryPart
    if not body then return nil end
    
    body.Anchored = false
    body.CanCollide = false
    pet.Parent = PetsFolder

    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    pet:PivotTo(root.CFrame * CFrame.new(offset.X, offset.Y + 0.1, offset.Z))

    local a0 = Instance.new("Attachment")
    a0.Parent = body

    local attName = "PetTargetAttachment_" .. tostring(slot)
    local a1 = root:FindFirstChild(attName) or Instance.new("Attachment")
    a1.Name = attName
    if a1:IsA("Attachment") then
        a1.Position = offset
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

-- Hủy toàn bộ model cũ và sinh lại cả đội hình (tối đa 3 con) đi theo chủ
function PetService.SpawnEquippedPets(player: Player): {Model}
    local pData = playerData[player]
    if not pData then return {} end

    for _, m in ipairs(pData.models) do
        if m and m.Parent then
            m:Destroy()
        end
    end
    pData.models = {}
    pData.model = nil

    for idx, petId in ipairs(pData.equippedPets) do
        if idx > PetService.GetMaxPetSlots(pData.playerLevel) then
            break
        end
        local pet = PetService.SpawnPlayerPet(player, petId, idx)
        if pet then
            table.insert(pData.models, pet)
            if idx == 1 then
                pData.model = pet
                PetService.UpdatePetTag(pet, pData)
            end
        end
    end

    PetService.SetPetLeash(player, pData.isLeashed)
    return pData.models
end

function PetService.InitPlayerData(player: Player, assignedPlot: number, saved: {[string]: any}?): PlayerPetData
    local savedPetId = (saved and type(saved.currentPetId) == "string" and PetConfig.Pets[saved.currentPetId]) and saved.currentPetId or "Shiba"
    local savedLevel = (saved and tonumber(saved.level) and math.max(1, math.floor(tonumber(saved.level) :: number))) or 1
    local savedExp = (saved and tonumber(saved.exp) and math.max(0, math.floor(tonumber(saved.exp) :: number))) or 0
    local savedPlayerLevel = (saved and tonumber(saved.playerLevel) and math.max(1, math.floor(tonumber(saved.playerLevel) :: number))) or 1
    local savedPlayerExp = (saved and tonumber(saved.playerExp) and math.max(0, math.floor(tonumber(saved.playerExp) :: number))) or 0
    local maxSlots = PetService.GetMaxPetSlots(savedPlayerLevel)

    local equipped: {string} = {}
    if saved and type(saved.equippedPets) == "table" then
        for _, id in ipairs(saved.equippedPets) do
            if type(id) == "string" and PetConfig.Pets[id] and not table.find(equipped, id) and #equipped < maxSlots then
                table.insert(equipped, id)
            end
        end
    end
    if #equipped == 0 then
        table.insert(equipped, savedPetId)
    end
    savedPetId = equipped[1]

    local savedGearId = (saved and type(saved.equippedGearId) == "string") and saved.equippedGearId or nil
    local savedGearBonus = (saved and tonumber(saved.gearPowerBonus) and math.max(0, math.floor(tonumber(saved.gearPowerBonus) :: number))) or 0
    local computedPower = computeTeamPower(equipped, savedLevel, savedGearBonus, savedPlayerLevel)
    local savedLeashed = if saved and type(saved.isLeashed) == "boolean" then saved.isLeashed else true

    local data: PlayerPetData = {
        assignedPlot = assignedPlot,
        currentPetId = savedPetId,
        equippedPets = equipped,
        equippedGearId = savedGearId,
        gearPowerBonus = savedGearBonus,
        playerLevel = savedPlayerLevel,
        playerExp = savedPlayerExp,
        playerMaxExp = PetService.GetPlayerMaxExp(savedPlayerLevel),
        level = savedLevel,
        exp = savedExp,
        maxExp = PetConfig.GetMaxExp(savedLevel),
        power = computedPower,
        isLeashed = savedLeashed,
        model = nil,
        models = {},
    }
    playerData[player] = data
    return data
end

function PetService.GetPlayerData(player: Player): PlayerPetData?
    return playerData[player]
end

-- Cộng EXP & tăng cấp độ Người Chơi (mở khóa thêm slot Pet ở Lv.5, 10, 15, 20 và Buff +25% ở Lv.30)
function PetService.AddPlayerExp(player: Player, amount: number): boolean
    local pData = playerData[player]
    if not pData or amount <= 0 then return false end

    pData.playerExp = pData.playerExp + math.floor(amount)
    local leveledUp = false
    while pData.playerExp >= pData.playerMaxExp do
        pData.playerExp = pData.playerExp - pData.playerMaxExp
        pData.playerLevel = pData.playerLevel + 1
        pData.playerMaxExp = PetService.GetPlayerMaxExp(pData.playerLevel)
        leveledUp = true
    end

    if leveledUp then
        pData.power = computeTeamPower(pData.equippedPets, pData.level, pData.gearPowerBonus, pData.playerLevel)
        if pData.model then
            PetService.UpdatePetTag(pData.model, pData)
        end
    end

    return leveledUp
end

function PetService.AddExp(player: Player, amount: number): boolean
    local pData = playerData[player]
    if not pData then return false end

    pData.exp = pData.exp + amount
    -- Hoạt động nuôi pet cũng cộng 60% EXP cho Level Người Chơi
    PetService.AddPlayerExp(player, math.max(1, math.floor(amount * 0.6)))

    local leveledUp = false
    while pData.exp >= pData.maxExp do
        pData.exp = pData.exp - pData.maxExp
        pData.level = pData.level + 1
        pData.maxExp = PetConfig.GetMaxExp(pData.level)
        leveledUp = true
    end

    if leveledUp then
        pData.power = computeTeamPower(pData.equippedPets, pData.level, pData.gearPowerBonus, pData.playerLevel)
        for _, m in ipairs(pData.models) do
            if m and m.Parent then
                PetService.SpawnLevelUpEffect(m)
            end
        end
    end
    if pData.model then
        PetService.UpdatePetTag(pData.model, pData)
    end

    return leveledUp
end

-- Thêm / gỡ thú cưng trong đội hình (giới hạn theo Level Người Chơi: 1 -> 5 Pet ở Lv.5/10/15/20)
function PetService.EquipPet(player: Player, petId: string): boolean
    local pData = playerData[player]
    if not pData then return false end

    local petDef = PetConfig.Pets[petId]
    if not petDef then return false end

    local maxSlots = PetService.GetMaxPetSlots(pData.playerLevel)
    local existingIdx = table.find(pData.equippedPets, petId)
    if existingIdx then
        if #pData.equippedPets > 1 then
            table.remove(pData.equippedPets, existingIdx)
        else
            return true
        end
    else
        if #pData.equippedPets < maxSlots then
            table.insert(pData.equippedPets, petId)
        else
            pData.equippedPets[maxSlots] = petId
        end
    end

    pData.currentPetId = pData.equippedPets[1]
    pData.power = computeTeamPower(pData.equippedPets, pData.level, pData.gearPowerBonus, pData.playerLevel)
    PetService.SpawnEquippedPets(player)
    return true
end

-- Đeo / tháo Trang Bị tăng Sức Mạnh cho đội hình Pet
function PetService.EquipGear(player: Player, gearId: string, powerBonus: number): (boolean, string?)
    local pData = playerData[player]
    if not pData then return false, nil end

    if pData.equippedGearId == gearId then
        pData.equippedGearId = nil
        pData.gearPowerBonus = 0
    else
        pData.equippedGearId = gearId
        pData.gearPowerBonus = math.max(0, math.floor(powerBonus))
    end

    pData.power = computeTeamPower(pData.equippedPets, pData.level, pData.gearPowerBonus, pData.playerLevel)
    if pData.model then
        PetService.UpdatePetTag(pData.model, pData)
    end
    return true, pData.equippedGearId
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
        playerLevel = pData.playerLevel,
        playerExp = pData.playerExp,
        playerMaxExp = pData.playerMaxExp,
        power = pData.power,
        expPerFeed = petDef.ExpPerFeed or 25,
        rarity = petDef.Rarity,
        icon = petDef.Icon,
        equippedPets = pData.equippedPets,
        maxEquipped = PetService.GetMaxPetSlots(pData.playerLevel),
        nextSlotUnlockLevel = PetService.GetNextMilestoneLevel(pData.playerLevel),
        equippedGearId = pData.equippedGearId,
        gearPowerBonus = pData.gearPowerBonus,
    }
end

function PetService.CleanPlayer(player: Player)
    local pData = playerData[player]
    if pData then
        for _, m in ipairs(pData.models) do
            if m and m.Parent then
                m:Destroy()
            end
        end
        if pData.model and pData.model.Parent then
            pData.model:Destroy()
        end
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
