# Support Ukraine <img alt="ukraine" height="32" width="32" src="https://github.githubassets.com/images/icons/emoji/unicode/1f1fa-1f1e6.png">

While you're reading this text we're suffering from russia's bombs. Please help us to stand against russia's invasion and prevent World War III. It's pretty easy with **[UNITED24 fundraising platform](https://u24.gov.ua/)**. Thank you!

## YueS (Yue library Server)

This project aims to provide the power of [Yue](https://libyue.com/) for any language/framework without need in modification of runtime core sources.  
Written in [Lua 5.1](https://www.lua.org/manual/5.1/) with [LuaJIT](https://luajit.org/luajit.html) as a runtime core.  

### External dependencies:
- [Lua5.1 bindings for Yue library](https://github.com/yue/yue/releases)
- [LuaFileSystem for Lua 5.1](https://lunarmodules.github.io/luafilesystem/)
- [LuaSocket for Lua 5.1](https://lunarmodules.github.io/luasocket/)

### Bundled dependencies:
- [lua-uuid.lua](https://gist.github.com/jrus/3197011)
- [JSON.lua](http://regex.info/blog/lua/json)

### Usage
Server should be created as a subprocess of your app. On Unix-like systems there is need to create two named FIFOs and provide their paths to the server using CLI args:
```sh
$ yues /path/to/infifo /path/to/outfifo
```
Naming description: `infifo` is the FIFO your program writes to, `outfifo` is the FIFO your program reads from.

#### Main principles

The idea of such server is allowance of executing arbitrary code on server side and get the results on client side. Any definitions of components should be implemented on client side ([example](https://github.com/KaMeHb-UA/yues-gui-components-js/blob/master/src/components/view/index.ts)). That's why this server is compatible with any Yue library version. Needed library version also should be checked at the client side ([example](https://github.com/KaMeHb-UA/yues-gui-components-js/blob/master/src/utils/check-version.ts)).

#### Messaging protocol

> Each message is a JSON-encoded object with one required prop — `type` that is string and describes the type of the message. The rest props are defined according to the type of the message. Each message should have newline ending (`U+000A`)

##### Server-sent messages (`outfifio`)

- `INIT` <blockquote>Sent once after server is initialized. Has no more props</blockquote>  

- `POSTMESSAGE` <blockquote>Sent right after global `postMessage` has been called. List of props:</blockquote>  
`val` — `any`, the value that is passed to `postMessage` call. Can be of any serializable type  

- `CREATE_R` <blockquote>The result of function creation</blockquote>  
`id` — `string`, the id passed to `CREATE` call  
`res` — _optional_, `string`, the id of created function  
`err` — _optional_, `string`, the error message if there is an error  

- `CALL_R` <blockquote>The result of function call</blockquote>  
`id` — `string`, the id passed to `CALL` call  
`res` — _optional_, `any`, the result of function call. May be of any serializable type  
`err` — _optional_, `string`, the error message if there is an error  

- `REMOVE_R` <blockquote>The result of function removal</blockquote>  
`id` — `string`, the id passed to `REMOVE` call  

- `IIFE_R` <blockquote>The result of function creation and immidiate invocation</blockquote>  
`id` — `string`, the id passed to `IIFE` call  
`res` — _optional_, `any`, the result of function call. May be of any serializable type  
`err` — _optional_, `string`, the error message if there is an error  

##### Client-sent messages (`infifo`)

- `CREATE` <blockquote>Creates the function and returns it's id</blockquote>  
`id` — `string`, the id of the call, pseudorandom string used to properly corellate and get back result of the invocation. It's recommended to use [UUIDv4](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random))  
`args` — `Array<string>`, list of argument names to be passed to the function at its invocation  
`body` — `string`, the body of the function written in [Lua 5.1](https://www.lua.org/manual/5.1/)  

- `CALL` <blockquote>Calls already created function by it's id</blockquote>  
`id` — `string`, the id of the call, pseudorandom string used to properly corellate and get back result of the invocation. It's recommended to use [UUIDv4](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random))  
`ref` — `string`, the id of the function to be invoked  
`args` — `Array<any>`, the arguments passed to function call  

- `REMOVE` <blockquote>Removes already created function by it's id</blockquote>  
`id` — `string`, the id of the call, pseudorandom string used to properly corellate and get back result of the invocation. It's recommended to use [UUIDv4](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random))  
`ref` — `string`, the id of the function to be removed  

- `IIFE` <blockquote>Creates function, invokes it, returns the result and removes the function immidiately</blockquote>  
`id` — `string`, the id of the call, pseudorandom string used to properly corellate and get back result of the invocation. It's recommended to use [UUIDv4](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random))  
`argNames` — `Array<string>`, list of argument names to be passed to the function at its invocation  
`body` — `string`, the body of the function written in [Lua 5.1](https://www.lua.org/manual/5.1/)  
`args` — `Array<any>`, the arguments passed to function call  
