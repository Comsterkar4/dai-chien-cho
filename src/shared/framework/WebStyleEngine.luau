--!strict
-- WebStyleEngine.luau: Mang sức mạnh của CSS, HTML & Modern Web Design vào Roblox GUI
-- Hỗ trợ: Glassmorphism (Kính mờ), CSS Gradients, Box-Shadows (Bóng đổ), Glow Borders, Badges, Button Themes
local TweenService = game:GetService("TweenService")

local WebStyleEngine = {}

-- Bảng màu Web Hiện Đại (Tailwind / Modern Web UI Palettes)
WebStyleEngine.Palettes = {
    GlassDark = Color3.fromRGB(18, 20, 29),
    GlassCard = Color3.fromRGB(26, 30, 44),
    GlassHover = Color3.fromRGB(36, 42, 60),
    
    Primary = { Start = Color3.fromRGB(99, 102, 241), End = Color3.fromRGB(139, 92, 246) }, -- Indigo -> Violet
    Gold = { Start = Color3.fromRGB(245, 158, 11), End = Color3.fromRGB(234, 88, 12) },    -- Amber -> Orange
    Success = { Start = Color3.fromRGB(16, 185, 129), End = Color3.fromRGB(5, 150, 105) },  -- Emerald -> Green
    Danger = { Start = Color3.fromRGB(239, 68, 68), End = Color3.fromRGB(220, 38, 38) },    -- Rose -> Red
    Cyan = { Start = Color3.fromRGB(6, 182, 212), End = Color3.fromRGB(14, 165, 233) },     -- Cyan -> Sky
    Purple = { Start = Color3.fromRGB(168, 85, 247), End = Color3.fromRGB(192, 132, 252) }, -- Purple -> Lavender
    Pink = { Start = Color3.fromRGB(236, 72, 153), End = Color3.fromRGB(244, 114, 182) },   -- Pink -> Rose
}

-- 1. CSS Box Shadow (Tạo bóng đổ mềm mại, có chiều sâu 3D như CSS box-shadow)
function WebStyleEngine.ApplyBoxShadow(gui: GuiObject, options: {[string]: any}?): Frame
    options = options or {}
    local offset = options.Offset or Vector2.new(0, 6)
    local color = options.Color or Color3.fromRGB(0, 0, 0)
    local transparency = options.Transparency or 0.65
    local radius = options.Radius or 16

    local existingShadow = gui:FindFirstChild("WebBoxShadow")
    if existingShadow and existingShadow:IsA("Frame") then
        existingShadow:Destroy()
    end

    local shadow = Instance.new("Frame")
    shadow.Name = "WebBoxShadow"
    shadow.Size = UDim2.new(1, 8, 1, 8)
    shadow.Position = UDim2.new(0, -4 + offset.X, 0, -4 + offset.Y)
    shadow.BackgroundColor3 = color
    shadow.BackgroundTransparency = transparency
    shadow.ZIndex = math.max(1, gui.ZIndex - 1)
    shadow.BorderSizePixel = 0
    shadow.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = shadow

    return shadow
end

-- 2. CSS Linear Gradient (Tạo dải chuyển màu mượt mà theo góc xoay degree)
function WebStyleEngine.ApplyGradient(gui: GuiObject, startColor: Color3, endColor: Color3, rotationDeg: number?): UIGradient
    rotationDeg = rotationDeg or 45
    local grad = gui:FindFirstChildOfClass("UIGradient")
    if not grad then
        grad = Instance.new("UIGradient")
        grad.Parent = gui
    end
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, startColor),
        ColorSequenceKeypoint.new(1, endColor)
    })
    grad.Rotation = rotationDeg
    return grad
end

-- 3. CSS Glassmorphism (Hiệu ứng kính mờ tối giản sang trọng chuẩn Web 2026)
function WebStyleEngine.ApplyGlassmorphism(gui: GuiObject, options: {[string]: any}?)
    options = options or {}
    local bgCol = options.BackgroundColor or WebStyleEngine.Palettes.GlassDark
    local bgTrans = options.Transparency or 0.20
    local borderRadius = options.BorderRadius or 18
    local borderCol = options.BorderColor or Color3.fromRGB(255, 255, 255)
    local borderTrans = options.BorderTransparency or 0.70
    local borderWidth = options.BorderWidth or 1.5

    gui.BackgroundColor3 = bgCol
    gui.BackgroundTransparency = bgTrans
    gui.BorderSizePixel = 0

    -- Bo góc chuẩn CSS
    local corner = gui:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", gui)
    corner.CornerRadius = UDim.new(0, borderRadius)

    -- Viền sáng phản quang cao cấp (Glass Highlight Stroke)
    local stroke = gui:FindFirstChild("GlassStroke") or gui:FindFirstChildOfClass("UIStroke")
    if not stroke then
        stroke = Instance.new("UIStroke")
        stroke.Name = "GlassStroke"
        stroke.Parent = gui
    end
    stroke.Color = borderCol
    stroke.Transparency = borderTrans
    stroke.Thickness = borderWidth
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Bóng đổ 3D bên dưới
    WebStyleEngine.ApplyBoxShadow(gui, {
        Radius = borderRadius,
        Offset = Vector2.new(0, 8),
        Transparency = 0.55
    })
end

-- 4. CSS Button Theming (Style nút bấm rực rỡ với Gradient, Bo góc, Viền kim loại & Bóng đổ)
function WebStyleEngine.StyleButton(btn: GuiButton, themeName: string, borderRadius: number?)
    borderRadius = borderRadius or 14
    local theme = WebStyleEngine.Palettes[themeName] or WebStyleEngine.Palettes.Primary

    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 0.05
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

    -- Áp dụng gradient
    WebStyleEngine.ApplyGradient(btn, theme.Start, theme.End, 90)

    -- Bo góc tròn
    local corner = btn:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, borderRadius)

    -- Viền sáng trắng tinh tế ở cạnh trên (Highlight Sheen)
    local stroke = btn:FindFirstChild("ButtonStroke") or Instance.new("UIStroke", btn)
    stroke.Name = "ButtonStroke"
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.65
    stroke.Thickness = 1.2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Bóng đổ mềm
    WebStyleEngine.ApplyBoxShadow(btn, {
        Radius = borderRadius,
        Offset = Vector2.new(0, 4),
        Transparency = 0.6
    })
end

-- 5. CSS Badge / Tag (Huy hiệu thông tin bo tròn với màu sắc nổi bật)
function WebStyleEngine.StyleBadge(badge: GuiObject, bgColor: Color3, textColor: Color3?)
    badge.BackgroundColor3 = bgColor
    badge.BackgroundTransparency = 0.2
    badge.BorderSizePixel = 0

    local corner = badge:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", badge)
    corner.CornerRadius = UDim.new(0, 8)

    local stroke = badge:FindFirstChild("BadgeStroke") or Instance.new("UIStroke", badge)
    stroke.Name = "BadgeStroke"
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.75
    stroke.Thickness = 1
end

return WebStyleEngine
