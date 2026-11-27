--!strict
-- BattleService.luau: Quản lý Tổ Đội Co-op (tối đa 3 người), Đảo Map Ải riêng tách biệt & Chiến đấu Boss 3D
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ConfigFolder = Modules:FindFirstChild("Config") or Modules
local PetConfig = require(ConfigFolder:WaitForChild("PetConfig"))
local PetModels = ReplicatedStorage:WaitForChild("PetModels")

local BattleService = {}

BattleService.MAX_PARTY_SIZE = 3
BattleService.LOBBY_WAIT_SECONDS = 10

-- Cấu hình 5 Ải Đánh Quái / Boss Farm Xu (tăng độ khó + Boss Skill Nộ mỗi 3 lượt)
local BOSS_DATA = {
    stage1_pug = {
        name = "Ải 1: Pug Tập Sự",
        icon = "🐕",
        petModelId = "Pug",
        level = 1,
        power = 16,
        hp = 160,
        critChance = 0.15,
        rewardExp = 40,
        rewardPlayerExp = 45,
        rewardCoins = 40,
        drops = {
            { id = "gear_collar", chance = 5 },
            { id = "meat", chance = 8 },
            { id = "bone", chance = 28 },
        },
        color = Color3.fromRGB(34, 197, 94),
    },
    corgi_boss = {
        name = "Ải 2: Corgi Tốc Độ",
        icon = "🦊",
        petModelId = "Corgi",
        level = 5,
        power = 55,
        hp = 480,
        critChance = 0.20,
        rewardExp = 80,
        rewardPlayerExp = 90,
        rewardCoins = 100,
        drops = {
            { id = "gear_collar", chance = 5 },
            { id = "drumstick", chance = 10 },
            { id = "meat", chance = 28 },
        },
        color = Color3.fromRGB(245, 158, 11),
    },
    husky_boss = {
        name = "Ải 3: Husky Băng Giá",
        icon = "🐺",
        petModelId = "Husky",
        level = 10,
        power = 135,
        hp = 1250,
        critChance = 0.24,
        rewardExp = 200,
        rewardPlayerExp = 180,
        rewardCoins = 250,
        drops = {
            { id = "gacha_ticket", chance = 4 },
            { id = "gear_cape", chance = 5 },
            { id = "drumstick", chance = 26 },
        },
        color = Color3.fromRGB(6, 182, 212),
    },
    doberman_boss = {
        name = "Ải 4: Dũng Sĩ Doberman",
        icon = "⚡",
        petModelId = "Doberman",
        level = 15,
        power = 260,
        hp = 2600,
        critChance = 0.28,
        rewardExp = 360,
        rewardPlayerExp = 320,
        rewardCoins = 500,
        drops = {
            { id = "gear_armor", chance = 4 },
            { id = "gacha_ticket", chance = 6 },
            { id = "salmon", chance = 24 },
        },
        color = Color3.fromRGB(168, 85, 247),
    },
    tibetan_boss = {
        name = "Ải 5: Ngao Tây Tạng Vương",
        icon = "🦁",
        petModelId = "Shiba",
        level = 20,
        power = 450,
        hp = 5000,
        critChance = 0.32,
        rewardExp = 650,
        rewardPlayerExp = 550,
        rewardCoins = 1000,
        drops = {
            { id = "gear_crown", chance = 3 },
            { id = "gacha_ticket", chance = 7 },
            { id = "golden_bone", chance = 7 },
            { id = "salmon", chance = 28 },
        },
        color = Color3.fromRGB(239, 68, 68),
    },
}

-- Tọa độ Đảo Map Ải tách biệt (đặt xa hẳn khu chuồng chính để tạo cảm giác sang map riêng)
local STAGE_CENTER_POS = Vector3.new(1200, 64, 0)
local RED_CORNER_POS = STAGE_CENTER_POS + Vector3.new(-16, 2.2, 0)
local BLUE_CORNER_POS = STAGE_CENTER_POS + Vector3.new(16, 2.2, 0)
local ARENA_CENTER_POS = STAGE_CENTER_POS + Vector3.new(0, 2.2, 0)
local SPECTATOR_SPAWNS = {
    STAGE_CENTER_POS + Vector3.new(-22, 3.5, 16),
    STAGE_CENTER_POS + Vector3.new(-14, 3.5, 18),
    STAGE_CENTER_POS + Vector3.new(-28, 3.5, 12),
}

-- Trạng thái Đấu trường & Tổ đội Co-op
local arenaBusy = false
local activeBattleFolder: Folder? = nil
local battleSessionId = 0
local savedReturnCFrames: {[Player]: CFrame} = {}

