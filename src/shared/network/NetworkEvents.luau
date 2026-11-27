--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NetworkEvents = {}

local EVENT_NAMES = {
    "FeedPet",
    "UpdatePetData",
    "UseItem",
    "ToggleLeash",
    "UpdateInventory",
    "RollGacha",
    "GachaResult",
    "EquipPet",
    "UpdatePetCollection",
    "UpdateCoins",
    "StartPetBattle",
    "BattleUpdate",
    "BattleFinish",
    "PartyAction",
    "PartyUpdate",
}

local cachedEvents = {}

function NetworkEvents.Init()
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    if not eventsFolder then
        if RunService:IsServer() then
            eventsFolder = Instance.new("Folder")
            eventsFolder.Name = "Events"
            eventsFolder.Parent = ReplicatedStorage
        else
            eventsFolder = ReplicatedStorage:WaitForChild("Events", 10)
        end
    end

    for _, name in ipairs(EVENT_NAMES) do
        if RunService:IsServer() then
            local ev = eventsFolder:FindFirstChild(name)
            if not ev then
                ev = Instance.new("RemoteEvent")
                ev.Name = name
                ev.Parent = eventsFolder
            end
            cachedEvents[name] = ev
        else
            cachedEvents[name] = eventsFolder:WaitForChild(name, 10)
        end
    end

    NetworkEvents.Events = cachedEvents
    return cachedEvents
end

function NetworkEvents.Get(name: string)
    if not cachedEvents[name] then
        NetworkEvents.Init()
    end
    return cachedEvents[name]
end

return NetworkEvents
