local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Events = ReplicatedStorage:WaitForChild("Events")
local FeedEvent = Events:WaitForChild("FeedPet")
local UpdateEvent = Events:WaitForChild("UpdatePetData")
local UseItemEvent = Events:WaitForChild("UseItem")
local ToggleLeashEvent = Events:WaitForChild("ToggleLeash")
local InvUpdateEvent = Events:WaitForChild("UpdateInventory")
local RollGachaEvent = Events:WaitForChild("RollGacha")
local GachaResultEvent = Events:WaitForChild("GachaResult")
local EquipPetEvent = Events:WaitForChild("EquipPet")
local UpdateCollectionEvent = Events:WaitForChild("UpdatePetCollection")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local PetConfig = require(Modules:WaitForChild("PetConfig"))
local PetModels = ReplicatedStorage:WaitForChild("PetModels")
local PetsFolder = workspace:FindFirstChild("Pets") or Instance.new("Folder", workspace)
PetsFolder.Name = "Pets"

local playerData = {}
local cooldowns = {}

-- Kho đồ mẫu khởi đầu cho mỗi người chơi
local defaultInventory = {
    { id = "meat", name = "Thịt tươi", icon = "🥩", count = 5, exp = 50, desc = "+50 EXP thơm ngon" },
    { id = "bone", name = "Khúc xương", icon = "🦴", count = 10, exp = 25, desc = "+25 EXP yêu thích" },
    { id = "cookie", name = "Bánh thưởng", icon = "🍪", count = 15, exp = 15, desc = "+15 EXP snack" },
    { id = "toy", name = "Quả bóng", icon = "🎾", count = 1, exp = 30, desc = "+30 EXP vui chơi" }
}

local function cloneInventory()
    local t = {}
    for _, item in ipairs(defaultInventory) do
        table.insert(t, { id = item.id, name = item.name, icon = item.icon, count = item.count, exp = item.exp, desc = item.desc })
    end
    return t
end

-- Hiệu ứng thức ăn
local function spawnFoodEffect(petModel)
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

-- Hiệu ứng Level Up
local function spawnLevelUpEffect(petModel)
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

local function updatePetTag(petModel, pData)
    local head = petModel:FindFirstChild("Head") or petModel.PrimaryPart
    if not head then return end

    local bb = head:FindFirstChild("PetTag")
    if not bb then
        bb = Instance.new("BillboardGui")
        bb.Name = "PetTag"
        bb.Size = UDim2.new(0, 130, 0, 40)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = head
        bb.Parent = head

        local bg = Instance.new("Frame")
        bg.Name = "Frame"
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
        bg.BackgroundTransparency = 0.2
        bg.Parent = bb
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
    end

    local f = bb:FindFirstChild("Frame")
    if f then
        local petDef = PetConfig.Pets[pData.currentPetId] or PetConfig.Pets.Shiba
        local rarityDef = PetConfig.Rarities[petDef.Rarity] or PetConfig.Rarities.Common
        
        local nLbl = f:FindFirstChild("NameLabel")
        if nLbl then
            nLbl.Text = petDef.Icon .. " " .. petDef.DisplayName
            nLbl.TextColor3 = rarityDef.Color
        end
        local lLbl = f:FindFirstChild("LevelLabel")
        if lLbl then
            lLbl.Text = string.format("Lv.%d • ⚔️ %d", pData.level, pData.power)
        end
    end
end

-- DÂY DẮT CHÓ (LEASH BEAM)
local function setPetLeash(player, isEnabled)
    local pData = playerData[player]
    if not pData or not pData.model then return end
    
    local pet = pData.model
    local char = player.Character
    if not char then return end

    local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") or char:FindFirstChild("HumanoidRootPart")
    local collar = pet:FindFirstChild("Collar") or pet.PrimaryPart

    local existingBeam = pet:FindFirstChild("LeashBeam")
    if existingBeam then existingBeam:Destroy() end

    if isEnabled and hand and collar then
        local att0 = hand:FindFirstChild("LeashAttachment") or Instance.new("Attachment")
        att0.Name = "LeashAttachment"
        att0.Parent = hand

        local att1 = collar:FindFirstChild("LeashAttachment") or Instance.new("Attachment")
        att1.Name = "LeashAttachment"
        att1.Parent = collar

        local beam = Instance.new("Beam")
        beam.Name = "LeashBeam"
        beam.Attachment0 = att0
        beam.Attachment1 = att1
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

