local lfs = require 'lfs'
local os = require 'os'
local appFile = debug.getinfo(1).short_src
local ok, err = lfs.chdir(appFile:match '@?(.*/)')

if not ok then
  print(err)
  os.exit(1)
end

require 'app'
