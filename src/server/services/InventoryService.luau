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
    kind: string?, -- "food", "ticket", hoặc "gear"
    powerBonus: number?,
}

local defaultInventory: {InventoryItem} = {
    { id = "meat", name = "Thịt tươi", icon = "🥩", count = 5, exp = 50, desc = "+50 EXP thơm ngon", kind = "food" },
    { id = "bone", name = "Khúc xương", icon = "🦴", count = 10, exp = 25, desc = "+25 EXP yêu thích", kind = "food" },
    { id = "cookie", name = "Bánh thưởng", icon = "🍪", count = 15, exp = 15, desc = "+15 EXP snack", kind = "food" },
    { id = "toy", name = "Quả bóng", icon = "🎾", count = 1, exp = 30, desc = "+30 EXP vui chơi", kind = "food" },
    { id = "drumstick", name = "Đùi Gà Nướng", icon = "🍖", count = 0, exp = 120, desc = "+120 EXP (Rơi Ải 2-3)", kind = "food" },
    { id = "salmon", name = "Cá Hồi Thượng Hạng", icon = "🍣", count = 0, exp = 250, desc = "+250 EXP (Rơi Ải 4-5)", kind = "food" },
    { id = "golden_bone", name = "Xương Vàng Thần Thoại", icon = "🌟", count = 0, exp = 600, desc = "+600 EXP cực phẩm (Ải 5)", kind = "food" },
    { id = "gacha_ticket", name = "Vé Quay Gacha", icon = "🎟️", count = 0, exp = 0, desc = "Tự dùng miễn phí khi Quay x1", kind = "ticket" },
    -- Trang bị tăng Sức Mạnh cho đội hình Pet (rơi hiếm từ Ải 1-5)
    { id = "gear_collar", name = "Vòng Cổ Đinh Tán", icon = "🎀", count = 0, exp = 0, desc = "Trang bị: +12 Sức Mạnh", kind = "gear", powerBonus = 12 },
    { id = "gear_cape", name = "Áo Choàng Tốc Độ", icon = "🧣", count = 0, exp = 0, desc = "Trang bị: +30 Sức Mạnh", kind = "gear", powerBonus = 30 },
    { id = "gear_armor", name = "Giáp Chiến Khuyển", icon = "🛡️", count = 0, exp = 0, desc = "Trang bị: +65 Sức Mạnh", kind = "gear", powerBonus = 65 },
    { id = "gear_crown", name = "Vương Miện Khuyển Vương", icon = "👑", count = 0, exp = 0, desc = "Trang bị: +140 Sức Mạnh", kind = "gear", powerBonus = 140 },
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
            desc = item.desc,
            kind = item.kind,
            powerBonus = item.powerBonus,
        })
    end
    return t
end

function InventoryService.InitPlayer(player: Player, savedCounts: {[string]: number}?): {InventoryItem}
    local inv = cloneDefaultInventory()
    if type(savedCounts) == "table" then
        for _, item in ipairs(inv) do
            local savedCount = tonumber(savedCounts[item.id])
            if savedCount ~= nil then
                item.count = math.max(0, math.floor(savedCount))
            end
        end
    end
    playerInventories[player] = inv
    return inv
end

function InventoryService.ExportCounts(player: Player): {[string]: number}
    local inv = InventoryService.GetInventory(player)
    local counts: {[string]: number} = {}
    for _, item in ipairs(inv) do
        counts[item.id] = item.count
    end
    return counts
end

function InventoryService.GetInventory(player: Player): {InventoryItem}
    return playerInventories[player] or InventoryService.InitPlayer(player)
end

function InventoryService.GetItem(player: Player, itemId: string): InventoryItem?
    local inv = InventoryService.GetInventory(player)
    for _, it in ipairs(inv) do
        if it.id == itemId then
            return it
        end
    end
    return nil
end

function InventoryService.UseItem(player: Player, itemId: string): (boolean, number, {InventoryItem})
    local inv = InventoryService.GetInventory(player)
    for _, it in ipairs(inv) do
        if it.id == itemId and it.count > 0 and (it.kind == nil or it.kind == "food") then
            it.count = it.count - 1
            return true, it.exp, inv
        end
    end
    return false, 0, inv
end

function InventoryService.AddItem(player: Player, itemId: string, amount: number?): (boolean, InventoryItem?, {InventoryItem})
    local qty = math.max(1, math.floor(amount or 1))
    local inv = InventoryService.GetInventory(player)
    for _, it in ipairs(inv) do
        if it.id == itemId then
            it.count = it.count + qty
            return true, it, inv
        end
    end
    return false, nil, inv
end

function InventoryService.ConsumeItem(player: Player, itemId: string, amount: number?): (boolean, {InventoryItem})
    local qty = math.max(1, math.floor(amount or 1))
    local inv = InventoryService.GetInventory(player)
    for _, it in ipairs(inv) do
        if it.id == itemId and it.count >= qty then
            it.count = it.count - qty
            return true, inv
        end
    end
    return false, inv
end

function InventoryService.RemovePlayer(player: Player)
    playerInventories[player] = nil
end

return InventoryService
