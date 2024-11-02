--functions for server side
local server = require "configs.server"
local storage = require "server.storage"
function IsAdmin(source)
    return IsPlayerAceAllowed(source, server.permission.admin)
end

onResourceStart(function()
    storage.Init()
end)

