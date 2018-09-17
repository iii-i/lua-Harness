#! /usr/bin/lua
--
-- lua-Harness : <https://fperrad.frama.io/lua-Harness/>
--
-- Copyright (C) 2009-2018, Perrad Francois
--
-- This code is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--

--[[

=head1 Lua Stand-alone

=head2 Synopsis

    % prove 241-standalone.t

=head2 Description

See section "Lua Stand-alone" in "Reference Manual"
L<https://www.lua.org/manual/5.1/manual.html#6>,
L<https://www.lua.org/manual/5.2/manual.html#7>,
L<https://www.lua.org/manual/5.3/manual.html#7>

=cut

--]]

require'tap'
local has_error52 = _VERSION >= 'Lua 5.2'
local has_error53 = _VERSION >= 'Lua 5.3'

local lua = arg[-3] or arg[-1]
local luac = jit and lua or (lua .. 'c')

if not pcall(io.popen, lua .. [[ -e "a=1"]]) then
    skip_all "io.popen not supported"
end

plan'no_plan'
diag(lua)

local f = io.open('hello.lua', 'w')
f:write([[
print 'Hello World'
]])
f:close()

local cmd = lua .. " hello.lua"
f = io.popen(cmd)
is(f:read'*l', 'Hello World', "file")
f:close()

cmd = lua .. " no_file.lua 2>&1"
f = io.popen(cmd)
like(f:read'*l', "^[^:]+: cannot open no_file.lua", "no file")
f:close()

if jit then
    os.execute(lua .. " -b hello.lua hello.luac")
else
    os.execute(luac .. " -s -o hello.luac hello.lua")
end
cmd = lua .. " hello.luac"
f = io.popen(cmd)
is(f:read'*l', 'Hello World', "bytecode")
f:close()
os.remove('hello.luac') -- clean up

if not jit then
    os.execute(luac .. " -s -o hello2.luac hello.lua hello.lua")
    cmd = lua .. " hello2.luac"
    f = io.popen(cmd)
    is(f:read'*l', 'Hello World', "combine 1")
    is(f:read'*l', 'Hello World', "combine 2")
    f:close()
    os.remove('hello2.luac') -- clean up
end

cmd = lua .. " < hello.lua"
f = io.popen(cmd)
is(f:read'*l', 'Hello World', "redirect")
f:close()

cmd = lua .. [[ -e"a=1" -e "print(a)"]]
f = io.popen(cmd)
is(f:read'*l', '1', "-e")
f:close()

cmd = lua .. [[ -e "error('msg')"  2>&1]]
f = io.popen(cmd)
is(f:read'*l', lua .. [[: (command line):1: msg]], "error")
is(f:read'*l', "stack traceback:", "backtrace")
f:close()

cmd = lua .. [[ -e "error(setmetatable({}, {__tostring=function() return 'MSG' end}))"  2>&1]]
f = io.popen(cmd)
if has_error52 or jit then
    is(f:read'*l', lua .. [[: MSG]], "error with object")
else
    is(f:read'*l', lua .. [[: (error object is not a string)]], "error with object")
end
if jit then
    is(f:read'*l', "stack traceback:", "backtrace")
else
    is(f:read'*l', nil, "not backtrace")
end
f:close()

cmd = lua .. [[ -e "error{}"  2>&1]]
f = io.popen(cmd)
if has_error53 then
    is(f:read'*l', lua .. [[: (error object is a table value)]], "error")
    is(f:read'*l', "stack traceback:", "backtrace")
elseif has_error52 then
    is(f:read'*l', lua .. [[: (no error message)]], "error")
    is(f:read'*l', nil, "not backtrace")
else
    is(f:read'*l', lua .. [[: (error object is not a string)]], "error")
    is(f:read'*l', nil, "not backtrace")
end
f:close()

cmd = lua .. [[ -e"a=1" -e "print(a)" hello.lua]]
f = io.popen(cmd)
is(f:read'*l', '1', "-e & script")
is(f:read'*l', 'Hello World')
f:close()

cmd = lua .. [[ -e "?syntax error?" 2>&1]]
f = io.popen(cmd)
like(f:read'*l', "lua", "-e bad")
f:close()

cmd = lua .. [[ -e 2>&1]]
f = io.popen(cmd)
if _VERSION ~= 'Lua 5.1' then
    like(f:read'*l', "^[^:]+: '%-e' needs argument", "no file")
end
like(f:read'*l', "^usage: ", "no file")
f:close()

cmd = lua .. [[ -v 2>&1]]
f = io.popen(cmd)
like(f:read'*l', '^Lua', "-v")
f:close()

cmd = lua .. [[ -v hello.lua 2>&1]]
f = io.popen(cmd)
like(f:read'*l', '^Lua', "-v & script")
is(f:read'*l', 'Hello World')
f:close()

if _VERSION >= 'Lua 5.2' then
    cmd = lua .. [[ -E hello.lua 2>&1]]
    f = io.popen(cmd)
    is(f:read'*l', 'Hello World')
    f:close()
else
    diag("no -E")
end

cmd = lua .. [[ -u 2>&1]]
f = io.popen(cmd)
if _VERSION ~= 'Lua 5.1' then
    like(f:read'*l', "^[^:]+: unrecognized option '%-u'", "unknown option")
end
like(f:read'*l', "^usage: ", "no file")
f:close()

cmd = lua .. [[ -ltap -e "print(type(ok))"]]
f = io.popen(cmd)
is(f:read'*l', 'function', "-ltap")
f:close()

cmd = lua .. [[ -l tap -e "print(type(ok))"]]
f = io.popen(cmd)
is(f:read'*l', 'function', "-l tap")
f:close()

cmd = lua .. [[ -l lpeg -e "print(1)" 2>&1]]
f = io.popen(cmd)
isnt(f:read'*l', nil, "-l lpeg")
f:close()

cmd = lua .. [[ -l no_lib hello.lua 2>&1]]
f = io.popen(cmd)
like(f:read'*l', "^[^:]+: module 'no_lib' not found:", "-l no lib")
f:close()

os.remove('hello.lua') -- clean up
done_testing()

-- Local Variables:
--   mode: lua
--   lua-indent-level: 4
--   fill-column: 100
-- End:
-- vim: ft=lua expandtab shiftwidth=4:
