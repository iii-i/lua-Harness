#! /usr/bin/lua
--
-- lua-Harness : <https://fperrad.frama.io/lua-Harness/>
--
-- Copyright (C) 2010-2018, Perrad Francois
--
-- This code is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--

--[[

=head1 Lua Stand-alone

=head2 Synopsis

    % prove t/242-luac.t

=head2 Description

See section "Lua Stand-alone" in "Reference Manual"
L<https://www.lua.org/manual/5.1/manual.html#6>,
L<https://www.lua.org/manual/5.2/manual.html#7>,
L<https://www.lua.org/manual/5.3/manual.html#7>

=cut

--]]

require'tap'

if jit then
    skip_all("LuaJIT")
end

local lua = arg[-3] or arg[-1]
local luac = lua .. 'c'

if not pcall(io.popen, lua .. [[ -e "a=1"]]) then
    skip_all "io.popen not supported"
end

plan'no_plan'
diag(luac)

local bin_version
if     _VERSION == 'Lua 5.1' then
    bin_version = "\x51"
elseif _VERSION == 'Lua 5.2' then
    bin_version = "\x52"
elseif _VERSION == 'Lua 5.3' then
    bin_version = "\x53"
elseif _VERSION == 'Lua 5.4' then
    bin_version = "\x54"
end

do -- hello.lua
    local f = io.open('hello.lua', 'w')
    f:write([[
local a = false
b = a + 1
pi = 3.14
s = "all escaped \1\a\b\f\n\r\t\v\\\""
local t = { "a", "b", "c", "d" }
local f = table.concat
local function f () while true do print(a) end end
s = nil

print 'Hello World'
]])
    f:close()
end

do -- luac -v
    local cmd = luac .. [[ -v 2>&1]]
    local f = io.popen(cmd)
    like(f:read'*l', '^Lua', "-v")
    f:close()
end

do -- luac -u
    local cmd = luac .. [[ -u 2>&1]]
    local f = io.popen(cmd)
    like(f:read'*l', "^[^:]+: unrecognized option '%-u'", "unknown option")
    like(f:read'*l', "^usage:")
    f:close()
end

do -- luac -p hello.lua
    local cmd = luac .. [[ -p hello.lua 2>&1]]
    local f = io.popen(cmd)
    is(f:read'*l', nil)
    f:close()
end

do -- luac -o no_file.lua
    local cmd = luac .. [[ -p no_file.lua 2>&1]]
    local f = io.popen(cmd)
    like(f:read'*l', "^[^:]+: cannot open no_file.lua", "no file")
    f:close()
end

do -- luac -v -l -l hello.lua
    local cmd = luac .. [[ -v -l -l hello.lua]]
    local f = io.popen(cmd)
    like(f:read'*l', '^Lua', "-v -l -l")
    is(f:read'*l', '')
    like(f:read'*l', "^main")
    f:close()
end

do -- luac -l luac.out
    local cmd = luac .. [[ -l luac.out]]
    local f = io.popen(cmd)
    is(f:read'*l', '')
    like(f:read'*l', "^main")
    f:close()
end

if _VERSION ~= 'Lua 5.1' then
    local f = io.open('luac.out', 'w')
    f:write("\x1bLua" .. bin_version .. "\x00")
    f:close()
    local cmd = luac .. [[ luac.out 2>&1]]
    f = io.popen(cmd)
    like(f:read'*l', "truncated precompiled chunk")
    f:close()
end

if _VERSION ~= 'Lua 5.1' then
    local f = io.open('luac.out', 'w')
    f:write("\x1bFoo" .. bin_version .. "\x00\xde\xad\xbe\xef\x00\x19\x93\r\n\x1a\nCode")
    f:close()
    local cmd = luac .. [[ luac.out 2>&1]]
    f = io.popen(cmd)
    like(f:read'*l', "not a precompiled chunk")
    f:close()
end

if _VERSION ~= 'Lua 5.1' then
    local f = io.open('luac.out', 'w')
    f:write "\x1bLua\x51\x00\xde\xad\xbe\xef\x00\x19\x93\r\n\x1a\nCode"
    f:close()
    local cmd = luac .. [[ luac.out 2>&1]]
    f = io.popen(cmd)
    like(f:read'*l', "version mismatch in precompiled chunk")
    f:close()
end

if _VERSION ~= 'Lua 5.1' then
    local f = io.open('luac.out', 'w')
    f:write("\x1bLua" .. bin_version .. "\x00\xde\xad\xbe\xef\x00\x19\x93\r\n\x1a\nCode")
    f:close()
    local cmd = luac .. [[ luac.out 2>&1]]
    f = io.popen(cmd)
    if _VERSION >= 'Lua 5.3' then
        like(f:read'*l', "corrupted precompiled chunk")
    else
        like(f:read'*l', "incompatible precompiled chunk")
    end
    f:close()
end

os.remove('hello.lua') -- clean up
os.remove('luac.out') -- clean up
done_testing()

-- Local Variables:
--   mode: lua
--   lua-indent-level: 4
--   fill-column: 100
-- End:
-- vim: ft=lua expandtab shiftwidth=4:
