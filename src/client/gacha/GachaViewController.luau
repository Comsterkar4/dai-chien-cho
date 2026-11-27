
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

    gachaBtn.MouseButton1Click:Connect(openGacha)

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

        stageDesc.Text = "✨ Chạm vào vận may để triệu hồi! ✨"

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

        resStats.Text = string.format(
            "⚔️ Sức mạnh: %d\n🍖 EXP mỗi lần ăn: +%d",
            power,
            exp
        )

        -- Popup border changes according to rarity.
        if resStroke and resStroke:IsA("UIStroke") then
            resStroke.Color = rarityColor
            resStroke.Thickness = 3
        end

        -- Close gacha and display result.
        gachaModal.Visible = false
        resPopup.Visible = true

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

    stageDesc.Text = "💗 Chạm vào vận may để triệu hồi linh thú! 💗"
end

return GachaViewController
