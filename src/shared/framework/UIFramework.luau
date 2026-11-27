--!strict
-- UIFramework.luau (v2.0 Production-Ready): Quản lý chuyển động vật lý lò xo & hiệu ứng giao diện
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Spring = require(script.Parent:WaitForChild("Spring"))
local SoundManager: any = nil
if RunService:IsClient() then
    local smModule = script.Parent:FindFirstChild("SoundManager")
    if smModule and smModule:IsA("ModuleScript") then
        SoundManager = require(smModule)
    end
end

local UIFramework = {}

-- Lấy hoặc tạo mới UIScale bên trong GUI Instance
local function getOrCreateUIScale(instance: GuiObject): UIScale
    local uiScale = instance:FindFirstChildOfClass("UIScale")
    if not uiScale then
        uiScale = Instance.new("UIScale")
        uiScale.Scale = 1.0
        uiScale.Parent = instance
    end
    return uiScale
end

-- Tự căn tâm AnchorPoint về giữa (0.5, 0.5) mà không làm lệch vị trí hiện tại
local function ensureCenterAnchor(gui: GuiObject)
    if gui.AnchorPoint == Vector2.new(0.5, 0.5) then return end
    local ap = gui.AnchorPoint
    local size = gui.AbsoluteSize
    local pos = gui.Position
    if size.X > 0 and size.Y > 0 then
        gui.Position = UDim2.new(
            pos.X.Scale, pos.X.Offset + (0.5 - ap.X) * size.X,
            pos.Y.Scale, pos.Y.Offset + (0.5 - ap.Y) * size.Y
        )
        gui.AnchorPoint = Vector2.new(0.5, 0.5)
    end
end

-- 1. Nút bấm lò xo (Cơ chế Sleep / Wake: Tự ngắt RenderStepped khi cân bằng - 0% lãng phí CPU)
function UIFramework.ApplySpringButton(btn: GuiButton, options: {[string]: any}?)
    options = options or {}
    local hoverScale = options.HoverScale or 1.06
    local clickScale = options.ClickScale or 0.92
    local speed = options.Speed or 28
    local damping = options.Damping or 0.65

    ensureCenterAnchor(btn)
    local uiScale = getOrCreateUIScale(btn)
    local spring = Spring.new(1.0, speed, damping)

    local isHovered = false
    local isPressed = false
    local updateConn: RBXScriptConnection? = nil

    local function wakeUp()
        if updateConn then return end
        updateConn = RunService.RenderStepped:Connect(function(dt)
            local current = spring:Update(dt)
            uiScale.Scale = current
            -- Tự động ngủ đông (disconnect) khi lò xo đã cân bằng
            if math.abs(current - spring.Target) < 0.001 and math.abs(spring.Velocity) < 0.01 then
                uiScale.Scale = spring.Target
                if updateConn then
                    updateConn:Disconnect()
                    updateConn = nil
                end
            end
        end)
    end

    btn.MouseEnter:Connect(function()
        isHovered = true
        if not isPressed then
            spring:SetTarget(hoverScale)
            wakeUp()
            if SoundManager and not options.Silent then
                SoundManager.PlaySFX("ButtonHover", 0.04)
            end
        end
    end)

    btn.MouseLeave:Connect(function()
        isHovered = false
        isPressed = false
        spring:SetTarget(1.0)
        wakeUp()
    end)

    btn.MouseButton1Down:Connect(function()
        isPressed = true
        spring:SetTarget(clickScale)
        wakeUp()
        if SoundManager and not options.Silent then
            SoundManager.PlaySFX("ButtonClick", 0.04)
        end
    end)

    btn.MouseButton1Up:Connect(function()
        isPressed = false
        spring:SetTarget(isHovered and hoverScale or 1.0)
        wakeUp()
    end)

    btn.Destroying:Connect(function()
        if updateConn then
            updateConn:Disconnect()
            updateConn = nil
        end
    end)
end

-- 2. Mở Modal bung nở lò xo từ tâm (Spring Pop-In Modal)
local activeModalConns: {[GuiObject]: RBXScriptConnection} = {}

function UIFramework.SpringOpenModal(modalFrame: GuiObject)
    ensureCenterAnchor(modalFrame)
    local uiScale = getOrCreateUIScale(modalFrame)

    if activeModalConns[modalFrame] then
        activeModalConns[modalFrame]:Disconnect()
        activeModalConns[modalFrame] = nil
    end

    modalFrame.Visible = true
    uiScale.Scale = 0.7
    if SoundManager then
        SoundManager.PlaySFX("ModalOpen")
    end
    local spring = Spring.new(0.7, 24, 0.68)
    spring:SetTarget(1.0)

    local conn: RBXScriptConnection? = nil
    conn = RunService.RenderStepped:Connect(function(dt)
        local val = spring:Update(dt)
        uiScale.Scale = val
        if math.abs(val - 1.0) < 0.002 and math.abs(spring.Velocity) < 0.05 then
            uiScale.Scale = 1.0
            if conn then
                conn:Disconnect()
                conn = nil
                activeModalConns[modalFrame] = nil
            end
        end
    end)
    activeModalConns[modalFrame] = conn :: RBXScriptConnection
end

-- 3. Đóng Modal thu nhỏ mượt mà
function UIFramework.SpringCloseModal(modalFrame: GuiObject, callback: (() -> ())?)
    if activeModalConns[modalFrame] then
        activeModalConns[modalFrame]:Disconnect()
        activeModalConns[modalFrame] = nil
    end

    local uiScale = getOrCreateUIScale(modalFrame)
    if SoundManager then
        SoundManager.PlaySFX("ModalClose")
    end
    local tween = TweenService:Create(uiScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Scale = 0.5
    })
    tween:Play()
    tween.Completed:Connect(function()
        modalFrame.Visible = false
        uiScale.Scale = 1.0
        if callback then callback() end
    end)
end

-- 4. Hiệu ứng vệt sáng kim tuyến lướt qua (Shimmer)
function UIFramework.ApplyShimmer(frame: GuiObject)
    frame.ClipsDescendants = true
    local shimmer = Instance.new("Frame")
    shimmer.Name = "ShimmerGlow"
    shimmer.Size = UDim2.new(0.35, 0, 1.8, 0)
    shimmer.Position = UDim2.new(-0.5, 0, -0.4, 0)
    shimmer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shimmer.BackgroundTransparency = 0.75
    shimmer.Rotation = 22
    shimmer.ZIndex = frame.ZIndex + 1
    shimmer.Parent = frame

    local tween = TweenService:Create(shimmer, TweenInfo.new(1.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 1.0), {
        Position = UDim2.new(1.4, 0, -0.4, 0)
    })
    tween:Play()
end

return UIFramework