-- Spawn Pet Đồng Hành
local function spawnPlayerPet(player, petId)
    petId = petId or (playerData[player] and playerData[player].currentPetId) or "Shiba"
    local template = PetModels:FindFirstChild(petId) or PetModels:FindFirstChild("Shiba")
    if not template then return nil end

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
    a1.Position = Vector3.new(3.5, 0.4, 3.5)
    a1.Parent = root

    local alignPos = Instance.new("AlignPosition")
    alignPos.Attachment0 = a0
    alignPos.Attachment1 = a1
    alignPos.MaxForce = 35000
    alignPos.Responsiveness = 22
    alignPos.Parent = pet

    local alignRot = Instance.new("AlignOrientation")
    alignRot.Attachment0 = a0
    alignRot.Attachment1 = a1
    alignRot.MaxTorque = 35000
    alignRot.Responsiveness = 22
    alignRot.Parent = pet

    return pet
end

-- Khởi tạo người chơi mới
-- QUẢN LÝ 6 CHUỒNG NGƯỜI CHƠI (6 PLAYER PLOTS)
local playerPlots = {}
local plotOwners = {}

local function getAvailablePlot()
    for id = 1, 6 do
        if not plotOwners[id] then
            return id
        end
    end
    return 1
end

local function assignPlot(player)
    local plotId = getAvailablePlot()
    playerPlots[player] = plotId
    plotOwners[plotId] = player

    local gameMap = workspace:FindFirstChild("GameMap")
    local plotsFolder = gameMap and gameMap:FindFirstChild("PlayerPlots")
    if plotsFolder then
        local pModel = plotsFolder:FindFirstChild("Plot_" .. plotId)
        if pModel then
            local sign = pModel:FindFirstChild("PlotSign", true)
            if sign then
                local sf = sign:FindFirstChild("Frame")
                if sf then
                    local ownerLbl = sf:FindFirstChild("SignOwner")
                    if ownerLbl then
                        ownerLbl.Text = "👤 " .. player.DisplayName
                        ownerLbl.TextColor3 = Color3.fromRGB(255, 230, 80)
                    end
                end
            end
        end
    end
    return plotId
end

local function releasePlot(player)
    local plotId = playerPlots[player]
    if plotId then
        plotOwners[plotId] = nil
        playerPlots[player] = nil

        local gameMap = workspace:FindFirstChild("GameMap")
        local plotsFolder = gameMap and gameMap:FindFirstChild("PlayerPlots")
        if plotsFolder then
            local pModel = plotsFolder:FindFirstChild("Plot_" .. plotId)
            if pModel then
                local sign = pModel:FindFirstChild("PlotSign", true)
                if sign then
                    local sf = sign:FindFirstChild("Frame")
                    if sf then
                        local ownerLbl = sf:FindFirstChild("SignOwner")
                        if ownerLbl then
                            ownerLbl.Text = "[ Sẵn sàng đón chủ ]"
                            ownerLbl.TextColor3 = Color3.fromRGB(230, 235, 245)
                        end
                    end
                end
            end
        end
    end
end

