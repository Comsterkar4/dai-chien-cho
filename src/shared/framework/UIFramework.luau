local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Spring = require(script.Parent:WaitForChild("Spring"))

local UIFramework = {}

-- Gắn hiệu ứng lò xo nảy đàn hồi khi Hover và Click vào bất kỳ TextButton / ImageButton
function UIFramework.ApplySpringButton(btn, options)
    options = options or {}
    local hoverScale = options.HoverScale or 1.06
    local clickScale = options.ClickScale or 0.92
    local speed = options.Speed or 28
    local damping = options.Damping or 0.65

    local origSize = btn.Size
    local spring = Spring.new(1.0, speed, damping)
    local isHovered = false
    local isPressed = false

    local conn = RunService.RenderStepped:Connect(function(dt)
        local scale = spring:Update(dt)
        btn.Size = UDim2.new(
            origSize.X.Scale * scale,
            origSize.X.Offset * scale,
            origSize.Y.Scale * scale,
            origSize.Y.Offset * scale
        )
    end)

    btn.MouseEnter:Connect(function()
        isHovered = true
        if not isPressed then
            spring:SetTarget(hoverScale)
        end
    end)

    btn.MouseLeave:Connect(function()
        isHovered = false
        isPressed = false
        spring:SetTarget(1.0)
    end)

    btn.MouseButton1Down:Connect(function()
        isPressed = true
        spring:SetTarget(clickScale)
    end)

    btn.MouseButton1Up:Connect(function()
        isPressed = false
        spring:SetTarget(isHovered and hoverScale or 1.0)
    end)

    btn.Destroying:Connect(function()
        conn:Disconnect()
    end)
end

-- Hiệu ứng bung nở Modal lò xo từ tâm (Spring Pop-In Modal)
function UIFramework.SpringOpenModal(modalFrame, finalSize)
    finalSize = finalSize or modalFrame.Size
    modalFrame.Visible = true

    -- Thu nhỏ về 70% và bung nở lò xo ra kích thước thật
    local startSize = UDim2.new(finalSize.X.Scale * 0.7, finalSize.X.Offset * 0.7, finalSize.Y.Scale * 0.7, finalSize.Y.Offset * 0.7)
    modalFrame.Size = startSize

    local spring = Spring.new(0.7, 24, 0.68)
    spring:SetTarget(1.0)

    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        local scale = spring:Update(dt)
        modalFrame.Size = UDim2.new(
            finalSize.X.Scale * scale,
            finalSize.X.Offset * scale,
            finalSize.Y.Scale * scale,
            finalSize.Y.Offset * scale
        )
        if math.abs(scale - 1.0) < 0.002 and math.abs(spring.Velocity) < 0.05 then
            modalFrame.Size = finalSize
            conn:Disconnect()
        end
    end)
end

-- Hiệu ứng đóng Modal thu nhỏ và mờ dần
function UIFramework.SpringCloseModal(modalFrame, callback)
    local origSize = modalFrame.Size
    local tween = TweenService:Create(modalFrame, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(origSize.X.Scale * 0.6, origSize.X.Offset * 0.6, origSize.Y.Scale * 0.6, origSize.Y.Offset * 0.6)
    })
    tween:Play()
    tween.Completed:Connect(function()
        modalFrame.Visible = false
        modalFrame.Size = origSize
        if callback then callback() end
    end)
end

-- Hiệu ứng vệt sáng kim tuyến lướt qua (Shimmer)
function UIFramework.ApplyShimmer(frame)
    local shimmer = Instance.new("Frame")
    shimmer.Name = "ShimmerGlow"
    shimmer.Size = UDim2.new(0.3, 0, 1.5, 0)
    shimmer.Position = UDim2.new(-0.4, 0, -0.25, 0)
    shimmer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shimmer.BackgroundTransparency = 0.7
    shimmer.Rotation = 25
    shimmer.ZIndex = frame.ZIndex + 1
    shimmer.Parent = frame

    local tween = TweenService:Create(shimmer, TweenInfo.new(1.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 1.2), {
        Position = UDim2.new(1.3, 0, -0.25, 0)
    })
    tween:Play()
end

return UIFramework