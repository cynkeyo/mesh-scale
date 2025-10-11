local MeshScaler = require(script.Parent.MeshScaler)

local meshScaler: MeshScaler.ClassType?
local currentPlugin: Plugin

local function detachScaler()
	if meshScaler then
		meshScaler:Destroy()
        meshScaler = nil
	end
end

local MeshScalerAttacher = {}

function MeshScalerAttacher:init(plugin)
    currentPlugin = plugin
end

function MeshScalerAttacher.canAttachToInstance(instance: Instance): boolean
	return MeshScaler.canAttachToInstance(instance)
end

function MeshScalerAttacher:attachToPart(part: BasePart)
    assert(MeshScaler.canAttachToInstance(part), "Can't attach to this instance")

    currentPlugin:SelectRibbonTool(Enum.RibbonTool.None, UDim2.new())
    meshScaler = MeshScaler.new(part)
end

function MeshScalerAttacher:detach()
	detachScaler()
end

function MeshScalerAttacher:cleanup()
    detachScaler()
end

return MeshScalerAttacher
