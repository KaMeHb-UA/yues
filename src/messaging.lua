local binaryFormat = package.cpath:match('%p[\\|/]?%p(%a+)')

if os.getenv('PATH') and binaryFormat ~= 'dll' then
    return require 'messaging.unix'
end

return require 'messaging.win32'
