local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local GameMap = workspace:WaitForChild("GameMap")
local PlayerPlots = GameMap:WaitForChild("PlayerPlots")

-- Bảng lưu trữ trạng thái của từng cún
local petStates = {}

local function startPetAI(pet, plot, plotId)
    local body = pet.PrimaryPart or pet:FindFirstChild("Body")
    if not body then return end

    -- Bỏ anchor cho các part con, chỉ giữ Anchor cho PrimaryPart (hoặc unanchor hết nếu dùng physics, nhưng Anchor PrimaryPart + PivotTo là mượt nhất không rung lắc)
    for _, part in ipairs(pet:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Anchored = (part == body)
        end
    end

    local floor = plot:FindFirstChild("PlotFloor")
    local floorY = floor and (floor.Position.Y + (floor.Size.Y / 2)) or 1.35
    local baseElevation = floorY + 2.1 -- Độ cao chuẩn để 4 chân tiếp đất

    local plotCenterX = (plotId <= 3) and -42 or 42
    local plotCenterZ = (plotId == 1 or plotId == 4) and 40 or ((plotId == 2 or plotId == 5) and 75 or 110)
    local gateX = (plotId <= 3) and 1 or -1

    -- Ranh giới an toàn tuyệt đối bên trong hàng rào
    local minX = plotCenterX - 18
    local maxX = plotCenterX + 18
    local minZ = plotCenterZ - 13
    local maxZ = plotCenterZ + 13

    -- Điểm đồ chơi trong sân để cún ghé thăm
    local poiList = {}
    local toyRamp = plot:FindFirstChild("ToyRamp")
    if toyRamp then table.insert(poiList, toyRamp.Position + Vector3.new(0, 0, 0)) end
    local ballToy = plot:FindFirstChild("BallToy")
    if ballToy then table.insert(poiList, ballToy.Position + Vector3.new(0, 0, 0)) end
    local foodBowl = plot:FindFirstChild("FoodBowl")
    if foodBowl then table.insert(poiList, foodBowl.Position + Vector3.new(gateX * 1.5, 0, 0)) end
    local petBed = plot:FindFirstChild("PetBed")
    if petBed then table.insert(poiList, petBed.Position + Vector3.new(0, 0, 0)) end

    local function getRandomTarget()
        -- 40% cơ hội ghé thăm đồ chơi/bát ăn/đệm
        if #poiList > 0 and math.random(1, 100) <= 40 then
            local poi = poiList[math.random(1, #poiList)]
            return Vector3.new(poi.X, baseElevation, poi.Z)
        end
        -- 60% đi dạo ngẫu nhiên trên bãi cỏ
        local rx = math.random(minX * 10, maxX * 10) / 10
        local rz = math.random(minZ * 10, maxZ * 10) / 10

        -- Tránh đâm vào nhà Doghouse ở giữa phía sau
        local houseX = plotCenterX + (-gateX * 17)
        local houseZ = plotCenterZ
        if math.abs(rx - houseX) < 7 and math.abs(rz - houseZ) < 7 then
            rx = plotCenterX + (gateX * 5)
            rz = plotCenterZ
        end

        return Vector3.new(rx, baseElevation, rz)
    end

    -- Luồng điều khiển hành vi của cún
    task.spawn(function()
        while pet and pet.Parent do
            -- 1. CHỌN ĐÍCH ĐẾN MỚI
            local targetPos = getRandomTarget()
            local startPos = body.Position
            local dist = (Vector3.new(targetPos.X, 0, targetPos.Z) - Vector3.new(startPos.X, 0, startPos.Z)).Magnitude

            if dist > 2 then
                -- Xoay mặt về hướng đích
                local faceCFrame = CFrame.lookAt(Vector3.new(startPos.X, baseElevation, startPos.Z), Vector3.new(targetPos.X, baseElevation, targetPos.Z))
                pet:PivotTo(faceCFrame)

                -- Bước đi với tốc độ 4 - 6 studs/giây
                local speed = math.random(45, 65) / 10
                local duration = dist / speed
                local startTime = os.clock()

                while (os.clock() - startTime) < duration and pet and pet.Parent do
                    local alpha = (os.clock() - startTime) / duration
                    alpha = math.clamp(alpha, 0, 1)

                    -- Vị trí tịnh tiến phẳng X, Z
                    local currentFlatPos = startPos:Lerp(targetPos, alpha)
                    
                    -- Hiệu ứng nảy chân nhấp nhô vui vẻ (Bouncy Walk)
                    local bounceClock = (os.clock() - startTime) * 8
                    local bounceY = math.abs(math.sin(bounceClock)) * 0.45
                    local rollAngle = math.sin(bounceClock) * 0.08

                    local stepPos = Vector3.new(currentFlatPos.X, baseElevation + bounceY, currentFlatPos.Z)
                    local stepCFrame = CFrame.lookAt(stepPos, Vector3.new(targetPos.X, stepPos.Y, targetPos.Z)) * CFrame.Angles(0, 0, rollAngle)

                    pet:PivotTo(stepCFrame)
                    task.wait(0.03)
                end

                -- Đặt lại chuẩn khi tới đích
                local finalCFrame = CFrame.lookAt(Vector3.new(targetPos.X, baseElevation, targetPos.Z), Vector3.new(targetPos.X + math.random(-5, 5), baseElevation, targetPos.Z + math.random(-5, 5)))
                pet:PivotTo(finalCFrame)
            end

            -- 2. DỪNG LẠI THỰC HIỆN HÀNH ĐỘNG DỄ THƯƠNG
            local actionChoice = math.random(1, 4)
            if actionChoice == 1 then
                -- Dừng ngửi đất, nghiêng đầu ngơ ngác
                local waitSec = math.random(20, 45) / 10
                task.wait(waitSec)
            elseif actionChoice == 2 then
                -- Nhảy cẫng 2 nhịp vui vẻ (Excited Bounces)
                for _ = 1, 2 do
                    local curCF = body.CFrame
                    pet:PivotTo(curCF + Vector3.new(0, 0.8, 0))
                    task.wait(0.18)
                    pet:PivotTo(curCF)
                    task.wait(0.15)
                end
                task.wait(1.5)
            elseif actionChoice == 3 then
                -- Xoay tròn 1 vòng đuổi đuôi (Spin around)
                local curPos = body.Position
                for deg = 0, 360, 30 do
                    pet:PivotTo(CFrame.new(curPos) * CFrame.Angles(0, math.rad(deg), 0))
                    task.wait(0.04)
                end
                task.wait(2.0)
            else
                -- Đứng nghỉ ngơi thư giãn
                task.wait(math.random(25, 50) / 10)
            end
        end
    end)
end

-- Khởi động AI cho tất cả cún hiện có và lắng nghe khi có cún mới thả vào vườn
local function initAllRoamingPets()
    for id = 1, 6 do
        local plot = PlayerPlots:FindFirstChild("Plot_" .. id)
        if plot then
            local roamFolder = plot:FindFirstChild("RoamingPets")
            if roamFolder then
                for _, pet in ipairs(roamFolder:GetChildren()) do
                    startPetAI(pet, plot, id)
                end
                -- Tự động kích hoạt AI khi người chơi thả thêm cún mới vào vườn
                roamFolder.ChildAdded:Connect(function(newPet)
                    task.wait(0.2)
                    startPetAI(newPet, plot, id)
                end)
            end
        end
    end
end

initAllRoamingPets()
    for id = 1, 6 do
        local plot = PlayerPlots:FindFirstChild("Plot_" .. id)
        if plot then
            local roamFolder = plot:FindFirstChild("RoamingPets")
            if roamFolder then
                for _, pet in ipairs(roamFolder:GetChildren()) do
                    startPetAI(pet, plot, id)
                end
            end
        end
    end
end

-- Khởi động AI cho tất cả cún hiện có và lắng nghe khi có cún mới thả vào vườn
local function initAllRoamingPets()
    for id = 1, 6 do
        local plot = PlayerPlots:FindFirstChild("Plot_" .. id)
        if plot then
            local roamFolder = plot:FindFirstChild("RoamingPets")
            if roamFolder then
                for _, pet in ipairs(roamFolder:GetChildren()) do
                    startPetAI(pet, plot, id)
                end
                -- Tự động kích hoạt AI khi người chơi thả thêm cún mới vào vườn
                roamFolder.ChildAdded:Connect(function(newPet)
                    task.wait(0.2)
                    startPetAI(newPet, plot, id)
                end)
            end
        end
    end
end

initAllRoamingPets()
