local gui = require 'yue.gui'
local JSON = require 'JSON'
local messaging = require 'messaging'
local createFunction, getFunction, removeFunction = require 'function-creator' ()

local function postMessage(val)
    messaging.send{
        type = 'POSTMESSAGE',
        val = val,
    }
end

local funcEnv = {
    gui = gui,
    JSON = JSON,
    postMessage = postMessage,
    __getFunction = getFunction,
}

function messaging.onmessage(msg)
    if msg.type == 'CREATE' then
        local id, err = createFunction(msg.body, msg.args, funcEnv)
        if err ~= nil then
            return messaging.send{
                type = 'CREATE_R',
                id = msg.id,
                err = err,
            }
        end
        return messaging.send{
            type = 'CREATE_R',
            id = msg.id,
            res = id,
        }
    elseif msg.type == 'CALL' then
        local func, err = getFunction(msg.ref)
        if err ~= nil then
            return messaging.send{
                type = 'CALL_R',
                id = msg.id,
                err = err,
            }
        end
        local res, funcerr = func(unpack(msg.args))
        if funcerr ~= nil then
            return messaging.send{
                type = 'CALL_R',
                id = msg.id,
                err = funcerr,
            }
        end
        return messaging.send{
            type = 'CALL_R',
            id = msg.id,
            res = res,
        }
    elseif msg.type == 'REMOVE' then
        removeFunction(msg.ref)
        return messaging.send{
            type = 'REMOVE_R',
            id = msg.id,
        }
    elseif msg.type == 'IIFE' then
        local id, createrr = createFunction(msg.body, msg.argNames, funcEnv)
        if createrr ~= nil then
            return messaging.send{
                type = 'IIFE_R',
                id = msg.id,
                err = createrr,
            }
        end
        local func, geterr = getFunction(id)
        if geterr ~= nil then
            return messaging.send{
                type = 'IIFE_R',
                id = msg.id,
                err = geterr,
            }
        end
        removeFunction(id)
        local res, callerr = func(unpack(msg.args))
        if callerr ~= nil then
            return messaging.send{
                type = 'IIFE_R',
                id = msg.id,
                err = callerr,
            }
        end
        return messaging.send{
            type = 'IIFE_R',
            id = msg.id,
            res = res,
        }
    end
end

gui.MessageLoop.posttask(function()
    if gui.app.onready ~= nil then
        gui.app.onready()
    end
end)

-- Enter message loop.
-- WARNING: there is no escape here. You need to manually close message loop
-- using commands described above (call created function or using iife)
gui.MessageLoop.run()
