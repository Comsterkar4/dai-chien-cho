--!strict
-- InventoryService.luau: Quản lý túi đồ và tiêu hao vật phẩm của người chơi
local InventoryService = {}

export type InventoryItem = {
    id: string,
    name: string,
    icon: string,
    count: number,
    exp: number,
    desc: string,
}

local defaultInventory: {InventoryItem} = {
    { id = "meat", name = "Thịt tươi", icon = "🥩", count = 5, exp = 50, desc = "+50 EXP thơm ngon" },
    { id = "bone", name = "Khúc xương", icon = "🦴", count = 10, exp = 25, desc = "+25 EXP yêu thích" },
    { id = "cookie", name = "Bánh thưởng", icon = "🍪", count = 15, exp = 15, desc = "+15 EXP snack" },
    { id = "toy", name = "Quả bóng", icon = "🎾", count = 1, exp = 30, desc = "+30 EXP vui chơi" }
}

local playerInventories: {[Player]: {InventoryItem}} = {}

local function cloneDefaultInventory(): {InventoryItem}
    local t = {}
    for _, item in ipairs(defaultInventory) do
        table.insert(t, {
            id = item.id,
            name = item.name,
            icon = item.icon,
            count = item.count,
            exp = item.exp,
            desc = item.desc
        })
    end
    return t
end

function InventoryService.InitPlayer(player: Player): {InventoryItem}
    local inv = cloneDefaultInventory()
    playerInventories[player] = inv
    return inv
end

function InventoryService.GetInventory(player: Player): {InventoryItem}
    return playerInventories[player] or InventoryService.InitPlayer(player)
end

function InventoryService.UseItem(player: Player, itemId: string): (boolean, number, {InventoryItem})
    local inv = InventoryService.GetInventory(player)
    for _, it in ipairs(inv) do
        if it.id == itemId and it.count > 0 then
            it.count = it.count - 1
            return true, it.exp, inv
        end
    end
    return false, 0, inv
end

function InventoryService.RemovePlayer(player: Player)
    playerInventories[player] = nil
end

return InventoryService
