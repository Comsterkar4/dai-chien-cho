-- Spring Solver: Thuật toán mô phỏng chuyển động lò xo vật lý đàn hồi
-- Dựa trên phương trình dao động điều hòa có cản (Damped Harmonic Oscillator)
local Spring = {}
Spring.__index = Spring

function Spring.new(initialValue, speed, dampingRatio)
    local self = setmetatable({}, Spring)
    self.Value = initialValue or 0
    self.Target = initialValue or 0
    self.Velocity = 0
    self.Speed = speed or 25              -- Tốc độ nảy
    self.DampingRatio = dampingRatio or 0.75 -- Hệ số giảm chấn (0.7-0.8 = nảy êm)
    return self
end

function Spring:Update(dt)
    local d = self.DampingRatio
    local s = self.Speed
    local x0 = self.Value - self.Target
    local v0 = self.Velocity

    if d < 1 then
        -- Dưới cản (Underdamped - nảy đàn hồi sống động)
        local w = s * math.sqrt(1 - d * d)
        local exp = math.exp(-d * s * dt)
        local c1 = x0
        local c2 = (v0 + d * s * x0) / w
        self.Value = self.Target + exp * (c1 * math.cos(w * dt) + c2 * math.sin(w * dt))
        self.Velocity = exp * (-d * s * (c1 * math.cos(w * dt) + c2 * math.sin(w * dt)) + w * (-c1 * math.sin(w * dt) + c2 * math.cos(w * dt)))
    else
        -- Cản tới hạn (Critically damped)
        local exp = math.exp(-s * dt)
        self.Value = self.Target + exp * (x0 + (v0 + s * x0) * dt)
        self.Velocity = exp * (v0 * (1 - s * dt) - s * s * x0 * dt)
    end

    return self.Value
end

function Spring:SetTarget(newTarget)
    self.Target = newTarget
end

return Spring