local CoreGui = game:GetService("CoreGui")
local Selection = game:GetService("Selection")
local UserInputService = game:GetService("UserInputService")
local MeshScaler = require(script.MeshScaler)
local Janitor = require(script.Parent.Parent.Parent.packages.Janitor)

local ACTIVE_SCALER_JANITOR_INDEX = "ACTIVE_SCALER"
local MOUSE_CLICKED_JANITOR_INDEX = "MOUSE_CLICKED"
local MESH_SCALER_RIBBON_TOOL = Enum.RibbonTool.None

local MeshScalerTool = {
    RibbonTool = MESH_SCALER_RIBBON_TOOL
}
MeshScalerTool.__index = MeshScalerTool

export type ClassType = typeof(setmetatable(
	{} :: {
		_janitor: Janitor.Janitor,
		_plugin: Plugin,
	},
	MeshScalerTool
))

function MeshScalerTool.new(plugin: Plugin): ClassType
	local self = setmetatable({}, MeshScalerTool) :: ClassType

	local janitor = Janitor.new()
	self._plugin = plugin
	self._janitor = janitor

	local hoverHighlight = janitor:Add(Instance.new("Highlight"))
	hoverHighlight.OutlineColor = Color3.fromRGB(161, 0, 172)
	hoverHighlight.FillColor = Color3.fromRGB(161, 0, 172)
	hoverHighlight.FillTransparency = 0.9
	hoverHighlight.Parent = CoreGui

	-- selection functionality
	plugin:Activate(true)
	plugin:SelectRibbonTool(MESH_SCALER_RIBBON_TOOL, UDim2.new())
    
    repeat
        task.wait()
    until plugin:GetSelectedRibbonTool() == MESH_SCALER_RIBBON_TOOL

	local mouse = plugin:GetMouse()

	janitor:Add(UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end

		local target = mouse.Target
		if not target then
			return
		end
		hoverHighlight.Adornee = if MeshScaler.canAttachToInstance(target) then target else nil
	end))

	local activeScaler: MeshScaler.ClassType?
	local lastSelected: Instance?
	janitor:Add(
		UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end
			if activeScaler then
                if activeScaler.Hovered then
                    activeScaler:Start()
                    return
                end
			end

			local target = mouse.Target
			if not target or target == lastSelected then
				return
			end
			if not MeshScaler.canAttachToInstance(target) then
				return
			end

			if activeScaler then
				activeScaler:Destroy()
				activeScaler = nil
				janitor:Remove(ACTIVE_SCALER_JANITOR_INDEX)
			end

			Selection:Set({ target })

			activeScaler = MeshScaler.new(target, mouse)
			lastSelected = target

			janitor:Add(activeScaler, false, ACTIVE_SCALER_JANITOR_INDEX)
		end),
		false,
		MOUSE_CLICKED_JANITOR_INDEX
	)
    janitor:Add(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        if activeScaler then
            activeScaler:Stop()
        end
    end))

	local selection = Selection:Get()
	local firstSelected = selection[1]
	if #selection == 1 then
		if MeshScaler.canAttachToInstance(firstSelected) then
			activeScaler = MeshScaler.new(firstSelected, mouse)
			lastSelected = firstSelected

			janitor:Add(activeScaler, false, ACTIVE_SCALER_JANITOR_INDEX)
		end
	end

	return self
end
function MeshScalerTool.Destroy(self: ClassType)
	self._plugin:Deactivate()
	self._janitor:Cleanup()
	setmetatable(self :: any, nil)
	table.clear(self :: any)
	table.freeze(self)
end

return MeshScalerTool
