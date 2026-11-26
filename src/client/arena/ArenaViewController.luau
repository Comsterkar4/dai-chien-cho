--!strict
-- ArenaViewController.luau: Quản lý giao diện Đấu Trường Solo Pet (ArenaModal, Boss Selection & Real-time Combat Results)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Debris = game:GetService("Debris")

local ArenaViewController = {}

-- Danh sách 3 Boss thử thách trong Đấu Trường
local BOSS_LIST = {
    { id = "corgi_boss", name = "Corgi Tốc Độ", icon = "🦊", level = 3, power = 18, hp = 120, rewardExp = 60, rewardGold = 100, color = Color3.fromRGB(245, 158, 11) },
    { id = "husky_boss", name = "Husky Băng Giá", icon = "🐺", level = 8, power = 45, hp = 280, rewardExp = 180, rewardGold = 300, color = Color3.fromRGB(6, 182, 212) },
    { id = "tibetan_boss", name = "Ngao Tây Tạng Vương", icon = "🦁", level = 15, power = 110, hp = 650, rewardExp = 550, rewardGold = 1000, color = Color3.fromRGB(239, 68, 68) }
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

-- Tạo Popup kết quả trận đấu (Victory / Defeat Popup)
local function showBattleResult(mainHud: ScreenGui, result: {isVictory: boolean, bossName: string, rewardExp: number?, rewardGold: number?}, UIFramework: any, WebStyleEngine: any)
    local existing = mainHud:FindFirstChild("BattleResultModal")
    if existing then existing:Destroy() end

    local modal = Instance.new("Frame")
    modal.Name = "BattleResultModal"
    modal.Size = UDim2.new(0, 420, 0, 260)
    modal.Position = UDim2.new(0.5, 0, 0.5, 0)
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.ZIndex = 50
    modal.Parent = mainHud

    local isVic = result.isVictory
    local bColor = isVic and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(239, 68, 68)

    WebStyleEngine.ApplyGlassmorphism(modal, {
        BorderRadius = 24,
        BackgroundColor = Color3.fromRGB(20, 18, 30),
        Transparency = 0.05,
        BorderColor = bColor,
        BorderTransparency = 0.2,
        BorderWidth = 2.5
    })

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Position = UDim2.new(0, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = isVic and "🏆 CHIẾN THẮNG VANG DỘI! 🏆" or "💔 THẤT BẠI TIẾC NUỐI! 💔"
    title.TextColor3 = isVic and Color3.fromRGB(255, 220, 60) or Color3.fromRGB(255, 90, 90)
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 22
    title.ZIndex = 51
    title.Parent = modal

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -40, 0, 80)
    desc.Position = UDim2.new(0, 20, 0, 75)
    desc.BackgroundTransparency = 1
    if isVic then
        desc.Text = string.format("Hạ gục thành công %s!\n\n✨ Nhận: +%d EXP  •  💰 +%d Vàng", result.bossName, result.rewardExp or 0, result.rewardGold or 0)
    else
        desc.Text = string.format("Thú cưng đã bị %s áp đảo!\nHãy cho cún ăn để nâng cấp và phục thù nhé!\n\n✨ Nhận an ủi: +%d EXP", result.bossName, result.rewardExp or 15)
    end
    desc.TextColor3 = Color3.fromRGB(230, 225, 240)
    desc.Font = Enum.Font.GothamMedium
    desc.TextSize = 14
    desc.ZIndex = 51
    desc.Parent = modal

    local okBtn = Instance.new("TextButton")
    okBtn.Size = UDim2.new(0, 160, 0, 44)
    okBtn.Position = UDim2.new(0.5, -80, 1, -64)
    okBtn.Text = "XÁC NHẬN"
    okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    okBtn.Font = Enum.Font.FredokaOne
    okBtn.TextSize = 14
    okBtn.ZIndex = 51
    okBtn.Parent = modal

    WebStyleEngine.StyleButton(okBtn, isVic and "Gold" or "Danger", 14)
    UIFramework.ApplySpringButton(okBtn, {HoverScale = 1.08, ClickScale = 0.90, Speed = 30, Damping = 0.65})

    okBtn.MouseButton1Click:Connect(function()
        UIFramework.SpringCloseModal(modal)
        task.wait(0.5)
        modal:Destroy()
    end)

    UIFramework.SpringOpenModal(modal)
end

function ArenaViewController.Init(mainHud: ScreenGui, UIFramework: any, WebStyleEngine: any)
    local toolbar = mainHud:WaitForChild("RightToolbar")
    local battleBtn = toolbar:FindFirstChild("BattleBtn")

    local arenaModal = getOrCreateArenaModal(mainHud, WebStyleEngine)
    local closeBtn = arenaModal:WaitForChild("CloseBtn") :: GuiButton
    local bossList = arenaModal:WaitForChild("BossList") :: ScrollingFrame

    UIFramework.ApplySpringButton(closeBtn, {HoverScale = 1.15, ClickScale = 0.85, Speed = 32, Damping = 0.60})

    -- Lấy RemoteEvents
    local Events = ReplicatedStorage:WaitForChild("Events")
    local StartPetBattleEvent = Events:WaitForChild("StartPetBattle")
    local BattleUpdateEvent = Events:WaitForChild("BattleUpdate")
    local BattleFinishEvent = Events:WaitForChild("BattleFinish")

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

        -- Click Khiêu chiến: Đóng Modal và gửi lệnh lên Server bắt đầu trận chiến 3D
        fightBtn.MouseButton1Click:Connect(function()
            StartPetBattleEvent:FireServer(boss.id)
            UIFramework.SpringCloseModal(arenaModal)
        end)
    end

    -- Lắng nghe kết thúc trận đấu
    BattleFinishEvent.OnClientEvent:Connect(function(result)
        showBattleResult(mainHud, result, UIFramework, WebStyleEngine)
    end)

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
