--!strict
-- CoinService.luau: Quản lý Ví Xu (Coin) của người chơi — khởi tạo 100 Xu, cộng Xu vượt ải, trừ Xu quay Gacha (không âm)

local CoinService = {}

CoinService.STARTING_COINS = 100

local playerCoins: {[Player]: number} = {}

function CoinService.InitPlayer(player: Player, savedCoins: number?): number
    local initial = CoinService.STARTING_COINS
    if savedCoins ~= nil and tonumber(savedCoins) ~= nil then
        initial = math.max(0, math.floor(tonumber(savedCoins) :: number))
    end
    playerCoins[player] = initial
    return initial
end

function CoinService.GetCoins(player: Player): number
    if playerCoins[player] == nil then
        return CoinService.InitPlayer(player)
    end
    return playerCoins[player]
end

function CoinService.AddCoins(player: Player, amount: number): number
    local add = math.floor(amount)
    local current = CoinService.GetCoins(player)
    if add <= 0 then
        return current
    end
    local updated = current + add
    playerCoins[player] = updated
    return updated
end

function CoinService.SpendCoins(player: Player, amount: number): (boolean, number)
    local cost = math.floor(amount)
    local current = CoinService.GetCoins(player)
    if cost <= 0 then
        return false, current
    end
    if current < cost then
        return false, current
    end
    local updated = current - cost
    playerCoins[player] = updated
    return true, updated
end

function CoinService.RemovePlayer(player: Player)
    playerCoins[player] = nil
end

return CoinService
