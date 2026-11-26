--!strict
-- BattleService.luau: Quản lý toàn bộ vòng đời chiến đấu đối kháng 3D trong Đấu Trường (Battle Arena)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ConfigFolder = Modules:FindFirstChild("Config") or Modules
local PetConfig = require(ConfigFolder:WaitForChild("PetConfig"))

local BattleService = {}

-- Cấu hình 3 Boss Đấu Trường
local BOSS_DATA = {
    corgi_boss = {
        name = "Corgi Tốc Độ",
        icon = "🦊",
        petModelId = "corgi",
        level = 3,
        power = 18,
        hp = 120,
        rewardExp = 60,
        rewardGold = 100,
        color = Color3.fromRGB(245, 158, 11),
    },
    husky_boss = {
        name = "Husky Băng Giá",
        icon = "🐺",
        petModelId = "husky",
        level = 8,
        power = 45,
        hp = 280,
        rewardExp = 180,
        rewardGold = 300,
        color = Color3.fromRGB(6, 182, 212),
    },
    tibetan_boss = {
        name = "Ngao Tây Tạng Vương",
        icon = "🦁",
        petModelId = "shiba", -- fallback nếu chưa có model riêng
        level = 15,
        power = 110,
        hp = 650,
        rewardExp = 550,
        rewardGold = 1000,
        color = Color3.fromRGB(239, 68, 68),
    },
}

-- Trạng thái đấu trường
local arenaBusy = false
local currentBattler: Player? = nil

-- Tọa độ sàn đấu (trùng khớp với RedCornerPad và BlueCornerPad trong BattleZone)
local RED_CORNER_POS = Vector3.new(88.0, 4.2, 21.0)
local BLUE_CORNER_POS = Vector3.new(114.0, 4.2, 21.0)
local ARENA_CENTER_POS = Vector3.new(101.0, 4.2, 21.0)

-- Tạo bảng thanh máu 3D trên đầu Thú cưng
local function createHealthBar(parentPart: BasePart, nameText: string, maxHp: number, barColor: Color3): (BillboardGui, Frame, TextLabel)
    local bb = Instance.new("BillboardGui")
    bb.Name = "BattleHealthGui"
    bb.Size = UDim2.new(0, 150, 0, 45)
    bb.StudsOffset = Vector3.new(0, 4.5, 0)
    bb.AlwaysOnTop = true
    bb.Parent = parentPart

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
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
    bgBar.Size = UDim2.new(1, 0, 0, 14)
    bgBar.Position = UDim2.new(0, 0, 0, 20)
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
local function spawnDamagePopup(atPos: Vector3, damage: number, isCrit: boolean)
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 1, 1)
    part.Position = atPos + Vector3.new(math.random(-1, 1), 2, math.random(-1, 1))
    part.Transparency = 1
    part.CanCollide = false
    part.Anchored = true
    part.Parent = workspace

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 100, 0, 30)
    bb.AlwaysOnTop = true
    bb.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = isCrit and string.format("CRIT! -%d ⚡", damage) or string.format("-%d 💥", damage)
    label.TextColor3 = isCrit and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 60, 60)
    label.Font = Enum.Font.FredokaOne
    label.TextSize = isCrit and 22 or 17
    label.Parent = bb

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(40, 10, 10)
    stroke.Thickness = 2
    stroke.Parent = label

    local tween = TweenService:Create(part, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = part.Position + Vector3.new(0, 3.5, 0)
    })
    tween:Play()
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
        part:Destroy()
    end)
end

