local constants = require(script.Parent.Parent.constants)
local toolbar: PluginToolbar
local toggleScaleButton: PluginToolbarButton
local meshifyButton: PluginToolbarButton
local matchPartPivotToMesh: PluginToolbarButton

local UserInterface = {}

function UserInterface:init(plugin, onScaleToggled, onMeshify, onMatchPartPivotToMesh)
	toolbar = plugin:CreateToolbar(`{constants.PLUGIN_NAME} {constants.PLUGIN_VERSION}`)

	do
        local toggleScale = false

		toggleScaleButton = toolbar:CreateButton("Toggle", "Scale the selected mesh with handles", "rbxassetid://127843254741492")
		toggleScaleButton.Click:Connect(function()
            toggleScale = not toggleScale

            toggleScaleButton:SetActive(toggleScale)
            onScaleToggled(toggleScale)
        end)
	end

	meshifyButton = toolbar:CreateButton("Meshify", "Creates a mesh with the part's shape.", "rbxassetid://127843254741492")
	meshifyButton.Click:Connect(onMeshify)

    matchPartPivotToMesh = toolbar:CreateButton("Match pivot", "Matches the part's pivot to the mesh's center", "rbxassetid://127843254741492")
    matchPartPivotToMesh.Click:Connect(onMatchPartPivotToMesh)
end

function UserInterface:cleanup()
	toolbar:Destroy()
	toggleScaleButton:Destroy()
	meshifyButton:Destroy()
    matchPartPivotToMesh:Destroy()
end

return UserInterface
