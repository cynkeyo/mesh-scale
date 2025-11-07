function absVector(vector: Vector3): Vector3
    return Vector3.new(
        math.abs(vector.X),
        math.abs(vector.Y),
        math.abs(vector.Z)
    )
end

return absVector
