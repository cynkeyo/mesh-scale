local getUsedMeshFromParent = require(script.Parent.getUsedMeshFromParent)

function matchPartPivotToMesh(part: BasePart)
    local mesh = getUsedMeshFromParent(part)
    if not mesh then
        return
    end

    part.PivotOffset = CFrame.new(mesh.Offset)
end

return matchPartPivotToMesh
