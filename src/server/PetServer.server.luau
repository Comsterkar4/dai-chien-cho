--!strict
-- PetServer.server.luau: Bootstrap Entry Point cho toàn bộ hệ thống Server
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 1. Nạp Shared Modules (Network & Config)
local Modules = ReplicatedStorage:WaitForChild("Modules")
local NetworkFolder = Modules:FindFirstChild("Network") or Modules
local ConfigFolder = Modules:FindFirstChild("Config") or Modules

local NetworkEvents = require(NetworkFolder:WaitForChild("NetworkEvents"))
local PetConfig = require(ConfigFolder:WaitForChild("PetConfig"))

-- 2. Nạp các Server Services
local ServicesFolder = script.Parent:WaitForChild("services")
local PlotService = require(ServicesFolder:WaitForChild("PlotService"))
local InventoryService = require(ServicesFolder:WaitForChild("InventoryService"))
local GachaService = require(ServicesFolder:WaitForChild("GachaService"))
local PetService = require(ServicesFolder:WaitForChild("PetService"))
local BattleService = require(ServicesFolder:WaitForChild("BattleService"))
local CoinService = require(ServicesFolder:WaitForChild("CoinService"))
local PlayerDataStoreService = require(ServicesFolder:WaitForChild("PlayerDataStoreService"))

-- 3. Khởi tạo mạng RemoteEvents
local events = NetworkEvents.Init()
local FeedEvent = events["FeedPet"]
local UpdateEvent = events["UpdatePetData"]
local UseItemEvent = events["UseItem"]
local ToggleLeashEvent = events["ToggleLeash"]
local InvUpdateEvent = events["UpdateInventory"]
local RollGachaEvent = events["RollGacha"]
local GachaResultEvent = events["GachaResult"]
local EquipPetEvent = events["EquipPet"]
local UpdateCollectionEvent = events["UpdatePetCollection"]
local UpdateCoinsEvent = events["UpdateCoins"]
local StartPetBattleEvent = events["StartPetBattle"]
local BattleUpdateEvent = events["BattleUpdate"]
local PartyActionEvent = events["PartyAction"]

local GACHA_COST_SINGLE = 100
local GACHA_COST_FIVE = 450

local cooldowns: {[Player]: number} = {}
local gachaCooldowns: {[Player]: number} = {}

local function buildSavePayload(player: Player)
    local pData = PetService.GetPlayerData(player)
    if not pData then
        return nil
    end
    return {
        currentPetId = pData.currentPetId,
        equippedPets = pData.equippedPets,
        equippedGearId = pData.equippedGearId,
        gearPowerBonus = pData.gearPowerBonus,
        playerLevel = pData.playerLevel,
        playerExp = pData.playerExp,
        level = pData.level,
        exp = pData.exp,
        power = pData.power,
        coins = CoinService.GetCoins(player),
        isLeashed = pData.isLeashed,
        collection = GachaService.GetCollection(player),
        inventory = InventoryService.ExportCounts(player),
    }
end

-- 4. Xử lý Vòng đời Người chơi (Player Lifecycle)
local function onPlayerAdded(player: Player)
    local saved = PlayerDataStoreService.Load(player)
    local assignedPlot = PlotService.AssignPlot(player)
    local pData = PetService.InitPlayerData(player, assignedPlot, saved)
    local inventory = InventoryService.InitPlayer(player, saved and saved.inventory or nil)
    local collection = GachaService.InitPlayer(player, saved and saved.collection or nil)
    local coins = CoinService.InitPlayer(player, saved and saved.coins or nil)

    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)

        -- Dịch chuyển người chơi về điểm hồi sinh của Plot được giao
        local gameMap = workspace:FindFirstChild("GameMap")
        local plotsFolder = gameMap and gameMap:FindFirstChild("PlayerPlots")
        if plotsFolder and pData.assignedPlot then
            local pModel = plotsFolder:FindFirstChild("Plot_" .. pData.assignedPlot)
            local pSpawn = pModel and pModel:FindFirstChild("PlotSpawn")
            if pSpawn and pSpawn:IsA("BasePart") and char:FindFirstChild("HumanoidRootPart") then
                char:PivotTo(pSpawn.CFrame + Vector3.new(0, 3, 0))
            end
        end

        -- Hủy model cũ và sinh toàn bộ đội hình thú cưng (tối đa 3 con) đi theo chủ
        PetService.SpawnEquippedPets(player)

        -- Gửi dữ liệu khởi tạo về Client
        local payload = PetService.GetPetPayload(player)
        if payload then
            UpdateEvent:FireClient(player, payload)
        end
        InvUpdateEvent:FireClient(player, inventory)
        UpdateCollectionEvent:FireClient(player, collection)
        if UpdateCoinsEvent then
            UpdateCoinsEvent:FireClient(player, { coins = CoinService.GetCoins(player) })
        end
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in ipairs(Players:GetPlayers()) do
    onPlayerAdded(p)
end

Players.PlayerRemoving:Connect(function(player: Player)
    local payload = buildSavePayload(player)
    if payload then
        PlayerDataStoreService.Save(player, payload)
    end
    PlotService.ReleasePlot(player)
    PetService.CleanPlayer(player)
    InventoryService.RemovePlayer(player)
    GachaService.RemovePlayer(player)
    CoinService.RemovePlayer(player)
    cooldowns[player] = nil
    gachaCooldowns[player] = nil
end)

-- 5. Lắng nghe các Sự kiện Người chơi (Remote Event Handlers)

