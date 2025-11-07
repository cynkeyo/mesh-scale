local ChangeHistoryService = game:GetService("ChangeHistoryService")
local CoreGui = game:GetService("CoreGui")
local StudioService = game:GetService("StudioService")
local UserInputService = game:GetService("UserInputService")

local Janitor = require(script.Parent.Parent.Parent.Parent.packages.Janitor)
local signal = require(script.Parent.Parent.Parent.Parent.packages.signal)
local absVector = require(script.Parent.Parent.Parent.Parent.utils.absVector)
local getNonZeroAxis = require(script.Parent.Parent.Parent.Parent.utils.getNonZeroAxis)
local getUsedMeshFromParent = require(script.Parent.Parent.Parent.Parent.utils.getUsedMeshFromParent)
local isControlKey = require(script.Parent.Parent.Parent.Parent.utils.isControlKey)
local ScalerHandles = require(script.Parent.Parent.Parent.ScalerHandles)

local MESH_SCALE_RECORDING_NAME = "Scale Mesh"

local function canAttachToInstance(instance: Instance)
	if not instance:IsA("BasePart") then
		return false
	end

	return getUsedMeshFromParent(instance) ~= nil
end

local MeshScaler = {}
MeshScaler.__index = MeshScaler

export type ClassType = typeof(setmetatable(
	{} :: {
		Hovered: boolean,
		_mouse: PluginMouse,
		_recording: string?,
		_mouseDragConnection: signal.Connection?,
		_attachedPart: {
			ref: BasePart,
			preversedTransparency: number,
		},
		_attachedMesh: DataModelMesh,
		_scalerHandles: ScalerHandles.ClassType,
		_holdingControl: boolean,
		_janitor: Janitor.Janitor,
	},
	MeshScaler
))

function MeshScaler.canAttachToInstance(instance: Instance)
	return canAttachToInstance(instance)
end

function MeshScaler.new(attachedPart: BasePart, mouse: PluginMouse): ClassType
	assert(canAttachToInstance(attachedPart), "Can't attach to this part as it doesn't have a mesh.")

	local self = setmetatable({}, MeshScaler) :: ClassType
	self.Hovered = false
	self._mouse = mouse

	local janitor = Janitor.new()
	self._janitor = janitor

	local usedMesh = getUsedMeshFromParent(attachedPart)
	self._attachedPart = {
		ref = attachedPart,
		preversedTransparency = attachedPart.Transparency,
	}
	self._attachedMesh = usedMesh

	local scalerHandles = ScalerHandles.new(attachedPart, usedMesh)
	self._scalerHandles = scalerHandles

	self._holdingControl = false
	janitor:Add(UserInputService.InputBegan:Connect(function(input)
		if isControlKey(input) then
			self._holdingControl = true
		end
	end))
	janitor:Add(UserInputService.InputEnded:Connect(function(input)
		if isControlKey(input) then
			self._holdingControl = false
		end
	end))
	janitor:Add(scalerHandles.MouseEnter:Connect(function()
		if not self._mouseDragConnection then
			self._mouse.Icon = "rbxasset://SystemCursors/OpenHand"
		end
		self.Hovered = true
	end))
	janitor:Add(scalerHandles.MouseLeave:Connect(function()
		if not self._mouseDragConnection then
			self._mouse.Icon = ""
		end
		self.Hovered = false
	end))

	return self
end

function MeshScaler.Start(self: ClassType)
	local recording = ChangeHistoryService:TryBeginRecording(MESH_SCALE_RECORDING_NAME)
	if not recording then
		return
	end

	self._recording = recording

	if self._mouseDragConnection then
		return
	end

	local mesh = self._attachedMesh
	local part = self._attachedPart.ref
	local initialMeshScale = mesh.Scale
	local initialMeshOffset = mesh.Offset

	self._mouse.Icon = "rbxasset://SystemCursors/ClosedHand"
	self._attachedPart.ref.Transparency = 0.3
	self._mouseDragConnection = self._scalerHandles.MouseDrag:Connect(function(normal, distance)
		local gridSize = StudioService.GridSize
		distance = math.floor(distance / gridSize) * gridSize

		local normalVector = Vector3.fromNormalId(normal)
		local offsetVector = if self._holdingControl
			then initialMeshOffset
			else initialMeshOffset + (normalVector * distance / 2)
		local scaleVector = if self._holdingControl
			then initialMeshScale + (absVector(normalVector) / part.Size * distance * 2)
			else initialMeshScale + (absVector(normalVector) / part.Size * distance)

		-- prevent offsetting when scale vector gets is below zero since it's clamped to 0
		if (scaleVector.X < 0 or scaleVector.Y < 0 or scaleVector.Z < 0) and not self._holdingControl then
			local partSizeAxis = getNonZeroAxis(part.Size * absVector(normalVector))
			local absAxis = getNonZeroAxis(absVector(normalVector))

			local minDistance = -((initialMeshScale * partSizeAxis) / absAxis)
			offsetVector = initialMeshOffset + (normalVector * minDistance / 2)
		end

		scaleVector = Vector3.new(
			math.clamp(scaleVector.X, 0, math.huge),
			math.clamp(scaleVector.Y, 0, math.huge),
			math.clamp(scaleVector.Z, 0, math.huge)
		)

		mesh.Offset = offsetVector
		mesh.Scale = scaleVector
	end)
end

function MeshScaler.Stop(self: ClassType)
	self._mouse.Icon = ""
	local attachedPart = self._attachedPart
	attachedPart.ref.Transparency = attachedPart.preversedTransparency

	if self._recording then
		ChangeHistoryService:FinishRecording(self._recording, Enum.FinishRecordingOperation.Commit)
		self._recording = nil
	end

	if self._mouseDragConnection then
		self._mouseDragConnection:Disconnect()
		self._mouseDragConnection = nil
	end
end

function MeshScaler.Destroy(self: ClassType)
	self:Stop()
	self._scalerHandles:Destroy()
	self._janitor:Destroy()
	table.clear(self :: any)
	setmetatable(self :: any, nil)
	table.freeze(self)
end

return MeshScaler
