# Support Ukraine <img alt="ukraine" height="32" width="32" src="https://github.githubassets.com/images/icons/emoji/unicode/1f1fa-1f1e6.png">

While you're reading this text we're suffering from russia's bombs. Please help us to stand against russia's invasion and prevent World War III. It's pretty easy with **[UNITED24 fundraising platform](https://u24.gov.ua/)**. Thank you!

## YueS (Yue library Server)
[![License](https://img.shields.io/github/license/KaMeHb-UA/yues?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGZpbGw9Im5vbmUiIHZpZXdCb3g9IjAgMCAyNCAyNCIgc3Ryb2tlPSIjRkZENzAwIj48cGF0aCBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIHN0cm9rZS13aWR0aD0iMiIgZD0iTTMgNmwzIDFtMCAwbC0zIDlhNS4wMDIgNS4wMDIgMCAwMDYuMDAxIDBNNiA3bDMgOU02IDdsNi0ybTYgMmwzLTFtLTMgMWwtMyA5YTUuMDAyIDUuMDAyIDAgMDA2LjAwMSAwTTE4IDdsMyA5bS0zLTlsLTYtMm0wLTJ2Mm0wIDE2VjVtMCAxNkg5bTMgMGgzIi8%2BPC9zdmc%2BCg%3D%3D&label=License&style=flat-square)](https://github.com/KaMeHb-UA/yues/blob/master/LICENSE)
[![Runtime](https://img.shields.io/badge/Runtime-LuaJIT-4162bf?logo=lua&logoColor=2C2D72&style=flat-square)](https://luajit.org/)
[![AUR publish](https://img.shields.io/github/workflow/status/KaMeHb-UA/yues/aur-publish?style=flat-square&label=AUR%20publish&logo=github)](https://github.com/KaMeHb-UA/yues/actions/workflows/aur.yml)
[![AUR version](https://img.shields.io/aur/version/yues?style=flat-square&label=AUR%20version&logo=archlinux)](https://aur.archlinux.org/packages/yues)

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

- `CREATE` <blockquote>Creates the function and returns it's id. See **[Function scope](#function-scope)** section.</blockquote>  
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

- `IIFE` <blockquote>Creates function, invokes it, returns the result and removes the function immidiately. See **[Function scope](#function-scope)** section.</blockquote>  
`id` — `string`, the id of the call, pseudorandom string used to properly corellate and get back result of the invocation. It's recommended to use [UUIDv4](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random))  
`argNames` — `Array<string>`, list of argument names to be passed to the function at its invocation  
`body` — `string`, the body of the function written in [Lua 5.1](https://www.lua.org/manual/5.1/)  
`args` — `Array<any>`, the arguments passed to function call  

#### Function scope

There are some new globals available:

- `gui` — object that contains all the stuff from Yue lib. The same as `require('yue.gui')`

- `JSON` — JSON reader/encoder (see `JSON.lua` in **[Bundled dependencies](#bundled-dependencies)** section)

- `postMessage` — method that sends `POSTMESSAGE` with a value passed to the method. Usable for sending event messages. <blockquote>Signature: `postMessage(value: any): void`</blockquote>  

- `sleep` — method that temporarily stops the invocation for specified period of time in seconds. <blockquote>Signature: `sleep(seconds: number): void`</blockquote>  

- `__readMessagesSync` — method that synchronously reads new messages from `infifo` and invokes `messaging.onmessage` for each new message. <blockquote>Signature: `__readMessagesSync(): void`</blockquote>  

- `__getFunction` — method that returns a function that was previously created with a `CREATE` call by specified id. <blockquote>Signature: `__getFunction(ref: string): (...args: any[]) => any`</blockquote>  
