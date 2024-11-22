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
        trigger = {}
    }
    Assets.tile.img, Assets.tile.quads = love.graphics.getQuads("assets/images/game/blocks")
    Assets.hazard.img, Assets.hazard.quads = love.graphics.getQuads("assets/images/game/spike")
    Assets.trigger.img, Assets.trigger.quads = love.graphics.getQuads("assets/images/game/triggers")
    Assets.backbutton = love.graphics.newImage("assets/images/game/backbtn.png")

    slab.Initialize({"NoDocks"})
end

function EditorState:enter()
    Editor.camera = camera(nil, 0)
    Editor.camera.speed = 5
    Editor.camera.scrollZoom = 1 
    Editor.camera.targetZoom = 1
    editorLevelData = Editor.components.createLevel()

    print(debug.formattable(editorLevelData))

    Editor.data.objects = {}
    Editor.data.canEdit = false
    Editor.data.objType = "none"
    Editor.data.currentEditorMode = "append"
    Editor.data.objID = 1
    Editor.data.angle = 0

    Editor.data.mouse = {
        x = 0,
        y = 0
    }
end

function EditorState:draw()
    Editor.components.grid(Editor.camera, 32)

    Editor.camera:attach()
        for _, o in pairs(editorLevelData.objects) do
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
        end

        love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", Editor.data.mouse.x, Editor.data.mouse.y, 32, 32)
        love.graphics.setLineWidth(1)

        love.graphics.draw(lineGround, Editor.camera.x - (love.graphics.getWidth() - 128) / 2, editorLevelData.level.groundY, 0, love.graphics.getWidth() - 128, 2)
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

    if Editor.data.canEdit and Editor.data.objType ~= "none" and Editor.data.currentEditorMode == "append" then
        if Editor.flags.swipeMode then
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
end

function EditorState:mousepressed(x, y, button)
    if Editor.data.canEdit and Editor.data.objType ~= "none" and Editor.data.currentEditorMode == "append" then
        if not Editor.flags.swipeMode then
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
end

function EditorState:keypressed(k)
    if k == "q" then
        Editor.data.angle = Editor.data.angle - 90
    end
    if k == "e" then
        Editor.data.angle = Editor.data.angle + 90
    end
end

function EditorState:mousemoved(x, y, dx, dy)
    -- mouse scroll --
    if love.mouse.isDown(3) then
        Editor.camera.x = Editor.camera.x - dx / Editor.camera.scale
        Editor.camera.y = Editor.camera.y - dy / Editor.camera.scale
    end
end

return EditorState 