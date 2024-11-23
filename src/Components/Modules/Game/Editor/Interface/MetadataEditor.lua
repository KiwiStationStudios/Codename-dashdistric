return function()
    if registers.system.editor.metaDataWindow then
        slab.BeginWindow("metadataEditorWindow", {Title = "Metadata editor", AllowResize = false})
            slab.Text("Level title")
            if slab.Input("metadataEditorLevelTitleInput", {Text = editorLevelData.meta.title}) then
                editorLevelData.meta.title = slab.GetInputText()
            end
            slab.Separator()
            slab.Text("Color channels")
            for k, color in pairs(editorLevelData.level.colorChannels) do
                slab.Rectangle({W = 64, H = 16, Color = color, Rounding = 8})
                slab.SameLine()
                slab.Text(k)
                slab.SameLine()
                if slab.Button("edit") then
                    registers.system.editor.editColorChannelPicker = true
                    registers.system.editor.currentKey = k
                end
                if not lume.find({"bg", "obj", "finalObj"}, k) then
                    slab.SameLine()
                    if slab.Button("remove") then
                        editorLevelData.level.colorChannels[k] = nil
                        collectgarbage("collect")
                    end
                end
            end
            if slab.Button("Add new channel") then
                registers.system.editor.addNewColorChannel = true
            end
            if registers.system.editor.addNewColorChannel then
                slab.Text("Channel tag")
                slab.SameLine()
                if slab.Input("metadataEditorColorChannelTagInput", {Text = registers.system.editor.newColorChannelTag}) then
                    registers.system.editor.newColorChannelTag = slab.GetInputText()
                end
                slab.Rectangle({W = 64, H = 16, Color = registers.system.editor.colorChannelCreateCurrentColor, Rounding = 8})
                slab.SameLine()
                if slab.Button("Open color picker") then
                    registers.system.editor.colorChannelColorPicker = true
                end
                if slab.Button("Add channel") then
                    if registers.system.editor.newColorChannelTag ~= "" and not editorLevelData.level.colorChannels[registers.system.editor.newColorChannelTag] then
                        editorLevelData.level.colorChannels[registers.system.editor.newColorChannelTag] = registers.system.editor.colorChannelCreateCurrentColor
                    end
                    registers.system.editor.newColorChannelTag = ""
                    registers.system.editor.colorChannelColorPicker = false
                    registers.system.editor.addNewColorChannel = false
                end

                if registers.system.editor.colorChannelColorPicker then
                    local Result = slab.ColorPicker({Color = {1, 1, 1, 1}})
                    if Result.Button == 1 then
                        registers.system.editor.colorChannelCreateCurrentColor = Result.Color
                        registers.system.editor.colorChannelColorPicker = false
                    elseif Result.Button == -1 then
                        registers.system.editor.colorChannelColorPicker = false
                    end
                end
            end
            if registers.system.editor.editColorChannelPicker then
                local Result = slab.ColorPicker({Color = {1, 1, 1, 1}})
                if Result.Button == 1 then
                    editorLevelData.level.colorChannels[registers.system.editor.currentKey] = Result.Color
                    registers.system.editor.editColorChannelPicker = false
                elseif Result.Button == -1 then
                    registers.system.editor.editColorChannelPicker = false
                end
            end
            if slab.Button("OK") then
                registers.system.editor.newColorChannelTag = ""
                registers.system.editor.colorChannelColorPicker = false
                registers.system.editor.addNewColorChannel = false
                registers.system.editor.metaDataWindow = false
            end
        slab.EndWindow()
    end
end