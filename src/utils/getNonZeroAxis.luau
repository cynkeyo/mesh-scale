function getNonZeroAxis(vector: Vector3)
	if vector.X ~= 0 then
		return vector.X
	elseif vector.Y ~= 0 then
		return vector.Y
	else
		return vector.Z
	end
end

return getNonZeroAxis
