local _hitbox = require 'src.Components.Modules.Game.Objects.Hitbox'

return function(id, x, y, angle, collision)
    local h = {
        type = "hazard",
        id = id or 1,
        x = x,
        y = y,
        angle = angle or 0,
        collision = collision or true,
        hitbox = nil
    }

    switch(id, {
        [2] = function()
            h.hitbox = _hitbox("hazard", 24, 42, 16, 16)
        end,
        ["default"] = function()
            h.hitbox = _hitbox("hazard", 24, 24, 16, 32)
        end
    })

    return h
end