local Core = require(script.Core)

Core:init(plugin)

plugin.Unloading:Connect(function()
    Core:cleanup()
end)
