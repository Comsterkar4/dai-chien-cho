
--!strict
-- GachaViewController.luau
-- Cute Pet Pastel Edition
-- Giữ nguyên cấu trúc UI và hệ thống RemoteEvent hiện tại.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local GachaViewController = {}

local LocalPlayer = Players.LocalPlayer

--==================================================
-- REMOTE EVENTS
--==================================================

local Events = ReplicatedStorage:WaitForChild("Events")

local RollGachaEvent = Events:WaitForChild("RollGacha")
local GachaResultEvent = Events:WaitForChild("GachaResult")
local EquipPetEvent = Events:WaitForChild("EquipPet")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ConfigFolder = Modules:FindFirstChild("Config") or Modules
local PetConfig = require(ConfigFolder:WaitForChild("PetConfig"))
local FrameworkFolder = Modules:FindFirstChild("Framework") or Modules
local SoundManagerModule = FrameworkFolder:FindFirstChild("SoundManager")
local SoundManager: any = SoundManagerModule and require(SoundManagerModule) or nil

--==================================================
-- STATE
--==================================================

local lastRolledPetId: string? = nil
local isRolling = false
local rollToken = 0
local activeEggTween: Tween? = nil

--==================================================
-- CUTE PET PASTEL COLOR PALETTE
--==================================================

local Theme = {
    Background = Color3.fromRGB(255, 248, 252),
    Panel = Color3.fromRGB(255, 255, 255),

    Pink = Color3.fromRGB(255, 170, 205),
    PinkDark = Color3.fromRGB(239, 116, 171),

    Purple = Color3.fromRGB(190, 165, 255),
    PurpleDark = Color3.fromRGB(143, 112, 224),

    Mint = Color3.fromRGB(159, 235, 207),
    MintDark = Color3.fromRGB(91, 194, 154),

    Yellow = Color3.fromRGB(255, 225, 151),

    Text = Color3.fromRGB(94, 76, 111),
    SubText = Color3.fromRGB(157, 137, 166),

    White = Color3.fromRGB(255, 255, 255),
}

local RarityColors = {
    Common = Color3.fromRGB(170, 190, 180),
    Rare = Color3.fromRGB(100, 190, 255),
    Epic = Color3.fromRGB(190, 130, 255),
    Legendary = Color3.fromRGB(255, 190, 90),
    Mythic = Color3.fromRGB(255, 115, 170),
}

local RarityRank = {
    Mythic = 5,
    Legendary = 4,
    Epic = 3,
    Rare = 2,
    Common = 1,
}

--==================================================
-- UI HELPERS
--==================================================

local function addCorner(
    object: GuiObject,
    radius: number
): UICorner
    local corner = object:FindFirstChildOfClass("UICorner")

    if not corner then
        corner = Instance.new("UICorner")
        corner.Parent = object
    end

    corner.CornerRadius = UDim.new(0, radius)

    return corner
end

local function addStroke(
    object: GuiObject,
    color: Color3,
    thickness: number,
    transparency: number
): UIStroke
    local stroke = object:FindFirstChildOfClass("UIStroke")

    if not stroke then
        stroke = Instance.new("UIStroke")
        stroke.Parent = object
    end

    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Transparency = transparency
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    return stroke
end

local function addGradient(
    object: GuiObject,
    color1: Color3,
    color2: Color3,
    rotation: number?
)
    local gradient = object:FindFirstChildOfClass("UIGradient")

    if not gradient then
        gradient = Instance.new("UIGradient")
        gradient.Parent = object
    end

    gradient.Color = ColorSequence.new(color1, color2)
    gradient.Rotation = rotation or 90
end

local function styleLabel(
    label: TextLabel,
    color: Color3,
    font: Enum.Font?
)
    label.TextColor3 = color
    label.Font = font or Enum.Font.GothamBold
    label.TextStrokeTransparency = 1
end

--==================================================
-- BUTTON STYLE
--==================================================

