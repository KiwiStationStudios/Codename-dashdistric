local uuid = require 'src.Components.Modules.Game.Editor.Functions.UUID'

return function(levelname)
    return {
        meta = {
            title = levelname or "Unnamed level",
            gameversion = 0,
            requestedDifficulty = 0, -- int range 1 -> 5
            songid = "builtin:dubnix"
        },
        level = {
            startPos = {0, 0},
            endPos = 256,
            groundY = 0,
            colorChannels = {
                bg = {60, 205, 168},
                objs = {255, 255, 255},
                black = {0, 0, 0},
                finalObj = {191, 113, 216}
            },
            startGamemode = "cube",
            startSpeed = 0, -- range from 0 to 4
            gravityFlipped = false,
        },
        objects = {
        },
    }
end