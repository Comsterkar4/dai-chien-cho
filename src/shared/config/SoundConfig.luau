--!strict
-- SoundConfig.luau: Cấu hình tập trung toàn bộ nhạc nền (BGM) và hiệu ứng âm thanh (SFX)
-- Bạn có thể thay thế bất kỳ SoundId nào bằng âm thanh công khai từ Roblox Creator Store
-- hoặc âm thanh do chính tài khoản của bạn upload trong Roblox Studio.

export type SoundDef = {
    SoundId: string,
    Volume: number,
    PlaybackSpeed: number?,
    Looped: boolean?,
}

local SoundConfig = {}

SoundConfig.DefaultBGMVolume = 0.28
SoundConfig.DefaultSFXVolume = 0.65

-- Nhạc nền (Background Music)
SoundConfig.BGM = {
    Park = {
        SoundId = "rbxassetid://1848354536",   -- Nhạc nền vui tươi, nhẹ nhàng (Relaxed Scene)
        Volume = 0.25,
        PlaybackSpeed = 1.0,
        Looped = true,
    },
    Battle = {
        SoundId = "rbxassetid://1837879082",   -- Nhạc đấu trường sôi động (Action)
        Volume = 0.32,
        PlaybackSpeed = 1.0,
        Looped = true,
    },
}

-- Hiệu ứng âm thanh (Sound Effects)
SoundConfig.SFX = {
    -- Giao diện (UI)
    ButtonHover = {
        SoundId = "rbxassetid://6895079853",
        Volume = 0.22,
        PlaybackSpeed = 1.15,
    },
    ButtonClick = {
        SoundId = "rbxassetid://6895079853",
        Volume = 0.45,
        PlaybackSpeed = 0.95,
    },
    ModalOpen = {
        SoundId = "rbxassetid://6042053626",
        Volume = 0.35,
        PlaybackSpeed = 1.15,
    },
    ModalClose = {
        SoundId = "rbxassetid://6042053626",
        Volume = 0.28,
        PlaybackSpeed = 0.85,
    },
    Reject = {
        SoundId = "rbxassetid://2865228021",
        Volume = 0.45,
        PlaybackSpeed = 0.9,
    },

    -- Chăm sóc thú cưng
    FeedEat = {
        SoundId = "rbxassetid://3073752340",
        Volume = 0.5,
        PlaybackSpeed = 1.05,
    },
    LevelUp = {
        SoundId = "rbxassetid://4612375233",
        Volume = 0.65,
        PlaybackSpeed = 1.0,
    },
    LeashToggle = {
        SoundId = "rbxassetid://6895079853",
        Volume = 0.4,
        PlaybackSpeed = 1.3,
    },

    -- Gacha Linh Thú
    EggShake = {
        SoundId = "rbxassetid://6042053626",
        Volume = 0.3,
        PlaybackSpeed = 1.35,
    },
    GachaReveal = {
        SoundId = "rbxassetid://4612375233",
        Volume = 0.55,
        PlaybackSpeed = 1.1,
    },
    GachaRare = {
        SoundId = "rbxassetid://12222253",
        Volume = 0.7,
        PlaybackSpeed = 1.0,
    },

    -- Đấu Trường Solo Pet
    BattleStart = {
        SoundId = "rbxassetid://12222242",
        Volume = 0.55,
        PlaybackSpeed = 1.0,
    },
    AttackHit = {
        SoundId = "rbxassetid://3932505023",
        Volume = 0.5,
        PlaybackSpeed = 1.0,
    },
    CritHit = {
        SoundId = "rbxassetid://3932505023",
        Volume = 0.75,
        PlaybackSpeed = 1.28,
    },
    Victory = {
        SoundId = "rbxassetid://12222253",
        Volume = 0.65,
        PlaybackSpeed = 1.05,
    },
    Defeat = {
        SoundId = "rbxassetid://2865228021",
        Volume = 0.55,
        PlaybackSpeed = 0.75,
    },
}

return SoundConfig