local function onPlayerAdded(player)
    local assignedPlot = assignPlot(player)
    playerData[player] = {
        assignedPlot = assignedPlot,
        currentPetId = "Shiba",
        ownedPets = {"Shiba"},
        level = 1,
        exp = 0,
        maxExp = PetConfig.GetMaxExp(1),
        power = 10,
        isLeashed = true,
        inventory = cloneInventory(),
        model = nil
    }

    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local gameMap = workspace:FindFirstChild("GameMap")
        local plotsFolder = gameMap and gameMap:FindFirstChild("PlayerPlots")
        if plotsFolder and playerData[player].assignedPlot then
            local pModel = plotsFolder:FindFirstChild("Plot_" .. playerData[player].assignedPlot)
            local pSpawn = pModel and pModel:FindFirstChild("PlotSpawn")
            if pSpawn and char:FindFirstChild("HumanoidRootPart") then
                char:PivotTo(pSpawn.CFrame + Vector3.new(0, 3, 0))
            end
        end
        if playerData[player].model then
            playerData[player].model:Destroy()
        end
        local pet = spawnPlayerPet(player, playerData[player].currentPetId)
        playerData[player].model = pet
        updatePetTag(pet, playerData[player])
        setPetLeash(player, playerData[player].isLeashed)

        local pDef = PetConfig.Pets[playerData[player].currentPetId] or PetConfig.Pets.Shiba
        UpdateEvent:FireClient(player, {
            name = pDef.DisplayName,
            level = playerData[player].level,
            exp = playerData[player].exp,
            maxExp = playerData[player].maxExp,
            power = playerData[player].power,
            rarity = pDef.Rarity,
            icon = pDef.Icon
        })
        InvUpdateEvent:FireClient(player, playerData[player].inventory)
        UpdateCollectionEvent:FireClient(player, playerData[player].ownedPets)
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in ipairs(Players:GetPlayers()) do
    onPlayerAdded(p)
end

Players.PlayerRemoving:Connect(function(player)
    releasePlot(player)
    if playerData[player] and playerData[player].model then
        playerData[player].model:Destroy()
    end
    playerData[player] = nil
    cooldowns[player] = nil
end)

-- 1. Xử lý Cho ăn nhanh (FeedPet)
FeedEvent.OnServerEvent:Connect(function(player)
    local now = os.clock()
    if cooldowns[player] and (now - cooldowns[player]) < 0.3 then return end
    cooldowns[player] = now

    local pData = playerData[player]
    if not pData or not pData.model then return end

    local petDef = PetConfig.Pets[pData.currentPetId] or PetConfig.Pets.Shiba
    local addExp = petDef.ExpPerFeed or 25
    pData.exp = pData.exp + addExp

    spawnFoodEffect(pData.model)

    local leveledUp = false
    while pData.exp >= pData.maxExp do
        pData.exp = pData.exp - pData.maxExp
        pData.level = pData.level + 1
        pData.maxExp = PetConfig.GetMaxExp(pData.level)
        pData.power = pData.power + (petDef.PowerPerLevel or 5)
        leveledUp = true
    end

    if leveledUp then
        spawnLevelUpEffect(pData.model)
    end
    updatePetTag(pData.model, pData)

    UpdateEvent:FireClient(player, {
        name = petDef.DisplayName,
        level = pData.level,
        exp = pData.exp,
        maxExp = pData.maxExp,
        power = pData.power,
        rarity = petDef.Rarity,
        icon = petDef.Icon
    })
end)

-- 2. Xử lý Sử dụng vật phẩm từ Túi Đồ (UseItem)
UseItemEvent.OnServerEvent:Connect(function(player, itemId)
    local pData = playerData[player]
    if not pData or not pData.model then return end

    local targetItem = nil
    for _, it in ipairs(pData.inventory) do
        if it.id == itemId then
            targetItem = it
            break
        end
    end

    if targetItem and targetItem.count > 0 then
        targetItem.count = targetItem.count - 1
        local petDef = PetConfig.Pets[pData.currentPetId] or PetConfig.Pets.Shiba
        pData.exp = pData.exp + targetItem.exp

        spawnFoodEffect(pData.model)

        local leveledUp = false
        while pData.exp >= pData.maxExp do
            pData.exp = pData.exp - pData.maxExp
            pData.level = pData.level + 1
            pData.maxExp = PetConfig.GetMaxExp(pData.level)
            pData.power = pData.power + (petDef.PowerPerLevel or 5)
            leveledUp = true
        end

        if leveledUp then
            spawnLevelUpEffect(pData.model)
        end
        updatePetTag(pData.model, pData)

        UpdateEvent:FireClient(player, {
            name = petDef.DisplayName,
            level = pData.level,
            exp = pData.exp,
            maxExp = pData.maxExp,
            power = pData.power,
            rarity = petDef.Rarity,
            icon = petDef.Icon
        })
        InvUpdateEvent:FireClient(player, pData.inventory)
    end
end)

