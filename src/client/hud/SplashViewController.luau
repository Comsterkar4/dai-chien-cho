--!strict
-- SplashViewController.luau: Màn hình chào mừng hiển thị thương hiệu & ảnh đại diện/banner Đại Chiến Chó khi vào game
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ConfigFolder = Modules:FindFirstChild("Config") or Modules
local GameBranding = require(ConfigFolder:WaitForChild("GameBranding"))

local SplashViewController = {}

local function hasAssetId(assetId: string?): boolean
    return type(assetId) == "string" and string.len(assetId) > 0
end

function SplashViewController.Init(mainHud: ScreenGui, UIFramework: any, WebStyleEngine: any)
    local existing = mainHud:FindFirstChild("WelcomeSplashOverlay")
    if existing then
        existing:Destroy()
    end

    local overlay = Instance.new("Frame")
    overlay.Name = "WelcomeSplashOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(10, 12, 22)
    overlay.BackgroundTransparency = 0.25
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 90
    overlay.Parent = mainHud

    local card = Instance.new("Frame")
    card.Name = "SplashCard"
    card.Size = UDim2.new(0, 560, 0, 410)
    card.Position = UDim2.new(0.5, 0, 0.5, 0)
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.ZIndex = 91
    card.Parent = overlay

    WebStyleEngine.ApplyGlassmorphism(card, {
        BorderRadius = 26,
        BackgroundColor = Color3.fromRGB(20, 22, 36),
        Transparency = 0.04,
        BorderColor = Color3.fromRGB(255, 200, 70),
        BorderTransparency = 0.15,
        BorderWidth = 2.5,
    })

    -- Khung Banner Thumbnail 16:9
    local bannerFrame = Instance.new("Frame")
    bannerFrame.Name = "BannerFrame"
    bannerFrame.Size = UDim2.new(1, -28, 0, 240)
    bannerFrame.Position = UDim2.new(0, 14, 0, 14)
    bannerFrame.BackgroundColor3 = Color3.fromRGB(45, 130, 235)
    bannerFrame.BorderSizePixel = 0
    bannerFrame.ClipsDescendants = true
    bannerFrame.ZIndex = 92
    bannerFrame.Parent = card

    local bannerCorner = Instance.new("UICorner")
    bannerCorner.CornerRadius = UDim.new(0, 18)
    bannerCorner.Parent = bannerFrame

    WebStyleEngine.ApplyGradient(
        bannerFrame,
        Color3.fromRGB(56, 189, 248),
        Color3.fromRGB(249, 115, 22),
        35
    )

    if hasAssetId(GameBranding.ThumbnailAssetId) then
        local bannerImg = Instance.new("ImageLabel")
        bannerImg.Name = "ThumbnailImage"
        bannerImg.Size = UDim2.new(1, 0, 1, 0)
        bannerImg.BackgroundTransparency = 1
        bannerImg.Image = GameBranding.ThumbnailAssetId
        bannerImg.ScaleType = Enum.ScaleType.Crop
        bannerImg.ZIndex = 93
        bannerImg.Parent = bannerFrame
    else
        local fallbackEmoji = Instance.new("TextLabel")
        fallbackEmoji.Size = UDim2.new(1, 0, 0, 74)
        fallbackEmoji.Position = UDim2.new(0, 0, 0.22, 0)
        fallbackEmoji.BackgroundTransparency = 1
        fallbackEmoji.Text = "🐶  🦊  🐺  🔥"
        fallbackEmoji.TextSize = 52
        fallbackEmoji.ZIndex = 93
        fallbackEmoji.Parent = bannerFrame

        local fallbackTitle = Instance.new("TextLabel")
        fallbackTitle.Size = UDim2.new(1, -24, 0, 56)
        fallbackTitle.Position = UDim2.new(0, 12, 0.56, 0)
        fallbackTitle.BackgroundTransparency = 1
        fallbackTitle.Text = GameBranding.GameTitleDisplay
        fallbackTitle.TextColor3 = Color3.fromRGB(255, 225, 75)
        fallbackTitle.Font = Enum.Font.FredokaOne
        fallbackTitle.TextSize = 42
        fallbackTitle.ZIndex = 93
        fallbackTitle.Parent = bannerFrame

        local titleStroke = Instance.new("UIStroke")
        titleStroke.Color = Color3.fromRGB(25, 30, 60)
        titleStroke.Thickness = 3.5
        titleStroke.Parent = fallbackTitle
    end

    -- Huy hiệu Icon vuông 1:1 (nếu đã có AssetId)
    if hasAssetId(GameBranding.IconAssetId) then
        local iconFrame = Instance.new("ImageLabel")
        iconFrame.Name = "GameIconBadge"
        iconFrame.Size = UDim2.new(0, 68, 0, 68)
        iconFrame.Position = UDim2.new(0, 12, 1, -80)
        iconFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        iconFrame.Image = GameBranding.IconAssetId
        iconFrame.ScaleType = Enum.ScaleType.Fit
        iconFrame.ZIndex = 94
        iconFrame.Parent = bannerFrame

        local icCorner = Instance.new("UICorner")
        icCorner.CornerRadius = UDim.new(0, 16)
        icCorner.Parent = iconFrame

        local icStroke = Instance.new("UIStroke")
        icStroke.Color = Color3.fromRGB(255, 220, 90)
        icStroke.Thickness = 2.5
        icStroke.Parent = iconFrame
    end

    -- Tiêu đề & mô tả ngắn
    local heading = Instance.new("TextLabel")
    heading.Name = "GameTitle"
    heading.Size = UDim2.new(1, -36, 0, 34)
    heading.Position = UDim2.new(0, 18, 0, 266)
    heading.BackgroundTransparency = 1
    heading.Text = "🐶 " .. GameBranding.GameTitleDisplay .. " ⚔️"
    heading.TextColor3 = Color3.fromRGB(255, 220, 80)
    heading.Font = Enum.Font.FredokaOne
    heading.TextSize = 26
    heading.ZIndex = 92
    heading.Parent = card

    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, -36, 0, 24)
    subtitle.Position = UDim2.new(0, 18, 0, 302)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = GameBranding.Subtitle
    subtitle.TextColor3 = Color3.fromRGB(215, 220, 240)
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.TextSize = 14
    subtitle.ZIndex = 92
    subtitle.Parent = card

    -- Nút Chơi Ngay
    local playBtn = Instance.new("TextButton")
    playBtn.Name = "PlayNowBtn"
    playBtn.Size = UDim2.new(0, 210, 0, 48)
    playBtn.Position = UDim2.new(0.5, -105, 1, -64)
    playBtn.Text = "CHƠI NGAY! 🐾"
    playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    playBtn.Font = Enum.Font.FredokaOne
    playBtn.TextSize = 18
    playBtn.ZIndex = 92
    playBtn.Parent = card

    WebStyleEngine.StyleButton(playBtn, "Gold", 16)
    UIFramework.ApplySpringButton(playBtn, {
        HoverScale = 1.07,
        ClickScale = 0.92,
        Speed = 30,
        Damping = 0.65,
    })

    local isClosing = false
    local function dismissSplash()
        if isClosing then
            return
        end
        isClosing = true
        UIFramework.SpringCloseModal(card)
        local fade = TweenService:Create(overlay, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1,
        })
        fade:Play()
        task.delay(0.35, function()
            if overlay.Parent then
                overlay:Destroy()
            end
        end)
    end

    playBtn.MouseButton1Click:Connect(dismissSplash)

    UIFramework.SpringOpenModal(card)
end

return SplashViewController