-- Cho ăn nhanh (FeedPet)
FeedEvent.OnServerEvent:Connect(function(player: Player)
    local now = os.clock()
    if cooldowns[player] and (now - cooldowns[player]) < 0.5 then return end
    cooldowns[player] = now

    local pData = PetService.GetPlayerData(player)
    if not pData or not pData.model then return end

    local petDef = PetConfig.Pets[pData.currentPetId] or PetConfig.Pets.Shiba
    local addExp = petDef.ExpPerFeed or 25
    PetService.AddExp(player, addExp)
    PetService.SpawnFoodEffect(pData.model)

    local payload = PetService.GetPetPayload(player)
    if payload then
        UpdateEvent:FireClient(player, payload)
    end
end)

-- Sử dụng vật phẩm hoặc Đeo/Tháo Trang Bị từ Túi Đồ (UseItem)
UseItemEvent.OnServerEvent:Connect(function(player: Player, itemId: string)
    if typeof(itemId) ~= "string" then return end
    local pData = PetService.GetPlayerData(player)
    if not pData then return end

    local itemDef = InventoryService.GetItem(player, itemId)
    if itemDef and itemDef.kind == "gear" and itemDef.count > 0 then
        local ok = PetService.EquipGear(player, itemId, itemDef.powerBonus or 0)
        if ok then
            local payload = PetService.GetPetPayload(player)
            if payload then
                UpdateEvent:FireClient(player, payload)
            end
        end
        return
    end

    if not pData.model then return end
    local success, expGained, updatedInv = InventoryService.UseItem(player, itemId)
    if success then
        PetService.AddExp(player, expGained)
        PetService.SpawnFoodEffect(pData.model)

        local payload = PetService.GetPetPayload(player)
        if payload then
            UpdateEvent:FireClient(player, payload)
        end
        InvUpdateEvent:FireClient(player, updatedInv)
    end
end)

-- Bật / Tắt Dây dắt thú cưng (ToggleLeash)
ToggleLeashEvent.OnServerEvent:Connect(function(player: Player)
    local pData = PetService.GetPlayerData(player)
    if not pData then return end
    pData.isLeashed = not pData.isLeashed
    PetService.SetPetLeash(player, pData.isLeashed)
end)

-- Quay Gacha Linh thú (RollGacha — tốn 100 Xu x1 / 450 Xu x5)
RollGachaEvent.OnServerEvent:Connect(function(player: Player, rollCount: number)
    local now = os.clock()
    if gachaCooldowns[player] and (now - gachaCooldowns[player]) < 0.5 then return end
    gachaCooldowns[player] = now

    local normalizedCount = (rollCount == 5) and 5 or 1
    local cost = (normalizedCount == 5) and GACHA_COST_FIVE or GACHA_COST_SINGLE

    -- Ưu tiên dùng 1 Vé Quay Gacha miễn phí nếu quay x1
    local usedTicket = false
    if normalizedCount == 1 then
        local consumed, updatedInv = InventoryService.ConsumeItem(player, "gacha_ticket", 1)
        if consumed then
            usedTicket = true
            InvUpdateEvent:FireClient(player, updatedInv)
        end
    end

    if not usedTicket then
        local spent, remainingCoins = CoinService.SpendCoins(player, cost)
        if not spent then
            GachaResultEvent:FireClient(player, {
                error = true,
                message = string.format(
                    "Không đủ Xu! Cần %d Xu (hiện có %d Xu). Hãy vào Ải đánh quái để kiếm thêm Xu!",
                    cost,
                    remainingCoins
                ),
            })
            return
        end

        if UpdateCoinsEvent then
            UpdateCoinsEvent:FireClient(player, {
                coins = remainingCoins,
                delta = -cost,
                reason = "Gacha",
            })
        end
    end

    local results, collection = GachaService.Roll(player, normalizedCount)
    GachaResultEvent:FireClient(player, results)
    UpdateCollectionEvent:FireClient(player, collection)
end)

-- Trang bị Thú cưng từ Bộ sưu tập (EquipPet)
EquipPetEvent.OnServerEvent:Connect(function(player: Player, petId: string)
    if not GachaService.HasPet(player, petId) then return end
    local equipped = PetService.EquipPet(player, petId)
    if equipped then
        local payload = PetService.GetPetPayload(player)
        if payload then
            UpdateEvent:FireClient(player, payload)
        end
    end
end)

-- Khiêu chiến Ải Đấu trường Pet (mở Tổ Đội Co-op tối đa 3 người)
StartPetBattleEvent.OnServerEvent:Connect(function(player: Player, bossId: string)
    if typeof(bossId) ~= "string" then return end
    local success, message = BattleService.StartBattle(player, bossId, PetService, NetworkEvents, CoinService, InventoryService)
    if not success and BattleUpdateEvent then
        BattleUpdateEvent:FireClient(player, {
            state = "Rejected",
            message = message or "Không thể bắt đầu trận đấu lúc này!",
        })
    end
end)

-- Thao tác Tổ Đội Co-op (join / start_now / cancel)
if PartyActionEvent then
    PartyActionEvent.OnServerEvent:Connect(function(player: Player, action: string)
        if typeof(action) ~= "string" then return end
        local ok, msg = BattleService.HandlePartyAction(player, action)
        if not ok and BattleUpdateEvent then
            BattleUpdateEvent:FireClient(player, {
                state = "Rejected",
                message = msg or "Không thể thực hiện thao tác tổ đội!",
            })
        end
    end)
end

-- 6. Khởi động Vòng lặp dạo bộ tích lũy EXP & Tự động lưu DataStore
PetService.StartWalkingLoop(function(player: Player, payload: any)
    if payload then
        UpdateEvent:FireClient(player, payload)
    end
end)
PlayerDataStoreService.StartAutoSaveLoop(buildSavePayload)
