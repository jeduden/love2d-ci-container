function love.conf(t)
    t.identity = "love2d-ci-test"
    t.version = "11.4"
    t.console = false
    
    t.window.title = "Love2D CI Test"
    t.window.width = 800
    t.window.height = 600
    t.window.vsync = 1
    t.window.display = 1
    
    -- Audio is disabled for headless CI environments
    -- Set SDL_AUDIODRIVER=dummy environment variable to enable audio module
    -- without requiring actual audio hardware
    t.modules.audio = false
    
    -- Minimize modules for faster startup
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.touch = false
end
