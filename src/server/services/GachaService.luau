--!strict
-- GachaService.luau: Quản lý tính năng quay Gacha thú cưng, tỷ lệ rơi và bộ sưu tập
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local ConfigFolder = Modules:FindFirstChild("Config") or Modules
local PetConfig = require(ConfigFolder:WaitForChild("PetConfig"))

local GachaService = {}

export type GachaResult = {
    id: string,
    name: string,
    icon: string,
    rarity: string,
    rarityName: string,
    rarityColor: {number},
    basePower: number,
    expPerFeed: number,
    desc: string,
}

local playerCollections: {[Player]: {string}} = {}

function GachaService.InitPlayer(player: Player, savedCollection: {string}?): {string}
    local initial: {string} = {}
    if type(savedCollection) == "table" and #savedCollection > 0 then
        for _, petId in ipairs(savedCollection) do
            if type(petId) == "string" and PetConfig.Pets[petId] and not table.find(initial, petId) then
                table.insert(initial, petId)
            end
        end
    end
    if not table.find(initial, "Shiba") then
        table.insert(initial, "Shiba")
    end
    playerCollections[player] = initial
    return initial
end

function GachaService.GetHourlyBanner(timestamp: number?)
    return PetConfig.GetHourlyPool(timestamp)
end

function GachaService.GetCollection(player: Player): {string}
    return playerCollections[player] or GachaService.InitPlayer(player)
end

function GachaService.Roll(player: Player, rollCount: number): ({GachaResult}, {string})
    local collection = GachaService.GetCollection(player)
    rollCount = (rollCount == 5) and 5 or 1
    local results: {GachaResult} = {}

    for _ = 1, rollCount do
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

        if not table.find(collection, petId) then
            table.insert(collection, petId)
        end
    end

    return results, collection
end

function GachaService.HasPet(player: Player, petId: string): boolean
    local collection = GachaService.GetCollection(player)
    return table.find(collection, petId) ~= nil
end

function GachaService.RemovePlayer(player: Player)
    playerCollections[player] = nil
end

return GachaService
