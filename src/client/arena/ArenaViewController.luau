--!strict
-- ArenaViewController.luau: Quản lý giao diện Đấu Trường Solo Pet (ArenaModal, Boss Selection & Real-time Combat Results)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local ArenaViewController = {}

local Modules = ReplicatedStorage:WaitForChild("Modules")
local FrameworkFolder = Modules:FindFirstChild("Framework") or Modules
local SoundManagerModule = FrameworkFolder:FindFirstChild("SoundManager")
local SoundManager: any = SoundManagerModule and require(SoundManagerModule) or nil

-- Danh sách 5 Ải Đánh Quái / Boss Farm Xu (tăng độ khó + Boss Skill mỗi 3 lượt, mở slot 1..5 Pet theo Lv.5/10/15/20/30)
local BOSS_LIST = {
    { id = "stage1_pug", name = "Ải 1: Pug Tập Sự", icon = "🐕", level = 1, power = 16, hp = 160, rewardExp = 40, rewardCoins = 40, color = Color3.fromRGB(34, 197, 94) },
    { id = "corgi_boss", name = "Ải 2: Corgi Tốc Độ", icon = "🦊", level = 5, power = 55, hp = 480, rewardExp = 80, rewardCoins = 100, color = Color3.fromRGB(245, 158, 11) },
    { id = "husky_boss", name = "Ải 3: Husky Băng Giá", icon = "🐺", level = 10, power = 135, hp = 1250, rewardExp = 200, rewardCoins = 250, color = Color3.fromRGB(6, 182, 212) },
    { id = "doberman_boss", name = "Ải 4: Dũng Sĩ Doberman", icon = "⚡", level = 15, power = 260, hp = 2600, rewardExp = 360, rewardCoins = 500, color = Color3.fromRGB(168, 85, 247) },
    { id = "tibetan_boss", name = "Ải 5: Ngao Tây Tạng Vương", icon = "🦁", level = 20, power = 450, hp = 5000, rewardExp = 650, rewardCoins = 1000, color = Color3.fromRGB(239, 68, 68) },
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
    title.Text = "⚔️ VƯỢT ẢI ĐÁNH QUÁI FARM XU ⚔️"
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
    bossListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    bossListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    bossListFrame.Parent = modal

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = bossListFrame

    return modal
end

-- Tạo Popup kết quả trận đấu (Victory / Defeat Popup)
local function showBattleResult(mainHud: ScreenGui, result: {isVictory: boolean, bossName: string, rewardExp: number?, rewardCoins: number?, rewardGold: number?, droppedItem: {id: string, name: string, icon: string}?}, UIFramework: any, WebStyleEngine: any)
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
        local coinsEarned = result.rewardCoins or result.rewardGold or 0
        local rewardLine = coinsEarned > 0
            and string.format("🪙 Nhận: +%d Xu  •  ✨ +%d EXP", coinsEarned, result.rewardExp or 0)
            or string.format("✨ Nhận: +%d EXP", result.rewardExp or 0)
        if type(result.droppedItem) == "table" and result.droppedItem.name then
            rewardLine = rewardLine .. string.format("\n🎁 Rơi vật phẩm: +1 %s %s", tostring(result.droppedItem.icon or "🎁"), tostring(result.droppedItem.name))
        end
        desc.Text = string.format("Vượt ải thành công %s!\n\n%s", result.bossName, rewardLine)
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

-- Hiển thị thông báo từ chối khiêu chiến (tách biệt với kết quả thua trận)
local function showBattleRejection(mainHud: ScreenGui, message: string, UIFramework: any, WebStyleEngine: any)
    local existing = mainHud:FindFirstChild("BattleRejectionModal")
    if existing then existing:Destroy() end

    local modal = Instance.new("Frame")
    modal.Name = "BattleRejectionModal"
    modal.Size = UDim2.new(0, 400, 0, 220)
    modal.Position = UDim2.new(0.5, 0, 0.5, 0)
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.ZIndex = 50
    modal.Parent = mainHud

    WebStyleEngine.ApplyGlassmorphism(modal, {
        BorderRadius = 24,
        BackgroundColor = Color3.fromRGB(20, 18, 30),
        Transparency = 0.05,
        BorderColor = Color3.fromRGB(245, 158, 11),
        BorderTransparency = 0.2,
        BorderWidth = 2.5
    })

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 42)
    title.Position = UDim2.new(0, 0, 0, 18)
    title.BackgroundTransparency = 1
    title.Text = "⚠️ KHÔNG THỂ KHIÊU CHIẾN"
    title.TextColor3 = Color3.fromRGB(245, 158, 11)
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 20
    title.ZIndex = 51
    title.Parent = modal

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -40, 0, 70)
    desc.Position = UDim2.new(0, 20, 0, 68)
    desc.BackgroundTransparency = 1
    desc.Text = message
    desc.TextWrapped = true
    desc.TextColor3 = Color3.fromRGB(230, 225, 240)
    desc.Font = Enum.Font.GothamMedium
    desc.TextSize = 14
    desc.ZIndex = 51
    desc.Parent = modal

    local okBtn = Instance.new("TextButton")
    okBtn.Size = UDim2.new(0, 140, 0, 40)
    okBtn.Position = UDim2.new(0.5, -70, 1, -58)
    okBtn.Text = "ĐÓNG"
    okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    okBtn.Font = Enum.Font.FredokaOne
    okBtn.TextSize = 14
    okBtn.ZIndex = 51
    okBtn.Parent = modal

    WebStyleEngine.StyleButton(okBtn, "Gold", 14)
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
    local PartyActionEvent = Events:WaitForChild("PartyAction", 10)
    local PartyUpdateEvent = Events:WaitForChild("PartyUpdate", 10)

    -- Thanh Banner Tổ Đội Co-op tối đa 3 người (ở giữa phía trên màn hình)
    local existingPartyBanner = mainHud:FindFirstChild("PartyLobbyBanner")
    if existingPartyBanner then
        existingPartyBanner:Destroy()
    end

    local partyBanner = Instance.new("Frame")
    partyBanner.Name = "PartyLobbyBanner"
    partyBanner.Size = UDim2.new(0, 470, 0, 88)
    partyBanner.Position = UDim2.new(0.5, 0, 0, 14)
    partyBanner.AnchorPoint = Vector2.new(0.5, 0)
    partyBanner.Visible = false
    partyBanner.ZIndex = 48
    partyBanner.Parent = mainHud

    WebStyleEngine.ApplyGlassmorphism(partyBanner, {
        BorderRadius = 18,
        BackgroundColor = Color3.fromRGB(22, 20, 38),
        Transparency = 0.08,
        BorderColor = Color3.fromRGB(255, 195, 65),
        BorderTransparency = 0.2,
        BorderWidth = 2,
    })

    local partyTitle = Instance.new("TextLabel")
    partyTitle.Size = UDim2.new(1, -24, 0, 24)
    partyTitle.Position = UDim2.new(0, 12, 0, 8)
    partyTitle.BackgroundTransparency = 1
    partyTitle.Text = "👥 TỔ ĐỘI VƯỢT ẢI (1/3) • ⏱️ 10s"
    partyTitle.TextColor3 = Color3.fromRGB(255, 220, 80)
    partyTitle.Font = Enum.Font.FredokaOne
    partyTitle.TextSize = 15
    partyTitle.TextXAlignment = Enum.TextXAlignment.Left
    partyTitle.ZIndex = 49
    partyTitle.Parent = partyBanner

    local partyMembersLbl = Instance.new("TextLabel")
    partyMembersLbl.Size = UDim2.new(0, 250, 0, 36)
    partyMembersLbl.Position = UDim2.new(0, 12, 0, 36)
    partyMembersLbl.BackgroundTransparency = 1
    partyMembersLbl.Text = "Thành viên: ..."
    partyMembersLbl.TextColor3 = Color3.fromRGB(215, 220, 240)
    partyMembersLbl.Font = Enum.Font.GothamMedium
    partyMembersLbl.TextSize = 12
    partyMembersLbl.TextXAlignment = Enum.TextXAlignment.Left
    partyMembersLbl.TextWrapped = true
    partyMembersLbl.ZIndex = 49
    partyMembersLbl.Parent = partyBanner

    local primaryActionBtn = Instance.new("TextButton")
    primaryActionBtn.Name = "PrimaryPartyBtn"
    primaryActionBtn.Size = UDim2.new(0, 112, 0, 36)
    primaryActionBtn.Position = UDim2.new(1, -196, 1, -46)
    primaryActionBtn.Text = "THAM GIA"
    primaryActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    primaryActionBtn.Font = Enum.Font.FredokaOne
    primaryActionBtn.TextSize = 13
    primaryActionBtn.ZIndex = 49
    primaryActionBtn.Parent = partyBanner
    WebStyleEngine.StyleButton(primaryActionBtn, "Success", 12)
    UIFramework.ApplySpringButton(primaryActionBtn, { HoverScale = 1.06, ClickScale = 0.92, Speed = 30, Damping = 0.65 })

    local cancelPartyBtn = Instance.new("TextButton")
    cancelPartyBtn.Name = "CancelPartyBtn"
    cancelPartyBtn.Size = UDim2.new(0, 70, 0, 36)
    cancelPartyBtn.Position = UDim2.new(1, -78, 1, -46)
    cancelPartyBtn.Text = "HỦY"
    cancelPartyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelPartyBtn.Font = Enum.Font.FredokaOne
    cancelPartyBtn.TextSize = 12
    cancelPartyBtn.ZIndex = 49
    cancelPartyBtn.Parent = partyBanner
    WebStyleEngine.StyleButton(cancelPartyBtn, "Danger", 12)
    UIFramework.ApplySpringButton(cancelPartyBtn, { HoverScale = 1.06, ClickScale = 0.92, Speed = 30, Damping = 0.65 })

    local currentPrimaryAction = "join"
    primaryActionBtn.MouseButton1Click:Connect(function()
        if PartyActionEvent and PartyActionEvent:IsA("RemoteEvent") then
            PartyActionEvent:FireServer(currentPrimaryAction)
        end
    end)
    cancelPartyBtn.MouseButton1Click:Connect(function()
        if PartyActionEvent and PartyActionEvent:IsA("RemoteEvent") then
            PartyActionEvent:FireServer("cancel")
        end
    end)

    if PartyUpdateEvent and PartyUpdateEvent:IsA("RemoteEvent") then
        PartyUpdateEvent.OnClientEvent:Connect(function(payload)
            if type(payload) ~= "table" then return end
            if payload.state == "Open" then
                local lp = Players.LocalPlayer
                local isHost = lp and (payload.hostUserId == lp.UserId)
                local membersList = type(payload.members) == "table" and payload.members or {}
                local alreadyJoined = false
                if lp then
                    for _, name in ipairs(membersList) do
                        if name == lp.DisplayName then
                            alreadyJoined = true
                            break
                        end
                    end
                end

                partyTitle.Text = string.format(
                    "👥 %s (%d/%d) • ⏱️ %ds",
                    tostring(payload.bossName or "Vượt Ải"),
                    tonumber(payload.memberCount) or 1,
                    tonumber(payload.maxMembers) or 3,
                    tonumber(payload.timeLeft) or 0
                )
                partyMembersLbl.Text = "Thành viên: " .. table.concat(membersList, ", ")

                if isHost then
                    currentPrimaryAction = "start_now"
                    primaryActionBtn.Text = "VÀO ẢI NGAY"
                    primaryActionBtn.Visible = true
                    cancelPartyBtn.Text = "HỦY"
                    cancelPartyBtn.Visible = true
                    WebStyleEngine.StyleButton(primaryActionBtn, "Gold", 12)
                elseif alreadyJoined then
                    primaryActionBtn.Visible = false
                    cancelPartyBtn.Text = "RỜI ĐỘI"
                    cancelPartyBtn.Visible = true
                else
                    currentPrimaryAction = "join"
                    primaryActionBtn.Text = "THAM GIA"
                    primaryActionBtn.Visible = true
                    cancelPartyBtn.Visible = false
                    WebStyleEngine.StyleButton(primaryActionBtn, "Success", 12)
                end

                partyBanner.Visible = true
            else
                partyBanner.Visible = false
            end
        end)
    end

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
        stats.Size = UDim2.new(0, 270, 0, 34)
        stats.Position = UDim2.new(0, 82, 0, 40)
        stats.BackgroundTransparency = 1
        stats.Text = string.format("❤️ HP: %d • ⚔️ %d\n🪙 +%d Xu • ✨ +%d EXP", boss.hp, boss.power, boss.rewardCoins, boss.rewardExp)
        stats.TextColor3 = Color3.fromRGB(220, 225, 240)
        stats.Font = Enum.Font.GothamMedium
        stats.TextSize = 11
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

    -- Lắng nghe cập nhật / từ chối khiêu chiến
    BattleUpdateEvent.OnClientEvent:Connect(function(payload)
        if type(payload) ~= "table" then
            return
        end
        if payload.state == "Rejected" then
            if SoundManager then
                SoundManager.PlaySFX("Reject")
            end
            showBattleRejection(
                mainHud,
                tostring(payload.message or "Không thể bắt đầu trận đấu lúc này!"),
                UIFramework,
                WebStyleEngine
            )
        elseif payload.state == "Ready" then
            if SoundManager then
                SoundManager.PlaySFX("BattleStart")
                SoundManager.PlayBGM("Battle", 0.6)
            end
        elseif payload.state == "Round" then
            if SoundManager then
                SoundManager.PlaySFX(payload.isCrit and "CritHit" or "AttackHit", 0.08)
            end
        end
    end)

    -- Lắng nghe kết thúc trận đấu
    BattleFinishEvent.OnClientEvent:Connect(function(result)
        if SoundManager and type(result) == "table" then
            SoundManager.PlaySFX(result.isVictory and "Victory" or "Defeat")
            task.delay(2.5, function()
                SoundManager.PlayBGM("Park", 1.0)
            end)
        end
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
