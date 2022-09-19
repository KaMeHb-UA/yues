local gui = require 'yue.gui'
local JSON = require 'JSON'
local createfiforeader = require 'messaging.fifo.read'
local createfifowriter = require 'messaging.fifo.write'
local initmsg = require 'messaging.initmsg'

local inFifo = createfiforeader(arg[1])
local outFifo = createfifowriter(arg[2])

local messaging = {}

function messaging.send(msg)
    outFifo.write(JSON:encode(msg))
end

function messaging.onmessage() end

local function interval(time, func)
    local function wrapped()
        func()
        gui.MessageLoop.postdelayedtask(time, wrapped)
    end
    gui.MessageLoop.postdelayedtask(time, wrapped)
end

local function read()
    for i, line in pairs(inFifo.readLines()) do
        messaging.onmessage(JSON:decode(line))
    end
end

function gui.app.onready()
    interval(10, read)
    outFifo.write(initmsg)
end

return messaging
