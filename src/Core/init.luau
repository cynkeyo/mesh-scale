local Selection = game:GetService("Selection")
local MeshScalerAttacher = require(script.MeshScalerAttacher)
local UserInterface = require(script.UserInterface)

local selectionChangedConnection: RBXScriptConnection
local meshScalerActive = false

local Core = {}

local function onSelectionChanged()
	if not meshScalerActive then
		return
	end

	local selection = Selection:Get()
	local firstSelected = selection[1]
	if #selection ~= 1 or not MeshScalerAttacher.canAttachToInstance(firstSelected) then
		MeshScalerAttacher:detach()
		return
	end

	MeshScalerAttacher:detach()
	MeshScalerAttacher:attachToPart(firstSelected)
end

function Core:init(plugin)
	MeshScalerAttacher:init(plugin)
	UserInterface:init(plugin, function(toggle)
		meshScalerActive = toggle

		if not toggle then
			MeshScalerAttacher:detach()
		else
			onSelectionChanged()
		end
	end, function() end)

	selectionChangedConnection = Selection.SelectionChanged:Connect(onSelectionChanged)
end

function Core:cleanup()
	selectionChangedConnection:Disconnect()
	MeshScalerAttacher:cleanup()
end

return Core
