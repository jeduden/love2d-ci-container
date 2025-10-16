-- Simple Love2D test game
-- This game runs for a few seconds then exits successfully
-- Tests graphics rendering, audio functionality, and screenshot capability

local frameCount = 0
local maxFrames = 180  -- Run for ~3 seconds at 60 FPS
local screenshotsTaken = {}
local audioSource = nil

function love.load()
    print("Love2D test game starting...")
    print("LuaJIT version: " .. jit.version)
    print("Love2D version: " .. love.getVersion())
    
    -- Test audio functionality
    print("Testing audio system...")
    local audioStatus = {
        module_enabled = false,
        source_created = false,
        playback_attempted = false,
        playback_success = false
    }
    
    if love.audio then
        print("Audio module: enabled")
        audioStatus.module_enabled = true
        local success, err = pcall(function()
            -- Create a simple beep sound programmatically
            local sampleRate = 44100
            local duration = 0.1
            local frequency = 440
            local samples = math.floor(sampleRate * duration)
            local soundData = love.sound.newSoundData(samples, sampleRate, 16, 1)
            
            for i = 0, samples - 1 do
                local t = i / sampleRate
                local value = math.sin(2 * math.pi * frequency * t)
                soundData:setSample(i, value)
            end
            
            audioSource = love.audio.newSource(soundData)
        end)
        
        if success then
            print("Audio test sound created successfully")
            audioStatus.source_created = true
        else
            print("Audio initialization failed (expected in headless mode): " .. tostring(err))
            audioSource = nil
        end
    else
        print("Audio module: disabled")
    end
    
    -- Store audio status for later reporting
    _G.audioStatus = audioStatus
    
    -- Create screenshots directory
    local info = love.filesystem.getInfo("screenshots")
    if not info then
        love.filesystem.createDirectory("screenshots")
        print("Created screenshots directory")
    end
end

function love.update(dt)
    frameCount = frameCount + 1
    
    -- Play audio at frame 60
    if frameCount == 60 and audioSource then
        _G.audioStatus.playback_attempted = true
        local success, err = pcall(function()
            audioSource:play()
        end)
        if success then
            print("Playing audio test sound")
            _G.audioStatus.playback_success = true
        else
            print("Audio playback failed (expected in headless mode): " .. tostring(err))
        end
    end
    
    if frameCount >= maxFrames then
        print("Test completed successfully!")
        print("Frames rendered: " .. frameCount)
        print("Screenshots taken: " .. countScreenshots())
        
        -- Write audio status report
        local statusReport = string.format(
            "AUDIO_TEST_RESULTS:\nModule Enabled: %s\nSource Created: %s\nPlayback Attempted: %s\nPlayback Success: %s",
            tostring(_G.audioStatus.module_enabled),
            tostring(_G.audioStatus.source_created),
            tostring(_G.audioStatus.playback_attempted),
            tostring(_G.audioStatus.playback_success)
        )
        love.filesystem.write("audio-status.txt", statusReport)
        print(statusReport)
        
        love.event.quit(0)
    end
end

function love.draw()
    -- Clear background with a color
    love.graphics.clear(0.2, 0.3, 0.4, 1.0)
    
    -- Draw some graphics to test rendering
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Love2D CI Container Test", 10, 10)
    love.graphics.print("Test Frame: " .. frameCount .. " / " .. maxFrames, 10, 30)
    love.graphics.print("Screenshots: " .. countScreenshots(), 10, 50)
    
    -- Draw a bouncing circle
    local time = frameCount / 60
    local x = 400 + math.sin(time * 2) * 200
    local y = 300 + math.cos(time * 3) * 150
    love.graphics.setColor(1, 0.5, 0, 1)
    love.graphics.circle("fill", x, y, 30)
    
    -- Draw some rectangles
    love.graphics.setColor(0, 1, 1, 1)
    love.graphics.rectangle("fill", 50, 100, 100, 50)
    
    love.graphics.setColor(1, 0, 1, 1)
    love.graphics.rectangle("line", 200, 100, 100, 50)
    
    -- Draw text showing audio status
    love.graphics.setColor(1, 1, 1, 1)
    if audioSource then
        love.graphics.print("Audio: Disabled (headless)", 10, 70)
    else
        love.graphics.print("Audio: Disabled", 10, 70)
    end
    
    -- Take screenshots at specific frames (must be in draw function)
    if frameCount == 30 and not screenshotsTaken[30] then
        takeScreenshot("frame_30.png")
        screenshotsTaken[30] = true
    end
    
    if frameCount == 90 and not screenshotsTaken[90] then
        takeScreenshot("frame_90.png")
        screenshotsTaken[90] = true
    end
    
    if frameCount == 150 and not screenshotsTaken[150] then
        takeScreenshot("frame_150.png")
        screenshotsTaken[150] = true
    end
end

function takeScreenshot(filename)
    love.graphics.captureScreenshot(function(imageData)
        local data = imageData:encode("png")
        local success = love.filesystem.write("screenshots/" .. filename, data)
        if success then
            print("Screenshot saved: screenshots/" .. filename)
        else
            print("Failed to save screenshot: " .. filename)
        end
    end)
end

function countScreenshots()
    local count = 0
    for _ in pairs(screenshotsTaken) do
        count = count + 1
    end
    return count
end
