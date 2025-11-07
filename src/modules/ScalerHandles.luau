local AxisHandle = require(script.Parent.AxisHandle)
local signal = require(script.Parent.Parent.packages.signal)
local createChainerSignal = require(script.Parent.Parent.utils.createChainerSignal)

local ScalerHandles = {}
ScalerHandles.__index = ScalerHandles

export type ClassType = typeof(setmetatable(
	{} :: {
		MouseButton1Down: signal.Signal<>,
		MouseDrag: signal.Signal<Enum.NormalId, number>,
		MouseButton1Up: signal.Signal<>,
        MouseEnter: signal.Signal<>,
        MouseLeave: signal.Signal<>,
		_attachedPart: BasePart,
		_attachedMesh: DataModelMesh,
		_axisHandles: { [Enum.NormalId]: AxisHandle.ClassType },
		_partSizeChangedConnection: RBXScriptConnection,
		_meshScaleChangedConnection: RBXScriptConnection,
	},
	ScalerHandles
))

function ScalerHandles.new(attachedPart: BasePart, attachedMesh: DataModelMesh, onMouseDrag): ClassType
	local self = setmetatable({}, ScalerHandles) :: ClassType

    local mouseButton1DownSignal, onMouseButton1Down = createChainerSignal(signal.new())
    local mouseButton1UpSignal, onMouseButton1Up = createChainerSignal(signal.new())
    local mouseDragSignal, onMouseDrag = createChainerSignal(signal.new() :: signal.Signal<Enum.NormalId, number>)
    local mouseEnterSignal, onMouseEnter = createChainerSignal(signal.new())
    local mouseLeaveSignal, onMouseLeave = createChainerSignal(signal.new())
    self.MouseButton1Down = mouseButton1DownSignal
    self.MouseButton1Up = mouseButton1UpSignal
    self.MouseDrag = mouseDragSignal
    self.MouseEnter = mouseEnterSignal
    self.MouseLeave = mouseLeaveSignal

    self._axisHandles = {}
	for _, normal in pairs(Enum.NormalId:GetEnumItems()) do
        local axisHandle = AxisHandle.new(normal)
        axisHandle.MouseButton1Down:Connect(onMouseButton1Down)
        axisHandle.MouseButton1Up:Connect(onMouseButton1Up)
        axisHandle.MouseEnter:Connect(onMouseEnter)
        axisHandle.MouseLeave:Connect(onMouseLeave)
        axisHandle.MouseDrag:Connect(onMouseDrag)
		self._axisHandles[normal] = axisHandle
	end

	self._partSizeChangedConnection = attachedPart:GetPropertyChangedSignal("Size"):Connect(function()
		self:_updateHandles()
	end)
	self._meshScaleChangedConnection = attachedMesh:GetPropertyChangedSignal("Scale"):Connect(function()
		self:_updateHandles()
	end)

	self._attachedPart = attachedPart
	self._attachedMesh = attachedMesh

	self:_updateHandles()

	return self
end

function ScalerHandles._updateHandles(self: ClassType)
	for _, axisHandle in pairs(self._axisHandles) do
		axisHandle:Update(self._attachedPart, self._attachedMesh)
	end
end

function ScalerHandles.Destroy(self: ClassType)
	self.MouseButton1Down:Destroy()
	self.MouseButton1Up:Destroy()
	self.MouseDrag:Destroy()
    self.MouseEnter:Destroy()
    self.MouseEnter:Destroy()
	for _, axisHandle in pairs(self._axisHandles) do
        axisHandle:Destroy()
	end
	self._partSizeChangedConnection:Disconnect()
	self._meshScaleChangedConnection:Disconnect()

	table.clear(self :: any)
	setmetatable(self :: any, nil)
	table.freeze(self)
end

return ScalerHandles
