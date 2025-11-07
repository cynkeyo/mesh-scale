local partTypeToMeshTypeMap = {
    Ball = Enum.MeshType.Sphere,
    Block = Enum.MeshType.Brick,
    Cylinder = Enum.MeshType.Cylinder,
    Wedge = Enum.MeshType.Wedge,
    CornerWedge = Enum.MeshType.CornerWedge
}
function getMeshTypeFromPart(part: BasePart): Enum.MeshType?
    if part:IsA("WedgePart") then
        return Enum.MeshType.Wedge
    elseif part:IsA("CornerWedgePart") then
        return Enum.MeshType.CornerWedge
    elseif part:IsA("Part") then
        return partTypeToMeshTypeMap[part.Shape.Name]
    else
        return nil
    end
end

function meshify(part: BasePart)
    local meshType = getMeshTypeFromPart(part)

    if not meshType then
        warn("Can't meshify this part due to it's shape not being a SpecialMesh type.")
        return
    end

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = meshType
    mesh.Parent = part
end

return meshify
