EditorState = {}

local function isHover(x, y)
    for _, o in pairs(editorLevelData.objects) do
        if o.x == x then
            if o.y == y then
                return true
            end
        end
    end
    return false
end

local function removeAt(x, y)
    for _, o in pairs(editorLevelData.objects) do
        if o.x == x then
            if o.y == y then
                table.remove(editorLevelData.objects, _)
            end
        end
    end
end

local function isVisible(obj, camera)
    local sw, sh = love.graphics.getDimensions()
    local ox, oy 
end

---------------------------------------------------------------------------------------------

function EditorState:init()
    Editor = {
        components = {},
        objects = {},
        interface = {},
        data = {},
        flags = {
            swipeMode = false,
            showHitbox = false
        },
    }

    Editor.components.grid = require 'src.Components.Modules.Game.Editor.EditorGrid'
    Editor.components.createLevel = require 'src.Components.Modules.Game.Editor.Functions.CreateLevel'

    Editor.objects["tile"] = require 'src.Components.Modules.Game.Objects.Tiles'
    Editor.objects["hazard"] = require 'src.Components.Modules.Game.Objects.Hazards'

    -- interface components --
    Editor.interface.toolbox = require 'src.Components.Modules.Game.Editor.Interface.Toolkit'
    Editor.interface.menubar = require 'src.Components.Modules.Game.Editor.Interface.MenuBar'
    Editor.interface.metadataEditor = require 'src.Components.Modules.Game.Editor.Interface.MetadataEditor'
    Editor.interface.openFileDialog = require 'src.Components.Modules.Game.Editor.Interface.OpenLevelDialog'
    Editor.interface.saveFileDialog = require 'src.Components.Modules.Game.Editor.Interface.SaveLevelDialog'

    lineGround = love.graphics.newGradient("horizontal", 
        {0, 0, 0, 0}, 
        {255, 255, 255, 255}, 
        {255, 255, 255, 255}, 
        {255, 255, 255, 255},
        {0, 0, 0, 0}
    )
    
    Assets = {
        tile = {},
        hazard = {},
        trigger = {},
        bgs = {},
    }
    Assets.tile.img, Assets.tile.quads = love.graphics.getQuads("assets/images/game/blocks")
    Assets.hazard.img, Assets.hazard.quads = love.graphics.getQuads("assets/images/game/spike")
    Assets.trigger.img, Assets.trigger.quads = love.graphics.getQuads("assets/images/game/triggers")
    Assets.backbutton = love.graphics.newImage("assets/images/game/backbtn.png")

    local bgs = love.filesystem.getDirectoryItems("assets/images/game/backgrounds")
    for b = 1, #bgs, 1 do
        table.insert(Assets.bgs, love.graphics.newImage("assets/images/game/backgrounds/" .. bgs[b]))
    end

    slab.Initialize({"NoDocks"})
end

function EditorState:enter()
    Editor.camera = camera(nil, 0)
    Editor.camera.speed = 5
    Editor.camera.scrollZoom = 1 
    Editor.camera.targetZoom = 1
    editorLevelData = Editor.components.createLevel()
    Editor.camera.visibleArea = {
        x = 0,
        y = 0,
        w = love.graphics.getWidth(),
        h = love.graphics.getHeight(),
    }

    Editor.data.objects = {}
    Editor.data.levelPath = ""
    Editor.data.canEdit = false
    Editor.data.objType = "none"
    Editor.data.currentEditorMode = "append"
    Editor.data.objID = 1
    Editor.data.angle = 0
    Editor.data.selectionArea = {
        mode = "build",
        visible = false,
        x = 0,
        y = 0,
        w = 0,
        h = 0,
        normalizedW = 0,
        normalizedH = 0,
        storedObjectsIndexes = {}
    }

    Editor.data.mouse = {
        x = 0,
        y = 0
    }
end

