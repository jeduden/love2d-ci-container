-- Simple Love2D test game
-- This game runs for a few seconds then exits successfully

local frameCount = 0
local maxFrames = 60  -- Run for ~1 second at 60 FPS

function love.load()
    print("Love2D test game starting...")
    print("LuaJIT version: " .. jit.version)
    print("Love2D version: " .. love.getVersion())
end

function love.update(dt)
    frameCount = frameCount + 1
    if frameCount >= maxFrames then
        print("Test completed successfully!")
        print("Frames rendered: " .. frameCount)
        love.event.quit(0)
    end
end

function love.draw()
    -- Simple draw to test rendering
    love.graphics.print("Test Frame: " .. frameCount, 10, 10)
end
