function selectRibbonTool(plugin: Plugin, ribbonTool: Enum.RibbonTool)
    if plugin:GetSelectedRibbonTool() == ribbonTool then
        return
    end

	plugin:SelectRibbonTool(ribbonTool, UDim2.new())
end

return selectRibbonTool