local function styleCuteButton(
    button: GuiButton,
    color1: Color3,
    color2: Color3,
    strokeColor: Color3
)
    button.AutoButtonColor = false

    addCorner(button, 18)
    addStroke(button, strokeColor, 2, 0.15)
    addGradient(button, color1, color2, 90)

    if button:IsA("TextButton") then
        button.Font = Enum.Font.GothamBold
        button.TextColor3 = Theme.White
        button.TextStrokeTransparency = 1
    end
end

local function animateButton(button: GuiButton)
    local originalColor = button.BackgroundColor3

    button.MouseEnter:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad),
            {
                BackgroundColor3 = Theme.White,
            }
        ):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad),
            {
                BackgroundColor3 = originalColor,
            }
        ):Play()
    end)
end

--==================================================
-- MODAL STYLE
--==================================================

local function styleModal(modal: GuiObject)
    modal.BackgroundColor3 = Theme.Background
    modal.BackgroundTransparency = 0

    addCorner(modal, 28)
    addStroke(modal, Theme.Pink, 3, 0.1)
    addGradient(
        modal,
        Color3.fromRGB(255, 250, 255),
        Color3.fromRGB(238, 235, 255),
        45
    )
end

local function styleStage(stage: GuiObject)
    stage.BackgroundColor3 = Theme.White
    stage.BackgroundTransparency = 0

    addCorner(stage, 24)
    addStroke(stage, Theme.Purple, 2, 0.35)
    addGradient(
        stage,
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 235, 246),
        90
    )
end

local function stylePopup(popup: GuiObject)
    popup.BackgroundColor3 = Theme.White
    popup.BackgroundTransparency = 0

    addCorner(popup, 30)
    addStroke(popup, Theme.Pink, 3, 0.05)

    addGradient(
        popup,
        Color3.fromRGB(255, 250, 253),
        Color3.fromRGB(242, 237, 255),
        45
    )
end

--==================================================
-- EGG ANIMATION
--==================================================

local function cancelActiveEggTween()
    if activeEggTween then
        activeEggTween:Cancel()
        activeEggTween = nil
    end
end

local function restoreEggPose(
    eggGraphic: GuiObject,
    neutralPosition: UDim2,
    neutralRotation: number,
    animated: boolean
)
    cancelActiveEggTween()

    if animated then
        local tween = TweenService:Create(
            eggGraphic,
            TweenInfo.new(0.2, Enum.EasingStyle.Back),
            {
                Position = neutralPosition,
                Rotation = neutralRotation,
            }
        )
        activeEggTween = tween
        tween:Play()
    else
        eggGraphic.Position = neutralPosition
        eggGraphic.Rotation = neutralRotation
    end
end

local function playEggShakeAnimation(
    eggGraphic: GuiObject,
    currentToken: number,
    neutralPosition: UDim2,
    neutralRotation: number
)
    cancelActiveEggTween()
    eggGraphic.Position = neutralPosition
    eggGraphic.Rotation = neutralRotation

    local shakeCount = 16

    for i = 1, shakeCount do
        if currentToken ~= rollToken or not isRolling then
            break
        end

        local direction = (i % 2 == 0) and 1 or -1
        local intensity = math.min(i * 1.5, 14)

        local targetPosition = neutralPosition
            + UDim2.fromOffset(direction * intensity, 0)

        local targetRotation = neutralRotation + direction * 10

        cancelActiveEggTween()
        local tween = TweenService:Create(
            eggGraphic,
            TweenInfo.new(
                0.055,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            ),
            {
                Position = targetPosition,
                Rotation = targetRotation,
            }
        )

        activeEggTween = tween
        tween:Play()
        if SoundManager and (i % 3 == 1) then
            SoundManager.PlaySFX("EggShake", 0.08)
        end
        task.wait(0.055)
    end

    if currentToken == rollToken then
        restoreEggPose(eggGraphic, neutralPosition, neutralRotation, true)
    end
end

--==================================================
-- RESULT POPUP ANIMATION
--==================================================

local function playResultAnimation(popup: GuiObject)
    local scale = popup:FindFirstChildOfClass("UIScale")

    if not scale then
        scale = Instance.new("UIScale")
        scale.Parent = popup
    end

    scale.Scale = 0.65

    local tween = TweenService:Create(
        scale,
        TweenInfo.new(
            0.4,
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        ),
        {
            Scale = 1,
        }
    )

    tween:Play()
