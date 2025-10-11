local CoreGui = game:GetService("CoreGui")
local StudioService = game:GetService("StudioService")

local function getUsedMeshFromParent(parent: BasePart): DataModelMesh
	local usedMesh = nil
	for _, child in pairs(parent:GetChildren()) do
		if child:IsA("DataModelMesh") then
			usedMesh = child
		end
	end

	return usedMesh
end

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

local MeshScaler = {}
MeshScaler.__index = MeshScaler

export type ClassType = typeof(setmetatable(
	{} :: {
		_scalerHandles: Handles,
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
	local scalerHandles = Instance.new("Handles")

	scalerHandles.MouseButton1Down:Connect(function()
		local initialMeshScale = usedMesh.Scale
		local initialMeshOffset = usedMesh.Offset
		local initialTransparency = attachedPart.Transparency

		attachedPart.Transparency = 0.3

		local onDrag = scalerHandles.MouseDrag:Connect(function(normal, distance)
			local gridSize = StudioService.GridSize
			distance = math.floor(distance / gridSize) * gridSize

			-- local unitVector = Vector3.one
			local normalVector = Vector3.fromNormalId(normal)
			local offsetVector = initialMeshOffset + (normalVector * distance / 2)
			local scaleVector = initialMeshScale + (absVector(normalVector) / attachedPart.Size * distance)

			if scaleVector.X < 0 or scaleVector.Y < 0 or scaleVector.Z < 0 then
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
			onDrag:Disconnect()
		end)
	end)

	scalerHandles.Adornee = attachedPart
	scalerHandles.Parent = CoreGui

	self._scalerHandles = scalerHandles

	return self
end

function MeshScaler.Destroy(self: ClassType)
	self._scalerHandles:Destroy()
	table.clear(self :: any)
	setmetatable(self :: any, nil)
	table.freeze(self)
end

return MeshScaler
