--!strict
-- PlayerDataStoreService.luau: Lưu dữ liệu người chơi vĩnh viễn trên Roblox DataStoreService (Miễn phí 100%)
-- Hỗ trợ: tải khi vào game, tự động lưu định kỳ mỗi 3 phút, lưu khi thoát & BindToClose.
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PlayerDataStoreService = {}

local DATASTORE_NAME = "DaiChienCho_PlayerData_v1"
local AUTO_SAVE_INTERVAL = 180 -- 3 phút

export type SavedPlayerData = {
    currentPetId: string?,
    equippedPets: {string}?,
    equippedGearId: string?,
    gearPowerBonus: number?,
    playerLevel: number?,
    playerExp: number?,
    level: number?,
    exp: number?,
    power: number?,
    coins: number?,
    isLeashed: boolean?,
    collection: {string}?,
    inventory: {[string]: number}?,
    lastSaved: number?,
}

local playerStore: DataStore? = nil
local storeReady = false

local function getStore(): DataStore?
    if storeReady then
        return playerStore
    end
    storeReady = true
    local ok, ds = pcall(function()
        return DataStoreService:GetDataStore(DATASTORE_NAME)
    end)
    if ok then
        playerStore = ds
    else
        warn("[PlayerDataStoreService] Không thể truy cập DataStore (cần bật Enable Studio Access to API Services):", ds)
    end
    return playerStore
end

local function getKey(player: Player): string
    return "Player_" .. tostring(player.UserId)
end

function PlayerDataStoreService.Load(player: Player): SavedPlayerData?
    local ds = getStore()
    if not ds then
        return nil
    end

    local key = getKey(player)
    local ok, result = pcall(function()
        return ds:GetAsync(key)
    end)

    if ok and type(result) == "table" then
        return result :: SavedPlayerData
    elseif not ok then
        warn("[PlayerDataStoreService] Lỗi tải dữ liệu cho " .. player.Name .. ":", result)
    end

    return nil
end

function PlayerDataStoreService.Save(player: Player, payload: SavedPlayerData): boolean
    local ds = getStore()
    if not ds then
        return false
    end

    local key = getKey(player)
    payload.lastSaved = os.time()

    local ok, err = pcall(function()
        ds:UpdateAsync(key, function()
            return payload
        end)
    end)

    if not ok then
        warn("[PlayerDataStoreService] Lỗi lưu dữ liệu cho " .. player.Name .. ":", err)
        return false
    end

    return true
end

function PlayerDataStoreService.StartAutoSaveLoop(buildPayload: (Player) -> SavedPlayerData?)
    task.spawn(function()
        while true do
            task.wait(AUTO_SAVE_INTERVAL)
            for _, player in ipairs(Players:GetPlayers()) do
                local payload = buildPayload(player)
                if payload then
                    PlayerDataStoreService.Save(player, payload)
                end
            end
        end
    end)

    game:BindToClose(function()
        if RunService:IsStudio() then
            task.wait(0.2)
        end
        for _, player in ipairs(Players:GetPlayers()) do
            local payload = buildPayload(player)
            if payload then
                PlayerDataStoreService.Save(player, payload)
            end
        end
    end)
end

return PlayerDataStoreService