type ActiveLobby = {
    id: number,
    host: Player,
    bossId: string,
    members: {Player},
    timeLeft: number,
    petService: any,
    networkEvents: any,
    coinService: any?,
    inventoryService: any?,
}

local currentLobby: ActiveLobby? = nil
local activeBattlers: {Player} = {}

-- Tự dựng Đảo Map Ải riêng trên workspace (1 lần duy nhất)
local function ensureStageMap(): Folder
    local existing = workspace:FindFirstChild("StageBattleIsland")
    if existing and existing:IsA("Folder") then
        return existing
    end

    local island = Instance.new("Folder")
    island.Name = "StageBattleIsland"
    island.Parent = workspace

    -- Sàn đấu chính
    local floor = Instance.new("Part")
    floor.Name = "ArenaFloor"
    floor.Size = Vector3.new(76, 4, 54)
    floor.Position = STAGE_CENTER_POS - Vector3.new(0, 2, 0)
    floor.Anchored = true
    floor.Material = Enum.Material.SmoothPlastic
    floor.Color = Color3.fromRGB(38, 44, 62)
    floor.Parent = island

    -- Viền sân phát sáng
    local rim = Instance.new("Part")
    rim.Name = "ArenaRim"
    rim.Size = Vector3.new(80, 1.5, 58)
    rim.Position = STAGE_CENTER_POS - Vector3.new(0, 3.5, 0)
    rim.Anchored = true
    rim.Material = Enum.Material.Neon
    rim.Color = Color3.fromRGB(255, 185, 65)
    rim.Parent = island

    -- Bệ Góc Đỏ (Đội hình Người chơi)
    local redPad = Instance.new("Part")
    redPad.Name = "RedCornerPad"
    redPad.Size = Vector3.new(14, 0.5, 18)
    redPad.Position = RED_CORNER_POS - Vector3.new(0, 1.9, 0)
    redPad.Anchored = true
    redPad.Material = Enum.Material.Neon
    redPad.Color = Color3.fromRGB(59, 130, 246)
    redPad.Transparency = 0.25
    redPad.Parent = island

    -- Bệ Góc Xanh (Boss)
    local bluePad = Instance.new("Part")
    bluePad.Name = "BlueCornerPad"
    bluePad.Size = Vector3.new(12, 0.5, 12)
    bluePad.Position = BLUE_CORNER_POS - Vector3.new(0, 1.9, 0)
    bluePad.Anchored = true
    bluePad.Material = Enum.Material.Neon
    bluePad.Color = Color3.fromRGB(239, 68, 68)
    bluePad.Transparency = 0.25
    bluePad.Parent = island

    -- Tường chắn vô hình quanh đảo chống rơi
    local walls = {
        { size = Vector3.new(76, 20, 2), pos = STAGE_CENTER_POS + Vector3.new(0, 10, 27) },
        { size = Vector3.new(76, 20, 2), pos = STAGE_CENTER_POS + Vector3.new(0, 10, -27) },
        { size = Vector3.new(2, 20, 54), pos = STAGE_CENTER_POS + Vector3.new(38, 10, 0) },
        { size = Vector3.new(2, 20, 54), pos = STAGE_CENTER_POS + Vector3.new(-38, 10, 0) },
    }
    for i, w in ipairs(walls) do
        local wall = Instance.new("Part")
        wall.Name = "Barrier_" .. tostring(i)
        wall.Size = w.size
        wall.Position = w.pos
        wall.Anchored = true
        wall.Transparency = 1
        wall.CanCollide = true
        wall.Parent = island
    end

    -- 4 Cột đèn trang trí ở 4 góc đảo
    local corners = {
        Vector3.new(-34, 8, -23),
        Vector3.new(34, 8, -23),
        Vector3.new(-34, 8, 23),
        Vector3.new(34, 8, 23),
    }
    for i, c in ipairs(corners) do
        local pillar = Instance.new("Part")
        pillar.Name = "Pillar_" .. tostring(i)
        pillar.Size = Vector3.new(3, 16, 3)
        pillar.Position = STAGE_CENTER_POS + c
        pillar.Anchored = true
        pillar.Material = Enum.Material.Marble
        pillar.Color = Color3.fromRGB(60, 68, 92)
        pillar.Parent = island

        local orb = Instance.new("Part")
        orb.Name = "Lantern_" .. tostring(i)
        orb.Shape = Enum.PartType.Ball
        orb.Size = Vector3.new(3.6, 3.6, 3.6)
        orb.Position = STAGE_CENTER_POS + c + Vector3.new(0, 9.5, 0)
        orb.Anchored = true
        orb.Material = Enum.Material.Neon
        orb.Color = Color3.fromRGB(255, 210, 95)
        orb.Parent = island

        local light = Instance.new("PointLight")
        light.Range = 55
        light.Brightness = 2
        light.Color = Color3.fromRGB(255, 230, 170)
        light.Parent = orb
    end

    return island
