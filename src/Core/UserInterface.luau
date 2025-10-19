local constants = require(script.Parent.Parent.constants)
local toolbar: PluginToolbar
local toggleScaleButton: PluginToolbarButton
local meshifyButton: PluginToolbarButton

local UserInterface = {}

function UserInterface:init(plugin, onScaleToggled, onMeshify)
	toolbar = plugin:CreateToolbar(`{constants.PLUGIN_NAME} {constants.PLUGIN_VERSION}`)

	do
        local toggleScale = false

		toggleScaleButton = toolbar:CreateButton("Toggle Mesh Scaler", "Scale the selected mesh with handles", "rbxassetid://127843254741492")
		toggleScaleButton.Click:Connect(function()
            toggleScale = not toggleScale

            toggleScaleButton:SetActive(toggleScale)
            onScaleToggled(toggleScale)
        end)
	end

	meshifyButton = toolbar:CreateButton("Meshify part", "Creates a mesh with the part's shape.", "rbxassetid://127843254741492")
	meshifyButton.Click:Connect(onMeshify)
end

function UserInterface:cleanup()
	toolbar:Destroy()
	toggleScaleButton:Destroy()
	meshifyButton:Destroy()
end

return UserInterface
