local _hitbox = require 'src.Components.Modules.Game.Objects.Hitbox'

return function(id, x, y, angle, collision)
    return {
        type = "tile",
        id = id or 1,
        x = x,
        y = y,
        angle = angle or 0,
        collision = collision or true,
        hitbox = _hitbox("solid", 0, 0, 64, 64),
        meta = {
            alpha = 0,
            color = 1,
        }
    }
end