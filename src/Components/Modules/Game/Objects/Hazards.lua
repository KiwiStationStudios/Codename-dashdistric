local _hitbox = require 'src.Components.Modules.Game.Objects.Hitbox'
local _object = require 'src.Components.Modules.Game.Objects.Object'

return function(id, x, y, angle, collision)
    local o = _object(x, y, angle)
    o.id = id or 1
    o.type = "hazard"
    o.collision = collision or true
    switch(id, {
        [2] = function()
            o.hitbox = _hitbox("hazard", 24, 42, 16, 16)
        end,
        ["default"] = function()
            o.hitbox = _hitbox("hazard", 24, 24, 16, 32)
        end
    })
    o.meta = {
        alpha = 0,
        color = "obj",
    }
    return o
end