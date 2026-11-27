--!strict
-- HudController.client.luau: Master Orchestrator điều phối toàn bộ các View Controller UI
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local mainHud = script.Parent:IsA("ScreenGui") and script.Parent or script.Parent.Parent:WaitForChild("MainHUD") :: ScreenGui

-- 1. Nạp Shared Framework (UI Spring & Web Style Engine)
local Modules = ReplicatedStorage:WaitForChild("Modules")
local FrameworkFolder = Modules:FindFirstChild("Framework") or Modules

local UIFramework = require(FrameworkFolder:WaitForChild("UIFramework"))
local WebStyleEngine = require(FrameworkFolder:WaitForChild("WebStyleEngine"))
local SoundManagerModule = FrameworkFolder:FindFirstChild("SoundManager")
if SoundManagerModule and SoundManagerModule:IsA("ModuleScript") then
    local SoundManager = require(SoundManagerModule)
    SoundManager.Init()
end

-- 2. Hàm hỗ trợ tìm nạp ModuleViewController (linh hoạt dù nằm trong script hay trong MainHUD)
local function getViewController(folderName: string, moduleName: string)
    local folder = script:FindFirstChild(folderName) or script.Parent:FindFirstChild(folderName) or mainHud:FindFirstChild(folderName)
    if not folder then
        folder = script:WaitForChild(folderName, 5) or script.Parent:WaitForChild(folderName, 5) or mainHud:WaitForChild(folderName, 5)
    end
    if folder then
        local mod = folder:FindFirstChild(moduleName) or folder:WaitForChild(moduleName, 5)
        if mod and mod:IsA("ModuleScript") then
            return require(mod)
        end
    end
    return nil
end

-- 3. Nạp và khởi tạo từng thành phần giao diện độc lập (Modular View Controllers)

-- A. Thanh công cụ Toolbar & Thẻ thú cưng PetCard (hud/)
local ToolbarViewController = getViewController("hud", "ToolbarViewController")
if ToolbarViewController then
    ToolbarViewController.Init(mainHud, UIFramework, WebStyleEngine)
end

-- B. Cửa sổ Túi Đồ & Cho ăn vật phẩm (inventory/)
local InventoryViewController = getViewController("inventory", "InventoryViewController")
if InventoryViewController then
    InventoryViewController.Init(mainHud, UIFramework, WebStyleEngine)
end

-- C. Cửa sổ Triệu Hồi Linh Thú & Gacha (gacha/)
local GachaViewController = getViewController("gacha", "GachaViewController")
if GachaViewController then
    GachaViewController.Init(mainHud, UIFramework, WebStyleEngine)
end

-- C2. Sổ Sưu Tập 305 Loài Chó (gacha/CollectionViewController)
local CollectionViewController = getViewController("gacha", "CollectionViewController")
if CollectionViewController then
    CollectionViewController.Init(mainHud, UIFramework, WebStyleEngine)
end

-- D. Cửa sổ Đấu Trường Solo Pet (arena/)
local ArenaViewController = getViewController("arena", "ArenaViewController")
if ArenaViewController then
    ArenaViewController.Init(mainHud, UIFramework, WebStyleEngine)
end

-- E. Màn hình Chào Mừng / Thương Hiệu Game (hud/SplashViewController)
local SplashViewController = getViewController("hud", "SplashViewController")
if SplashViewController then
    SplashViewController.Init(mainHud, UIFramework, WebStyleEngine)
end

print("✨ [MainHUD] Toàn bộ hệ thống giao diện đã được khởi tạo thành công theo cấu trúc module riêng biệt!")
