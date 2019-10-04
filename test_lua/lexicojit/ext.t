--
-- lua-Harness : <https://fperrad.frama.io/lua-Harness/>
--
-- Copyright (C) 2019, Perrad Francois
--
-- This code is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--

do -- thread.exdata
    local r, exdata = pcall(require, 'thread.exdata')
    is(r, true, 'thread.exdata')
    type_ok(exdata, 'function')
    is(package.loaded['thread.exdata'], exdata)

    local ffi = require'ffi'
    local u64 = ffi.new('uintptr_t', 0xefdeaddeadbeefLL)
    local ptr = ffi.cast('void *', u64)
    exdata(u64)  -- set
    is(exdata(), ptr) -- get

    error_like(function () exdata(42) end,
               "^[^:]+:%d+: bad argument #1 to 'exdata' %(cdata expected, got number%)")
end

-- Local Variables:
--   mode: lua
--   lua-indent-level: 4
--   fill-column: 100
-- End:
-- vim: ft=lua expandtab shiftwidth=4:
