local CoreGui = game:GetService("CoreGui")

local signal = require(script.Parent.Parent.Parent.packages.signal)

type axisHandle = {
    handleAdornment: Handles,
    handlePart: BasePart,
    normalVector3: Vector3
}

type signals = {
    MouseButton1Down: signal.Signal,
    MouseDrag: signal.Signal<number, Vector3>,
    MouseButton1Up: signal.Signal,
}

local function getHandleColorFromNormal(normal: Enum.NormalId): Color3
    local normalVector = Vector3.fromNormalId(normal)

    return Color3.new(
        math.abs(normalVector.X),
        math.abs(normalVector.Y),
        math.abs(normalVector.Z)
    )
end

local function createAxisHandleFromNormal(normal: Enum.NormalId, signals: signals): axisHandle
    local handlePart = Instance.new("Part")
    handlePart.Name = `Handle{normal.Name}`
    handlePart.Transparency = 1
    handlePart.Size = Vector3.zero
    handlePart.Archivable = false
    handlePart.Locked = true

    local handleAdornment = Instance.new("Handles")
    handleAdornment.Color3 = getHandleColorFromNormal(normal)
    handleAdornment.Faces = Faces.new(normal)
    handleAdornment.Adornee = handlePart
    handleAdornment.MouseButton1Down:Connect(function()
        signals.MouseButton1Down:Fire()
    end)
    handleAdornment.MouseDrag:Connect(function(distance, normal)
        signals.MouseDrag:Fire(distance, normal)
    end)
    handleAdornment.MouseButton1Up:Connect(function()
        signals.MouseButton1Up:Fire()
    end)
    handleAdornment.Parent = CoreGui

    return {
        handleAdornment = handleAdornment,
        handlePart = handlePart,
        normalVector3 = Vector3.fromNormalId(normal)
    }
end

local function updateAxisHandle(axisHandle: axisHandle, attachedPart: BasePart, mesh: DataModelMesh)
    local offsetCFrame = attachedPart.CFrame * CFrame.new(mesh.Offset)
    axisHandle.handlePart.CFrame = offsetCFrame * CFrame.new(((attachedPart.Size * mesh.Scale) * axisHandle.normalVector3 / 2) + axisHandle.normalVector3)
end

local function destroyAxisHandle(axisHandle: axisHandle)
    axisHandle.handleAdornment:Destroy()
    axisHandle.handlePart:Destroy()

    table.clear(axisHandle)
    table.freeze(axisHandle)
end

local ScalerHandles = {}
ScalerHandles.__index = ScalerHandles

export type ClassType = typeof(setmetatable(
	{} :: {
        MouseButton1Down: signal.Signal,
        MouseDrag: signal.Signal<number, Vector3>,
        MouseButton1Up: signal.Signal,
        _attachedPart: BasePart,
        _attachedMesh: DataModelMesh,
		_leftHandle: axisHandle,
		_rightHandle: axisHandle,
		_topHandle: axisHandle,
		_bottomHandle: axisHandle,
		_frontHandle: axisHandle,
		_backHandle: axisHandle,
        _partSizeChangedConnection: RBXScriptConnection,
        _meshScaleChangedConnection: RBXScriptConnection,
	},
	ScalerHandles
))

function ScalerHandles.new(attachedPart: BasePart, attachedMesh: DataModelMesh, onMouseDrag): ClassType
    local self = setmetatable({}, ScalerHandles) :: ClassType

    local signals: signals = {
        MouseButton1Down = signal.new(),
        MouseDrag = signal.new(),
        MouseButton1Up = signal.new()
    }

    self.MouseButton1Down = signals.MouseButton1Down
    self.MouseDrag = signals.MouseDrag
    self.MouseButton1Up = signals.MouseButton1Up
    self._attachedPart = attachedPart
    self._attachedMesh = attachedMesh
    self._bottomHandle = createAxisHandleFromNormal(Enum.NormalId.Bottom, signals)
    self._topHandle = createAxisHandleFromNormal(Enum.NormalId.Top, signals)
    self._frontHandle = createAxisHandleFromNormal(Enum.NormalId.Front, signals)
    self._backHandle = createAxisHandleFromNormal(Enum.NormalId.Back, signals)
    self._rightHandle = createAxisHandleFromNormal(Enum.NormalId.Right, signals)
    self._leftHandle = createAxisHandleFromNormal(Enum.NormalId.Left, signals)
    self._partSizeChangedConnection = attachedPart:GetPropertyChangedSignal("Size"):Connect(function()
        self:_updateHandles()
    end)
    self._meshScaleChangedConnection = attachedMesh:GetPropertyChangedSignal("Scale"):Connect(function()
        self:_updateHandles()
    end)

    self:_updateHandles()

    self._bottomHandle.handlePart.Parent = workspace.Terrain
    self._topHandle.handlePart.Parent = workspace.Terrain
    self._frontHandle.handlePart.Parent = workspace.Terrain
    self._backHandle.handlePart.Parent = workspace.Terrain
    self._rightHandle.handlePart.Parent = workspace.Terrain
    self._leftHandle.handlePart.Parent = workspace.Terrain

    return self
end

function ScalerHandles._updateHandles(self: ClassType)
    updateAxisHandle(self._bottomHandle, self._attachedPart, self._attachedMesh)
    updateAxisHandle(self._topHandle, self._attachedPart, self._attachedMesh)
    updateAxisHandle(self._frontHandle, self._attachedPart, self._attachedMesh)
    updateAxisHandle(self._backHandle, self._attachedPart, self._attachedMesh)
    updateAxisHandle(self._rightHandle, self._attachedPart, self._attachedMesh)
    updateAxisHandle(self._leftHandle, self._attachedPart, self._attachedMesh)
end

function ScalerHandles.Destroy(self: ClassType)
    self.MouseButton1Down:Destroy()
    self.MouseDrag:Destroy()
    self.MouseButton1Up:Destroy()
    destroyAxisHandle(self._bottomHandle)
    destroyAxisHandle(self._topHandle)
    destroyAxisHandle(self._frontHandle)
    destroyAxisHandle(self._backHandle)
    destroyAxisHandle(self._rightHandle)
    destroyAxisHandle(self._leftHandle)
    self._partSizeChangedConnection:Disconnect()
    self._meshScaleChangedConnection:Disconnect()

    table.clear(self :: any)
    setmetatable(self :: any, nil)
    table.freeze(self)
end

return ScalerHandles
