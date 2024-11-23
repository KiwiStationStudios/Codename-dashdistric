return function()
    if registers.system.editor.fileDialogOpen then
        local Result = slab.FileDialog({AllowMultiSelect = false, Type = 'openfile', Filters = {"*.wlf", "QWaver Level files"}})

        if Result.Button == "OK" then
            Editor.data.levelPath = Result.Files[1]
            editorLevelData = json.decode(love.data.decompress("string", nativefs.read(Editor.data.levelPath)))
            registers.system.editor.fileDialogOpen = false
        elseif Result.Button == "Cancel" then
            registers.system.editor.fileDialogOpen = false
        end
    end
end