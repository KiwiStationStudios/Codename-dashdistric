local types = {
    "tile", "hazard", "trigger"
}

return function()
    slab.BeginWindow("toolboxWindow", { Title = "", X = 0, Y = love.graphics.getHeight() - 128, W = love.graphics.getWidth(), H = 128, AutoSizeWindow = false, AllowResize = false, AllowMove = false })
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
    
                    if o % 14 ~= 0 then
                        slab.SameLine()
                    end
    
                    if slab.IsControlClicked() then
                        Editor.data.objID = o
                    end
                end
            end
        end
    slab.EndWindow()
end