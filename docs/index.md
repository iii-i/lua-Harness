
# lua-Harness

---

## Overview

This is a test suite for Lua.

This suite is usable with :

- the standard [lua](http://www.lua.org/),
- [LuaJIT](http://luajit.org/),
- [OpenResty](https://github.com/openresty/luajit2),
- [LuaVela](https://github.com/iponweb/luavela),
- [RaptorJIT](https://github.com/raptorjit/raptorjit),
- ...

See the given coverage :

 - [Lua 5.1.5](cover_lua515/src/index.html),
 - [Lua 5.2.4](cover_lua524/src/index.html),
 - [Lua 5.3.6](cover_lua536/src/index.html),
 - [Lua 5.4.1](cover_lua541/src/index.html)

It uses the
[Test Anything Protocol](http://en.wikipedia.org/wiki/Test_Anything_Protocol)
as output, that allows a compatibility with the Perl QA ecosystem.

## Download

lua-Harness source can be downloaded from
[Framagit](http://framagit.org/fperrad/lua-Harness).

## Copyright and License

Copyright &copy; 2009-2020 Fran&ccedil;ois Perrad

This library is licensed under the terms of the MIT/X11 license,
like Lua itself.