function EditorState:draw()
    local curBG = Assets.bgs[editorLevelData.level.bgID]
    local bgOffsetX = Editor.camera.x * editorLevelData.meta.bgConfig.bgFactor.x + editorLevelData.meta.bgConfig.bgOffsetX
    local bgOffsetY = Editor.camera.y * editorLevelData.meta.bgConfig.bgFactor.y + editorLevelData.meta.bgConfig.bgOffsetY

    -- Calcula o início e o fim do grid de texturas que precisam ser desenhadas
    local startX = math.floor(bgOffsetX / curBG:getWidth()) * curBG:getWidth()
    local startY = math.floor(bgOffsetY / curBG:getHeight()) * curBG:getHeight()

    local endX = startX + love.graphics.getWidth() + curBG:getWidth()
    local endY = startY + love.graphics.getHeight() + curBG:getHeight()

    for x = startX, endX, curBG:getWidth() do
        for y = startY, endY, curBG:getHeight() do
            local color = editorLevelData.level.colorChannels["bg"]
            love.graphics.setColor(editorLevelData.level.colorChannels["bg"])
                love.graphics.draw(curBG, x - bgOffsetX, y - bgOffsetY)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    Editor.components.grid(Editor.camera, 32)

    Editor.camera:attach()
        for _, o in pairs(editorLevelData.objects) do
            if o.meta.selected then
                love.graphics.setColor(0, 1, 0, 1)
            else
                love.graphics.setColor(editorLevelData.level.colorChannels["obj"])
            end
            switch(o.type, {
                ["tile"] = function()
                    local qx, qy, qw, qh = Assets[o.type].quads[o.id]:getViewport()
                    love.graphics.draw(
                        Assets[o.type].img, Assets[o.type].quads[o.id], 
                        o.x, o.y, math.rad(o.angle), 1, 1, qw / 2, qh / 2
                    )
                end,
                ["hazard"] = function()
                    local qx, qy, qw, qh = Assets[o.type].quads[o.id]:getViewport()
                    love.graphics.draw(
                        Assets[o.type].img, Assets[o.type].quads[o.id], 
                        o.x, o.y, math.rad(o.angle), 0.5, 0.5, qw / 2, qh / 2
                    )
                end,
                ["trigger"] = function()
                    local qx, qy, qw, qh = Assets[o.type].quads[o.id]:getViewport()
                    love.graphics.draw(
                        Assets[o.type].img, Assets[o.type].quads[o.id], 
                        o.x, o.y, math.rad(o.angle), 1, 1, qw / 2, qh / 2
                    )
                end,
            })
            love.graphics.setColor(1, 1, 1, 1)
            
            if o.hitbox then
                switch(o.hitbox.type, {
                    ["solid"] = function()
                        if Editor.flags.showHitbox then
                            love.graphics.setColor(0, 0, 1, 0.6)
                                love.graphics.rectangle("fill", o.hitbox.x, o.hitbox.y, o.hitbox.w, o.hitbox.h)
                            love.graphics.setColor(0, 0, 1, 1)
                                love.graphics.rectangle("line", o.hitbox.x, o.hitbox.y, o.hitbox.w, o.hitbox.h)
                            love.graphics.setColor(1, 1, 1, 1)
                        end
                    end,
                    ["hazard"] = function()
                        if Editor.flags.showHitbox then
                            love.graphics.setColor(1, 0, 0, 0.6)
                                love.graphics.rectangle("fill", o.hitbox.x, o.hitbox.y, o.hitbox.w, o.hitbox.h)
                            love.graphics.setColor(1, 0, 0, 1)
                                love.graphics.rectangle("line", o.hitbox.x, o.hitbox.y, o.hitbox.w, o.hitbox.h)
                            love.graphics.setColor(1, 1, 1, 1)
                        end
                    end
                })
            end
        end

        if Editor.data.selectionArea.visible then

            love.graphics.setColor(0, 1, 1, 0.4)
                love.graphics.rectangle("fill", Editor.data.selectionArea.x, Editor.data.selectionArea.y, Editor.data.selectionArea.w, Editor.data.selectionArea.h)
            love.graphics.setColor(1, 1, 1, 1)

            love.graphics.setColor(0, 1, 1, 1)
                love.graphics.setLineWidth(3)
                    love.graphics.rectangle("line", Editor.data.selectionArea.x, Editor.data.selectionArea.y, Editor.data.selectionArea.w, Editor.data.selectionArea.h)
                love.graphics.setLineWidth(1)
            love.graphics.setColor(1, 1, 1, 1)
        end

        love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", Editor.data.mouse.x, Editor.data.mouse.y, 32, 32)
        love.graphics.setLineWidth(1)

        love.graphics.setColor(editorLevelData.level.colorChannels["ground"])
            love.graphics.draw(lineGround, Editor.camera.x - (love.graphics.getWidth() - 128) / 2, editorLevelData.level.groundY, 0, love.graphics.getWidth() - 128, 2)
        love.graphics.setColor(1, 1, 1, 1)
    Editor.camera:detach()

    switch(Editor.data.objType, {
        ["tile"] = function()
            local qx, qy, qw, qh = Assets[Editor.data.objType].quads[Editor.data.objID]:getViewport()
            love.graphics.draw(
                Assets[Editor.data.objType].img, Assets[Editor.data.objType].quads[Editor.data.objID], 
                48, 48, math.rad(Editor.data.angle), 1, 1, qw / 2, qh / 2
            )
        end,
        ["hazard"] = function()
            local qx, qy, qw, qh = Assets[Editor.data.objType].quads[Editor.data.objID]:getViewport()
            love.graphics.draw(
                Assets[Editor.data.objType].img, Assets[Editor.data.objType].quads[Editor.data.objID], 
                48, 48, math.rad(Editor.data.angle), 0.5, 0.5, qw / 2, qh / 2
            )
        end,
        ["trigger"] = function()
            local qx, qy, qw, qh = Assets[Editor.data.objType].quads[Editor.data.objID]:getViewport()
            love.graphics.draw(
                Assets[Editor.data.objType].img, Assets[Editor.data.objType].quads[Editor.data.objID], 
                48, 48, math.rad(Editor.data.angle), 2, 2, qw / 2, qh / 2
            )
        end,
    })

    love.graphics.print(tostring(slab.IsVoidHovered()), 10, 90)
    love.graphics.print(Editor.data.objType, 10, 105)

    slab.Draw()
end

