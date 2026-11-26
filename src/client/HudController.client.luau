local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ProximityPromptService = game:GetService("ProximityPromptService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local UIFramework = require(Modules:WaitForChild("UIFramework"))

local Events = ReplicatedStorage:WaitForChild("Events")
local FeedEvent = Events:WaitForChild("FeedPet")
local UpdateEvent = Events:WaitForChild("UpdatePetData")
local UseItemEvent = Events:WaitForChild("UseItem")
local ToggleLeashEvent = Events:WaitForChild("ToggleLeash")
local InvUpdateEvent = Events:WaitForChild("UpdateInventory")
local RollGachaEvent = Events:WaitForChild("RollGacha")
local GachaResultEvent = Events:WaitForChild("GachaResult")
local EquipPetEvent = Events:WaitForChild("EquipPet")
local UpdateCollectionEvent = Events:WaitForChild("UpdatePetCollection")

-- 1. UI Elements
local card = script.Parent:WaitForChild("PetCard")
local nameLabel = card:WaitForChild("PetName")
local statsLabel = card:WaitForChild("StatsLabel")
local expBg = card:WaitForChild("ExpBg")
local expFill = expBg:WaitForChild("ExpFill")
local expText = expBg:WaitForChild("ExpText")
local cardStroke = card:FindFirstChildOfClass("UIStroke")

local toolbar = script.Parent:WaitForChild("RightToolbar")
local feedBtn = toolbar:WaitForChild("FeedFastBtn")
local bagBtn = toolbar:WaitForChild("BagBtn")
local leashBtn = toolbar:WaitForChild("LeashBtn")
local gachaBtn = toolbar:WaitForChild("GachaBtn")

local invModal = script.Parent:WaitForChild("InventoryModal")
local closeInvBtn = invModal:WaitForChild("CloseBtn")
local itemList = invModal:WaitForChild("ItemList")

local gachaModal = script.Parent:WaitForChild("GachaModal")
local closeGachaBtn = gachaModal:WaitForChild("CloseBtn")
local roll1Btn = gachaModal:WaitForChild("Roll1Btn")
local roll5Btn = gachaModal:WaitForChild("Roll5Btn")
local eggGraphic = gachaModal.Stage:WaitForChild("EggGraphic")
local stageDesc = gachaModal.Stage:WaitForChild("StageDesc")

local resPopup = script.Parent:WaitForChild("GachaResultPopup")
local resIcon = resPopup:WaitForChild("PetIcon")
local resName = resPopup:WaitForChild("PetName")
local resRarity = resPopup:WaitForChild("RarityBadge")
local resStats = resPopup:WaitForChild("StatsDesc")
local resEquip = resPopup:WaitForChild("EquipBtn")
local resDismiss = resPopup:WaitForChild("DismissBtn")
local resStroke = resPopup:FindFirstChild("PopupStroke") or resPopup:FindFirstChildOfClass("UIStroke")

-- 2. TÍCH HỢP UI FRAMEWORK: GẮN HIỆU ỨNG VẬT LÝ LÒ XO VÀO TẤT CẢ NÚT BẤM
UIFramework.ApplySpringButton(feedBtn, {HoverScale = 1.08, ClickScale = 0.90, Speed = 30, Damping = 0.65})
UIFramework.ApplySpringButton(bagBtn, {HoverScale = 1.08, ClickScale = 0.90, Speed = 30, Damping = 0.65})
UIFramework.ApplySpringButton(leashBtn, {HoverScale = 1.08, ClickScale = 0.90, Speed = 30, Damping = 0.65})
UIFramework.ApplySpringButton(gachaBtn, {HoverScale = 1.08, ClickScale = 0.90, Speed = 30, Damping = 0.65})
UIFramework.ApplySpringButton(roll1Btn, {HoverScale = 1.05, ClickScale = 0.93, Speed = 28, Damping = 0.70})
UIFramework.ApplySpringButton(roll5Btn, {HoverScale = 1.05, ClickScale = 0.93, Speed = 28, Damping = 0.70})
UIFramework.ApplySpringButton(equipBtn, {HoverScale = 1.06, ClickScale = 0.92, Speed = 28, Damping = 0.70})
UIFramework.ApplySpringButton(resDismiss, {HoverScale = 1.06, ClickScale = 0.92, Speed = 28, Damping = 0.70})
UIFramework.ApplySpringButton(closeInvBtn, {HoverScale = 1.15, ClickScale = 0.85, Speed = 32, Damping = 0.60})
UIFramework.ApplySpringButton(closeGachaBtn, {HoverScale = 1.15, ClickScale = 0.85, Speed = 32, Damping = 0.60})

local lastRolledPetId = nil
local isRolling = false

-- Popup EXP bay lên
local function spawnExpPopup(btn, text, col)
    local popup = Instance.new("TextLabel")
    popup.Size = UDim2.new(0, 150, 0, 35)
    popup.Position = UDim2.new(0, -140, 0, 10)
    popup.BackgroundTransparency = 1
    popup.Text = text or "+25 EXP ✨"
    popup.TextColor3 = col or Color3.fromRGB(255, 235, 70)
    popup.Font = Enum.Font.FredokaOne
    popup.TextSize = 20
    popup.ZIndex = 25
    popup.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 40, 0)
    stroke.Thickness = 2
    stroke.Parent = popup

    local tweenMove = TweenService:Create(popup, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, -180, 0, -35),
        TextTransparency = 1
    })
    local tweenStroke = TweenService:Create(stroke, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 1
    })

    tweenMove:Play()
    tweenStroke:Play()
    Debris:AddItem(popup, 0.7)
