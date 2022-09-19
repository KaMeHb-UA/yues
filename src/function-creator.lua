local uuid = require 'lua-uuid'

local functionStorage = {}

local function getNextUuid()
    local id = uuid()
    if functionStorage[id] == nil then
        return id
    end
    return getNextUuid()
end

local function createFunction(body, args, env)
    local func = loadstring('return (function(' .. table.concat(args, ', ') .. ')\n' .. body .. '\nend)(...)')
    if func == nil then
        local _, err = loadstring(body)
        return nil, err
    end
    local id = getNextUuid()
    functionStorage[id] = setfenv(func, env)
    return id
end

local function getFunction(id)
    local func = functionStorage[id]
    if func == nil then
        return nil, 'couldn\'t get function referenced as ' .. id
    end
    return func
end

local function removeFunction(id)
    functionStorage[id] = nil
end

return function()
    return createFunction, getFunction, removeFunction
end