function EditorState:update(elapsed)
    slab.Update(elapsed)

    local mx, my = Editor.camera:mousePosition()
    Editor.data.mouse.x, Editor.data.mouse.y = math.floor(mx / 32) * 32, math.floor(my / 32) * 32
    Editor.camera.visibleArea.x, Editor.camera.visibleArea.y = Editor.camera.x, Editor.camera.y

    Editor.data.selectionArea.visible = love.mouse.isDown(1)

    if Editor.flags.swipeMode then
        if Editor.data.canEdit and Editor.data.objType ~= "none" and Editor.data.currentEditorMode == "append" then
            if love.mouse.isDown(1) then

                if not isHover(Editor.data.mouse.x + 16, Editor.data.mouse.y + 16) then
                    if Editor.objects[Editor.data.objType] then
                        table.insert(editorLevelData.objects, Editor.objects[Editor.data.objType](Editor.data.objID, Editor.data.mouse.x + 16, Editor.data.mouse.y + 16, Editor.data.angle, true))
                    end
                end
            elseif love.mouse.isDown(2) then
                if isHover(Editor.data.mouse.x + 16, Editor.data.mouse.y + 16) then
                    removeAt(Editor.data.mouse.x + 16, Editor.data.mouse.y + 16)
                end
            end
        end
    end

    Editor.data.canEdit = slab.IsVoidHovered()

    if Assets[Editor.data.objType] then
        if Editor.data.objID < 1 then
            Editor.data.objID = 1
        end
    
        if Editor.data.objID > #Assets[Editor.data.objType].quads then
            Editor.data.objID = #Assets[Editor.data.objType].quads
        end
    end

    Editor.interface.toolbox()
    Editor.interface.menubar()
    Editor.interface.metadataEditor()
    Editor.interface.saveFileDialog()
    Editor.interface.openFileDialog()
end

function EditorState:mousepressed(x, y, button)
    if not Editor.flags.swipeMode then
        if Editor.data.canEdit and Editor.data.objType ~= "none" and Editor.data.currentEditorMode == "append" then
            if button == 1 then
                if not isHover(Editor.data.mouse.x + 16, Editor.data.mouse.y + 16) then
                    if Editor.objects[Editor.data.objType] then
                        table.insert(editorLevelData.objects, Editor.objects[Editor.data.objType](Editor.data.objID, Editor.data.mouse.x + 16, Editor.data.mouse.y + 16, Editor.data.angle, true))
                    end
                end
            elseif button == 2 then
                if isHover(Editor.data.mouse.x + 16, Editor.data.mouse.y + 16) then
                    removeAt(Editor.data.mouse.x + 16, Editor.data.mouse.y + 16)
                end
            end
        end
    end

    if Editor.data.canEdit and Editor.data.currentEditorMode == "edit" then
        Editor.data.selectionArea.x = math.floor(Editor.data.mouse.x / 32) * 32
        Editor.data.selectionArea.y = math.floor(Editor.data.mouse.y / 32) * 32
    end
end

function EditorState:mousereleased(x, y, button)
    -- clear --
    for _, o in pairs(editorLevelData.objects) do
        o.meta.selected = false
    end
    -- store all selected objects --
    for _, o in ipairs(editorLevelData.objects) do
        if collision.rectRect(Editor.data.selectionArea, o.hitbox) then
            o.meta.selected = true
        end
    end

    -- reset --
    Editor.data.selectionArea.x = 0
    Editor.data.selectionArea.y = 0
    Editor.data.selectionArea.w = 0
    Editor.data.selectionArea.h = 0
    Editor.data.selectionArea.normalizedW = 0
    Editor.data.selectionArea.normalizedH = 0
end

function EditorState:keypressed(k)
    if k == "q" then
        Editor.data.angle = Editor.data.angle - 90
    end
    if k == "e" then
        Editor.data.angle = Editor.data.angle + 90
    end
    if k == "t" then
        Editor.flags.swipeMode = not Editor.flags.swipeMode
    end
    if k == "delete" then
        if Editor.data.currentEditorMode == "edit" then
            for i = #editorLevelData.objects, 1, -1 do
                local o = editorLevelData.objects[i]
                if o and o.meta.selected then
                    table.remove(editorLevelData.objects, i)
                end
            end
        end
    end
end

function EditorState:mousemoved(x, y, dx, dy)
    -- mouse scroll --
    if love.mouse.isDown(3) then
        Editor.camera.x = Editor.camera.x - dx / Editor.camera.scale
        Editor.camera.y = Editor.camera.y - dy / Editor.camera.scale
    end

    if Editor.data.currentEditorMode == "edit" then
        if love.mouse.isDown(1) then
            Editor.data.selectionArea.normalizedW = (Editor.data.selectionArea.normalizedW + dx)
            Editor.data.selectionArea.normalizedH = (Editor.data.selectionArea.normalizedH + dy)
            Editor.data.selectionArea.w = math.floor((Editor.data.selectionArea.normalizedW + 32) / 32) * 32
            Editor.data.selectionArea.h = math.floor((Editor.data.selectionArea.normalizedH + 32) / 32) * 32
        end
    end
end

return EditorState 