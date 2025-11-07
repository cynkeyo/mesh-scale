function getAxisColorFromNormal(normal: Enum.NormalId): Color3
    local normalVector = Vector3.fromNormalId(normal)

    return Color3.new(
        math.abs(normalVector.X),
        math.abs(normalVector.Y),
        math.abs(normalVector.Z)
    )
end

return getAxisColorFromNormal
