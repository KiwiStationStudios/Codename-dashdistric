love.filesystem.load("src/Components/Initialization/Run.lua")()
love.filesystem.load("src/Components/Initialization/ErrorHandler.lua")()

function love.initialize(args)
    fontcache = require 'src.Components.Modules.System.FontCache'
    Presence = require 'src.Components.Modules.API.Presence'
    GameColors = require 'src.Components.Modules.Utils.GameColors'
    LanguageController = require 'src.Components.Modules.System.LanguageManager'
    connectGJ = require 'src.Components.Modules.API.InitializeGJ'

    fontcache.init()

    gameslot = neuron.new("game")

    gameslot.save.game = {
        user = {
            settings = {
                shaders = true,
                language = "English",
                gamejolt = {
                    username = "",
                    usertoken = ""
                },
            },
            game = {
                totalPoints = 0,
            },
            achievments = {},
        }
    }
    gameslot:initialize()

    love.graphics.setDefaultFilter("nearest", "nearest")

    languageService = LanguageController(gameslot.save.game.user.settings.language)

    registers = {
        user = {
            roundStarted = false,
            paused = false,
        },
        system = {
            showDebugHitbox = false,
            gameTime = 0,
            editor = {
                fileDialogOpen = false,
                fileDialogSave = false,
                metaDataWindow = false,
                addNewColorChannel = false,
                newColorChannelTag = "",
                colorChannelColorPicker = false,
                colorChannelCreateCurrentColor = {1, 1, 1, 1},
                editColorChannelPicker = false,
                currentKey = 0,
                currentSelectedLevelID = 0,
                saveName = "",
                useCustomSongFlag = false,
            }
        }
    }

    local gitStuff = require 'src.Components.Initialization.GitStuff'
    connectGJ()

    if not love.filesystem.isFused() then
        gitStuff.getAll()

        if love.filesystem.getInfo(".commitid") then
            local title = love.window.getTitle()
            love.window.setTitle(title .. " | " .. love.filesystem.read(".commitid"))
        end
    end

    local states = love.filesystem.getDirectoryItems("src/States")
    for s = 1, #states, 1 do
        require("src.States." .. states[s]:gsub(".lua", ""))
    end
    if DEBUG_APP then
        love.filesystem.createDirectory("screenshots")
    end

    love.filesystem.createDirectory("user")
    love.filesystem.createDirectory("user/editor")
    love.filesystem.createDirectory("user/saved")
    love.filesystem.createDirectory("user/songs")

    gamestate.registerEvents()
    gamestate.switch(EditorState)
end

function love.update(elapsed)
    if gamejolt.isLoggedIn then
        registers.system.gameTime = registers.system.gameTime + elapsed
        if math.floor(registers.system.gameTime) >= 20 then
            gamejolt.pingSession(true)
            registers.system.gameTime = 0
            io.printf(string.format("{bgGreen}{brightWhite}{bold}[Gamejolt]{reset}{brightWhite} : Client heartbeated a session (%s, %s){reset}\n", gamejolt.username, gamejolt.userToken))
        end
    end
end

function love.keypressed(k)
    if DEBUG_APP then
        if k == "f11" then
            love.graphics.captureScreenshot("screenshots/screen_" .. os.date("%Y-%m-%d %H-%M-%S") .. ".png")
        end
    end
end

function love.quit()
    if gamejolt.isLoggedIn then
        gamejolt.closeSession()
    end
end
