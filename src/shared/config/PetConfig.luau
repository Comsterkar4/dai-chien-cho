--!strict
-- PetConfig.luau: Hệ thống >300 giống chó (305 loài) chia theo 5 cấp độ hiếm + Pool Gacha 30 con luân phiên mỗi 1 giờ

local PetConfig = {}

PetConfig.Genders = {
    Male = {
        Id = "Male",
        Name = "Đực",
        Symbol = "♂",
        Color = Color3.fromRGB(65, 150, 255),
        BadgeColor = Color3.fromRGB(40, 120, 230),
        Bonus = "+5% Tốc độ di chuyển",
    },
    Female = {
        Id = "Female",
        Name = "Cái",
        Symbol = "♀",
        Color = Color3.fromRGB(255, 115, 185),
        BadgeColor = Color3.fromRGB(235, 80, 155),
        Bonus = "+5% EXP thưởng cho ăn",
        HasBow = true,
    },
}

PetConfig.Rarities = {
    Common = {
        Id = "Common",
        Name = "Thông Thường",
        Chance = 50,
        Rank = 1,
        Color = Color3.fromRGB(189, 195, 199),
        BadgeColor = Color3.fromRGB(120, 130, 140),
        PowerMultiplier = 1.0,
    },
    Rare = {
        Id = "Rare",
        Name = "Hiếm",
        Chance = 28,
        Rank = 2,
        Color = Color3.fromRGB(46, 204, 113),
        BadgeColor = Color3.fromRGB(39, 174, 96),
        PowerMultiplier = 1.3,
    },
    Epic = {
        Id = "Epic",
        Name = "Siêu Hiếm",
        Chance = 14,
        Rank = 3,
        Color = Color3.fromRGB(155, 89, 182),
        BadgeColor = Color3.fromRGB(142, 68, 173),
        PowerMultiplier = 1.8,
    },
    Legendary = {
        Id = "Legendary",
        Name = "Huyền Thoại",
        Chance = 6,
        Rank = 4,
        Color = Color3.fromRGB(241, 196, 15),
        BadgeColor = Color3.fromRGB(212, 172, 13),
        PowerMultiplier = 2.5,
    },
    Mythic = {
        Id = "Mythic",
        Name = "Thần Thoại",
        Chance = 2,
        Rank = 5,
        Color = Color3.fromRGB(231, 76, 60),
        BadgeColor = Color3.fromRGB(192, 57, 43),
        PowerMultiplier = 4.0,
    },
}

-- Cơ cấu 30 con chuẩn Kim Tự Tháp mỗi 1 tiếng (từ cao xuống thấp)
PetConfig.HourlyPoolQuota = {
    Mythic = 1,    -- 2%
    Legendary = 3, -- 6%
    Epic = 5,      -- 14%
    Rare = 8,      -- 28%
    Common = 13,   -- 50%
} -- Tổng = 30 con / giờ

PetConfig.RarityOrderDesc = { "Mythic", "Legendary", "Epic", "Rare", "Common" }