end

local function rollStageDrop(drops: {{id: string, chance: number}}?): string?
    if not drops then
        return nil
    end
    local roll = math.random() * 100
    local acc = 0
    for _, entry in ipairs(drops) do
        acc += entry.chance
        if roll <= acc then
            return entry.id
        end
    end
    return nil
end

local function teleportPlayerBack(player: Player)
    local retCf = savedReturnCFrames[player]
    savedReturnCFrames[player] = nil
    if player.Parent ~= Players or not player.Character then
        return
    end
    if retCf then
        player.Character:PivotTo(retCf)
    end
end

local function broadcastPartyUpdate(NetworkEvents: any, payload: {[string]: any})
    local events = NetworkEvents.Init()
    local PartyUpdateEvent = events["PartyUpdate"]
    if PartyUpdateEvent then
        PartyUpdateEvent:FireAllClients(payload)
    end
end

local function releaseArena(sessionId: number?)
    if sessionId ~= nil and sessionId ~= battleSessionId then
        return
    end
    for _, p in ipairs(activeBattlers) do
        teleportPlayerBack(p)
    end
    activeBattlers = {}
    if activeBattleFolder then
        activeBattleFolder:Destroy()
        activeBattleFolder = nil
    end
    arenaBusy = false
end

local function getAliveMembers(list: {Player}): {Player}
    local alive: {Player} = {}
    for _, p in ipairs(list) do
        if p.Parent == Players then
            table.insert(alive, p)
        end
    end
    return alive
end

-- Tạo bản sao mô hình thú cưng neo cố định cho Đấu trường
local function spawnBattleModel(petId: string, modelName: string, spawnCFrame: CFrame, parent: Instance): Model?
    local petDef = PetConfig.Pets[petId]
    local templateName = (petDef and petDef.ModelTemplate) or petId
    local template = PetModels:FindFirstChild(templateName) or PetModels:FindFirstChild(petId) or PetModels:FindFirstChild("Shiba")
    if not template or not template:IsA("Model") then
        return nil
    end

    local clone = template:Clone()
    clone.Name = modelName

    for _, desc in ipairs(clone:GetDescendants()) do
        if desc:IsA("AlignPosition") or desc:IsA("AlignOrientation") or desc:IsA("Beam") then
            desc:Destroy()
        end
    end

    local primary = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")
    if not primary then
        clone:Destroy()
        return nil
    end
    clone.PrimaryPart = primary

    for _, desc in ipairs(clone:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.CanCollide = false
            desc.Anchored = (desc == primary)
        end
    end

    clone.Parent = parent
    clone:PivotTo(spawnCFrame)
    return clone
end

-- Tạo bảng thanh máu 3D trên đầu Thú cưng
local function createHealthBar(parentPart: BasePart, nameText: string, maxHp: number, barColor: Color3): (BillboardGui, Frame, TextLabel)
    local bb = Instance.new("BillboardGui")
    bb.Name = "BattleHealthGui"
    bb.Size = UDim2.new(0, 175, 0, 48)
    bb.StudsOffset = Vector3.new(0, 4.8, 0)
    bb.AlwaysOnTop = true
    bb.Parent = parentPart

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = nameText
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.FredokaOne
    nameLabel.TextSize = 14
    nameLabel.Parent = bb
    local nStroke = Instance.new("UIStroke")
    nStroke.Color = Color3.fromRGB(0, 0, 0)
    nStroke.Thickness = 1.5
    nStroke.Parent = nameLabel

    local bgBar = Instance.new("Frame")
    bgBar.Size = UDim2.new(1, 0, 0, 15)
    bgBar.Position = UDim2.new(0, 0, 0, 21)
    bgBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    bgBar.BorderSizePixel = 0
    bgBar.Parent = bb
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = bgBar
    local bgStroke = Instance.new("UIStroke")
    bgStroke.Color = Color3.fromRGB(255, 255, 255)
    bgStroke.Thickness = 1
    bgStroke.Transparency = 0.5
    bgStroke.Parent = bgBar

    local fillBar = Instance.new("Frame")
    fillBar.Name = "HpFill"
    fillBar.Size = UDim2.new(1, 0, 1, 0)
    fillBar.BackgroundColor3 = barColor
    fillBar.BorderSizePixel = 0
    fillBar.Parent = bgBar
    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(1, 0)
    fCorner.Parent = fillBar

    local hpText = Instance.new("TextLabel")
    hpText.Size = UDim2.new(1, 0, 1, 0)
    hpText.BackgroundTransparency = 1
    hpText.Text = string.format("%d / %d", maxHp, maxHp)
    hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
    hpText.Font = Enum.Font.GothamBold
    hpText.TextSize = 10
    hpText.Parent = bgBar

    return bb, fillBar, hpText
end

-- Hiển thị số sát thương 3D nảy lên
local function spawnDamagePopup(atPos: Vector3, damage: number, isCrit: boolean, customPrefix: string?)
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 1, 1)
    part.Position = atPos + Vector3.new(math.random(-1, 1), 2, math.random(-1, 1))
    part.Transparency = 1
    part.CanCollide = false
    part.Anchored = true
    part.Parent = workspace

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 140, 0, 32)
    bb.AlwaysOnTop = true
    bb.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    if customPrefix then
        label.Text = string.format("%s -%d", customPrefix, damage)
    else
        label.Text = isCrit and string.format("CRIT! -%d ⚡", damage) or string.format("-%d 💥", damage)
    end
    label.TextColor3 = isCrit and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 60, 60)
    label.Font = Enum.Font.FredokaOne
    label.TextSize = isCrit and 22 or 17
    label.Parent = bb

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(40, 10, 10)
    stroke.Thickness = 2
    stroke.Parent = label

    TweenService:Create(part, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = part.Position + Vector3.new(0, 3.5, 0)
    }):Play()
    Debris:AddItem(part, 0.75)