-- 3. Xử lý Bật/Tắt Dây Dắt (ToggleLeash)
ToggleLeashEvent.OnServerEvent:Connect(function(player)
    local pData = playerData[player]
    if not pData then return end
    pData.isLeashed = not pData.isLeashed
    setPetLeash(player, pData.isLeashed)
end)

-- 4. XỬ LÝ QUAY GACHA (RollGacha)
RollGachaEvent.OnServerEvent:Connect(function(player, rollCount)
    local pData = playerData[player]
    if not pData then return end

    rollCount = (rollCount == 5) and 5 or 1
    local results = {}

    for i = 1, rollCount do
        local petId, petDef, rarityDef = PetConfig.RollPet()
        table.insert(results, {
            id = petId,
            name = petDef.DisplayName,
            icon = petDef.Icon,
            rarity = petDef.Rarity,
            rarityName = rarityDef.Name,
            rarityColor = {rarityDef.Color.R, rarityDef.Color.G, rarityDef.Color.B},
            basePower = petDef.BasePower,
            expPerFeed = petDef.ExpPerFeed,
            desc = petDef.Description
        })

        if not table.find(pData.ownedPets, petId) then
            table.insert(pData.ownedPets, petId)
        end
    end

    GachaResultEvent:FireClient(player, results)
    UpdateCollectionEvent:FireClient(player, pData.ownedPets)
end)

-- 5. XỬ LÝ TRANG BỊ PET (EquipPet)
EquipPetEvent.OnServerEvent:Connect(function(player, petId)
    local pData = playerData[player]
    if not pData then return end

    local petDef = PetConfig.Pets[petId]
    if not petDef or not table.find(pData.ownedPets, petId) then return end

    pData.currentPetId = petId
    pData.power = petDef.BasePower + (pData.level - 1) * petDef.PowerPerLevel

    if pData.model then
        pData.model:Destroy()
    end

    local newModel = spawnPlayerPet(player, petId)
    pData.model = newModel
    updatePetTag(newModel, pData)
    setPetLeash(player, pData.isLeashed)

    UpdateEvent:FireClient(player, {
        name = petDef.DisplayName,
        level = pData.level,
        exp = pData.exp,
        maxExp = pData.maxExp,
        power = pData.power,
        rarity = petDef.Rarity,
        icon = petDef.Icon
    })
end)

-- VÒNG LẶP DẮT CHÓ ĐI DẠO CỘNG EXP & NHẶT XƯƠNG
task.spawn(function()
    while true do
        task.wait(3.5)
        for player, pData in pairs(playerData) do
            if player.Character and pData.model and pData.model.PrimaryPart then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.MoveDirection.Magnitude > 0.1 then
                    local bonusExp = pData.isLeashed and 15 or 8
                    pData.exp = pData.exp + bonusExp

                    local petDef = PetConfig.Pets[pData.currentPetId] or PetConfig.Pets.Shiba
                    local leveledUp = false
                    while pData.exp >= pData.maxExp do
                        pData.exp = pData.exp - pData.maxExp
                        pData.level = pData.level + 1
                        pData.maxExp = PetConfig.GetMaxExp(pData.level)
                        pData.power = pData.power + (petDef.PowerPerLevel or 5)
                        leveledUp = true
                    end

                    if leveledUp then
                        spawnLevelUpEffect(pData.model)
                    end
                    updatePetTag(pData.model, pData)

                    UpdateEvent:FireClient(player, {
                        name = petDef.DisplayName,
                        level = pData.level,
                        exp = pData.exp,
                        maxExp = pData.maxExp,
                        power = pData.power,
                        rarity = petDef.Rarity,
                        icon = petDef.Icon
                    })
                end
            end
        end
    end
end)
