return function()
    if registers.system.editor.fileDialogSave then
        local Result = slab.FileDialog({Directory = love.filesystem.getSaveDirectory(), Type = 'savefile', Filters = {"*.wlf", "QWaver Level files"}})

        if Result.Button == "OK" then
            local path = Result.Files[1]
            print(debug.formattable(Result))
            local lvlFile = nativefs.newFile(path, "w")
            lvlFile:write(love.data.compress("string", "zlib", json.encode(editorLevelData)))
            lvlFile:close()
            Editor.data.levelPath = path
            registers.system.editor.fileDialogSave = false
        elseif Result.Button == "Cancel" then
            registers.system.editor.fileDialogSave = false
        end
    end
end