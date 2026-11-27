--!strict
-- CollectionViewController.luau: Sổ Sưu Tập 305 loài chó (làm mờ khi chưa Gacha trúng, sáng lên & trang bị khi đã mở khóa)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ConfigFolder = Modules:FindFirstChild("Config") or Modules
local PetConfig = require(ConfigFolder:WaitForChild("PetConfig"))

local Events = ReplicatedStorage:WaitForChild("Events")
local UpdateCollectionEvent = Events:WaitForChild("UpdatePetCollection")
local UpdatePetDataEvent = Events:WaitForChild("UpdatePetData")
local EquipPetEvent = Events:WaitForChild("EquipPet")

local CollectionViewController = {}

local FILTER_TABS = {
    { key = "All", label = "Tất cả" },
    { key = "Mythic", label = "🔥 Thần Thoại" },
    { key = "Legendary", label = "⭐ Huyền Thoại" },
    { key = "Epic", label = "💜 Siêu Hiếm" },
    { key = "Rare", label = "💚 Hiếm" },
    { key = "Common", label = "⚪ Thường" },
}

function CollectionViewController.Init(mainHud: ScreenGui, UIFramework: any, WebStyleEngine: any)
    local unlockedSet: {[string]: boolean} = { Shiba = true }
    local equippedSet: {[string]: boolean} = { Shiba = true }
    local equippedCount = 1
    local maxEquipped = 1
    local playerLevel = 1
    local nextUnlockLevel: number? = 5
    local activeFilter = "All"

    -- Xóa UI cũ nếu reload
    local existingBtn = mainHud:FindFirstChild("CollectionToggleBtn")
    if existingBtn then existingBtn:Destroy() end
    local existingModal = mainHud:FindFirstChild("CollectionModal")
    if existingModal then existingModal:Destroy() end

    -- 1. Nút mở Sổ Sưu Tập ở góc trên phải (cạnh nút loa)
    local openBtn = Instance.new("TextButton")
    openBtn.Name = "CollectionToggleBtn"
    openBtn.Size = UDim2.new(0, 122, 0, 44)
    openBtn.Position = UDim2.new(1, -188, 0, 14)
    openBtn.Text = string.format("📖 1/%d", PetConfig.TotalPets)
    openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    openBtn.Font = Enum.Font.FredokaOne
    openBtn.TextSize = 15
    openBtn.ZIndex = 20
    openBtn.Parent = mainHud

    WebStyleEngine.StyleButton(openBtn, "Purple", 14)
    UIFramework.ApplySpringButton(openBtn, { HoverScale = 1.07, ClickScale = 0.92, Speed = 30, Damping = 0.65 })

    -- 2. Cửa sổ Sổ Sưu Tập 305 loài chó
    local modal = Instance.new("Frame")
    modal.Name = "CollectionModal"
    modal.Size = UDim2.new(0, 680, 0, 480)
    modal.Position = UDim2.new(0.5, 0, 0.5, 0)
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.Visible = false
    modal.ZIndex = 40
    modal.Parent = mainHud

    WebStyleEngine.ApplyGlassmorphism(modal, {
        BorderRadius = 24,
        BackgroundColor = Color3.fromRGB(18, 20, 34),
        Transparency = 0.06,
        BorderColor = Color3.fromRGB(190, 140, 255),
        BorderTransparency = 0.25,
        BorderWidth = 2,
    })

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -120, 0, 38)
    titleLabel.Position = UDim2.new(0, 20, 0, 14)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = string.format("📖 SỔ SƯU TẬP CHÓ (1 / %d)", PetConfig.TotalPets)
    titleLabel.TextColor3 = Color3.fromRGB(255, 225, 110)
    titleLabel.Font = Enum.Font.FredokaOne
    titleLabel.TextSize = 22
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 41
    titleLabel.Parent = modal

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 36, 0, 36)
    closeBtn.Position = UDim2.new(1, -48, 0, 14)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundTransparency = 0.85
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.FredokaOne
    closeBtn.TextSize = 18
    closeBtn.ZIndex = 41
    closeBtn.Parent = modal
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(1, 0)
    cCorner.Parent = closeBtn
    UIFramework.ApplySpringButton(closeBtn, { HoverScale = 1.12, ClickScale = 0.88, Speed = 32, Damping = 0.65 })

    -- Thanh Tab lọc theo 5 cấp độ hiếm
    local tabBar = Instance.new("Frame")
    tabBar.Name = "FilterTabs"
    tabBar.Size = UDim2.new(1, -32, 0, 36)
    tabBar.Position = UDim2.new(0, 16, 0, 58)
    tabBar.BackgroundTransparency = 1
    tabBar.ZIndex = 41
    tabBar.Parent = modal

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabBar

    -- Khung lưới thẻ chó (ScrollingFrame)
    local gridScroll = Instance.new("ScrollingFrame")
    gridScroll.Name = "PetGrid"
    gridScroll.Size = UDim2.new(1, -32, 1, -112)
    gridScroll.Position = UDim2.new(0, 16, 0, 102)
    gridScroll.BackgroundTransparency = 1
    gridScroll.BorderSizePixel = 0
    gridScroll.ScrollBarThickness = 6
    gridScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    gridScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    gridScroll.ZIndex = 41
    gridScroll.Parent = modal

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 120, 0, 128)
    gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = gridScroll

    local tabButtons: {[string]: TextButton} = {}

    local function countUnlocked(): number
        local n = 0
        for id, owned in pairs(unlockedSet) do
            if owned and PetConfig.Pets[id] then
                n += 1
            end
        end
        return n
    end

    local function updateCounters()
        local unlocked = countUnlocked()
        openBtn.Text = string.format("📖 %d/%d", unlocked, PetConfig.TotalPets)
        local milestoneText = nextUnlockLevel
            and string.format(" (Mốc tiếp: Lv.%d)", nextUnlockLevel)
            or " (👑 Khuyển Vương +25%)"
        titleLabel.Text = string.format("📖 %d/%d • 👤Lv.%d • 🐾%d/%d%s", unlocked, PetConfig.TotalPets, playerLevel, equippedCount, maxEquipped, milestoneText)
    end

    local function renderGrid()
        for _, child in ipairs(gridScroll:GetChildren()) do
            if child:IsA("GuiObject") then
                child:Destroy()
            end
        end

        local order = 0
        for _, petId in ipairs(PetConfig.PetOrder) do
            local pet = PetConfig.Pets[petId]
            if pet and (activeFilter == "All" or pet.Rarity == activeFilter) then
                order += 1
                local isUnlocked = unlockedSet[petId] == true
                local isEquipped = equippedSet[petId] == true
                local rarityDef = PetConfig.Rarities[pet.Rarity] or PetConfig.Rarities.Common

                local card = Instance.new("TextButton")
                card.Name = "Pet_" .. petId
                card.LayoutOrder = order
                card.AutoButtonColor = false
                card.Text = ""
                card.BackgroundColor3 = isEquipped and Color3.fromRGB(28, 56, 52) or (isUnlocked and Color3.fromRGB(34, 38, 58) or Color3.fromRGB(16, 18, 28))
                card.BackgroundTransparency = isUnlocked and 0.12 or 0.45
                card.BorderSizePixel = 0
                card.ZIndex = 42
                card.Parent = gridScroll

                local cardCorner = Instance.new("UICorner")
                cardCorner.CornerRadius = UDim.new(0, 14)
                cardCorner.Parent = card

                local cardStroke = Instance.new("UIStroke")
                cardStroke.Color = isEquipped and Color3.fromRGB(52, 211, 153) or (isUnlocked and rarityDef.Color or Color3.fromRGB(70, 75, 95))
                cardStroke.Thickness = isEquipped and 2.5 or (isUnlocked and 2 or 1)
                cardStroke.Transparency = isUnlocked and 0.15 or 0.6
                cardStroke.Parent = card

                -- Nhãn cấp độ hiếm
                local tierBadge = Instance.new("TextLabel")
                tierBadge.Size = UDim2.new(1, -10, 0, 18)
                tierBadge.Position = UDim2.new(0, 5, 0, 5)
                tierBadge.BackgroundColor3 = rarityDef.BadgeColor
                tierBadge.BackgroundTransparency = isUnlocked and 0.1 or 0.7
                tierBadge.Text = rarityDef.Name
                tierBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
                tierBadge.TextTransparency = isUnlocked and 0 or 0.55
                tierBadge.Font = Enum.Font.GothamBold
                tierBadge.TextSize = 10
                tierBadge.ZIndex = 43
                tierBadge.Parent = card
                local tbCorner = Instance.new("UICorner")
                tbCorner.CornerRadius = UDim.new(0, 6)
                tbCorner.Parent = tierBadge

                -- Biểu tượng chó (làm mờ tối khi chưa mở khóa, hiện rõ khi đã Gacha ra)
                local iconLabel = Instance.new("TextLabel")
                iconLabel.Size = UDim2.new(1, 0, 0, 52)
                iconLabel.Position = UDim2.new(0, 0, 0, 26)
                iconLabel.BackgroundTransparency = 1
                iconLabel.Text = isUnlocked and (pet.Icon or "🐶") or "🔒"
                iconLabel.TextColor3 = isUnlocked and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(90, 95, 115)
                iconLabel.TextTransparency = isUnlocked and 0 or 0.65
                iconLabel.TextSize = isUnlocked and 36 or 28
                iconLabel.ZIndex = 43
                iconLabel.Parent = card

                -- Tên giống chó (ẩn ??? khi chưa mở khóa)
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, -8, 0, 26)
                nameLabel.Position = UDim2.new(0, 4, 0, 78)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = isUnlocked and pet.DisplayName or "???"
                nameLabel.TextColor3 = isUnlocked and Color3.fromRGB(245, 245, 255) or Color3.fromRGB(120, 125, 145)
                nameLabel.TextTransparency = isUnlocked and 0 or 0.45
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 11
                nameLabel.TextWrapped = true
                nameLabel.ZIndex = 43
                nameLabel.Parent = card

                -- Dòng chỉ số / trạng thái
                local subLabel = Instance.new("TextLabel")
                subLabel.Size = UDim2.new(1, -8, 0, 16)
                subLabel.Position = UDim2.new(0, 4, 1, -20)
                subLabel.BackgroundTransparency = 1
                subLabel.Text = isEquipped and "✅ Đang dẫn (Tháo)" or (isUnlocked and string.format("⚔️ %d • + Dẫn theo", pet.BasePower) or "Chưa sở hữu")
                subLabel.TextColor3 = isEquipped and Color3.fromRGB(110, 255, 190) or (isUnlocked and Color3.fromRGB(130, 240, 180) or Color3.fromRGB(100, 105, 125))
                subLabel.Font = Enum.Font.GothamMedium
                subLabel.TextSize = 10
                subLabel.ZIndex = 43
                subLabel.Parent = card

                if isUnlocked then
                    card.MouseButton1Click:Connect(function()
                        EquipPetEvent:FireServer(petId)
                    end)
                end
            end
        end
    end

    local function updateTabStyles()
        for key, btn in pairs(tabButtons) do
            if key == activeFilter then
                WebStyleEngine.StyleButton(btn, "Gold", 10)
            else
                WebStyleEngine.StyleButton(btn, "Muted", 10)
            end
        end
    end

    for idx, tab in ipairs(FILTER_TABS) do
        local btn = Instance.new("TextButton")
        btn.Name = "Tab_" .. tab.key
        btn.LayoutOrder = idx
        btn.Size = UDim2.new(0, 102, 1, 0)
        btn.Text = tab.label
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.FredokaOne
        btn.TextSize = 12
        btn.ZIndex = 42
        btn.Parent = tabBar

        tabButtons[tab.key] = btn
        UIFramework.ApplySpringButton(btn, { HoverScale = 1.05, ClickScale = 0.94, Speed = 30, Damping = 0.65 })

        btn.MouseButton1Click:Connect(function()
            activeFilter = tab.key
            updateTabStyles()
            renderGrid()
        end)
    end

    updateTabStyles()
    updateCounters()

    local function toggleModal()
        if not modal.Visible then
            for _, otherName in ipairs({ "InventoryModal", "GachaModal", "GachaResultPopup", "ArenaModal" }) do
                local other = mainHud:FindFirstChild(otherName)
                if other and other:IsA("GuiObject") then
                    other.Visible = false
                end
            end
            renderGrid()
            UIFramework.SpringOpenModal(modal)
        else
            UIFramework.SpringCloseModal(modal)
        end
    end

    openBtn.MouseButton1Click:Connect(toggleModal)
    closeBtn.MouseButton1Click:Connect(function()
        UIFramework.SpringCloseModal(modal)
    end)

    -- Cập nhật ngay khi Server gửi bộ sưu tập mới (lúc vào game hoặc sau mỗi lượt Gacha)
    UpdateCollectionEvent.OnClientEvent:Connect(function(collection)
        if type(collection) ~= "table" then
            return
        end
        unlockedSet = {}
        for _, petId in ipairs(collection) do
            if type(petId) == "string" then
                unlockedSet[petId] = true
            end
        end
        updateCounters()
        if modal.Visible then
            renderGrid()
        end
    end)

    -- Đồng bộ danh sách tối đa 3 cún đang dẫn theo
    UpdatePetDataEvent.OnClientEvent:Connect(function(data)
        if type(data) ~= "table" or type(data.equippedPets) ~= "table" then
            return
        end
        equippedSet = {}
        local count = 0
        for _, petId in ipairs(data.equippedPets) do
            if type(petId) == "string" then
                equippedSet[petId] = true
                count += 1
            end
        end
        equippedCount = math.max(1, count)
        if tonumber(data.maxEquipped) then
            maxEquipped = tonumber(data.maxEquipped) :: number
        end
        if tonumber(data.playerLevel) then
            playerLevel = tonumber(data.playerLevel) :: number
        end
        nextUnlockLevel = tonumber(data.nextSlotUnlockLevel)
        updateCounters()
        if modal.Visible then
            renderGrid()
        end
    end)
end

return CollectionViewController
