--!strict
-- tests/run_tests.luau
-- Test runner độc lập bằng Lune CLI để kiểm tra logic & cú pháp mà không cần mở Roblox Studio

local fs = require("@lune/fs")
local luau = require("@lune/luau")

-- 1. Mock môi trường Roblox
local robloxEnv = {}
robloxEnv.math = math
robloxEnv.table = table
robloxEnv.string = string
robloxEnv.os = os
robloxEnv.pairs = pairs
robloxEnv.ipairs = ipairs
robloxEnv.type = type
robloxEnv.typeof = typeof or type
robloxEnv.tostring = tostring
robloxEnv.tonumber = tonumber
robloxEnv.print = print
robloxEnv.warn = warn
robloxEnv.error = error
robloxEnv.pcall = pcall

robloxEnv.Color3 = {
    fromRGB = function(r: number, g: number, b: number)
        return { R = r / 255, G = g / 255, B = b / 255 }
    end,
    new = function(r: number, g: number, b: number)
        return { R = r, G = g, B = b }
    end,
}

robloxEnv.Vector3 = {
    new = function(x: number, y: number, z: number)
        return { X = x or 0, Y = y or 0, Z = z or 0 }
    end,
}

robloxEnv.Vector2 = {
    new = function(x: number, y: number)
        return { X = x or 0, Y = y or 0 }
    end,
}

robloxEnv.CFrame = {
    new = function(...)
        return {}
    end,
    Angles = function(...)
        return {}
    end,
}

robloxEnv.UDim = {
    new = function(scale: number, offset: number)
        return { Scale = scale, Offset = offset }
    end,
}

robloxEnv.UDim2 = {
    new = function(sx: number, ox: number, sy: number, oy: number)
        return { X = { Scale = sx, Offset = ox }, Y = { Scale = sy, Offset = oy } }
    end,
    fromOffset = function(x: number, y: number)
        return { X = { Scale = 0, Offset = x }, Y = { Scale = 0, Offset = y } }
    end,
}

robloxEnv.Instance = {
    new = function(className: string)
        return {
            ClassName = className,
            Name = className,
            Destroy = function() end,
        }
    end,
}

local moduleCache = {}

local function mockRequire(modulePath: any): any
    if type(modulePath) == "table" then
        return modulePath
    end
    if moduleCache[modulePath] then
        return moduleCache[modulePath]
    end

    local filePath = tostring(modulePath)
    if not string.find(filePath, "%.luau$") and not string.find(filePath, "%.lua$") then
        if fs.isFile(filePath .. ".luau") then
            filePath = filePath .. ".luau"
        elseif fs.isFile(filePath .. ".lua") then
            filePath = filePath .. ".lua"
        end
    end

    local code = fs.readFile(filePath)
    local fn = luau.load(code, {
        environment = robloxEnv,
    })
    local result = fn()
    moduleCache[modulePath] = result
    return result
end

robloxEnv.require = mockRequire
robloxEnv.script = {
    Parent = {
        WaitForChild = function(_self: any, childName: string)
            if childName == "DogBreedsData" then
                return mockRequire("src/shared/config/DogBreedsData.luau")
            end
            return nil
        end,
    },
}

-- Mock ReplicatedStorage cho các module game
local mockReplicatedStorage = {
    WaitForChild = function(self: any, name: string)
        return {
            WaitForChild = function(s: any, childName: string)
                if childName == "PetConfig" then
                    return mockRequire("src/shared/config/PetConfig.luau")
                end
                return s
            end,
            FindFirstChild = function(s: any, childName: string)
                if childName == "PetConfig" then
                    return mockRequire("src/shared/config/PetConfig.luau")
                end
                return s
            end,
        }
    end,
    FindFirstChild = function(self: any, name: string)
        return nil
    end,
}

robloxEnv.game = {
    GetService = function(self: any, serviceName: string)
        if serviceName == "ReplicatedStorage" then
            return mockReplicatedStorage
        end
        return {}
    end,
}

-- Helpers kiểm tra Test
local function assertEq(actual: any, expected: any, msg: string)
    if actual ~= expected then
        error(string.format("❌ ASSERT FAILED: %s (Expected %s, got %s)", msg, tostring(expected), tostring(actual)))
    end
