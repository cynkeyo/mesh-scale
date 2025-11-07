local CoreGui = game:GetService("CoreGui")
local getAxisColorFromNormal = require(script.Parent.Parent.utils.getAxisColorFromNormal)
local AxisHandle = {}
AxisHandle.__index = AxisHandle

export type ClassType = typeof(setmetatable(
	{} :: {
		MouseEnter: RBXScriptSignal,
		MouseLeave: RBXScriptSignal,
		MouseButton1Down: RBXScriptSignal,
		MouseDrag: RBXScriptSignal<Enum.NormalId, number>,
		MouseButton1Up: RBXScriptSignal<>,
		_normal: Enum.NormalId,
		_handles: Handles,
		_handlesPart: BasePart,
	},
	AxisHandle
))

local function createHandlePart(normal: Enum.NormalId): BasePart
	local handlePart = Instance.new("Part")
	handlePart.Name = `Handle{normal.Name}`
	handlePart.Transparency = 1
	handlePart.Size = Vector3.zero
	handlePart.Archivable = false
	handlePart.Locked = true
    handlePart.Parent = workspace.Terrain

	return handlePart
end

local function createHandleAdornment(normal: Enum.NormalId, handlePart: BasePart): Handles
	local handleAdornment = Instance.new("Handles")
	handleAdornment.Color3 = getAxisColorFromNormal(normal)
	handleAdornment.Faces = Faces.new(normal)
	handleAdornment.Adornee = handlePart
	handleAdornment.Parent = CoreGui

	return handleAdornment
end

function AxisHandle.new(normal: Enum.NormalId): ClassType
	local self = setmetatable({}, AxisHandle) :: ClassType

	self._normal = normal

	local handlesPart = createHandlePart(normal)
	local handles = createHandleAdornment(normal, handlesPart)
	self.MouseEnter = handles.MouseEnter
	self.MouseLeave = handles.MouseLeave
	self.MouseDrag = handles.MouseDrag
	self.MouseButton1Down = handles.MouseButton1Down
	self.MouseButton1Up = handles.MouseButton1Up
	self._handles = handles
	self._handlesPart = handlesPart

	return self
end

function AxisHandle.Update(self: ClassType, targetPart: BasePart, targetMesh: DataModelMesh)
	local offsetCFrame = targetPart.CFrame * CFrame.new(targetMesh.Offset)
	local normalVector3 = Vector3.fromNormalId(self._normal)
	self._handlesPart.CFrame = offsetCFrame
		* CFrame.new(((targetPart.Size * targetMesh.Scale) * normalVector3 / 2) + normalVector3)
end

function AxisHandle.Destroy(self: ClassType)
	self._handles:Destroy()
	self._handlesPart:Destroy()
	setmetatable(self :: any, nil)
	table.clear(self :: any)
	table.freeze(self)
end

return AxisHandle
