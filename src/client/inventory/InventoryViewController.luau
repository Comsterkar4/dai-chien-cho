--!strict
-- InventoryViewController.luau: Quản lý giao diện Túi Đồ (InventoryModal) & Thao tác cho ăn vật phẩm
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local InventoryViewController = {}

local Events = ReplicatedStorage:WaitForChild("Events")
local UseItemEvent = Events:WaitForChild("UseItem")
local InvUpdateEvent = Events:WaitForChild("UpdateInventory")
local UpdatePetDataEvent = Events:WaitForChild("UpdatePetData")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local FrameworkFolder = Modules:FindFirstChild("Framework") or Modules
local SoundManagerModule = FrameworkFolder:FindFirstChild("SoundManager")
local SoundManager: any = SoundManagerModule and require(SoundManagerModule) or nil

local function spawnExpPopup(btn: GuiButton, text: string?)
    local popup = Instance.new("TextLabel")
    popup.Size = UDim2.new(0, 150, 0, 35)
    popup.Position = UDim2.new(0, -140, 0, 10)
    popup.BackgroundTransparency = 1
    popup.Text = text or "+25 EXP ✨"
    popup.TextColor3 = Color3.fromRGB(255, 235, 70)
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

function InventoryViewController.Init(mainHud: ScreenGui, UIFramework: any, WebStyleEngine: any)
    local toolbar = mainHud:WaitForChild("RightToolbar")
    local bagBtn = toolbar:WaitForChild("BagBtn") :: GuiButton

    local invModal = mainHud:WaitForChild("InventoryModal") :: GuiObject
    local closeInvBtn = invModal:WaitForChild("CloseBtn") :: GuiButton
    local itemList = invModal:WaitForChild("ItemList")

    -- Kính mờ Glassmorphism
    WebStyleEngine.ApplyGlassmorphism(invModal, {
        BorderRadius = 22,
        BackgroundColor = Color3.fromRGB(16, 18, 28),
        Transparency = 0.15,
        BorderColor = Color3.fromRGB(100, 160, 255),
        BorderTransparency = 0.6
    })

    -- Nút đóng tròn
    closeInvBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    closeInvBtn.BackgroundTransparency = 0.85
    local cCorner = closeInvBtn:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", closeInvBtn)
    cCorner.CornerRadius = UDim.new(1, 0)
    UIFramework.ApplySpringButton(closeInvBtn, {HoverScale = 1.15, ClickScale = 0.85, Speed = 32, Damping = 0.60})

    -- Toggle mở/đóng túi đồ
    bagBtn.MouseButton1Click:Connect(function()
        if not invModal.Visible then
            local gachaModal = mainHud:FindFirstChild("GachaModal")
            local resPopup = mainHud:FindFirstChild("GachaResultPopup")
            local arenaModal = mainHud:FindFirstChild("ArenaModal")
            if gachaModal then gachaModal.Visible = false end
            if resPopup then resPopup.Visible = false end
            if arenaModal then arenaModal.Visible = false end
            UIFramework.SpringOpenModal(invModal)
        else
            UIFramework.SpringCloseModal(invModal)
        end
    end)

    closeInvBtn.MouseButton1Click:Connect(function()
        UIFramework.SpringCloseModal(invModal)
    end)

    local equippedGearId: string? = nil
    local lastInventory: {any}? = nil

    -- Cập nhật danh sách vật phẩm kính mờ (Glass Cards)
    local function renderInventory(inventory: {any})
        lastInventory = inventory
        for _, child in ipairs(itemList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        for _, it in ipairs(inventory) do
            local slot = Instance.new("Frame")
            slot.Name = "Slot_" .. it.id
            slot.Size = UDim2.new(1, -10, 0, 68)
            slot.Parent = itemList

            local isGear = it.kind == "gear"
            local isEquippedGear = isGear and (equippedGearId == it.id)

            WebStyleEngine.ApplyGlassmorphism(slot, {
                BorderRadius = 14,
                BackgroundColor = isEquippedGear and Color3.fromRGB(24, 52, 48) or Color3.fromRGB(26, 30, 44),
                Transparency = 0.35,
                BorderColor = isEquippedGear and Color3.fromRGB(52, 211, 153) or Color3.fromRGB(255, 255, 255),
                BorderTransparency = isEquippedGear and 0.25 or 0.85,
                BorderWidth = isEquippedGear and 2 or 1
            })

            local icon = Instance.new("TextLabel")
            icon.Size = UDim2.new(0, 46, 0, 46)
            icon.Position = UDim2.new(0, 10, 0.5, -23)
            icon.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
            icon.BackgroundTransparency = 0.3
            icon.Text = it.icon
            icon.TextSize = 28
            icon.Parent = slot
            local icCorner = Instance.new("UICorner")
            icCorner.CornerRadius = UDim.new(0, 10)
            icCorner.Parent = icon

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(0, 180, 0, 20)
            title.Position = UDim2.new(0, 68, 0, 13)
            title.BackgroundTransparency = 1
            title.Text = it.name .. "  (x" .. it.count .. ")"
            title.TextColor3 = Color3.fromRGB(255, 230, 100)
            title.Font = Enum.Font.FredokaOne
            title.TextSize = 15
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Parent = slot

            local desc = Instance.new("TextLabel")
            desc.Size = UDim2.new(0, 180, 0, 18)
            desc.Position = UDim2.new(0, 68, 0, 35)
            desc.BackgroundTransparency = 1
            desc.Text = it.desc
            desc.TextColor3 = Color3.fromRGB(180, 195, 215)
            desc.Font = Enum.Font.GothamMedium
            desc.TextSize = 11
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.Parent = slot

            local isTicket = it.kind == "ticket"
            local useBtn = Instance.new("TextButton")
            useBtn.Size = UDim2.new(0, 90, 0, 40)
            useBtn.Position = UDim2.new(1, -100, 0.5, -20)
            if isGear then
                useBtn.Text = it.count > 0 and (isEquippedGear and "ĐANG ĐEO" or "TRANG BỊ") or "CHƯA CÓ"
            elseif isTicket then
                useBtn.Text = it.count > 0 and "DÙNG GACHA" or "HẾT"
            else
                useBtn.Text = it.count > 0 and "CHO ĂN" or "HẾT"
            end
            useBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            useBtn.Font = Enum.Font.FredokaOne
            useBtn.TextSize = (isTicket or isGear) and 11 or 13
            useBtn.Parent = slot

            if it.count > 0 and isGear then
                WebStyleEngine.StyleButton(useBtn, isEquippedGear and "Success" or "Cyan", 10)
                UIFramework.ApplySpringButton(useBtn, {HoverScale = 1.08, ClickScale = 0.90, Speed = 30, Damping = 0.65})
                useBtn.MouseButton1Click:Connect(function()
                    UseItemEvent:FireServer(it.id)
                end)
            elseif it.count > 0 and not isTicket then
                WebStyleEngine.StyleButton(useBtn, "Gold", 10)
                UIFramework.ApplySpringButton(useBtn, {HoverScale = 1.08, ClickScale = 0.90, Speed = 30, Damping = 0.65})
                local isUsing = false
                useBtn.MouseButton1Click:Connect(function()
                    if isUsing then
                        return
                    end
                    isUsing = true
                    UseItemEvent:FireServer(it.id)
                    if SoundManager then
                        SoundManager.PlaySFX("FeedEat", 0.08)
                    end
                    spawnExpPopup(useBtn, "+" .. it.exp .. " EXP ✨")
                    task.delay(0.3, function()
                        isUsing = false
                    end)
                end)
            else
                WebStyleEngine.StyleButton(useBtn, isTicket and it.count > 0 and "Purple" or "Muted", 10)
                useBtn.Active = false
                useBtn.AutoButtonColor = false
            end
        end
    end

    InvUpdateEvent.OnClientEvent:Connect(renderInventory)
    UpdatePetDataEvent.OnClientEvent:Connect(function(data)
        if type(data) ~= "table" then return end
        local newGear = (type(data.equippedGearId) == "string") and data.equippedGearId or nil
        if newGear ~= equippedGearId then
            equippedGearId = newGear
            if lastInventory then
                renderInventory(lastInventory)
            end
        end
    end)
end

return InventoryViewController