end

-- 3. Click nút Cho ăn nhanh
feedBtn.MouseButton1Click:Connect(function()
    FeedEvent:FireServer()
    spawnExpPopup(feedBtn, "+25 EXP 🥩")
end)

-- 4. Click nút Túi Đồ (Mở mượt bằng Spring Modal)
bagBtn.MouseButton1Click:Connect(function()
    if not invModal.Visible then
        gachaModal.Visible = false
        resPopup.Visible = false
        UIFramework.SpringOpenModal(invModal)
    else
        UIFramework.SpringCloseModal(invModal)
    end
end)

closeInvBtn.MouseButton1Click:Connect(function()
    UIFramework.SpringCloseModal(invModal)
end)

-- 5. Click nút Dắt Chó
local isLeashing = true
leashBtn.MouseButton1Click:Connect(function()
    isLeashing = not isLeashing
    ToggleLeashEvent:FireServer()
    if isLeashing then
        leashBtn.BackgroundColor3 = Color3.fromRGB(245, 160, 30)
        spawnExpPopup(leashBtn, "🦮 BẬT DẮT")
    else
        leashBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 130)
        spawnExpPopup(leashBtn, "❌ THẢ DÂY")
    end
end)

-- 6. Giao diện Gacha (Mở mượt bằng Spring Modal)
gachaBtn.MouseButton1Click:Connect(function()
    if not gachaModal.Visible then
        invModal.Visible = false
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
        invModal.Visible = false
        UIFramework.SpringOpenModal(gachaModal)
    end
end)

-- Hoạt ảnh lắc trứng khi bốc thăm
local function playEggShakeAnimation()
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

roll1Btn.MouseButton1Click:Connect(function()
    if isRolling then return end
    isRolling = true
    stageDesc.Text = "⏳ Đang triệu hồi linh thú..."
    task.spawn(playEggShakeAnimation)
    RollGachaEvent:FireServer(1)
end)

roll5Btn.MouseButton1Click:Connect(function()
    if isRolling then return end
    isRolling = true
    stageDesc.Text = "⏳ Đang triệu hồi 5 linh thú..."
    task.spawn(playEggShakeAnimation)
    RollGachaEvent:FireServer(5)
end)

-- 7. Nhận kết quả Gacha và mở Popup lò xo
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
    if resStroke then
        resStroke.Color = rCol
    end

    gachaModal.Visible = false
    UIFramework.SpringOpenModal(resPopup)
end)

resEquip.MouseButton1Click:Connect(function()
    if lastRolledPetId then
        EquipPetEvent:FireServer(lastRolledPetId)
        spawnExpPopup(resEquip, "🐾 ĐÃ TRANG BỊ!", Color3.fromRGB(80, 255, 120))
    end
    task.wait(0.2)
    UIFramework.SpringCloseModal(resPopup)
end)

