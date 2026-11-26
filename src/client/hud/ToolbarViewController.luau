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

    -- Click Cho ăn nhanh
    feedBtn.MouseButton1Click:Connect(function()
        FeedEvent:FireServer()
        ToolbarViewController.SpawnExpPopup(feedBtn, "+25 EXP 🥩")
    end)

    -- Click Bật/Tắt Dây dắt chó
    local isLeashing = true
    leashBtn.MouseButton1Click:Connect(function()
        isLeashing = not isLeashing
        ToggleLeashEvent:FireServer()
        if isLeashing then
            WebStyleEngine.StyleButton(leashBtn, "Cyan", 16)
            ToolbarViewController.SpawnExpPopup(leashBtn, "🦮 BẬT DẮT")
        else
            WebStyleEngine.StyleButton(leashBtn, "GlassHover", 16)
            ToolbarViewController.SpawnExpPopup(leashBtn, "❌ THẢ DÂY")
        end
    end)

    -- Lắng nghe cập nhật Pet Data
    UpdateEvent.OnClientEvent:Connect(function(data)
        if not card or not nameLabel or not statsLabel or not expText or not expFill then
            return
        end

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
end

return ToolbarViewController
