local filename = arg[1]
if not filename then
    print("Usage: lua brainfuck.lua <filename>")
    os.exit(1)
end

local file = io.open(filename, "r")
if not file then
    print("Error: Could not open file " .. filename)
    os.exit(1)
end

local code = file:read("*all")
file:close()

local tape = {}
local ptr = 1
local code_ptr = 1
local loop_stack = {}

while code_ptr <= #code do
    local cmd = code:sub(code_ptr, code_ptr)
    if cmd == ">" then
        ptr = ptr + 1
    elseif cmd == "<" then
        ptr = ptr - 1
    elseif cmd == "+" then
        tape[ptr] = (tape[ptr] or 0) + 1
    elseif cmd == "-" then
        tape[ptr] = (tape[ptr] or 0) - 1
    elseif cmd == "." then
        io.write(string.char(tape[ptr] or 0))
    elseif cmd == "," then
        tape[ptr] = io.read(1):byte() or 0
    elseif cmd == "[" then
        if tape[ptr] and tape[ptr] ~= 0 then
            table.insert(loop_stack, code_ptr)
        else
            local open_brackets = 1
            while open_brackets > 0 do
                code_ptr = code_ptr + 1
                local current_cmd = code:sub(code_ptr, code_ptr)
                if current_cmd == "[" then
                    open_brackets = open_brackets + 1
                elseif current_cmd == "]" then
                    open_brackets = open_brackets - 1
                end
            end
        end
    elseif cmd == "]" then
        if tape[ptr] and tape[ptr] ~= 0 then
            code_ptr = loop_stack[#loop_stack]
        else
            table.remove(loop_stack)
        end
    end
    code_ptr = code_ptr + 1
end
