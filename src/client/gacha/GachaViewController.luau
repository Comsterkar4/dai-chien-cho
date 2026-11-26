--!strict
-- GachaViewController.luau: Quản lý giao diện Triệu Hồi Linh Thú (GachaModal & GachaResultPopup)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local GachaViewController = {}

local Events = ReplicatedStorage:WaitForChild("Events")
local RollGachaEvent = Events:WaitForChild("RollGacha")
local GachaResultEvent = Events:WaitForChild("GachaResult")
local EquipPetEvent = Events:WaitForChild("EquipPet")

local lastRolledPetId: string? = nil
local isRolling = false

local function playEggShakeAnimation(eggGraphic: GuiObject)
    local origPos = eggGraphic.Position
    for i = 1, 10 do
        local offset = (i % 2 == 0) and 18 or -18
        eggGraphic.Position = origPos + UDim2.new(0, offset, 0, 0)
        eggGraphic.Rotation = (i % 2 == 0) and 12 or -12
        task.wait(0.06)
    end
    eggGraphic.Position = origPos
    eggGraphic.Rotation = 0
end

function GachaViewController.Init(mainHud: ScreenGui, UIFramework: any, WebStyleEngine: any)
    local toolbar = mainHud:WaitForChild("RightToolbar")
    local gachaBtn = toolbar:WaitForChild("GachaBtn") :: GuiButton

    local gachaModal = mainHud:WaitForChild("GachaModal") :: GuiObject
    local closeGachaBtn = gachaModal:WaitForChild("CloseBtn") :: GuiButton
    local roll1Btn = gachaModal:WaitForChild("Roll1Btn") :: GuiButton
    local roll5Btn = gachaModal:WaitForChild("Roll5Btn") :: GuiButton
    local eggGraphic = gachaModal.Stage:WaitForChild("EggGraphic") :: GuiObject
    local stageDesc = gachaModal.Stage:WaitForChild("StageDesc") :: TextLabel

    local resPopup = mainHud:WaitForChild("GachaResultPopup") :: GuiObject
    local resIcon = resPopup:WaitForChild("PetIcon") :: TextLabel
    local resName = resPopup:WaitForChild("PetName") :: TextLabel
    local resRarity = resPopup:WaitForChild("RarityBadge") :: TextLabel
    local resStats = resPopup:WaitForChild("StatsDesc") :: TextLabel
    local resEquip = resPopup:WaitForChild("EquipBtn") :: GuiButton
    local resDismiss = resPopup:WaitForChild("DismissBtn") :: GuiButton
    local resStroke = resPopup:FindFirstChild("PopupStroke") or resPopup:FindFirstChildOfClass("UIStroke")

    -- Kính mờ Glassmorphism cho Gacha Modal & Popup
    WebStyleEngine.ApplyGlassmorphism(gachaModal, {
        BorderRadius = 24,
        BackgroundColor = Color3.fromRGB(18, 20, 32),
        Transparency = 0.15,
        BorderColor = Color3.fromRGB(192, 132, 252),
        BorderTransparency = 0.5
    })

    WebStyleEngine.ApplyGlassmorphism(resPopup, {
        BorderRadius = 24,
        BackgroundColor = Color3.fromRGB(20, 22, 36),
        Transparency = 0.12,
        BorderColor = Color3.fromRGB(245, 158, 11),
        BorderTransparency = 0.4
    })

    WebStyleEngine.StyleButton(roll1Btn, "Purple", 14)
    WebStyleEngine.StyleButton(roll5Btn, "Gold", 14)
    WebStyleEngine.StyleButton(resEquip, "Success", 14)
    WebStyleEngine.StyleButton(resDismiss, "Danger", 14)

    -- Nút đóng tròn
    closeGachaBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    closeGachaBtn.BackgroundTransparency = 0.85
    local cCorner = closeGachaBtn:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", closeGachaBtn)
    cCorner.CornerRadius = UDim.new(1, 0)

    UIFramework.ApplySpringButton(roll1Btn, {HoverScale = 1.05, ClickScale = 0.93, Speed = 28, Damping = 0.70})
    UIFramework.ApplySpringButton(roll5Btn, {HoverScale = 1.05, ClickScale = 0.93, Speed = 28, Damping = 0.70})
    UIFramework.ApplySpringButton(resEquip, {HoverScale = 1.06, ClickScale = 0.92, Speed = 28, Damping = 0.70})
    UIFramework.ApplySpringButton(resDismiss, {HoverScale = 1.06, ClickScale = 0.92, Speed = 28, Damping = 0.70})
    UIFramework.ApplySpringButton(closeGachaBtn, {HoverScale = 1.15, ClickScale = 0.85, Speed = 32, Damping = 0.60})

    -- Toggle mở/đóng Gacha
    gachaBtn.MouseButton1Click:Connect(function()
        if not gachaModal.Visible then
            local invModal = mainHud:FindFirstChild("InventoryModal")
            local arenaModal = mainHud:FindFirstChild("ArenaModal")
            if invModal then invModal.Visible = false end
            if arenaModal then arenaModal.Visible = false end
            resPopup.Visible = false
            UIFramework.SpringOpenModal(gachaModal)
        else
            UIFramework.SpringCloseModal(gachaModal)
        end
    end)

    closeGachaBtn.MouseButton1Click:Connect(function()
        UIFramework.SpringCloseModal(gachaModal)
    end)

    ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
        if prompt.Name == "GachaPrompt" then
            local invModal = mainHud:FindFirstChild("InventoryModal")
            if invModal then invModal.Visible = false end
            UIFramework.SpringOpenModal(gachaModal)
        end
    end)

    -- Roll 1
    roll1Btn.MouseButton1Click:Connect(function()
        if isRolling then return end
        isRolling = true
        stageDesc.Text = "⏳ Đang triệu hồi linh thú..."
        task.spawn(playEggShakeAnimation, eggGraphic)
        RollGachaEvent:FireServer(1)
    end)

    -- Roll 5
    roll5Btn.MouseButton1Click:Connect(function()
        if isRolling then return end
        isRolling = true
        stageDesc.Text = "⏳ Đang triệu hồi 5 linh thú..."
        task.spawn(playEggShakeAnimation, eggGraphic)
        RollGachaEvent:FireServer(5)
    end)

    -- Nhận kết quả Gacha
    GachaResultEvent.OnClientEvent:Connect(function(results)
        task.wait(0.5)
        isRolling = false
        stageDesc.Text = "✨ Chạm vào vận may để triệu hồi Thần Khuyển! ✨"

        if not results or #results == 0 then return end

        local best = results[1]
        local rarityRank = { Mythic = 5, Legendary = 4, Epic = 3, Rare = 2, Common = 1 }
        for _, r in ipairs(results) do
            if (rarityRank[r.rarity] or 1) > (rarityRank[best.rarity] or 1) then
                best = r
            end
        end

        lastRolledPetId = best.id

        local rCol = Color3.new(unpack(best.rarityColor))
        resIcon.Text = best.icon or "🐶"
        resName.Text = best.name
        resRarity.Text = "★ " .. string.upper(best.rarityName) .. " ★"
        resRarity.BackgroundColor3 = rCol
        resStats.Text = string.format("⚔️ Sức Mạnh Cơ Bản: %d  •  +%d EXP/Lần Ăn", best.basePower, best.expPerFeed)
        if resStroke and resStroke:IsA("UIStroke") then
            resStroke.Color = rCol
        end

        gachaModal.Visible = false
        UIFramework.SpringOpenModal(resPopup)
    end)

    resEquip.MouseButton1Click:Connect(function()
        if lastRolledPetId then
            EquipPetEvent:FireServer(lastRolledPetId)
        end
        task.wait(0.2)
        UIFramework.SpringCloseModal(resPopup)
    end)

    resDismiss.MouseButton1Click:Connect(function()
        UIFramework.SpringCloseModal(resPopup)
    end)
end

return GachaViewController
