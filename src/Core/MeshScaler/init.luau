local ChangeHistoryService = game:GetService("ChangeHistoryService")
local CoreGui = game:GetService("CoreGui")
local StudioService = game:GetService("StudioService")
local UserInputService = game:GetService("UserInputService")

local getUsedMeshFromParent = require(script.Parent.getUsedMeshFromParent)
local ScalerHandles = require(script.ScalerHandles)

local MESH_SCALE_RECORDING_NAME = "Scale Mesh"

local function canAttachToInstance(instance: Instance)
	if not instance:IsA("BasePart") then
		return false
	end

	return getUsedMeshFromParent(instance) ~= nil
end

local function absVector(vector: Vector3)
	return Vector3.new(math.abs(vector.X), math.abs(vector.Y), math.abs(vector.Z))
end

local function getNonZeroAxis(vector: Vector3)
	if vector.X ~= 0 then
		return vector.X
	elseif vector.Y ~= 0 then
		return vector.Y
	else
		return vector.Z
	end
end

local function isControlKey(input: InputObject): boolean
	return input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl
end

local MeshScaler = {}
MeshScaler.__index = MeshScaler

export type ClassType = typeof(setmetatable(
	{} :: {
		_scalerHandles: ScalerHandles.ClassType,
		_holdingControl: boolean,
		_inputBeganConnection: RBXScriptConnection,
		_inputEndedConnection: RBXScriptConnection,
	},
	MeshScaler
))

function MeshScaler.canAttachToInstance(instance: Instance)
	return canAttachToInstance(instance)
end

function MeshScaler.new(attachedPart: BasePart): ClassType
	assert(canAttachToInstance(attachedPart), "Can't attach to this part as it doesn't have a mesh.")

	local self = setmetatable({}, MeshScaler) :: ClassType

	local usedMesh = getUsedMeshFromParent(attachedPart)
	local scalerHandles = ScalerHandles.new(attachedPart, usedMesh)

	scalerHandles.MouseButton1Down:Connect(function()
        local recording = ChangeHistoryService:TryBeginRecording(MESH_SCALE_RECORDING_NAME)
        if not recording then
            return
        end

		local initialMeshScale = usedMesh.Scale
		local initialMeshOffset = usedMesh.Offset
		local initialTransparency = attachedPart.Transparency

		attachedPart.Transparency = 0.3

		local onDrag = scalerHandles.MouseDrag:Connect(function(normal, distance)
			local gridSize = StudioService.GridSize
			distance = math.floor(distance / gridSize) * gridSize

			local normalVector = Vector3.fromNormalId(normal)
			local offsetVector = if self._holdingControl
                then initialMeshOffset
                else initialMeshOffset + (normalVector * distance / 2)
			local scaleVector = if self._holdingControl
				then initialMeshScale + (absVector(normalVector) / attachedPart.Size * distance * 2)
				else initialMeshScale + (absVector(normalVector) / attachedPart.Size * distance)

			-- prevent offsetting when scale vector gets is below zero since it's clamped to 0
			if (scaleVector.X < 0 or scaleVector.Y < 0 or scaleVector.Z < 0) and not self._holdingControl then
				local partSizeAxis = getNonZeroAxis(attachedPart.Size * absVector(normalVector))
				local absAxis = getNonZeroAxis(absVector(normalVector))

				local minDistance = -((initialMeshScale * partSizeAxis) / absAxis)
				offsetVector = initialMeshOffset + (normalVector * minDistance / 2)
			end

			scaleVector = Vector3.new(
				math.clamp(scaleVector.X, 0, math.huge),
				math.clamp(scaleVector.Y, 0, math.huge),
				math.clamp(scaleVector.Z, 0, math.huge)
			)

			usedMesh.Offset = offsetVector
			usedMesh.Scale = scaleVector
		end)

		scalerHandles.MouseButton1Up:Once(function()
			attachedPart.Transparency = initialTransparency

            ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)

			onDrag:Disconnect()
		end)
	end)

	scalerHandles.Adornee = attachedPart
	scalerHandles.Parent = CoreGui

	self._scalerHandles = scalerHandles
	self._holdingControl = false
	self._inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
		if isControlKey(input) then
			self._holdingControl = true
		end
	end)
	self._inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
		if isControlKey(input) then
			self._holdingControl = false
		end
	end)

	return self
end

function MeshScaler.Destroy(self: ClassType)
	self._scalerHandles:Destroy()
	self._inputBeganConnection:Disconnect()
	self._inputEndedConnection:Disconnect()
	table.clear(self :: any)
	setmetatable(self :: any, nil)
	table.freeze(self)
end

return MeshScaler
