local MeshScaler = require(script.Parent.MeshScaler)

local meshScaler: MeshScaler.ClassType?
local lastTool: Enum.RibbonTool?
local currentPlugin: Plugin

-- wrapper for the select ribbon tool because if you set the ribbon tool to the current one it just deselects it?
local function selectRibbonTool(ribbonTool: Enum.RibbonTool)
    if currentPlugin:GetSelectedRibbonTool() == ribbonTool then
        return
    end

	currentPlugin:SelectRibbonTool(ribbonTool, UDim2.new())
end

local function detachScaler()
	if meshScaler then
		if lastTool then
			selectRibbonTool(lastTool)
			lastTool = nil
		end

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

	lastTool = currentPlugin:GetSelectedRibbonTool()
	selectRibbonTool(Enum.RibbonTool.Select)

	meshScaler = MeshScaler.new(part)
end

function MeshScalerAttacher:detach()
	detachScaler()
end

function MeshScalerAttacher:cleanup()
	detachScaler()
end

return MeshScalerAttacher
