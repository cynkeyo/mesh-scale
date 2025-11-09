local constants = require(script.Parent.Parent.constants)
local toolbar: PluginToolbar
local toggleScaleButton: PluginToolbarButton
local toggleScale = false
local meshifyButton: PluginToolbarButton
local matchPartPivotToMesh: PluginToolbarButton

local UserInterface = {}

function UserInterface:init(plugin: Plugin, onScaleToggled, onMeshify, onMatchPartPivotToMesh)
	toolbar = plugin:CreateToolbar(constants.PLUGIN_NAME)

    toggleScaleButton = toolbar:CreateButton("Scaler", "Toggles the Mesh Scaler tool.", "rbxassetid://127843254741492")
    toggleScaleButton.Click:Connect(function()
        toggleScale = not toggleScale

        toggleScaleButton:SetActive(toggleScale)
        onScaleToggled(toggleScale)
    end)

	meshifyButton = toolbar:CreateButton("Meshify", "Creates a mesh with the part's shape.", "rbxassetid://127843254741492")
	meshifyButton.Click:Connect(onMeshify)

    matchPartPivotToMesh = toolbar:CreateButton("Match pivot", "Matches the part's pivot to the mesh's center", "rbxassetid://127843254741492")
    matchPartPivotToMesh.Click:Connect(onMatchPartPivotToMesh)
end

function UserInterface:SetToggleActive(active: boolean)
    toggleScaleButton:SetActive(active)
    toggleScale = active
end

function UserInterface:cleanup()
	toolbar:Destroy()
	toggleScaleButton:Destroy()
	meshifyButton:Destroy()
    matchPartPivotToMesh:Destroy()
end

return UserInterface
