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
    }
}

PetConfig.Rarities = {
    Common = {
        Id = "Common",
        Name = "Thông Thường",
        Chance = 50,
        Color = Color3.fromRGB(189, 195, 199),
        BadgeColor = Color3.fromRGB(120, 130, 140),
        PowerMultiplier = 1.0,
    },
    Rare = {
        Id = "Rare",
        Name = "Hiếm",
        Chance = 28,
        Color = Color3.fromRGB(46, 204, 113),
        BadgeColor = Color3.fromRGB(39, 174, 96),
        PowerMultiplier = 1.3,
    },
    Epic = {
        Id = "Epic",
        Name = "Siêu Hiếm",
        Chance = 14,
        Color = Color3.fromRGB(155, 89, 182),
        BadgeColor = Color3.fromRGB(142, 68, 173),
        PowerMultiplier = 1.8,
    },
    Legendary = {
        Id = "Legendary",
        Name = "Huyền Thoại",
        Chance = 6,
        Color = Color3.fromRGB(241, 196, 15),
        BadgeColor = Color3.fromRGB(212, 172, 13),
        PowerMultiplier = 2.5,
    },
    Mythic = {
        Id = "Mythic",
        Name = "Thần Thoại",
        Chance = 2,
        Color = Color3.fromRGB(231, 76, 60),
        BadgeColor = Color3.fromRGB(192, 57, 43),
        PowerMultiplier = 4.0,
    }
}

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
    }
}

-- Tính EXP tối đa cần để lên cấp
function PetConfig.GetMaxExp(level)
    return 100 + (level - 1) * 50
end

-- Hàm quay Gacha với tỷ lệ chuẩn xác và chia ngẫu nhiên Giống Đực (50%) vs Giống Cái (50%)
function PetConfig.RollPet()
    local roll = math.random() * 100
    local tier
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

    local pool = {}
    for id, pet in pairs(PetConfig.Pets) do
        if pet.Rarity == tier then
            table.insert(pool, id)
        end
    end

    local chosenId = pool[math.random(1, #pool)]
    local genderId = (math.random() > 0.5) and "Male" or "Female"
    local genderDef = PetConfig.Genders[genderId]

    return chosenId, PetConfig.Pets[chosenId], PetConfig.Rarities[tier], genderDef
end

-- Gắn phụ kiện giới tính (Nơ hồng cho bé cái ♀, vòng cổ phong cách cho bé đực ♂)
function PetConfig.ApplyGenderVisuals(petModel, genderId)
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