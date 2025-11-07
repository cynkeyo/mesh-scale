local Selection = game:GetService("Selection")

local MeshScalerRibbonTool = require(script.Parent.modules.MeshScalerRibbonTool)
local UserInterface = require(script.Parent.modules.UserInterface)
local matchPartPivotToMesh = require(script.Parent.utils.matchPartPivotToMesh)
local meshify = require(script.Parent.utils.meshify)

local ribbonTool: MeshScalerRibbonTool.ClassType

local Core = {}

function Core:init(plugin)
    ribbonTool = MeshScalerRibbonTool.new(plugin)

	UserInterface:init(plugin, function(toggle)
		if not toggle then
            ribbonTool:Deactivate()
		else
            ribbonTool:Activate()
		end
	end, function()
		for _, selected in pairs(Selection:Get()) do
			if not selected:IsA("BasePart") then
				continue
			end

			meshify(selected)
		end
	end, function()
		for _, selected in pairs(Selection:Get()) do
			if not selected:IsA("BasePart") then
				continue
			end

			matchPartPivotToMesh(selected)
		end
	end)
end

function Core:cleanup()
    ribbonTool:Destroy()
end

return Core
