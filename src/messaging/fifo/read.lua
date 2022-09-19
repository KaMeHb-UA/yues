local ffi = require 'ffi'

ffi.cdef[[
    int open(const char* pathname, int flags);
    int close(int fd);
    int read(int fd, void* buf, size_t count);
]]

local O_NONBLOCK = 2048
local chunk_size = 1

return function(fifo)
    local res = {}
    local buffer = ffi.new('uint8_t[?]', chunk_size)
    local fd = ffi.C.open(fifo, O_NONBLOCK)
    function res.close()
        ffi.C.close(fd)
    end
    function res.readLines()
        local nbytes = 1
        local res = ''
        while nbytes > 0 do
            nbytes = ffi.C.read(fd, buffer, chunk_size)
            if nbytes > 0 then res = res .. ffi.string(buffer) end
        end
        local lines = {}
        if res == '' then return lines end
        for line in res:gmatch("[^\r\n]+") do
            if line ~= '' then
                table.insert(lines, line)
            end
        end
        return lines
    end
    return res
end
