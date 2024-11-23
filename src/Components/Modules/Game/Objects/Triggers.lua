local _hitbox = require 'src.Components.Modules.Game.Objects.Hitbox'
local _object = require 'src.Components.Modules.Game.Objects.Object'

return function(id, x, y, angle, collision)
    local o = _object(x, y, angle)
    o.id = id or 1
    o.type = "trigger"

    return o
end