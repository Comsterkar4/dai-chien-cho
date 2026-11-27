--!strict
-- tests/check_syntax.luau
-- Kiểm tra cú pháp Luau (compile & check errors) cho toàn bộ file trong src/

local fs = require("@lune/fs")
local luau = require("@lune/luau")

local function scanDir(dir: string, list: {string})
    for _, entry in ipairs(fs.readDir(dir)) do
        local fullPath = dir .. "/" .. entry
        if fs.isDir(fullPath) then
            scanDir(fullPath, list)
        elseif string.find(entry, "%.luau$") or string.find(entry, "%.lua$") then
            table.insert(list, fullPath)
        end
    end
end

local files = {}
scanDir("src", files)

print(string.format("🔍 Bắt đầu kiểm tra cú pháp Luau cho %d files trong src/...", #files))
print("==================================================")

local passed = 0
local failed = 0

for _, file in ipairs(files) do
    local content = fs.readFile(file)
    local success, err = pcall(function()
        luau.compile(content)
    end)

    if success then
        passed += 1
        print(string.format("  ✅ [PASS] %s", file))
    else
        failed += 1
        print(string.format("  ❌ [FAIL] %s:\n     %s", file, tostring(err)))
    end
end

print("==================================================")
if failed == 0 then
    print(string.format("🎉 CÚ PHÁP HOÀN HẢO! %d/%d files biên dịch Luau thành công 100%%!", passed, #files))
else
    print(string.format("⚠️ Phát hiện %d files lỗi cú pháp!", failed))
    error("Syntax verification failed.")
end