end

local function assertTrue(condition: boolean, msg: string)
    if not condition then
        error("❌ ASSERT FAILED: " .. msg)
    end
end

print("🚀 Bắt đầu chạy Unit Tests với Lune (Luau CLI Runtime)...")
print("==================================================")

-- [1/3] Test PetConfig (>340 giống chó thực tế toàn thế giới + Pool 30 con/giờ theo kim tự tháp)
print("\n[1/3] Đang kiểm tra PetConfig.luau...")
local PetConfig = mockRequire("src/shared/config/PetConfig.luau")

-- Check >340 real breeds & exact pyramid counts & 0 duplicates
assertTrue(PetConfig.TotalPets > 340, "Tổng số giống chó phải > 340 giống toàn thế giới")
assertEq(PetConfig.TotalPets, 350, "Tổng số giống chó phải là 350")
assertEq(#PetConfig.PetsByRarity.Common, 140, "Common = 140 giống")
assertEq(#PetConfig.PetsByRarity.Rare, 95, "Rare = 95 giống")
assertEq(#PetConfig.PetsByRarity.Epic, 62, "Epic = 62 giống")
assertEq(#PetConfig.PetsByRarity.Legendary, 35, "Legendary = 35 giống")
assertEq(#PetConfig.PetsByRarity.Mythic, 18, "Mythic = 18 giống")

local seenNames: {[string]: boolean} = {}
for _, id in ipairs(PetConfig.PetOrder) do
    local p = PetConfig.Pets[id]
    assertTrue(not seenNames[p.DisplayName], "Không được trùng tên giống chó: " .. tostring(p.DisplayName))
    seenNames[p.DisplayName] = true
end

-- Check Rarities
assertTrue(PetConfig.Rarities.Common ~= nil, "Phải có độ hiếm Common")
assertTrue(PetConfig.Rarities.Mythic ~= nil, "Phải có độ hiếm Mythic")
assertEq(PetConfig.Rarities.Common.Chance, 50, "Tỷ lệ Common phải là 50%")
assertEq(PetConfig.Rarities.Mythic.Chance, 2, "Tỷ lệ Mythic phải là 2%")

-- Check Hourly 30-pet rotation pool (deterministic + rotates each hour)
local sampleTs = 1700000000
local poolA = PetConfig.GetHourlyPool(sampleTs)
local poolA2 = PetConfig.GetHourlyPool(sampleTs + 120)
local poolNextHour = PetConfig.GetHourlyPool(sampleTs + 3600)

assertEq(#poolA.petIds, 30, "Banner mỗi giờ phải có đúng 30 con")
assertEq(#poolA.byRarity.Mythic, 1, "Mỗi giờ có đúng 1 Mythic")
assertEq(#poolA.byRarity.Legendary, 3, "Mỗi giờ có đúng 3 Legendary")
assertEq(#poolA.byRarity.Epic, 5, "Mỗi giờ có đúng 5 Epic")
assertEq(#poolA.byRarity.Rare, 8, "Mỗi giờ có đúng 8 Rare")
assertEq(#poolA.byRarity.Common, 13, "Mỗi giờ có đúng 13 Common")
assertEq(poolA.petIds[1], poolA2.petIds[1], "Cùng 1 giờ phải đồng bộ giống hệt nhau")

local poolSet: {[string]: boolean} = {}
for _, id in ipairs(poolA.petIds) do
    poolSet[id] = true
end

local hasDifferenceNextHour = false
for i = 1, 30 do
    if poolA.petIds[i] ~= poolNextHour.petIds[i] then
        hasDifferenceNextHour = true
        break
    end
end
assertTrue(hasDifferenceNextHour, "Sang giờ tiếp theo banner 30 con phải đổi khác")

-- Check GetMaxExp formula
assertEq(PetConfig.GetMaxExp(1), 100, "Cấp 1 max exp = 100")
assertEq(PetConfig.GetMaxExp(2), 150, "Cấp 2 max exp = 150")
assertEq(PetConfig.GetMaxExp(5), 300, "Cấp 5 max exp = 300")

-- Check RollPet chỉ quay trúng trong 30 con của giờ hiện tại
local rollCounts = { Common = 0, Rare = 0, Epic = 0, Legendary = 0, Mythic = 0 }
for i = 1, 300 do
    local petId, petDef, rarityDef, genderDef = PetConfig.RollPet(sampleTs)
    assertTrue(petId ~= nil and #petId > 0, "petId hợp lệ")
    assertTrue(poolSet[petId] == true, "RollPet phải rơi đúng trong 30 con của giờ hiện tại")
    assertTrue(petDef ~= nil and petDef.DisplayName ~= nil, "petDef hợp lệ")
    assertTrue(rarityDef ~= nil and rarityDef.Name ~= nil, "rarityDef hợp lệ")
    assertTrue(genderDef ~= nil and (genderDef.Id == "Male" or genderDef.Id == "Female"), "gender hợp lệ")
    rollCounts[rarityDef.Id] = (rollCounts[rarityDef.Id] or 0) + 1
end
print(string.format("   ✓ 305 giống chó & Pool 30 con/giờ OK! 300 lượt RollPet: Common=%d, Rare=%d, Epic=%d, Leg=%d, Mythic=%d",
    rollCounts.Common, rollCounts.Rare, rollCounts.Epic, rollCounts.Legendary, rollCounts.Mythic))

-- [2/3] Test InventoryService
print("\n[2/3] Đang kiểm tra InventoryService.luau...")
local InventoryService = mockRequire("src/server/services/InventoryService.luau")

local mockPlayer = { Name = "TestPlayer_1" } :: any
local inv = InventoryService.InitPlayer(mockPlayer)
assertTrue(#inv >= 4, "Túi đồ mặc định có ít nhất 4 món")

local meatItem = nil
for _, item in ipairs(inv) do
    if item.id == "meat" then
        meatItem = item
        break
    end
end
assertTrue(meatItem ~= nil, "Phải có món thịt tươi (meat)")
assertEq(meatItem.count, 5, "Thịt tươi ban đầu = 5")

-- Thử ăn thịt tươi
local success, expGained, updatedInv = InventoryService.UseItem(mockPlayer, "meat")
assertTrue(success, "UseItem meat phải thành công")
assertEq(expGained, 50, "Ăn thịt tươi nhận đúng +50 EXP")

for _, item in ipairs(updatedInv) do
    if item.id == "meat" then
        assertEq(item.count, 4, "Số lượng thịt tươi sau khi ăn phải giảm còn 4")
    end
end

-- Thử ăn vật phẩm không tồn tại
local failSuccess, failExp = InventoryService.UseItem(mockPlayer, "item_not_found")
assertEq(failSuccess, false, "Item không tồn tại phải trả về false")
assertEq(failExp, 0, "Item không tồn tại exp = 0")

-- Thử cộng vật phẩm rơi từ Ải (drumstick + gacha_ticket) và kiểm tra không cho ăn Vé Gacha
local addedDrum, drumItem = InventoryService.AddItem(mockPlayer, "drumstick", 1)
assertTrue(addedDrum and drumItem ~= nil and drumItem.count == 1, "AddItem drumstick phải tăng lên 1")
local addedTicket = InventoryService.AddItem(mockPlayer, "gacha_ticket", 1)
assertTrue(addedTicket, "AddItem gacha_ticket phải thành công")
local feedTicketOk = InventoryService.UseItem(mockPlayer, "gacha_ticket")
assertEq(feedTicketOk, false, "Không được phép dùng UseItem cho ăn Vé Quay Gacha")
local consumeTicketOk = InventoryService.ConsumeItem(mockPlayer, "gacha_ticket", 1)
assertTrue(consumeTicketOk, "ConsumeItem gacha_ticket khi quay Gacha phải thành công")

-- Thử cộng Trang Bị Pet (gear_crown) và xác thực không bị ăn nhầm qua UseItem
local addedCrown, crownItem = InventoryService.AddItem(mockPlayer, "gear_crown", 1)
assertTrue(addedCrown and crownItem ~= nil and crownItem.kind == "gear" and crownItem.powerBonus == 140, "AddItem gear_crown (+140 Power) phải hợp lệ")
local feedGearOk = InventoryService.UseItem(mockPlayer, "gear_crown")
assertEq(feedGearOk, false, "Không được tiêu hao Trang Bị qua UseItem cho ăn")

InventoryService.RemovePlayer(mockPlayer)
print("   ✓ InventoryService: Khởi tạo túi đồ, trừ số lượng và tính EXP hoạt động chuẩn xác!")

-- [3/3] Test GachaService
print("\n[3/3] Đang kiểm tra GachaService.luau...")
local GachaService = mockRequire("src/server/services/GachaService.luau")

local gachaPlayer = { Name = "TestPlayer_2" } :: any
local col = GachaService.InitPlayer(gachaPlayer)
assertTrue(GachaService.HasPet(gachaPlayer, "Shiba"), "Mặc định người chơi phải có chú chó khởi đầu Shiba")
assertEq(GachaService.HasPet(gachaPlayer, "Cerberus"), false, "Mặc định chưa có Cerberus")

-- Roll x1
local results1, newCol1 = GachaService.Roll(gachaPlayer, 1)
assertEq(#results1, 1, "Roll x1 phải trả về đúng 1 kết quả")
assertTrue(GachaService.HasPet(gachaPlayer, results1[1].id), "Bộ sưu tập phải cập nhật thú cưng vừa trúng")

-- Roll x5
local results5, newCol5 = GachaService.Roll(gachaPlayer, 5)
assertEq(#results5, 5, "Roll x5 phải trả về đúng 5 kết quả")
for _, res in ipairs(results5) do
    assertTrue(res.id ~= nil, "Kết quả x5 chứa id hợp lệ")
    assertTrue(res.basePower > 0, "Sức mạnh cơ bản > 0")
    assertTrue(res.expPerFeed > 0, "EXP mỗi lần ăn > 0")
    assertTrue(GachaService.HasPet(gachaPlayer, res.id), "Pet trúng phải có trong collection")
end
print("   ✓ GachaService: Roll x1, Roll x5 và cập nhật Collection chuẩn xác!")

-- [4/4] Test CoinService (Ví Xu: 100 Xu khởi đầu, cộng Xu thắng ải, trừ Xu Gacha 100/450 không âm)
print("\n[4/4] Đang kiểm tra CoinService.luau...")
local CoinService = mockRequire("src/server/services/CoinService.luau")

local coinPlayer = { Name = "TestPlayer_Coin" } :: any
local startCoins = CoinService.InitPlayer(coinPlayer)
assertEq(startCoins, 100, "Người chơi mới phải có sẵn 100 Xu khởi đầu")

-- Quay x1 tốn 100 Xu -> còn 0 Xu
local spent1, rem1 = CoinService.SpendCoins(coinPlayer, 100)
assertTrue(spent1, "Đủ 100 Xu phải trừ thành công")
assertEq(rem1, 0, "Sau khi trừ 100 Xu số dư còn 0")

-- Không đủ Xu quay x1 -> bị chặn, giữ nguyên 0 Xu
local spentFail, remFail = CoinService.SpendCoins(coinPlayer, 100)
assertEq(spentFail, false, "Thiếu Xu phải bị chặn")
assertEq(remFail, 0, "Số dư giữ nguyên 0 Xu khi bị chặn")

-- Thắng ải 1 (+40 Xu) và ải 4 (+500 Xu) -> 540 Xu, quay x5 (-450 Xu) -> còn 90 Xu
CoinService.AddCoins(coinPlayer, 40)
CoinService.AddCoins(coinPlayer, 500)
assertEq(CoinService.GetCoins(coinPlayer), 540, "Cộng thưởng ải phải đạt 540 Xu")

local spent5, rem5 = CoinService.SpendCoins(coinPlayer, 450)
assertTrue(spent5, "Đủ 540 Xu phải trừ 450 Xu (x5) thành công")
assertEq(rem5, 90, "Sau khi quay x5 số dư còn 90 Xu")

CoinService.RemovePlayer(coinPlayer)
print("   ✓ CoinService: Khởi tạo 100 Xu, cộng Xu vượt ải, trừ Xu Gacha 100/450 & chặn âm chuẩn xác!")

print("\n==================================================")
print("🎉 TẤT CẢ UNIT TESTS ĐỀU PASS 100% TRÊN LUNE CLI!")
