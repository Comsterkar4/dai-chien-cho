--!strict
-- ToolbarViewController.luau: Quản lý thanh công cụ bên phải (RightToolbar) & Thẻ thông tin thú cưng (PetCard)
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ToolbarViewController = {}

local Events = ReplicatedStorage:WaitForChild("Events")
local FeedEvent = Events:WaitForChild("FeedPet")
local UpdateEvent = Events:WaitForChild("UpdatePetData")
local ToggleLeashEvent = Events:WaitForChild("ToggleLeash")
local UpdateCoinsEvent = Events:WaitForChild("UpdateCoins", 10)

local Modules = ReplicatedStorage:WaitForChild("Modules")
local FrameworkFolder = Modules:FindFirstChild("Framework") or Modules
local SoundManagerModule = FrameworkFolder:FindFirstChild("SoundManager")
local SoundManager: any = SoundManagerModule and require(SoundManagerModule) or nil

local rarityColorMap = {
    Common = Color3.fromRGB(189, 195, 199),
    Rare = Color3.fromRGB(46, 204, 113),
    Epic = Color3.fromRGB(155, 89, 182),
    Legendary = Color3.fromRGB(241, 196, 15),
    Mythic = Color3.fromRGB(231, 76, 60),
}

function ToolbarViewController.SpawnExpPopup(btn: GuiButton, text: string?, col: Color3?)
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
    stroke.Color = Color3.fromRGB(50, 25, 0)
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