-- 12 giống chó cốt lõi ban đầu (giữ nguyên Id và thông số để tương thích ngược 100%)
PetConfig.Pets = {
    -- 1. THÔNG THƯỜNG (50%)
    Shiba = {
        Id = "Shiba",
        DisplayName = "Shiba Inu",
        Rarity = "Common",
        Icon = "🐶",
        Description = "Chú chó quốc dân năng động, trung thành và lanh lợi.",
        BasePower = 10,
        PowerPerLevel = 5,
        ExpPerFeed = 25,
        PrimaryColor = Color3.fromRGB(235, 145, 55),
        SecondaryColor = Color3.fromRGB(255, 250, 240),
        EarStyle = "Pointy",
        ModelTemplate = "Shiba",
    },
    Pug = {
        Id = "Pug",
        DisplayName = "Chó Mặt Xệ (Pug)",
        Rarity = "Common",
        Icon = "🐕",
        Description = "Khuôn mặt xệ ngộ nghĩnh, béo tròn và cực kỳ đáng yêu.",
        BasePower = 10,
        PowerPerLevel = 5,
        ExpPerFeed = 25,
        PrimaryColor = Color3.fromRGB(200, 180, 155),
        SecondaryColor = Color3.fromRGB(40, 40, 45),
        EarStyle = "Floppy",
        ModelTemplate = "Pug",
    },
    Chihuahua = {
        Id = "Chihuahua",
        DisplayName = "Chó Chihuahua",
        Rarity = "Common",
        Icon = "🐕‍🦺",
        Description = "Thân hình tí hon nhưng giọng sủa đầy nhiệt huyết.",
        BasePower = 10,
        PowerPerLevel = 5,
        ExpPerFeed = 25,
        PrimaryColor = Color3.fromRGB(235, 215, 180),
        SecondaryColor = Color3.fromRGB(250, 240, 225),
        EarStyle = "LargePointy",
        Scale = 0.8,
        ModelTemplate = "Chihuahua",
    },

    -- 2. HIẾM (28%)
    Corgi = {
        Id = "Corgi",
        DisplayName = "Chân Ngắn Corgi",
        Rarity = "Rare",
        Icon = "🦊",
        Description = "Bốn chân ngắn tũn cùng chiếc mông trái tim đốn tim người chơi.",
        BasePower = 15,
        PowerPerLevel = 7,
        ExpPerFeed = 30,
        PrimaryColor = Color3.fromRGB(240, 160, 60),
        SecondaryColor = Color3.fromRGB(255, 255, 255),
        EarStyle = "RoundedErect",
        ModelTemplate = "Corgi",
    },
    Poodle = {
        Id = "Poodle",
        DisplayName = "Poodle Quý Phái",
        Rarity = "Rare",
        Icon = "🐩",
        Description = "Bộ lông xoăn bồng bềnh phong cách quý tộc sang chảnh.",
        BasePower = 15,
        PowerPerLevel = 7,
        ExpPerFeed = 30,
        PrimaryColor = Color3.fromRGB(245, 235, 220),
        SecondaryColor = Color3.fromRGB(255, 250, 245),
        EarStyle = "Puffy",
        Special = "Puffs",
        ModelTemplate = "Poodle",
    },
    Dalmatian = {
        Id = "Dalmatian",
        DisplayName = "Chó Đốm Dalmatian",
        Rarity = "Rare",
        Icon = "🐾",
        Description = "Bộ lông trắng điểm xuyết những đốm đen vô cùng nổi bật.",
        BasePower = 15,
        PowerPerLevel = 7,
        ExpPerFeed = 30,
        PrimaryColor = Color3.fromRGB(255, 255, 255),
        SecondaryColor = Color3.fromRGB(30, 30, 35),
        EarStyle = "Floppy",
        Special = "Spots",
        ModelTemplate = "Dalmatian",
    },

    -- 3. SIÊU HIẾM (14%)
    Husky = {
        Id = "Husky",
        DisplayName = "Đại Ngáo Husky",
        Rarity = "Epic",
        Icon = "🐺",
        Description = "Ánh mắt xanh băng tuyết ngầu lòi nhưng tính tình thì cực kỳ tấu hài.",
        BasePower = 25,
        PowerPerLevel = 10,
        ExpPerFeed = 40,
        PrimaryColor = Color3.fromRGB(75, 80, 90),
        SecondaryColor = Color3.fromRGB(255, 255, 255),
        EyeColor = Color3.fromRGB(0, 220, 255),
        EarStyle = "Pointy",
        ModelTemplate = "Husky",
    },
    Golden = {
        Id = "Golden",
        DisplayName = "Golden Retriever",
        Rarity = "Epic",
        Icon = "🦮",
        Description = "Bộ lông vàng óng ả, ấm áp, thông minh và cực kỳ quấn chủ.",
        BasePower = 25,
        PowerPerLevel = 10,
        ExpPerFeed = 40,
        PrimaryColor = Color3.fromRGB(245, 185, 65),
        SecondaryColor = Color3.fromRGB(255, 220, 130),
        EarStyle = "FloppyLong",
        ModelTemplate = "Golden",
    },

    -- 4. HUYỀN THOẠI (6%)
    Samoyed = {
        Id = "Samoyed",
        DisplayName = "Bạch Tuyết Samoyed",
        Rarity = "Legendary",
        Icon = "❄️",
        Description = "Thiên thần lông tuyết trắng muốt cùng nụ cười tỏa sáng khắp thế giới.",
        BasePower = 40,
        PowerPerLevel = 15,
        ExpPerFeed = 55,
        PrimaryColor = Color3.fromRGB(255, 255, 255),
        SecondaryColor = Color3.fromRGB(255, 250, 245),
        EarStyle = "PointyFluffy",
        Aura = "GoldHalo",
        ModelTemplate = "Samoyed",
    },
    Doberman = {
        Id = "Doberman",
        DisplayName = "Dũng Sĩ Doberman",
        Rarity = "Legendary",
        Icon = "⚡",
        Description = "Vóc dáng cơ bắp, đôi tai nhọn dựng đứng và khí chất hộ vệ tối thượng.",
        BasePower = 40,
        PowerPerLevel = 15,
        ExpPerFeed = 55,
        PrimaryColor = Color3.fromRGB(30, 30, 35),
        SecondaryColor = Color3.fromRGB(160, 80, 40),
        EarStyle = "CroppedTall",
        Aura = "LightningSparks",
        ModelTemplate = "Doberman",
    },

    -- 5. THẦN THOẠI (2%)
    Cerberus = {
        Id = "Cerberus",
        DisplayName = "Chó Lửa Cerberus",
        Rarity = "Mythic",
        Icon = "🔥",
        Description = "Chiến khuyển địa ngục bọc trong ngọn lửa đỏ rực thiêu đốt mọi thử thách.",
        BasePower = 75,
        PowerPerLevel = 25,
        ExpPerFeed = 80,
        PrimaryColor = Color3.fromRGB(160, 25, 25),
        SecondaryColor = Color3.fromRGB(255, 100, 20),
        EyeColor = Color3.fromRGB(255, 240, 0),
        EarStyle = "DemonHorns",
        Aura = "InfernoFlame",
        ModelTemplate = "Cerberus",
    },
    CelestialWolf = {
        Id = "CelestialWolf",
        DisplayName = "Thần Khuyển Ánh Trăng",
        Rarity = "Mythic",
        Icon = "🌌",
        Description = "Khuyển thần giáng trần từ dải ngân hà, mang năng lượng ánh trăng vĩnh cửu.",
        BasePower = 75,
        PowerPerLevel = 25,
        ExpPerFeed = 80,
        PrimaryColor = Color3.fromRGB(20, 35, 80),
        SecondaryColor = Color3.fromRGB(0, 230, 255),
        EyeColor = Color3.fromRGB(180, 240, 255),
        EarStyle = "CelestialCrest",
        Aura = "CosmicStars",
        ModelTemplate = "CelestialWolf",
    },
}

