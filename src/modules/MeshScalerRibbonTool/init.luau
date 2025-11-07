local ReplicatedFirst = game:GetService("ReplicatedFirst")
local MeshScalerTool = require(script.MeshScalerTool)
local Janitor = require(script.Parent.Parent.packages.Janitor)
local UserInterface = require(script.Parent.UserInterface)
local MeshScalerRibbonTool = {}

local TOOL_CHANGED_JANITOR_INDEX = "TOOL_CHANGED"

MeshScalerRibbonTool.__index = MeshScalerRibbonTool

export type ClassType = typeof(setmetatable(
	{} :: {
		_plugin: Plugin,
		_meshScalerTool: MeshScalerTool.ClassType?,
		_janitor: Janitor.Janitor,
	},
	MeshScalerRibbonTool
))

function MeshScalerRibbonTool.new(plugin: Plugin): ClassType
	local self = setmetatable({}, MeshScalerRibbonTool) :: ClassType
	self._plugin = plugin

    local janitor = Janitor.new()
	self._janitor = janitor

    janitor:Add(plugin.Deactivation:Connect(function()
        self:Deactivate()
    end))

	return self
end

function MeshScalerRibbonTool.Activate(self: ClassType)
	if self._meshScalerTool then
		return
	end

	self._meshScalerTool = MeshScalerTool.new(self._plugin)
	self._janitor:Add(
		task.defer(function()
			while task.wait() do
				if self._plugin:GetSelectedRibbonTool() ~= MeshScalerTool.RibbonTool then
					break
				end
			end

            self:Deactivate()
		end),
		true,
		TOOL_CHANGED_JANITOR_INDEX
	)
end

function MeshScalerRibbonTool.Deactivate(self: ClassType)
	if not self._meshScalerTool then
		return
	end

    UserInterface:SetToggleActive(false)

    self._janitor:Remove(TOOL_CHANGED_JANITOR_INDEX)
	self._meshScalerTool:Destroy()
	self._meshScalerTool = nil
end

function MeshScalerRibbonTool.Destroy(self: ClassType)
	local meshScalerTool = self._meshScalerTool
	if meshScalerTool then
		meshScalerTool:Destroy()
	end
	self._janitor:Destroy()
	setmetatable(self :: any, nil)
	table.clear(self :: any)
	table.freeze(self)
end

return MeshScalerRibbonTool