-- Bắt đầu trận đấu
function BattleService.StartBattle(player: Player, bossId: string, PetService: any, NetworkEvents: any): (boolean, string)
    if arenaBusy then
        return false, "Đấu trường đang có trận đấu diễn ra! Vui lòng chờ giây lát."
    end

    local boss = BOSS_DATA[bossId]
    if not boss then
        return false, "Không tìm thấy dữ liệu Boss thử thách!"
    end

    local pData = PetService.GetPlayerData(player)
    if not pData then
        return false, "Bạn chưa có thú cưng nào đồng hành!"
    end

    arenaBusy = true
    currentBattler = player

    local events = NetworkEvents.Init()
    local BattleUpdateEvent = events["BattleUpdate"]
    local BattleFinishEvent = events["BattleFinish"]

    -- Tạo thư mục chứa các đối tượng chiến đấu trong Đấu trường
    local battleFolder = Instance.new("Folder")
    battleFolder.Name = "ActiveBattleArena"
    battleFolder.Parent = workspace

    -- 1. Sinh mô hình Thú cưng người chơi tại Góc Đỏ
    local challengerModel = PetService.SpawnPlayerPet(player, pData.currentPetId)
    if not challengerModel then
        arenaBusy = false
        currentBattler = nil
        battleFolder:Destroy()
        return false, "Không thể khởi tạo thú cưng chiến đấu!"
    end
    challengerModel.Name = "ChallengerPet"
    challengerModel.Parent = battleFolder
    challengerModel:PivotTo(CFrame.new(RED_CORNER_POS, BLUE_CORNER_POS))

    -- 2. Sinh mô hình Boss tại Góc Xanh
    local bossModel = PetService.SpawnPlayerPet(player, boss.petModelId)
    if not bossModel then
        bossModel = challengerModel:Clone()
    end
    bossModel.Name = "BossPet"
    bossModel.Parent = battleFolder
    bossModel:PivotTo(CFrame.new(BLUE_CORNER_POS, RED_CORNER_POS))

    -- 3. Tạo thanh máu trên đầu cả 2 pet
    local playerMaxHp = math.floor(100 + (pData.level - 1) * 25 + pData.power * 2)
    local playerCurrentHp = playerMaxHp
    local playerPower = math.max(10, pData.power)

    local bossMaxHp = boss.hp
    local bossCurrentHp = bossMaxHp
    local bossPower = boss.power

    local pPrimary = challengerModel.PrimaryPart or challengerModel:FindFirstChildWhichIsA("BasePart")
    local bPrimary = bossModel.PrimaryPart or bossModel:FindFirstChildWhichIsA("BasePart")

    if not pPrimary or not bPrimary then
        arenaBusy = false
        currentBattler = nil
        battleFolder:Destroy()
        return false, "Lỗi vật thể thú cưng không hợp lệ!"
    end

    local _, pFill, pHpText = createHealthBar(pPrimary, string.format("🐶 %s (Lv.%d)", pData.currentPetId, pData.level), playerMaxHp, Color3.fromRGB(46, 204, 113))
    local _, bFill, bHpText = createHealthBar(bPrimary, string.format("%s %s (Lv.%d)", boss.icon, boss.name, boss.level), bossMaxHp, Color3.fromRGB(239, 68, 68))

    -- Thông báo trạng thái bắt đầu cho Client
    BattleUpdateEvent:FireClient(player, {
        state = "Ready",
        message = string.format("Trận đấu bắt đầu: Bạn VS %s!", boss.name),
        playerHp = playerCurrentHp,
        playerMaxHp = playerMaxHp,
        bossHp = bossCurrentHp,
        bossMaxHp = bossMaxHp
    })

    -- 4. Chạy vòng lặp chiến đấu thời gian thực (Real-time Combat Loop)
    task.spawn(function()
        task.wait(1.5)

        -- Di chuyển 2 pet về cự ly giáp chiến trung tâm
        local pCombatPos = ARENA_CENTER_POS + Vector3.new(-4.5, 0, 0)
        local bCombatPos = ARENA_CENTER_POS + Vector3.new(4.5, 0, 0)

        local moveTweenP = TweenService:Create(pPrimary, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {CFrame = CFrame.new(pCombatPos, bCombatPos)})
        local moveTweenB = TweenService:Create(bPrimary, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {CFrame = CFrame.new(bCombatPos, pCombatPos)})
        moveTweenP:Play()
        moveTweenB:Play()
        task.wait(1.4)

        local round = 0
        local isGameOver = false
        local isVictory = false

        while not isGameOver and challengerModel.Parent and bossModel.Parent do
            round += 1

            -- LƯỢT 1: Thú cưng người chơi tấn công Boss
            local isCritP = math.random() < 0.22
            local dmgP = math.floor(playerPower * (isCritP and 1.8 or 1.0) + math.random(-2, 4))
            dmgP = math.max(6, dmgP)

            -- Animation lao vào húc
            local lungeP = TweenService:Create(pPrimary, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {CFrame = CFrame.new(pCombatPos + Vector3.new(2.5, 0.5, 0), bCombatPos)})
            lungeP:Play()
            task.wait(0.2)
            local backP = TweenService:Create(pPrimary, TweenInfo.new(0.22, Enum.EasingStyle.Back), {CFrame = CFrame.new(pCombatPos, bCombatPos)})
            backP:Play()

            -- Hiệu ứng sát thương lên Boss
            spawnDamagePopup(bPrimary.Position, dmgP, isCritP)
            bossCurrentHp = math.max(0, bossCurrentHp - dmgP)
            bFill.Size = UDim2.new(math.clamp(bossCurrentHp / bossMaxHp, 0, 1), 0, 1, 0)
            bHpText.Text = string.format("%d / %d", bossCurrentHp, bossMaxHp)

            BattleUpdateEvent:FireClient(player, {
                state = "Round",
                attacker = "Player",
                damage = dmgP,
                isCrit = isCritP,
                playerHp = playerCurrentHp,
                bossHp = bossCurrentHp
            })

            if bossCurrentHp <= 0 then
                isGameOver = true
                isVictory = true
                break
            end

            task.wait(0.7)

            -- LƯỢT 2: Boss tấn công lại Thú cưng người chơi
            local isCritB = math.random() < 0.18
            local dmgB = math.floor(bossPower * (isCritB and 1.7 or 1.0) + math.random(-2, 3))
            dmgB = math.max(5, dmgB)

            local lungeB = TweenService:Create(bPrimary, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {CFrame = CFrame.new(bCombatPos + Vector3.new(-2.5, 0.5, 0), pCombatPos)})
            lungeB:Play()
            task.wait(0.2)
            local backB = TweenService:Create(bPrimary, TweenInfo.new(0.22, Enum.EasingStyle.Back), {CFrame = CFrame.new(bCombatPos, pCombatPos)})
            backB:Play()

            spawnDamagePopup(pPrimary.Position, dmgB, isCritB)
            playerCurrentHp = math.max(0, playerCurrentHp - dmgB)
            pFill.Size = UDim2.new(math.clamp(playerCurrentHp / playerMaxHp, 0, 1), 0, 1, 0)
            pHpText.Text = string.format("%d / %d", playerCurrentHp, playerMaxHp)

            BattleUpdateEvent:FireClient(player, {
                state = "Round",
                attacker = "Boss",
                damage = dmgB,
                isCrit = isCritB,
                playerHp = playerCurrentHp,
                bossHp = bossCurrentHp
            })

            if playerCurrentHp <= 0 then
                isGameOver = true
                isVictory = false
                break
            end

            task.wait(0.8)
        end

        -- XỬ LÝ KẾT THÚC TRẬN ĐẤU (Game Over / Victory Ceremony)
        if isVictory then
            -- Boss ngã gục
            TweenService:Create(bPrimary, TweenInfo.new(0.4), {CFrame = bPrimary.CFrame * CFrame.Angles(0, 0, math.rad(90))}):Play()
            -- Thú cưng chiến thắng nhảy cẫng lên ăn mừng
            for _ = 1, 3 do
                local jumpUp = TweenService:Create(pPrimary, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Position = pPrimary.Position + Vector3.new(0, 3, 0)})
                jumpUp:Play()
                task.wait(0.25)
                local jumpDown = TweenService:Create(pPrimary, TweenInfo.new(0.25, Enum.EasingStyle.Bounce), {Position = pPrimary.Position - Vector3.new(0, 3, 0)})
                jumpDown:Play()
                task.wait(0.25)
            end
            spawnVictoryConfetti(pPrimary.Position + Vector3.new(0, 4, 0))

            -- Trao thưởng cho người chơi
            PetService.AddExp(player, boss.rewardExp)
            
            BattleFinishEvent:FireClient(player, {
                isVictory = true,
                bossName = boss.name,
                rewardExp = boss.rewardExp,
                rewardGold = boss.rewardGold,
            })
        else
            -- Thú cưng người chơi ngã gục
            TweenService:Create(pPrimary, TweenInfo.new(0.4), {CFrame = pPrimary.CFrame * CFrame.Angles(0, 0, math.rad(90))}):Play()

            BattleFinishEvent:FireClient(player, {
                isVictory = false,
                bossName = boss.name,
                rewardExp = 15,
                rewardGold = 0,
            })
        end

        -- Dọn dẹp sàn đấu sau 3.5 giây
        task.wait(3.5)
        battleFolder:Destroy()
        arenaBusy = false
        currentBattler = nil
    end)

    return true, "Trận đấu bắt đầu!"
end

function BattleService.IsBusy(): boolean
    return arenaBusy
end

return BattleService