--======================================================================
-- MỞ RỘNG DANH MỤC LÊN 350 GIỐNG CHÓ THỰC TẾ TRÊN TOÀN THẾ GIỚI
-- Common: 140 | Rare: 95 | Epic: 62 | Legendary: 35 | Mythic: 18 (Tổng = 350)
--======================================================================

local DogBreedsData = require(script.Parent:WaitForChild("DogBreedsData"))

local TIER_BASE_STATS: {[string]: {basePower: number, powerPerLevel: number, expPerFeed: number, primary: Color3, secondary: Color3, desc: string}} = {
    Common = {
        basePower = 10,
        powerPerLevel = 5,
        expPerFeed = 25,
        primary = Color3.fromRGB(220, 165, 95),
        secondary = Color3.fromRGB(252, 245, 232),
        desc = "Giống chó thuần chủng được công nhận quốc tế, thân thiện và rất quấn chủ.",
    },
    Rare = {
        basePower = 15,
        powerPerLevel = 7,
        expPerFeed = 30,
        primary = Color3.fromRGB(115, 215, 175),
        secondary = Color3.fromRGB(240, 255, 248),
        desc = "Giống chó quý hiếm với bản năng lanh lợi và sức bền vượt trội.",
    },
    Epic = {
        basePower = 25,
        powerPerLevel = 10,
        expPerFeed = 40,
        primary = Color3.fromRGB(145, 115, 245),
        secondary = Color3.fromRGB(238, 228, 255),
        desc = "Giống chó siêu hiếm nổi tiếng với vóc dáng uy nghiêm và lực chiến ấn tượng.",
    },
    Legendary = {
        basePower = 40,
        powerPerLevel = 15,
        expPerFeed = 55,
        primary = Color3.fromRGB(255, 205, 45),
        secondary = Color3.fromRGB(255, 245, 195),
        desc = "Quốc khuyển / giống chó huyền thoại hiếm có trên thế giới, sức mạnh áp đảo.",
    },
    Mythic = {
        basePower = 75,
        powerPerLevel = 25,
        expPerFeed = 80,
        primary = Color3.fromRGB(215, 55, 65),
        secondary = Color3.fromRGB(255, 215, 90),
        desc = "Chiến khuyển cổ đại cực hiếm mang khí chất thần thoại tối thượng.",
    },
}

