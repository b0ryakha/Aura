window.set_visible(false)

local args = globalvars.get_args()
local program = args[1]

if #args < 2 then
    error("using: " .. program .. " <path>")
end

local path = args[2]

print(program .. ": Tests processing...")

local list = {}

for _, file_name in ipairs(file.get_list(path)) do
    if string.find(file_name, ".lua") then
        list[#list + 1] = file_name
        print(program .. ": Added " .. file_name .. "...")
    end
end

local tasks_path = "./.vscode/tasks.json"
local tasks = file.read(tasks_path)

local is_options = false
local options_start = 0
local options_end = 0

for i, line in ipairs(tasks) do
    if string.find(line, "\"options\"") then
        options_start = i
        is_options = true
    end

    if is_options and string.find(line, "]") then
        options_end = i
        break
    end
end

for i = options_end, options_start, -1 do
    table.remove(tasks, i)
end

local indent = string.match(tasks[options_start - 1], "^(%s*)")
local aligned_heh = indent .. "\"options\": [ \"" .. table.concat(list, "\", \"") .. "\" ],"
table.insert(tasks, options_start, aligned_heh)

file.write(tasks_path, tasks, true)
print(program .. ": " .. tasks_path .. "has been successfully updated!")