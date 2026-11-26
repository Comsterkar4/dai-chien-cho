--!strict
-- ArenaViewController.luau: Quản lý giao diện Đấu Trường Solo Pet (ArenaModal, Boss Selection & HP Clash)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local ArenaViewController = {}

-- Danh sách 3 Boss thử thách trong Đấu Trường
local BOSS_LIST = {
    { id = "corgi_boss", name = "Corgi Tốc Độ", icon = "🦊", level = 3, power = 25, hp = 100, rewardExp = 50, rewardGold = 100, color = Color3.fromRGB(245, 158, 11) },
    { id = "husky_boss", name = "Husky Băng Giá", icon = "🐺", level = 8, power = 65, hp = 250, rewardExp = 150, rewardGold = 300, color = Color3.fromRGB(6, 182, 212) },
    { id = "tibetan_boss", name = "Ngao Tây Tạng Vương", icon = "🦁", level = 15, power = 150, hp = 600, rewardExp = 500, rewardGold = 1000, color = Color3.fromRGB(239, 68, 68) }
}

-- Khởi tạo hoặc tìm ArenaModal
local function getOrCreateArenaModal(mainHud: ScreenGui, WebStyleEngine: any): Frame
    local existing = mainHud:FindFirstChild("ArenaModal")
    if existing and existing:IsA("Frame") then
        return existing
    end

    local modal = Instance.new("Frame")
    modal.Name = "ArenaModal"
    modal.Size = UDim2.new(0, 520, 0, 420)
    modal.Position = UDim2.new(0.5, 0, 0.5, 0)
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.Visible = false
    modal.Parent = mainHud

    WebStyleEngine.ApplyGlassmorphism(modal, {
        BorderRadius = 24,
        BackgroundColor = Color3.fromRGB(18, 15, 25),
        Transparency = 0.12,
        BorderColor = Color3.fromRGB(239, 68, 68),
        BorderTransparency = 0.45,
        BorderWidth = 2
    })

    -- Tiêu đề Đấu Trường
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 0, 45)
    title.Position = UDim2.new(0, 20, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = "⚔️ ĐẤU TRƯỜNG SOLO PET ⚔️"
    title.TextColor3 = Color3.fromRGB(255, 90, 70)
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = modal

    -- Nút đóng
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 36, 0, 36)
    closeBtn.Position = UDim2.new(1, -48, 0, 15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundTransparency = 0.85
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.FredokaOne
    closeBtn.TextSize = 18
    closeBtn.Parent = modal
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(1, 0)
    cCorner.Parent = closeBtn

    -- Khung danh sách Boss
    local bossListFrame = Instance.new("ScrollingFrame")
    bossListFrame.Name = "BossList"
    bossListFrame.Size = UDim2.new(1, -40, 0, 320)
    bossListFrame.Position = UDim2.new(0, 20, 0, 75)
    bossListFrame.BackgroundTransparency = 1
    bossListFrame.ScrollBarThickness = 4
    bossListFrame.Parent = modal

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = bossListFrame

    return modal
end

function ArenaViewController.Init(mainHud: ScreenGui, UIFramework: any, WebStyleEngine: any)
    local toolbar = mainHud:WaitForChild("RightToolbar")
    local battleBtn = toolbar:FindFirstChild("BattleBtn")

    local arenaModal = getOrCreateArenaModal(mainHud, WebStyleEngine)
    local closeBtn = arenaModal:WaitForChild("CloseBtn") :: GuiButton
    local bossList = arenaModal:WaitForChild("BossList") :: ScrollingFrame

    UIFramework.ApplySpringButton(closeBtn, {HoverScale = 1.15, ClickScale = 0.85, Speed = 32, Damping = 0.60})

    -- Render 3 thẻ Boss thử thách
    for idx, boss in ipairs(BOSS_LIST) do
        local card = Instance.new("Frame")
        card.Name = "BossCard_" .. boss.id
        card.Size = UDim2.new(1, -10, 0, 90)
        card.LayoutOrder = idx
        card.Parent = bossList

        WebStyleEngine.ApplyGlassmorphism(card, {
            BorderRadius = 16,
            BackgroundColor = Color3.fromRGB(28, 22, 38),
            Transparency = 0.3,
            BorderColor = boss.color,
            BorderTransparency = 0.7,
            BorderWidth = 1.5
        })

        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 56, 0, 56)
        icon.Position = UDim2.new(0, 14, 0.5, -28)
        icon.BackgroundColor3 = Color3.fromRGB(45, 35, 60)
        icon.BackgroundTransparency = 0.3
        icon.Text = boss.icon
        icon.TextSize = 34
        icon.Parent = card
        local ic = Instance.new("UICorner")
        ic.CornerRadius = UDim.new(0, 12)
        ic.Parent = icon

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(0, 200, 0, 22)
        title.Position = UDim2.new(0, 82, 0, 16)
        title.BackgroundTransparency = 1
        title.Text = boss.name .. " (Lv." .. boss.level .. ")"
        title.TextColor3 = boss.color
        title.Font = Enum.Font.FredokaOne
        title.TextSize = 16
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = card

        local stats = Instance.new("TextLabel")
        stats.Size = UDim2.new(0, 240, 0, 18)
        stats.Position = UDim2.new(0, 82, 0, 42)
        stats.BackgroundTransparency = 1
        stats.Text = string.format("❤️ HP: %d  •  ⚔️ Sức Mạnh: %d", boss.hp, boss.power)
        stats.TextColor3 = Color3.fromRGB(200, 195, 215)
        stats.Font = Enum.Font.GothamMedium
        stats.TextSize = 12
        stats.TextXAlignment = Enum.TextXAlignment.Left
        stats.Parent = card

        local fightBtn = Instance.new("TextButton")
        fightBtn.Name = "FightBtn"
        fightBtn.Size = UDim2.new(0, 110, 0, 44)
        fightBtn.Position = UDim2.new(1, -125, 0.5, -22)
        fightBtn.Text = "KHIÊU CHIẾN"
        fightBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        fightBtn.Font = Enum.Font.FredokaOne
        fightBtn.TextSize = 13
        fightBtn.Parent = card

        WebStyleEngine.StyleButton(fightBtn, "Danger", 12)
        UIFramework.ApplySpringButton(fightBtn, {HoverScale = 1.08, ClickScale = 0.90, Speed = 30, Damping = 0.65})

        fightBtn.MouseButton1Click:Connect(function()
            fightBtn.Text = "ĐANG ĐẤU..."
            task.wait(1.2)
            fightBtn.Text = "CHIẾN THẮNG! 🏆"
            fightBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            task.wait(1.5)
            fightBtn.Text = "KHIÊU CHIẾN"
            fightBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        end)
    end

    -- Toggle mở/đóng Đấu Trường
    local function toggleArena()
        if not arenaModal.Visible then
            local invModal = mainHud:FindFirstChild("InventoryModal")
            local gachaModal = mainHud:FindFirstChild("GachaModal")
            local resPopup = mainHud:FindFirstChild("GachaResultPopup")
            if invModal then invModal.Visible = false end
            if gachaModal then gachaModal.Visible = false end
            if resPopup then resPopup.Visible = false end
            UIFramework.SpringOpenModal(arenaModal)
        else
            UIFramework.SpringCloseModal(arenaModal)
        end
    end

    if battleBtn and battleBtn:IsA("GuiButton") then
        battleBtn.MouseButton1Click:Connect(toggleArena)
    end

    closeBtn.MouseButton1Click:Connect(function()
        UIFramework.SpringCloseModal(arenaModal)
    end)

    -- Mở khi tương tác ProximityPrompt đấu trường (nếu có)
    ProximityPromptService.PromptTriggered:Connect(function(prompt)
        if prompt.Name == "ArenaPrompt" or prompt.Name == "BattlePrompt" then
            toggleArena()
        end
    end)
end

return ArenaViewController