end

--==================================================
-- SELECT BEST PET
--==================================================

local function getBestPet(results: {any}): any?
    local best = nil

    for _, pet in ipairs(results) do
        if type(pet) == "table" then
            if best == nil then
                best = pet
            elseif (RarityRank[pet.rarity] or 1)
                > (RarityRank[best.rarity] or 1) then
                best = pet
            end
        end
    end

    return best
end

--==================================================
-- INITIALIZE
--==================================================

function GachaViewController.Init(
    mainHud: ScreenGui,
    UIFramework: any,
    WebStyleEngine: any
)
    -- Main UI
    local toolbar = mainHud:WaitForChild("RightToolbar")
    local gachaBtn = toolbar:WaitForChild("GachaBtn") :: GuiButton

    local gachaModal = mainHud:WaitForChild("GachaModal") :: GuiObject

    local closeGachaBtn =
        gachaModal:WaitForChild("CloseBtn") :: GuiButton

    local roll1Btn =
        gachaModal:WaitForChild("Roll1Btn") :: GuiButton

    local roll5Btn =
        gachaModal:WaitForChild("Roll5Btn") :: GuiButton

    local stage = gachaModal:WaitForChild("Stage") :: GuiObject

    local eggGraphic =
        stage:WaitForChild("EggGraphic") :: GuiObject
    local neutralEggPosition = eggGraphic.Position
    local neutralEggRotation = eggGraphic.Rotation

    local stageDesc =
        stage:WaitForChild("StageDesc") :: TextLabel

    -- Result popup
    local resPopup =
        mainHud:WaitForChild("GachaResultPopup") :: GuiObject

    local resIcon =
        resPopup:WaitForChild("PetIcon") :: TextLabel

    local resName =
        resPopup:WaitForChild("PetName") :: TextLabel

    local resRarity =
        resPopup:WaitForChild("RarityBadge") :: TextLabel

    local resStats =
        resPopup:WaitForChild("StatsDesc") :: TextLabel

    local resEquip =
        resPopup:WaitForChild("EquipBtn") :: GuiButton

    local resDismiss =
        resPopup:WaitForChild("DismissBtn") :: GuiButton

    local resStroke =
        resPopup:FindFirstChild("PopupStroke")
        or resPopup:FindFirstChildOfClass("UIStroke")

    --==================================================
    -- APPLY BASE THEME
    --==================================================

    -- Keep existing glassmorphism integration.
    if WebStyleEngine then
        pcall(function()
            WebStyleEngine.ApplyGlassmorphism(gachaModal, {
                BorderRadius = 28,
                BackgroundColor = Theme.Background,
                Transparency = 0,
                BorderColor = Theme.Pink,
                BorderTransparency = 0.1,
            })
        end)

        pcall(function()
            WebStyleEngine.ApplyGlassmorphism(resPopup, {
                BorderRadius = 30,
                BackgroundColor = Theme.White,
                Transparency = 0,
                BorderColor = Theme.Purple,
                BorderTransparency = 0.1,
            })
        end)
    end

    -- Reapply pastel styling after the glass effect.
    styleModal(gachaModal)
    styleStage(stage)
    stylePopup(resPopup)

    --==================================================
    -- BUTTONS
    --==================================================

    styleCuteButton(
        roll1Btn,
        Theme.Pink,
        Theme.PinkDark,
        Color3.fromRGB(255, 205, 225)
    )

    styleCuteButton(
        roll5Btn,
        Theme.Purple,
        Theme.PurpleDark,
        Color3.fromRGB(215, 195, 255)
    )

    styleCuteButton(
        resEquip,
        Theme.Mint,
        Theme.MintDark,
        Color3.fromRGB(190, 245, 220)
    )

    styleCuteButton(
        resDismiss,
        Theme.Pink,
        Theme.PinkDark,
        Color3.fromRGB(255, 205, 225)
    )

    closeGachaBtn.BackgroundColor3 = Theme.Pink
    closeGachaBtn.BackgroundTransparency = 0.1

    addCorner(closeGachaBtn, 100)
    addStroke(closeGachaBtn, Theme.White, 2, 0.1)

    -- Optional existing framework animation.
    if UIFramework then
        local buttons = {
            roll1Btn,
            roll5Btn,
            resEquip,
            resDismiss,
            closeGachaBtn,
        }

        for _, button in ipairs(buttons) do
            pcall(function()
                UIFramework.ApplySpringButton(button, {
                    HoverScale = 1.06,
                    ClickScale = 0.92,
                    Speed = 28,
                    Damping = 0.70,
                })
            end)
        end
    end

    --==================================================
    -- LABELS
    --==================================================

    styleLabel(stageDesc, Theme.SubText, Enum.Font.GothamMedium)
    styleLabel(resName, Theme.Text, Enum.Font.GothamBlack)
    styleLabel(resStats, Theme.SubText, Enum.Font.GothamMedium)

    styleLabel(
        resRarity,
        Theme.White,
        Enum.Font.GothamBlack
    )

    resIcon.Font = Enum.Font.GothamBlack

    addCorner(resRarity, 12)
    addStroke(resRarity, Theme.White, 1.5, 0.3)

    -- Egg appearance.
    addStroke(eggGraphic, Theme.Pink, 2, 0.45)

    --==================================================
    -- HOURLY 30-PET BANNER & COUNTDOWN
    --==================================================

    local existingHourlyBtn = gachaModal:FindFirstChild("HourlyPoolBtn")
    if existingHourlyBtn then existingHourlyBtn:Destroy() end
    local existingHourlyPopup = mainHud:FindFirstChild("HourlyPoolPopup")
    if existingHourlyPopup then existingHourlyPopup:Destroy() end

    local hourlyBtn = Instance.new("TextButton")
    hourlyBtn.Name = "HourlyPoolBtn"
    hourlyBtn.Size = UDim2.new(0, 215, 0, 32)
    hourlyBtn.Position = UDim2.new(0, 18, 0, 14)
    hourlyBtn.Text = "⏰ 30 Cún Giờ Này (60:00)"
    hourlyBtn.TextSize = 12
    hourlyBtn.ZIndex = 12
    hourlyBtn.Parent = gachaModal
    styleCuteButton(hourlyBtn, Theme.Purple, Theme.PurpleDark, Color3.fromRGB(220, 200, 255))

    local hourlyPopup = Instance.new("Frame")
    hourlyPopup.Name = "HourlyPoolPopup"
    hourlyPopup.Size = UDim2.new(0, 560, 0, 420)
    hourlyPopup.Position = UDim2.new(0.5, 0, 0.5, 0)
    hourlyPopup.AnchorPoint = Vector2.new(0.5, 0.5)
    hourlyPopup.Visible = false
    hourlyPopup.ZIndex = 45
    hourlyPopup.Parent = mainHud
    styleModal(hourlyPopup)

    local hourlyTitle = Instance.new("TextLabel")
    hourlyTitle.Size = UDim2.new(1, -60, 0, 34)
    hourlyTitle.Position = UDim2.new(0, 18, 0, 12)
    hourlyTitle.BackgroundTransparency = 1
    hourlyTitle.Text = "⏰ 30 LINH THÚ TRONG BANNER GIỜ NÀY"
    hourlyTitle.TextSize = 17
    hourlyTitle.TextXAlignment = Enum.TextXAlignment.Left
    hourlyTitle.ZIndex = 46
    hourlyTitle.Parent = hourlyPopup
    styleLabel(hourlyTitle, Theme.Text, Enum.Font.GothamBlack)

    local hourlySub = Instance.new("TextLabel")
    hourlySub.Size = UDim2.new(1, -36, 0, 20)
    hourlySub.Position = UDim2.new(0, 18, 0, 44)
    hourlySub.BackgroundTransparency = 1
    hourlySub.Text = "1 Thần Thoại • 3 Huyền Thoại • 5 Siêu Hiếm • 8 Hiếm • 13 Thường"
    hourlySub.TextSize = 12
    hourlySub.TextXAlignment = Enum.TextXAlignment.Left
    hourlySub.ZIndex = 46
    hourlySub.Parent = hourlyPopup
    styleLabel(hourlySub, Theme.SubText, Enum.Font.GothamMedium)

    local closeHourlyBtn = Instance.new("TextButton")
    closeHourlyBtn.Size = UDim2.new(0, 32, 0, 32)
    closeHourlyBtn.Position = UDim2.new(1, -44, 0, 12)
    closeHourlyBtn.Text = "✕"
    closeHourlyBtn.BackgroundColor3 = Theme.Pink
    closeHourlyBtn.TextColor3 = Theme.White
    closeHourlyBtn.Font = Enum.Font.GothamBold
    closeHourlyBtn.TextSize = 15
    closeHourlyBtn.ZIndex = 46
    closeHourlyBtn.Parent = hourlyPopup
    addCorner(closeHourlyBtn, 100)

    local hourlyScroll = Instance.new("ScrollingFrame")
    hourlyScroll.Size = UDim2.new(1, -28, 1, -80)
    hourlyScroll.Position = UDim2.new(0, 14, 0, 70)
    hourlyScroll.BackgroundTransparency = 1
    hourlyScroll.BorderSizePixel = 0
    hourlyScroll.ScrollBarThickness = 5
    hourlyScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    hourlyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    hourlyScroll.ZIndex = 46
    hourlyScroll.Parent = hourlyPopup

    local hourlyGrid = Instance.new("UIGridLayout")
    hourlyGrid.CellSize = UDim2.new(0, 100, 0, 96)
    hourlyGrid.CellPadding = UDim2.new(0, 6, 0, 6)
    hourlyGrid.SortOrder = Enum.SortOrder.LayoutOrder
    hourlyGrid.Parent = hourlyScroll

    local lastRenderedHour: number? = nil
    local function renderHourlyPool()
        local pool = PetConfig.GetHourlyPool()
        lastRenderedHour = pool.hourIndex

        for _, child in ipairs(hourlyScroll:GetChildren()) do
            if child:IsA("GuiObject") then
                child:Destroy()
            end
        end

        for idx, petId in ipairs(pool.petIds) do
            local pet = PetConfig.Pets[petId]
            if pet then
                local rCol = RarityColors[pet.Rarity] or Color3.fromRGB(170, 190, 180)
                local tile = Instance.new("Frame")
                tile.Name = "Pool_" .. petId
                tile.LayoutOrder = idx
                tile.BackgroundColor3 = Theme.White
                tile.BorderSizePixel = 0
                tile.ZIndex = 47
                tile.Parent = hourlyScroll
                addCorner(tile, 12)
                addStroke(tile, rCol, 2, 0.1)

                local ic = Instance.new("TextLabel")
                ic.Size = UDim2.new(1, 0, 0, 42)
                ic.Position = UDim2.new(0, 0, 0, 6)
                ic.BackgroundTransparency = 1
                ic.Text = pet.Icon or "🐶"
                ic.TextSize = 28
                ic.ZIndex = 48
                ic.Parent = tile

                local nm = Instance.new("TextLabel")
                nm.Size = UDim2.new(1, -6, 0, 26)
                nm.Position = UDim2.new(0, 3, 0, 48)
                nm.BackgroundTransparency = 1
                nm.Text = pet.DisplayName
                nm.TextWrapped = true
                nm.TextSize = 10
                nm.ZIndex = 48
                nm.Parent = tile
                styleLabel(nm, Theme.Text, Enum.Font.GothamBold)

                local badge = Instance.new("TextLabel")
                badge.Size = UDim2.new(1, -8, 0, 16)
                badge.Position = UDim2.new(0, 4, 1, -20)
                badge.BackgroundColor3 = rCol
                badge.Text = (PetConfig.Rarities[pet.Rarity] and PetConfig.Rarities[pet.Rarity].Name) or pet.Rarity
                badge.TextColor3 = Theme.White
                badge.Font = Enum.Font.GothamBold
                badge.TextSize = 9
                badge.ZIndex = 48
                badge.Parent = tile
                addCorner(badge, 6)
            end
        end
    end

    hourlyBtn.MouseButton1Click:Connect(function()
        renderHourlyPool()
        if UIFramework then
            UIFramework.SpringOpenModal(hourlyPopup)
        else
            hourlyPopup.Visible = true
        end
    end)

    closeHourlyBtn.MouseButton1Click:Connect(function()
        if UIFramework then
            UIFramework.SpringCloseModal(hourlyPopup)
        else
            hourlyPopup.Visible = false
        end
    end)

    -- Cập nhật đồng hồ đếm ngược đổi 30 cún mỗi giây
    task.spawn(function()
        while gachaModal.Parent do
            local pool = PetConfig.GetHourlyPool()
            local mins = math.floor(pool.secondsRemaining / 60)
            local secs = pool.secondsRemaining % 60
            hourlyBtn.Text = string.format("⏰ 30 Cún Giờ Này (%02d:%02d)", mins, secs)
            if hourlyPopup.Visible and lastRenderedHour ~= pool.hourIndex then
                renderHourlyPool()
            end
            task.wait(1)
        end
    end)

    --==================================================
    -- OPEN / CLOSE MODAL
    --==================================================

    local function openGacha()
        local invModal = mainHud:FindFirstChild("InventoryModal")
        local arenaModal = mainHud:FindFirstChild("ArenaModal")

        if invModal and invModal:IsA("GuiObject") then
            invModal.Visible = false
        end

        if arenaModal and arenaModal:IsA("GuiObject") then
            arenaModal.Visible = false
        end

        resPopup.Visible = false

        if UIFramework then
            UIFramework.SpringOpenModal(gachaModal)
        else
            gachaModal.Visible = true
        end
    end

    local function closeGacha()
        if UIFramework then
            UIFramework.SpringCloseModal(gachaModal)
        else
            gachaModal.Visible = false
        end
    end

    gachaBtn.MouseButton1Click:Connect(function()
        if gachaModal.Visible then
            closeGacha()
        else
            openGacha()
        end
    end)

    closeGachaBtn.MouseButton1Click:Connect(closeGacha)

    ProximityPromptService.PromptTriggered:Connect(
        function(prompt, player)
            if prompt.Name ~= "GachaPrompt" then
                return
            end

            if player and player ~= LocalPlayer then
                return
            end

            local invModal = mainHud:FindFirstChild("InventoryModal")

            if invModal and invModal:IsA("GuiObject") then
                invModal.Visible = false
            end

            openGacha()
        end
    )

    --==================================================
    -- ROLL FUNCTION
    --==================================================

    local function startRoll(amount: number)
        if isRolling then
            return
        end

        isRolling = true
        rollToken += 1

        local currentToken = rollToken

        roll1Btn.Active = false
        roll5Btn.Active = false

        roll1Btn.AutoButtonColor = false
        roll5Btn.AutoButtonColor = false

        stageDesc.Text = amount == 1
            and "💗 Đang triệu hồi linh thú..."
            or "✨ Đang triệu hồi 5 linh thú..."

        task.spawn(
            playEggShakeAnimation,
            eggGraphic,
            currentToken,
            neutralEggPosition,
            neutralEggRotation
        )

        RollGachaEvent:FireServer(amount)

        -- Prevent an indefinitely locked interface if the server
        -- does not respond.
        task.delay(20, function()
            if currentToken ~= rollToken or not isRolling then
                return
            end

            isRolling = false
            rollToken += 1
            restoreEggPose(eggGraphic, neutralEggPosition, neutralEggRotation, false)

            roll1Btn.Active = true
            roll5Btn.Active = true

            stageDesc.Text = "💗 Hãy thử lại nhé!"
        end)
    end

    roll1Btn.MouseButton1Click:Connect(function()
        startRoll(1)
    end)

    roll5Btn.MouseButton1Click:Connect(function()
        startRoll(5)
    end)

    --==================================================
    -- RECEIVE GACHA RESULTS
    --==================================================

    GachaResultEvent.OnClientEvent:Connect(function(results)
        if not isRolling then
            return
        end

        if type(results) ~= "table" then
            return
        end

        isRolling = false
        rollToken += 1
        restoreEggPose(eggGraphic, neutralEggPosition, neutralEggRotation, false)

        roll1Btn.Active = true
        roll5Btn.Active = true

        -- Xử lý phản hồi lỗi từ server (ví dụ không đủ Xu để quay)
        if results.error == true then
            if SoundManager then
                SoundManager.PlaySFX("Reject")
            end
            stageDesc.Text = tostring(results.message or "Không đủ Xu để thực hiện lượt quay này!")
            return
        end

        stageDesc.Text = "✨ Quay 1 lần: 100 Xu  •  Quay 5 lần: 450 Xu ✨"

        local best = getBestPet(results)

        if not best then
            stageDesc.Text = "💗 Chưa có linh thú nào được triệu hồi!"
            return
        end

        if best.id == nil then
            return
        end

        lastRolledPetId = tostring(best.id)

        -- Pet icon
        resIcon.Text = best.icon or "🐶"

        -- Pet name
        resName.Text = best.name or "Linh thú bí ẩn"

        -- Rarity
        local rarity = tostring(best.rarity or "Common")
        local rarityColor = RarityColors[rarity]
            or Color3.fromRGB(170, 190, 180)

        if type(best.rarityColor) == "table"
            and #best.rarityColor >= 3 then

            local success, customColor = pcall(function()
                return Color3.new(
                    best.rarityColor[1],
                    best.rarityColor[2],
                    best.rarityColor[3]
                )
            end)

            if success then
                rarityColor = customColor
            end
        end

        resRarity.Text =
            "★ " .. string.upper(best.rarityName or rarity) .. " ★"

        resRarity.BackgroundColor3 = rarityColor

        addStroke(resRarity, rarityColor, 2, 0)

        -- Stats
        local power = tonumber(best.basePower) or 0
        local exp = tonumber(best.expPerFeed) or 0

        local statsText = string.format(
            "⚔️ Sức mạnh: %d\n🍖 EXP mỗi lần ăn: +%d",
            power,
            exp
        )

        if #results > 1 then
            local icons = {}
            for _, pet in ipairs(results) do
                if type(pet) == "table" then
                    table.insert(icons, tostring(pet.icon or "🐶"))
                end
            end
            statsText = statsText .. string.format(
                "\n🎁 Kết quả x%d: %s",
                #results,
                table.concat(icons, " ")
            )
        end

        resStats.Text = statsText

        -- Popup border changes according to rarity.
        if resStroke and resStroke:IsA("UIStroke") then
            resStroke.Color = rarityColor
            resStroke.Thickness = 3
        end

        -- Close gacha and display result.
        gachaModal.Visible = false
        resPopup.Visible = true

        if SoundManager then
            if (RarityRank[rarity] or 1) >= 3 then
                SoundManager.PlaySFX("GachaRare")
            else
                SoundManager.PlaySFX("GachaReveal")
            end
        end

        playResultAnimation(resPopup)
    end)

    --==================================================
    -- EQUIP PET
    --==================================================

    resEquip.MouseButton1Click:Connect(function()
        if not lastRolledPetId then
            return
        end

        EquipPetEvent:FireServer(lastRolledPetId)

        lastRolledPetId = nil

        if UIFramework then
            UIFramework.SpringCloseModal(resPopup)
        else
            resPopup.Visible = false
        end
    end)

    --==================================================
    -- DISMISS RESULT
    --==================================================

    resDismiss.MouseButton1Click:Connect(function()
        lastRolledPetId = nil

        if UIFramework then
            UIFramework.SpringCloseModal(resPopup)
        else
            resPopup.Visible = false
        end
    end)

    --==================================================
    -- INITIAL STATE
    --==================================================

    isRolling = false

    roll1Btn.Active = true
    roll5Btn.Active = true

    gachaModal.Visible = false
    resPopup.Visible = false

    stageDesc.Text = "🪙 Quay x1: 100 Xu • Quay x5: 450 Xu (Đi Ải kiếm Xu!)"
end

return GachaViewController
