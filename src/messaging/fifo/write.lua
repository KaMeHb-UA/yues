return function(fifo)
    local handler = io.open(fifo, 'w')
    local res = {}
    function res.close()
        handler:close()
    end
    function res.write(msg)
        handler:write(msg)
        handler:flush()
    end
    return res
end
