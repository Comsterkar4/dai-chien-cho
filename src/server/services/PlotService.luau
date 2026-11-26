--!strict
-- PlotService.luau: Quản lý 6 mảnh đất (Player Plots), cấp phát và thu hồi khu đất
local PlotService = {}

local playerPlots: {[Player]: number} = {}
local plotOwners: {[number]: Player} = {}

function PlotService.GetAvailablePlot(): number
    for id = 1, 6 do
        if not plotOwners[id] then
            return id
        end
    end
    return 1
end

function PlotService.AssignPlot(player: Player): number
    local plotId = PlotService.GetAvailablePlot()
    playerPlots[player] = plotId
    plotOwners[plotId] = player

    local gameMap = workspace:FindFirstChild("GameMap")
    local plotsFolder = gameMap and gameMap:FindFirstChild("PlayerPlots")
    if plotsFolder then
        local pModel = plotsFolder:FindFirstChild("Plot_" .. plotId)
        if pModel then
            local sign = pModel:FindFirstChild("PlotSign", true)
            if sign then
                local sf = sign:FindFirstChild("Frame")
                if sf then
                    local ownerLbl = sf:FindFirstChild("SignOwner")
                    if ownerLbl and ownerLbl:IsA("TextLabel") then
                        ownerLbl.Text = "👤 " .. player.DisplayName
                        ownerLbl.TextColor3 = Color3.fromRGB(255, 230, 80)
                    end
                end
            end
        end
    end
    return plotId
end

function PlotService.ReleasePlot(player: Player)
    local plotId = playerPlots[player]
    if plotId then
        plotOwners[plotId] = nil
        playerPlots[player] = nil

        local gameMap = workspace:FindFirstChild("GameMap")
        local plotsFolder = gameMap and gameMap:FindFirstChild("PlayerPlots")
        if plotsFolder then
            local pModel = plotsFolder:FindFirstChild("Plot_" .. plotId)
            if pModel then
                local sign = pModel:FindFirstChild("PlotSign", true)
                if sign then
                    local sf = sign:FindFirstChild("Frame")
                    if sf then
                        local ownerLbl = sf:FindFirstChild("SignOwner")
                        if ownerLbl and ownerLbl:IsA("TextLabel") then
                            ownerLbl.Text = "[ Sẵn sàng đón chủ ]"
                            ownerLbl.TextColor3 = Color3.fromRGB(230, 235, 245)
                        end
                    end
                end
            end
        end
    end
end

function PlotService.GetPlayerPlot(player: Player): number?
    return playerPlots[player]
end

return PlotService