end

-- Hiệu ứng pháo hoa ăn mừng chiến thắng
local function spawnVictoryConfetti(atPos: Vector3)
    local part = Instance.new("Part")
    part.Size = Vector3.new(2, 1, 2)
    part.Position = atPos
    part.Transparency = 1
    part.Anchored = true
    part.CanCollide = false
    part.Parent = workspace

    local pe = Instance.new("ParticleEmitter")
    pe.Rate = 120
    pe.Speed = NumberRange.new(12, 22)
    pe.Lifetime = NumberRange.new(1.2, 2.0)
    pe.SpreadAngle = Vector2.new(70, 70)
    pe.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 105, 180)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(50, 205, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 144, 255)),
    })
    pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.2)})
    pe.Parent = part
    pe:Emit(80)

    task.delay(2.5, function()
        if part.Parent then
            part:Destroy()
        end
    end)
end

-- Khởi chạy trận chiến Co-op trên Đảo Map Ải riêng cho toàn bộ tổ đội (1..3 người)
local function launchCoopBattle(lobby: ActiveLobby)
    local boss = BOSS_DATA[lobby.bossId]
    if not boss then
        return
    end

    local party = getAliveMembers(lobby.members)
    if #party == 0 then
        return
    end

    local PetService = lobby.petService
    local NetworkEvents = lobby.networkEvents
    local CoinService = lobby.coinService
    local InventoryService = lobby.inventoryService

    ensureStageMap()

    arenaBusy = true
    activeBattlers = party
    battleSessionId += 1
    local sessionId = battleSessionId

    local events = NetworkEvents.Init()
    local BattleUpdateEvent = events["BattleUpdate"]
    local BattleFinishEvent = events["BattleFinish"]
    local UpdatePetDataEvent = events["UpdatePetData"]
    local UpdateCoinsEvent = events["UpdateCoins"]
    local UpdateInventoryEvent = events["UpdateInventory"]

    -- Dịch chuyển cả tổ đội sang Đảo Map Ải riêng (lưu tọa độ cũ để trả về sau trận)
    for idx, member in ipairs(party) do
        local char = member.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if char and root and root:IsA("BasePart") then
            savedReturnCFrames[member] = root.CFrame
            local spawnPos = SPECTATOR_SPAWNS[idx] or SPECTATOR_SPAWNS[1]
            char:PivotTo(CFrame.new(spawnPos, ARENA_CENTER_POS))
        end
    end

    local battleFolder = Instance.new("Folder")
    battleFolder.Name = "ActiveBattleArena"
    battleFolder.Parent = workspace
    activeBattleFolder = battleFolder

    -- 1. Gom toàn bộ Pet của các thành viên trong tổ đội (tối đa 3 người × 5 Pet)
    local challengerModels: {Model} = {}
    local challengerPrimaries: {BasePart} = {}
    local challengerOffsets: {Vector3} = {}
    local totalPartyPower = 0
    local totalPartyHp = 0

    for mIdx, member in ipairs(party) do
        local pData = PetService.GetPlayerData(member)
        if pData then
            totalPartyPower += math.max(10, pData.power)
            totalPartyHp += math.floor(140 + (pData.level - 1) * 35 + pData.power * 2.5)
            local teamIds = (type(pData.equippedPets) == "table" and #pData.equippedPets > 0) and pData.equippedPets or { pData.currentPetId }
            local rowX = -(mIdx - 1) * 3.4
            for pIdx, petId in ipairs(teamIds) do
                if pIdx > 5 then break end
                local zSpread = (pIdx - (#teamIds + 1) / 2) * 3.2
                local off = Vector3.new(rowX, 0, zSpread)
                local m = spawnBattleModel(
                    petId,
                    string.format("Challenger_%d_%d", mIdx, pIdx),
                    CFrame.new(RED_CORNER_POS + off, BLUE_CORNER_POS),
                    battleFolder
                )
                if m then
                    local prim = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                    if prim then
                        table.insert(challengerModels, m)
                        table.insert(challengerPrimaries, prim)
                        table.insert(challengerOffsets, off)
                    end
                end
            end
        end
    end

    local challengerModel = challengerModels[1]
    if not challengerModel then
        releaseArena(sessionId)
        return
    end

    -- 2. Sinh Boss tại Góc Xanh (HP tăng +60% mỗi thành viên đi chung thêm!)
    local bossModel = spawnBattleModel(
        boss.petModelId,
        "BossPet",
        CFrame.new(BLUE_CORNER_POS, RED_CORNER_POS),
        battleFolder
    )
    if not bossModel then
        releaseArena(sessionId)
        return
    end

    local partyScale = 1 + (#party - 1) * 0.6
    local playerMaxHp = math.max(150, totalPartyHp)
    local playerCurrentHp = playerMaxHp
    local playerPower = math.max(10, totalPartyPower)

    local bossMaxHp = math.floor(boss.hp * partyScale)
    local bossCurrentHp = bossMaxHp
    local bossPower = math.floor(boss.power * (1 + (#party - 1) * 0.25))

    local pPrimary = challengerPrimaries[1]
    local bPrimary = bossModel.PrimaryPart or bossModel:FindFirstChildWhichIsA("BasePart")
    if not pPrimary or not bPrimary then
        releaseArena(sessionId)
        return
    end

    local teamLabel = #party > 1
        and string.format("👥 Tổ Đội %d Người (%d Pet)", #party, #challengerModels)
        or string.format("🐾 Đội %d Pet", #challengerModels)
    local _, pFill, pHpText = createHealthBar(pPrimary, teamLabel, playerMaxHp, Color3.fromRGB(46, 204, 113))
    local _, bFill, bHpText = createHealthBar(bPrimary, string.format("%s %s (x%.1f)", boss.icon, boss.name, partyScale), bossMaxHp, Color3.fromRGB(239, 68, 68))

    for _, member in ipairs(party) do
        if member.Parent == Players then
            BattleUpdateEvent:FireClient(member, {
                state = "Ready",
                message = string.format("Tổ đội (%d người) tiến vào %s!", #party, boss.name),
                playerHp = playerCurrentHp,
                playerMaxHp = playerMaxHp,
                bossHp = bossCurrentHp,
                bossMaxHp = bossMaxHp,
            })
        end
    end

    -- 3. Vòng lặp chiến đấu thời gian thực trên Đảo Ải
    task.spawn(function()
        task.wait(1.5)
        if sessionId ~= battleSessionId or #getAliveMembers(party) == 0 or not challengerModel.Parent or not bossModel.Parent then
            releaseArena(sessionId)
            return
        end

        local pCombatPos = ARENA_CENTER_POS + Vector3.new(-5.5, 0, 0)
        local bCombatPos = ARENA_CENTER_POS + Vector3.new(5.5, 0, 0)

        for idx, prim in ipairs(challengerPrimaries) do
            local off = challengerOffsets[idx] or Vector3.new(0, 0, 0)
            TweenService:Create(prim, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {CFrame = CFrame.new(pCombatPos + off, bCombatPos)}):Play()
        end
        TweenService:Create(bPrimary, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {CFrame = CFrame.new(bCombatPos, pCombatPos)}):Play()
        task.wait(1.4)

        local round = 0
        local isGameOver = false
        local isVictory = false

        while not isGameOver and sessionId == battleSessionId and #getAliveMembers(party) > 0 and challengerModel.Parent and bossModel.Parent do
            round += 1

            -- LƯỢT 1: Toàn bộ Pet của tổ đội cùng tấn công Boss
            local isCritP = math.random() < 0.22
            local dmgP = math.floor(playerPower * (isCritP and 1.8 or 1.0) + math.random(-2, 5))
            dmgP = math.max(6, dmgP)

            for idx, prim in ipairs(challengerPrimaries) do
                local off = challengerOffsets[idx] or Vector3.new(0, 0, 0)
                TweenService:Create(prim, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {CFrame = CFrame.new(pCombatPos + off + Vector3.new(2.8, 0.5, 0), bCombatPos)}):Play()
            end
            task.wait(0.2)
            if sessionId ~= battleSessionId or #getAliveMembers(party) == 0 or not challengerModel.Parent or not bossModel.Parent then
                releaseArena(sessionId)
                return
            end
            for idx, prim in ipairs(challengerPrimaries) do
                local off = challengerOffsets[idx] or Vector3.new(0, 0, 0)
                TweenService:Create(prim, TweenInfo.new(0.22, Enum.EasingStyle.Back), {CFrame = CFrame.new(pCombatPos + off, bCombatPos)}):Play()
            end

            spawnDamagePopup(bPrimary.Position, dmgP, isCritP)
            bossCurrentHp = math.max(0, bossCurrentHp - dmgP)
            bFill.Size = UDim2.new(math.clamp(bossCurrentHp / bossMaxHp, 0, 1), 0, 1, 0)
            bHpText.Text = string.format("%d / %d", bossCurrentHp, bossMaxHp)

            for _, member in ipairs(party) do
                if member.Parent == Players then
                    BattleUpdateEvent:FireClient(member, {
                        state = "Round",
                        attacker = "Player",
                        damage = dmgP,
                        isCrit = isCritP,
                        playerHp = playerCurrentHp,
                        bossHp = bossCurrentHp,
                    })
                end
            end

            if bossCurrentHp <= 0 then
                isGameOver = true
                isVictory = true
                break
            end

            task.wait(0.7)
            if sessionId ~= battleSessionId or #getAliveMembers(party) == 0 or not challengerModel.Parent or not bossModel.Parent then
                releaseArena(sessionId)
                return
            end

            -- LƯỢT 2: Boss phản công (mỗi 3 lượt tung Kỹ Năng Nộ 1.5x sát thương)
            local isBossSkill = (round % 3 == 0)
            local isCritB = isBossSkill or (math.random() < (boss.critChance or 0.2))
            local multB = isBossSkill and 1.5 or (isCritB and 1.7 or 1.0)
            local dmgB = math.floor(bossPower * multB + math.random(-2, 5))
            dmgB = math.max(5, dmgB)

            TweenService:Create(bPrimary, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {CFrame = CFrame.new(bCombatPos + Vector3.new(-2.8, 0.5, 0), pCombatPos)}):Play()
            task.wait(0.2)
            if sessionId ~= battleSessionId or #getAliveMembers(party) == 0 or not challengerModel.Parent or not bossModel.Parent then
                releaseArena(sessionId)
                return
            end
            TweenService:Create(bPrimary, TweenInfo.new(0.22, Enum.EasingStyle.Back), {CFrame = CFrame.new(bCombatPos, pCombatPos)}):Play()

            spawnDamagePopup(pPrimary.Position, dmgB, isCritB, isBossSkill and "🔥 SKILL BOSS!" or nil)
            playerCurrentHp = math.max(0, playerCurrentHp - dmgB)
            pFill.Size = UDim2.new(math.clamp(playerCurrentHp / playerMaxHp, 0, 1), 0, 1, 0)
            pHpText.Text = string.format("%d / %d", playerCurrentHp, playerMaxHp)

            for _, member in ipairs(party) do
                if member.Parent == Players then
                    BattleUpdateEvent:FireClient(member, {
                        state = "Round",
                        attacker = "Boss",
                        damage = dmgB,
                        isCrit = isCritB,
                        playerHp = playerCurrentHp,
                        bossHp = bossCurrentHp,
                    })
                end
            end

            if playerCurrentHp <= 0 then
                isGameOver = true
                isVictory = false
                break
            end

            task.wait(0.8)
        end

        local aliveAtEnd = getAliveMembers(party)
        if sessionId ~= battleSessionId or #aliveAtEnd == 0 then
            releaseArena(sessionId)
            return
        end

        -- 4. Chia thưởng riêng cho TỪNG thành viên tổ đội
        if isVictory then
            TweenService:Create(bPrimary, TweenInfo.new(0.4), {CFrame = bPrimary.CFrame * CFrame.Angles(0, 0, math.rad(90))}):Play()
            local baseCFrame = pPrimary.CFrame
            for _ = 1, 3 do
                if sessionId ~= battleSessionId then
                    releaseArena(sessionId)
                    return
                end
                TweenService:Create(pPrimary, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {CFrame = baseCFrame + Vector3.new(0, 3, 0)}):Play()
                task.wait(0.25)
                TweenService:Create(pPrimary, TweenInfo.new(0.25, Enum.EasingStyle.Bounce), {CFrame = baseCFrame}):Play()
                task.wait(0.25)
            end
            spawnVictoryConfetti(pPrimary.Position + Vector3.new(0, 4, 0))

            for _, member in ipairs(aliveAtEnd) do
                PetService.AddExp(member, boss.rewardExp)
                if PetService.AddPlayerExp and boss.rewardPlayerExp then
                    PetService.AddPlayerExp(member, boss.rewardPlayerExp)
                end
                local updatedPayload = PetService.GetPetPayload(member)
                if updatedPayload and UpdatePetDataEvent then
                    UpdatePetDataEvent:FireClient(member, updatedPayload)
                end

                local grantedCoins = 0
                if CoinService and boss.rewardCoins and boss.rewardCoins > 0 then
                    local newCoins = CoinService.AddCoins(member, boss.rewardCoins)
                    grantedCoins = boss.rewardCoins
                    if UpdateCoinsEvent then
                        UpdateCoinsEvent:FireClient(member, {
                            coins = newCoins,
                            delta = grantedCoins,
                            reason = "Victory",
                        })
                    end
                end

                local droppedItemInfo: {id: string, name: string, icon: string}? = nil
                if InventoryService and boss.drops then
                    local dropId = rollStageDrop(boss.drops)
                    if dropId then
                        local added, itemDef, updatedInv = InventoryService.AddItem(member, dropId, 1)
                        if added and itemDef then
                            droppedItemInfo = {
                                id = itemDef.id,
                                name = itemDef.name,
                                icon = itemDef.icon,
                            }
                            if UpdateInventoryEvent then
                                UpdateInventoryEvent:FireClient(member, updatedInv)
                            end
                        end
                    end
                end

                BattleFinishEvent:FireClient(member, {
                    isVictory = true,
                    bossName = boss.name,
                    rewardExp = boss.rewardExp,
                    rewardCoins = grantedCoins,
                    droppedItem = droppedItemInfo,
                })
            end
        else
            TweenService:Create(pPrimary, TweenInfo.new(0.4), {CFrame = pPrimary.CFrame * CFrame.Angles(0, 0, math.rad(90))}):Play()
            local consolationExp = 15
            for _, member in ipairs(aliveAtEnd) do
                PetService.AddExp(member, consolationExp)
                local updatedPayload = PetService.GetPetPayload(member)
                if updatedPayload and UpdatePetDataEvent then
                    UpdatePetDataEvent:FireClient(member, updatedPayload)
                end
                BattleFinishEvent:FireClient(member, {
                    isVictory = false,
                    bossName = boss.name,
                    rewardExp = consolationExp,
                })
            end
        end

        -- Dọn dẹp & đưa cả tổ đội về lại khu chuồng sau 3.5 giây
        task.wait(3.5)
        releaseArena(sessionId)
    end)
end

local function emitLobbyState(lobby: ActiveLobby, stateName: string)
    local boss = BOSS_DATA[lobby.bossId]
    local names: {string} = {}
    for _, p in ipairs(lobby.members) do
        if p.Parent == Players then
            table.insert(names, p.DisplayName)
        end
    end
    broadcastPartyUpdate(lobby.networkEvents, {
        state = stateName,
        hostName = lobby.host.DisplayName,
        hostUserId = lobby.host.UserId,
        bossId = lobby.bossId,
        bossName = boss and boss.name or lobby.bossId,
        members = names,
        memberCount = #names,
        maxMembers = BattleService.MAX_PARTY_SIZE,
        timeLeft = lobby.timeLeft,
    })
end

-- Mở Tổ Đội Co-op (tối đa 3 người, chờ 10 giây hoặc chủ phòng bấm Vào Ải Ngay)
function BattleService.StartBattle(player: Player, bossId: string, PetService: any, NetworkEvents: any, CoinService: any?, InventoryService: any?): (boolean, string)
    if arenaBusy then
        return false, "Đảo Ải đang có tổ đội chiến đấu! Vui lòng chờ giây lát."
    end
    if currentLobby ~= nil then
        return false, "Đang có tổ đội chờ vào Ải! Hãy bấm THAM GIA ở thanh thông báo phía trên."
    end

    local boss = BOSS_DATA[bossId]
    if not boss then
        return false, "Không tìm thấy dữ liệu Ải thử thách!"
    end

    local pData = PetService.GetPlayerData(player)
    if not pData then
        return false, "Bạn chưa có thú cưng nào đồng hành!"
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if player.Parent ~= Players or not char or not root then
        return false, "Nhân vật của bạn chưa sẵn sàng để khiêu chiến!"
    end

    battleSessionId += 1
    local lobby: ActiveLobby = {
        id = battleSessionId,
        host = player,
        bossId = bossId,
        members = { player },
        timeLeft = BattleService.LOBBY_WAIT_SECONDS,
        petService = PetService,
        networkEvents = NetworkEvents,
        coinService = CoinService,
        inventoryService = InventoryService,
    }
    currentLobby = lobby
    emitLobbyState(lobby, "Open")

    -- Đếm ngược 10 giây cho bạn bè cùng phòng bấm Tham gia
    task.spawn(function()
        while currentLobby == lobby and lobby.timeLeft > 0 do
            task.wait(1)
            if currentLobby ~= lobby then
                return
            end
            lobby.timeLeft -= 1
            if lobby.timeLeft > 0 then
                emitLobbyState(lobby, "Open")
            end
        end

        if currentLobby == lobby then
            currentLobby = nil
            emitLobbyState(lobby, "Starting")
            launchCoopBattle(lobby)
        end
    end)

    return true, "Đã mở Tổ Đội (tối đa 3 người)! Chờ bạn bè tham gia trong 10 giây..."
end

-- Xử lý nút Tham Gia / Vào Ải Ngay / Hủy Tổ Đội
function BattleService.HandlePartyAction(player: Player, action: string): (boolean, string)
    local lobby = currentLobby
    if not lobby then
        return false, "Hiện không có tổ đội nào đang mở."
    end

    if action == "join" then
        if table.find(lobby.members, player) then
            return true, "Bạn đã ở trong tổ đội này."
        end
        if #lobby.members >= BattleService.MAX_PARTY_SIZE then
            return false, "Tổ đội đã đủ 3/3 người!"
        end
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            return false, "Nhân vật của bạn chưa sẵn sàng!"
        end
        table.insert(lobby.members, player)
        emitLobbyState(lobby, "Open")

        -- Đủ 3/3 người -> tự động xuất phát ngay sau 1 giây
        if #lobby.members >= BattleService.MAX_PARTY_SIZE then
            task.delay(1, function()
                if currentLobby == lobby then
                    currentLobby = nil
                    emitLobbyState(lobby, "Starting")
                    launchCoopBattle(lobby)
                end
            end)
        end
        return true, "Đã tham gia tổ đội!"
    elseif action == "start_now" then
        if lobby.host ~= player then
            return false, "Chỉ chủ phòng mới có thể bắt đầu ngay!"
        end
        currentLobby = nil
        emitLobbyState(lobby, "Starting")
        launchCoopBattle(lobby)
        return true, "Xuất phát vào Đảo Ải ngay!"
    elseif action == "cancel" then
        if lobby.host == player then
            currentLobby = nil
            emitLobbyState(lobby, "Closed")
            return true, "Đã hủy tổ đội."
        else
            local idx = table.find(lobby.members, player)
            if idx then
                table.remove(lobby.members, idx)
                emitLobbyState(lobby, "Open")
            end
            return true, "Đã rời tổ đội."
        end
    end

    return false, "Thao tác không hợp lệ."
end

Players.PlayerRemoving:Connect(function(leavingPlayer: Player)
    savedReturnCFrames[leavingPlayer] = nil

    if currentLobby then
        local lobby = currentLobby
        local idx = table.find(lobby.members, leavingPlayer)
        if idx then
            table.remove(lobby.members, idx)
            if lobby.host == leavingPlayer or #lobby.members == 0 then
                currentLobby = nil
                emitLobbyState(lobby, "Closed")
            else
                emitLobbyState(lobby, "Open")
            end
        end
    end

    local bIdx = table.find(activeBattlers, leavingPlayer)
    if bIdx then
        table.remove(activeBattlers, bIdx)
        if #activeBattlers == 0 then
            battleSessionId += 1
            releaseArena(nil)
        end
    end
end)

function BattleService.IsBusy(): boolean
    return arenaBusy or (currentLobby ~= nil)
end

return BattleService
