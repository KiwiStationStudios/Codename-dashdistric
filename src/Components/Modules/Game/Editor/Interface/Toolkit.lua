local types = {
    "tile", "hazard", "trigger"
}

return function()
    slab.BeginWindow("toolboxWindow", { Title = "", X = 0, Y = love.graphics.getHeight() - 128, W = love.graphics.getWidth(), H = 128, AutoSizeWindow = false, AllowResize = false, AllowMove = false })
        slab.BeginLayout("toolboxLayoutItems", { AnchorX = true, Columns = 2 })
            slab.SetLayoutColumn(1)
            if slab.Button("Build mode") then
                Editor.data.currentEditorMode = "append"
            end
            if slab.Button("Edit mode") then
                Editor.data.currentEditorMode = "edit"
            end
            slab.SetLayoutColumn(2)
            if Editor.data.objType == "none" then 
                for t = 1, #types, 1 do
                    local qx, qy, qw, qh = Assets[types[t]].quads[1]:getViewport()
                    slab.Image("tileCatDisp" .. t, {
                        Image = Assets[types[t]].img,
                        SubX = qx,
                        SubY = qy,
                        SubW = qw,
                        SubH = qh,
                        W = 32,
                        H = 32,
                    })

                    if t % 32 ~= 0 then
                        slab.SameLine()
                    end

                    if slab.IsControlClicked() then
                        Editor.data.objType = types[t]
                    end
                end
            else
                if slab.Button("<<<", { W = 32, H = 32 }) then
                    Editor.data.objID = 1
                    Editor.data.objType = "none"
                end
                if Assets[Editor.data.objType] then
                    for o = 1, #Assets[Editor.data.objType].quads, 1 do
                        local qx, qy, qw, qh = Assets[Editor.data.objType].quads[o]:getViewport()
                        slab.Image("tileCatDisp" .. o, {
                            Image = Assets[Editor.data.objType].img,
                            SubX = qx,
                            SubY = qy,
                            SubW = qw,
                            SubH = qh,
                            W = 32,
                            H = 32,
                        })
        
                        if o % 32 ~= 0 then
                            slab.SameLine()
                        end
        
                        if slab.IsControlClicked() then
                            Editor.data.objID = o
                            Editor.data.angle = 0
                        end
                    end
                end
            end
        slab.EndLayout()
    slab.EndWindow()
end