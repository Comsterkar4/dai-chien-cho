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
local StartPetBattleEvent = events["StartPetBattle"]
local BattleUpdateEvent = events["BattleUpdate"]

local cooldowns: {[Player]: number} = {}

-- 4. Xử lý Vòng đời Người chơi (Player Lifecycle)
local function onPlayerAdded(player: Player)
    local assignedPlot = PlotService.AssignPlot(player)
    local pData = PetService.InitPlayerData(player, assignedPlot)
    local inventory = InventoryService.InitPlayer(player)
    local collection = GachaService.InitPlayer(player)

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

        -- Hủy model cũ nếu có và sinh thú cưng mới đi theo chủ
        if pData.model then
            pData.model:Destroy()
        end
        local pet = PetService.SpawnPlayerPet(player, pData.currentPetId)
        pData.model = pet
        if pet then
            PetService.UpdatePetTag(pet, pData)
        end
        PetService.SetPetLeash(player, pData.isLeashed)

        -- Gửi dữ liệu khởi tạo về Client
        local payload = PetService.GetPetPayload(player)
        if payload then
            UpdateEvent:FireClient(player, payload)
        end
        InvUpdateEvent:FireClient(player, inventory)
        UpdateCollectionEvent:FireClient(player, collection)
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in ipairs(Players:GetPlayers()) do
    onPlayerAdded(p)
end

Players.PlayerRemoving:Connect(function(player: Player)
    PlotService.ReleasePlot(player)
    PetService.CleanPlayer(player)
    InventoryService.RemovePlayer(player)
    GachaService.RemovePlayer(player)
    cooldowns[player] = nil
end)

-- 5. Lắng nghe các Sự kiện Người chơi (Remote Event Handlers)

-- Cho ăn nhanh (FeedPet)
FeedEvent.OnServerEvent:Connect(function(player: Player)
    local now = os.clock()
    if cooldowns[player] and (now - cooldowns[player]) < 0.3 then return end
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

-- Sử dụng vật phẩm từ Túi Đồ (UseItem)
UseItemEvent.OnServerEvent:Connect(function(player: Player, itemId: string)
    local pData = PetService.GetPlayerData(player)
    if not pData or not pData.model then return end

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

-- Quay Gacha Linh thú (RollGacha)
RollGachaEvent.OnServerEvent:Connect(function(player: Player, rollCount: number)
    local results, collection = GachaService.Roll(player, rollCount)
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

-- Khiêu chiến Đấu trường Pet (StartPetBattle)
StartPetBattleEvent.OnServerEvent:Connect(function(player: Player, bossId: string)
    if typeof(bossId) ~= "string" then return end
    local success, message = BattleService.StartBattle(player, bossId, PetService, NetworkEvents)
    if not success and BattleUpdateEvent then
        BattleUpdateEvent:FireClient(player, {
            state = "Rejected",
            message = message or "Không thể bắt đầu trận đấu lúc này!",
        })
    end
end)

-- 6. Khởi động Vòng lặp dạo bộ tích lũy EXP
PetService.StartWalkingLoop(function(player: Player, payload: any)
    if payload then
        UpdateEvent:FireClient(player, payload)
    end
end)
