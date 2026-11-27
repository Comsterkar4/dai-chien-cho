--!strict
-- SoundManager.luau: Quản lý phát nhạc nền (BGM) và hiệu ứng âm thanh (SFX) phía Client
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ConfigFolder = Modules:FindFirstChild("Config") or Modules
local SoundConfig = require(ConfigFolder:WaitForChild("SoundConfig"))

local SoundManager = {}

local isInitialized = false
local isMuted = false
local currentBgmName: string? = nil
local currentBgmSound: Sound? = nil
local bgmGroup: SoundGroup? = nil
local sfxGroup: SoundGroup? = nil
local sfxContainer: Folder? = nil

local function isValidSoundId(soundId: string?): boolean
    return type(soundId) == "string" and string.len(soundId) > 0
end

function SoundManager.Init()
    if isInitialized or not RunService:IsClient() then
        return
    end
    isInitialized = true

    local existingBgm = SoundService:FindFirstChild("BGMGroup")
    if existingBgm and existingBgm:IsA("SoundGroup") then
        bgmGroup = existingBgm
    else
        local g = Instance.new("SoundGroup")
        g.Name = "BGMGroup"
        g.Volume = 1
        g.Parent = SoundService
        bgmGroup = g
    end

    local existingSfx = SoundService:FindFirstChild("SFXGroup")
    if existingSfx and existingSfx:IsA("SoundGroup") then
        sfxGroup = existingSfx
    else
        local g = Instance.new("SoundGroup")
        g.Name = "SFXGroup"
        g.Volume = 1
        g.Parent = SoundService
        sfxGroup = g
    end

    local existingFolder = SoundService:FindFirstChild("GameAudioContainer")
    if existingFolder and existingFolder:IsA("Folder") then
        sfxContainer = existingFolder
    else
        local f = Instance.new("Folder")
        f.Name = "GameAudioContainer"
        f.Parent = SoundService
        sfxContainer = f
    end

    SoundManager.PlayBGM("Park", 0.8)
end

function SoundManager.PlaySFX(name: string, pitchJitter: number?)
    if not RunService:IsClient() or isMuted then
        return
    end
    if not isInitialized then
        SoundManager.Init()
    end

    local def = SoundConfig.SFX[name]
    if not def or not isValidSoundId(def.SoundId) then
        return
    end

    local container = sfxContainer or SoundService
    local sound = Instance.new("Sound")
    sound.Name = "SFX_" .. name
    sound.SoundId = def.SoundId
    sound.Volume = (def.Volume or 0.5) * SoundConfig.DefaultSFXVolume
    local basePitch = def.PlaybackSpeed or 1.0
    if pitchJitter and pitchJitter > 0 then
        local delta = (math.random() * 2 - 1) * pitchJitter
        sound.PlaybackSpeed = math.max(0.5, basePitch + delta)
    else
        sound.PlaybackSpeed = basePitch
    end
    sound.SoundGroup = sfxGroup
    sound.Parent = container

    pcall(function()
        sound:Play()
    end)

    sound.Ended:Connect(function()
        if sound.Parent then
            sound:Destroy()
        end
    end)
    Debris:AddItem(sound, 6)
end

function SoundManager.PlayBGM(name: string, fadeDuration: number?)
    if not RunService:IsClient() then
        return
    end
    if not isInitialized then
        SoundManager.Init()
    end
    if currentBgmName == name and currentBgmSound and currentBgmSound.Parent then
        return
    end

    local def = SoundConfig.BGM[name]
    if not def or not isValidSoundId(def.SoundId) then
        return
    end

    local duration = fadeDuration or 0.8
    local oldSound = currentBgmSound

    if oldSound and oldSound.Parent then
        local fadeOut = TweenService:Create(oldSound, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
            Volume = 0,
        })
        fadeOut:Play()
        task.delay(duration + 0.05, function()
            if oldSound and oldSound.Parent then
                oldSound:Stop()
                oldSound:Destroy()
            end
        end)
    end

    local container = sfxContainer or SoundService
    local newSound = Instance.new("Sound")
    newSound.Name = "BGM_" .. name
    newSound.SoundId = def.SoundId
    newSound.Looped = if def.Looped == nil then true else def.Looped
    newSound.PlaybackSpeed = def.PlaybackSpeed or 1.0
    newSound.Volume = 0
    newSound.SoundGroup = bgmGroup
    newSound.Parent = container

    currentBgmName = name
    currentBgmSound = newSound

    pcall(function()
        newSound:Play()
    end)

    local targetVolume = (def.Volume or 0.25) * (SoundConfig.DefaultBGMVolume / 0.28)
    TweenService:Create(newSound, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
        Volume = targetVolume,
    }):Play()
end

function SoundManager.SetMuted(muted: boolean)
    isMuted = muted
    local targetVol = muted and 0 or 1
    if bgmGroup then
        bgmGroup.Volume = targetVol
    end
    if sfxGroup then
        sfxGroup.Volume = targetVol
    end
end

function SoundManager.ToggleMute(): boolean
    SoundManager.SetMuted(not isMuted)
    return isMuted
end

function SoundManager.IsMuted(): boolean
    return isMuted
end

return SoundManager
