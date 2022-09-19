-- Name: lua-uuid.lua
-- Description: quick lua implementation of "random" UUID
-- Author: Jacob Rus
-- Link: https://gist.github.com/jrus/3197011
-- *Modified, see original above

math.randomseed(os.time())

local random = math.random
local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

local function uuid()
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

return uuid