function ToolbarViewController.Init(mainHud: ScreenGui, UIFramework: any, WebStyleEngine: any)
    local toolbar = mainHud:WaitForChild("RightToolbar")
    local feedBtn = toolbar:WaitForChild("FeedFastBtn") :: GuiButton
    local bagBtn = toolbar:WaitForChild("BagBtn") :: GuiButton
    local leashBtn = toolbar:WaitForChild("LeashBtn") :: GuiButton
    local gachaBtn = toolbar:WaitForChild("GachaBtn") :: GuiButton
    local battleBtn = toolbar:FindFirstChild("BattleBtn")

    local card = mainHud:FindFirstChild("PetCard")
    local nameLabel = card and card:FindFirstChild("PetName") :: TextLabel?
    local statsLabel = card and card:FindFirstChild("StatsLabel") :: TextLabel?
    local expBg = card and card:FindFirstChild("ExpBg")
    local expFill = expBg and expBg:FindFirstChild("ExpFill") :: Frame?
    local expText = expBg and expBg:FindFirstChild("ExpText") :: TextLabel?
    local cardStroke = card and card:FindFirstChildOfClass("UIStroke")

    -- Áp dụng CSS Web Style & Spring
    WebStyleEngine.StyleButton(feedBtn, "Gold", 16)
    WebStyleEngine.StyleButton(bagBtn, "Success", 16)
    WebStyleEngine.StyleButton(leashBtn, "Cyan", 16)
    WebStyleEngine.StyleButton(gachaBtn, "Purple", 16)
    if battleBtn and battleBtn:IsA("GuiButton") then
        WebStyleEngine.StyleButton(battleBtn, "Danger", 16)
        UIFramework.ApplySpringButton(battleBtn, {HoverScale = 1.08, ClickScale = 0.90, Speed = 30, Damping = 0.65})
    end

    UIFramework.ApplySpringButton(feedBtn, {HoverScale = 1.08, ClickScale = 0.90, Speed = 30, Damping = 0.65})
    UIFramework.ApplySpringButton(bagBtn, {HoverScale = 1.08, ClickScale = 0.90, Speed = 30, Damping = 0.65})
    UIFramework.ApplySpringButton(leashBtn, {HoverScale = 1.08, ClickScale = 0.90, Speed = 30, Damping = 0.65})
    UIFramework.ApplySpringButton(gachaBtn, {HoverScale = 1.08, ClickScale = 0.90, Speed = 30, Damping = 0.65})

    -- Click Cho ăn nhanh (đồng bộ cooldown 0.5s theo BR-03 và hiển thị đúng EXP của pet đang trang bị)
    local currentExpPerFeed = 25
    local lastFeedAt = 0
    local lastKnownLevel: number? = nil

    feedBtn.MouseButton1Click:Connect(function()
        local now = os.clock()
        if (now - lastFeedAt) < 0.5 then
            return
        end
        lastFeedAt = now
        FeedEvent:FireServer()
        if SoundManager then
            SoundManager.PlaySFX("FeedEat", 0.08)
        end
        ToolbarViewController.SpawnExpPopup(feedBtn, string.format("+%d EXP 🥩", currentExpPerFeed))
    end)

    -- Click Bật/Tắt Dây dắt chó
    local isLeashing = true
    local leashLabel = leashBtn:FindFirstChild("ButtonLabel") :: TextLabel?
    local leashIcon = leashBtn:FindFirstChild("ButtonIcon") :: TextLabel?

    leashBtn.MouseButton1Click:Connect(function()
        isLeashing = not isLeashing
        ToggleLeashEvent:FireServer()
        if SoundManager then
            SoundManager.PlaySFX("LeashToggle")
        end
        if isLeashing then
            WebStyleEngine.StyleButton(leashBtn, "Cyan", 16)
            if leashLabel then leashLabel.Text = "DẮT CHÓ" end
            if leashIcon then leashIcon.Text = "🦮" end
            ToolbarViewController.SpawnExpPopup(leashBtn, "🦮 BẬT DẮT")
        else
            WebStyleEngine.StyleButton(leashBtn, "Muted", 16)
            if leashLabel then leashLabel.Text = "THẢ DÂY" end
            if leashIcon then leashIcon.Text = "🐾" end
            ToolbarViewController.SpawnExpPopup(leashBtn, "❌ THẢ DÂY")
        end
    end)

    -- Nút Bật / Tắt Âm thanh gọn ở góc trên phải
    if SoundManager then
        local existingMute = mainHud:FindFirstChild("SoundToggleBtn")
        if existingMute then
            existingMute:Destroy()
        end

        local muteBtn = Instance.new("TextButton")
        muteBtn.Name = "SoundToggleBtn"
        muteBtn.Size = UDim2.new(0, 44, 0, 44)
        muteBtn.Position = UDim2.new(1, -58, 0, 14)
        muteBtn.Text = "🔊"
        muteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        muteBtn.Font = Enum.Font.FredokaOne
        muteBtn.TextSize = 20
        muteBtn.ZIndex = 20
        muteBtn.Parent = mainHud

        WebStyleEngine.StyleButton(muteBtn, "Primary", 14)
        UIFramework.ApplySpringButton(muteBtn, {HoverScale = 1.1, ClickScale = 0.9, Speed = 30, Damping = 0.65, Silent = true})

        muteBtn.MouseButton1Click:Connect(function()
            local muted = SoundManager.ToggleMute()
            muteBtn.Text = muted and "🔇" or "🔊"
            WebStyleEngine.StyleButton(muteBtn, muted and "Muted" or "Primary", 14)
            if not muted then
                SoundManager.PlaySFX("ButtonClick")
            end
        end)
    end

    -- Khung hiển thị Số Dư Ví Xu (CoinHUD) cạnh nút Sổ Sưu Tập ở góc trên phải
    local existingCoinHud = mainHud:FindFirstChild("CoinHUD")
    if existingCoinHud then
        existingCoinHud:Destroy()
    end

    local coinFrame = Instance.new("Frame")
    coinFrame.Name = "CoinHUD"
    coinFrame.Size = UDim2.new(0, 134, 0, 44)
    coinFrame.Position = UDim2.new(1, -330, 0, 14)
    coinFrame.ZIndex = 20
    coinFrame.Parent = mainHud

    WebStyleEngine.ApplyGlassmorphism(coinFrame, {
        BorderRadius = 14,
        BackgroundColor = Color3.fromRGB(24, 22, 36),
        Transparency = 0.12,
        BorderColor = Color3.fromRGB(255, 205, 60),
        BorderTransparency = 0.25,
        BorderWidth = 2,
    })

    local coinLabel = Instance.new("TextLabel")
    coinLabel.Name = "CoinBalanceLabel"
    coinLabel.Size = UDim2.new(1, -12, 1, 0)
    coinLabel.Position = UDim2.new(0, 6, 0, 0)
    coinLabel.BackgroundTransparency = 1
    coinLabel.Text = "🪙 100 Xu"
    coinLabel.TextColor3 = Color3.fromRGB(255, 225, 80)
    coinLabel.Font = Enum.Font.FredokaOne
    coinLabel.TextSize = 16
    coinLabel.ZIndex = 21
    coinLabel.Parent = coinFrame

    if UpdateCoinsEvent and UpdateCoinsEvent:IsA("RemoteEvent") then
        UpdateCoinsEvent.OnClientEvent:Connect(function(payload)
            if type(payload) ~= "table" then
                return
            end
            local balance = tonumber(payload.coins)
            if balance ~= nil then
                coinLabel.Text = string.format("🪙 %d Xu", math.floor(balance))
            end
        end)
    end

    -- Lắng nghe cập nhật Pet Data
    UpdateEvent.OnClientEvent:Connect(function(data)
        if type(data) == "table" and tonumber(data.expPerFeed) then
            currentExpPerFeed = tonumber(data.expPerFeed) :: number
        end

        if type(data) == "table" and tonumber(data.level) then
            local newLevel = tonumber(data.level) :: number
            if lastKnownLevel ~= nil and newLevel > lastKnownLevel and SoundManager then
                SoundManager.PlaySFX("LevelUp")
            end
            lastKnownLevel = newLevel
        end

        if not card or not nameLabel or not statsLabel or not expText or not expFill then
            return
        end

        local squadCount = (type(data.equippedPets) == "table" and #data.equippedPets > 0) and #data.equippedPets or 1
        local maxSquad = tonumber(data.maxEquipped) or 1
        local pLv = tonumber(data.playerLevel) or 1
        nameLabel.Text = (data.icon or "🐶") .. " " .. (data.name or "Shiba Inu")
        statsLabel.Text = string.format("👤Lv.%d • 🐾%d/%d • Pet Lv.%d • ⚔️%d", pLv, squadCount, maxSquad, data.level, data.power)
        
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
end

return ToolbarViewController