resDismiss.MouseButton1Click:Connect(function()
    UIFramework.SpringCloseModal(resPopup)
end)

-- 8. Cập nhật Pet Data lên HUD
local rarityColorMap = {
    Common = Color3.fromRGB(189, 195, 199),
    Rare = Color3.fromRGB(46, 204, 113),
    Epic = Color3.fromRGB(155, 89, 182),
    Legendary = Color3.fromRGB(241, 196, 15),
    Mythic = Color3.fromRGB(231, 76, 60),
}

UpdateEvent.OnClientEvent:Connect(function(data)
    nameLabel.Text = (data.icon or "🐶") .. " " .. (data.name or "Shiba Inu")
    statsLabel.Text = string.format("Level %d  •  ⚔️ Power: %d", data.level, data.power)
    
    local rCol = rarityColorMap[data.rarity] or Color3.fromRGB(255, 205, 50)
    if cardStroke then
        cardStroke.Color = rCol
    end

    local ratio = math.clamp(data.exp / data.maxExp, 0, 1)
    local percent = math.floor(ratio * 100)
    expText.Text = string.format("%d / %d EXP (%d%%)", data.exp, data.maxExp, percent)

    local targetSize = UDim2.new(ratio, 0, 1, 0)
    local tween = TweenService:Create(expFill, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize})
    tween:Play()
end)

-- 9. Cập nhật hiển thị danh sách vật phẩm trong Túi Đồ
InvUpdateEvent.OnClientEvent:Connect(function(inventory)
    for _, child in ipairs(itemList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for _, it in ipairs(inventory) do
        local slot = Instance.new("Frame")
        slot.Name = "Slot_" .. it.id
        slot.Size = UDim2.new(1, -10, 0, 65)
        slot.BackgroundColor3 = Color3.fromRGB(42, 45, 58)
        slot.Parent = itemList

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = slot

        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 45, 0, 45)
        icon.Position = UDim2.new(0, 10, 0.5, -22)
        icon.BackgroundColor3 = Color3.fromRGB(55, 58, 72)
        icon.Text = it.icon
        icon.TextSize = 28
        icon.Parent = slot
        local icCorner = Instance.new("UICorner")
        icCorner.CornerRadius = UDim.new(0, 8)
        icCorner.Parent = icon

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(0, 180, 0, 20)
        title.Position = UDim2.new(0, 65, 0, 12)
        title.BackgroundTransparency = 1
        title.Text = it.name .. "  (x" .. it.count .. ")"
        title.TextColor3 = Color3.fromRGB(255, 230, 100)
        title.Font = Enum.Font.FredokaOne
        title.TextSize = 15
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = slot

        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(0, 180, 0, 18)
        desc.Position = UDim2.new(0, 65, 0, 34)
        desc.BackgroundTransparency = 1
        desc.Text = it.desc
        desc.TextColor3 = Color3.fromRGB(180, 190, 205)
        desc.Font = Enum.Font.GothamMedium
        desc.TextSize = 11
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = slot

        local useBtn = Instance.new("TextButton")
        useBtn.Size = UDim2.new(0, 85, 0, 40)
        useBtn.Position = UDim2.new(1, -95, 0.5, -20)
        useBtn.BackgroundColor3 = it.count > 0 and Color3.fromRGB(255, 130, 30) or Color3.fromRGB(90, 90, 100)
        useBtn.Text = it.count > 0 and "CHO ĂN" or "HẾT"
        useBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        useBtn.Font = Enum.Font.FredokaOne
        useBtn.TextSize = 13
        useBtn.AutoButtonColor = it.count > 0
        useBtn.Parent = slot

        local ubCorner = Instance.new("UICorner")
        ubCorner.CornerRadius = UDim.new(0, 10)
        ubCorner.Parent = useBtn

        UIFramework.ApplySpringButton(useBtn, {HoverScale = 1.08, ClickScale = 0.90, Speed = 30, Damping = 0.65})

        if it.count > 0 then
            useBtn.MouseButton1Click:Connect(function()
                UseItemEvent:FireServer(it.id)
                spawnExpPopup(useBtn, "+" .. it.exp .. " EXP ✨")
            end)
        end
    end
end)