for idx, entry in ipairs(DogBreedsData) do
    local petId = entry[1]
    local displayName = entry[2]
    local tier = entry[3]
    local icon = entry[4]
    local template = entry[5]
    local earStyle = entry[6]

    if not PetConfig.Pets[petId] then
        local stats = TIER_BASE_STATS[tier] or TIER_BASE_STATS.Common
        local powerBonus = idx % 5
        PetConfig.Pets[petId] = {
            Id = petId,
            DisplayName = displayName,
            Rarity = tier,
            Icon = icon,
            Description = stats.desc,
            BasePower = stats.basePower + powerBonus,
            PowerPerLevel = stats.powerPerLevel,
            ExpPerFeed = stats.expPerFeed,
            PrimaryColor = stats.primary,
            SecondaryColor = stats.secondary,
            EarStyle = earStyle,
            ModelTemplate = template,
        }
    end
end

-- Phân loại sẵn danh sách PetId theo từng cấp độ hiếm (đã sort cố định để PRNG đồng bộ mọi server)
PetConfig.PetsByRarity = {
    Mythic = {},
    Legendary = {},
    Epic = {},
    Rare = {},
    Common = {},
}

for id, pet in pairs(PetConfig.Pets) do
    local bucket = PetConfig.PetsByRarity[pet.Rarity]
    if bucket then
        table.insert(bucket, id)
    end
end

for _, tier in ipairs(PetConfig.RarityOrderDesc) do
    table.sort(PetConfig.PetsByRarity[tier])
end

-- Danh sách tất cả 305 giống chó xếp từ cao (Mythic) xuống thấp (Common) cho Sổ Sưu Tập
PetConfig.PetOrder = {}
for _, tier in ipairs(PetConfig.RarityOrderDesc) do
    for _, id in ipairs(PetConfig.PetsByRarity[tier]) do
        table.insert(PetConfig.PetOrder, id)
    end
end
PetConfig.TotalPets = #PetConfig.PetOrder

-- Tính EXP tối đa cần để lên cấp
function PetConfig.GetMaxExp(level: number): number
    return 100 + (level - 1) * 50
end

-- Bộ sinh số ngẫu nhiên xác định (LCG) đồng bộ tuyệt đối giữa mọi server theo giờ
local function nextSeededInt(seed: number, maxVal: number): (number, number)
    local nextSeed = (seed * 1103515245 + 12345) % 2147483648
    local value = (math.floor(nextSeed / 65536) % maxVal) + 1
    return value, nextSeed
end

