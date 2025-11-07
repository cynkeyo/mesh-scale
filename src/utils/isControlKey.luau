function isControlKey(input: InputObject): boolean
	return input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl
end

return isControlKey
