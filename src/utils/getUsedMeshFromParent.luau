function getUsedMeshFromParent(parent: BasePart): DataModelMesh
	local usedMesh = nil
	for _, child in pairs(parent:GetChildren()) do
		if child:IsA("DataModelMesh") then
			usedMesh = child
		end
	end

	return usedMesh
end

return getUsedMeshFromParent