local function pickDeterministicFromList(source: {string}, count: number, seed: number): ({string}, number)
    local pool = {}
    for _, v in ipairs(source) do
        table.insert(pool, v)
    end

    local picked = {}
    local curSeed = seed
    local limit = math.min(count, #pool)

    for _ = 1, limit do
        local idx
        idx, curSeed = nextSeededInt(curSeed, #pool)
        table.insert(picked, pool[idx])
        table.remove(pool, idx)
    end

    return picked, curSeed
end

-- Lấy Pool 30 con Gacha luân phiên mỗi 1 tiếng (sắp xếp từ Mythic -> Common)
function PetConfig.GetHourlyPool(timestamp: number?)
    local now = timestamp or os.time()
    local hourIndex = math.floor(now / 3600)
    local secondsRemaining = 3600 - (now % 3600)
    local seed = (hourIndex * 2654435761) % 2147483648

    local poolIds: {string} = {}
    local poolByRarity: {[string]: {string}} = {}

    for _, tier in ipairs(PetConfig.RarityOrderDesc) do
        local quota = PetConfig.HourlyPoolQuota[tier] or 0
        local picked
        picked, seed = pickDeterministicFromList(PetConfig.PetsByRarity[tier], quota, seed)
        poolByRarity[tier] = picked
        for _, petId in ipairs(picked) do
            table.insert(poolIds, petId)
        end
    end

    return {
        hourIndex = hourIndex,
        secondsRemaining = secondsRemaining,
        petIds = poolIds,
        byRarity = poolByRarity,
    }
end

-- Hàm quay Gacha trong Pool 30 con của giờ hiện tại với tỷ lệ 5 bậc (50/28/14/6/2) và giới tính 50/50
function PetConfig.RollPet(timestamp: number?)
    local roll = math.random() * 100
    local tier: string
    if roll <= 2 then
        tier = "Mythic"
    elseif roll <= 2 + 6 then
        tier = "Legendary"
    elseif roll <= 2 + 6 + 14 then
        tier = "Epic"
    elseif roll <= 2 + 6 + 14 + 28 then
        tier = "Rare"
    else
        tier = "Common"
    end

    local hourlyPool = PetConfig.GetHourlyPool(timestamp)
    local tierPool = hourlyPool.byRarity[tier]
    if not tierPool or #tierPool == 0 then
        tierPool = PetConfig.PetsByRarity[tier]
    end

    local chosenId = tierPool[math.random(1, #tierPool)]
    local genderId = (math.random() > 0.5) and "Male" or "Female"
    local genderDef = PetConfig.Genders[genderId]

    return chosenId, PetConfig.Pets[chosenId], PetConfig.Rarities[tier], genderDef
end

-- Gắn phụ kiện giới tính (Nơ hồng cho bé cái ♀, vòng cổ phong cách cho bé đực ♂)
function PetConfig.ApplyGenderVisuals(petModel: any, genderId: string)
    local head = petModel:FindFirstChild("Head") or petModel.PrimaryPart
    local collar = petModel:FindFirstChild("Collar")
    if not head then return end

    local existingBow = head:FindFirstChild("GenderBow")
    if existingBow then existingBow:Destroy() end

    if genderId == "Female" then
        if collar then
            collar.Color = Color3.fromRGB(255, 110, 180)
        end
        local bow = Instance.new("Part")
        bow.Name = "GenderBow"
        bow.Size = Vector3.new(0.6, 0.4, 0.4)
        bow.Color = Color3.fromRGB(255, 90, 160)
        bow.Material = Enum.Material.SmoothPlastic
        bow.CanCollide = false
        bow.CFrame = head.CFrame * CFrame.new(-0.85, 1.1, -0.2) * CFrame.Angles(0, 0, math.rad(-25))
        bow.Parent = head

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = head
        weld.Part1 = bow
        weld.Parent = bow
    else
        if collar then
            collar.Color = Color3.fromRGB(50, 140, 245)
        end
    end
end

return PetConfig
