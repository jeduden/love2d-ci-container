# GitHub Copilot Instructions for Love2D CI Container

## Overview

This repository provides a Docker container for testing Love2D games in CI/CD environments with visual output capture. When reviewing PRs or testing Love2D games, use the container's screenshot and video recording capabilities to provide visual feedback.

## Container Capabilities

The Love2D CI container (`ghcr.io/jeduden/love2d-ci-container:latest`) provides:

1. **Headless game execution** - Runs Love2D games via Xvfb without GPU/display hardware
2. **Screenshot capture** - Extracts PNG screenshots at specific frames
3. **Video recording** - Records full game execution as MP4 (30 FPS)
4. **Animated GIF generation** - Converts videos to GIFs optimized for inline embedding (10 FPS, ~27KB)
5. **Audio testing** - Supports audio APIs with SDL dummy driver

## Helper Scripts

The container includes these scripts in the root directory:

- `/run-and-record.sh` - Run game, record video, generate GIF, extract screenshots (all-in-one)
- `/run-and-screenshot.sh` - Run game and extract screenshots only
- `/extract-screenshots.sh` - Extract screenshots from Love2D save directory
- `/run-with-audio.sh` - Run game with PulseAudio enabled for audio testing

## Usage Instructions for PR Reviews

### When to Use Visual Capture

Use the container's visual capture capabilities when:

- Reviewing PRs that modify Love2D game code, graphics, or rendering
- Testing visual regression between commits
- Verifying game behavior changes
- Documenting visual bugs or features
- Providing visual feedback on game state or UI changes

### How to Capture and Post Visual Feedback

When reviewing a PR with Love2D game changes:

1. **Run the container with video recording:**
   ```bash
   docker run --rm \
     -v $(pwd)/game:/game \
     -v $(pwd)/output:/output \
     ghcr.io/jeduden/love2d-ci-container:latest \
     /run-and-record.sh
   ```

2. **Generated outputs in `/output` directory:**
   - `game-recording.mp4` - Full quality video (30 FPS, H.264)
   - `game-recording.gif` - Animated GIF for inline embedding (~27KB, 10 FPS)
   - `frame_*.png` - Individual screenshots (if game captures them)
   - `audio-status.txt` - Audio system verification (if applicable)
   - `audio-info.txt` - Audio test information (if applicable)

3. **Post animated GIF in PR comments:**
   - **ALWAYS post the animated GIF inline** in your PR review comment
   - Load `output/game-recording.gif` and embed it directly
   - The GIF shows the complete game execution with smooth animation
   - This provides immediate visual feedback without requiring downloads

4. **Post individual screenshots:**
   - Load and post PNG screenshots from `output/frame_*.png`
   - These show specific game states at key frames
   - Useful for comparing before/after states

5. **Reference full video in artifacts:**
   - Mention that full quality MP4 is available in artifacts if needed
   - Provide download link for detailed frame-by-frame analysis

### Example PR Review Comment Format

When posting visual feedback, use this format:

```markdown
## 🎮 Love2D Game Test Results

I've tested the game changes using the Love2D CI container. Here's what I observed:

### Game Recording

![Game Recording](path/to/game-recording.gif)

The animated GIF above shows the complete game execution (~3 seconds at 10 FPS).

### Key Observations

- [Your observations about the visual behavior]
- [Any issues or improvements noticed]
- [Performance or rendering notes]

### Screenshots at Key Frames

**Frame 30 (1 second):**
![Frame 30](path/to/frame_30.png)

**Frame 90 (3 seconds):**
![Frame 90](path/to/frame_90.png)

**Frame 150 (5 seconds):**
![Frame 150](path/to/frame_150.png)

### Additional Details

- Resolution: 800x600 (headless mode via Xvfb)
- Full quality MP4 video available in artifacts
- Audio: [Tested with SDL dummy driver / Not applicable]

[Your detailed review comments here]
```

### Best Practices

1. **Always capture visual output** when reviewing Love2D game PRs
2. **Always post the animated GIF** inline in your comment for immediate visual feedback
3. **Post individual screenshots** to highlight specific states or issues
4. **Describe what you observe** in the visual output
5. **Compare with previous versions** if available (visual regression testing)
6. **Note any rendering issues** (glitches, performance, incorrect visuals)
7. **Verify expected behavior** matches the visual output
8. **Use artifacts** for full quality video when detailed analysis is needed

### Screenshot Capture in Game Code

If the game code doesn't capture screenshots automatically, you can modify the test to capture at specific frames:

```lua
-- In love.draw() or love.update()
if love.frame == 30 or love.frame == 90 or love.frame == 150 then
  love.graphics.captureScreenshot("frame_" .. love.frame .. ".png")
end
```

The container's `/extract-screenshots.sh` script will automatically find and extract these from Love2D's save directory.

### GitHub Actions Integration

For automated PR testing, use the example workflow in `examples/github-actions-example.yml`:

```yaml
- name: Record game video and screenshots
  run: |
    docker run --rm \
      -v $(pwd)/test-game:/game \
      -v $(pwd)/output:/output \
      ghcr.io/jeduden/love2d-ci-container:latest \
      /run-and-record.sh

- name: Upload outputs
  uses: actions/upload-artifact@v4
  with:
    name: game-outputs
    path: output/

- name: Post visual feedback
  uses: actions/github-script@v7
  with:
    script: |
      const fs = require('fs');
      const gifData = fs.readFileSync('output/game-recording.gif');
      const gifBase64 = gifData.toString('base64');
      
      await github.rest.issues.createComment({
        owner: context.repo.owner,
        repo: context.repo.repo,
        issue_number: context.issue.number,
        body: `## 🎮 Automated Game Test\n\n![Game Recording](data:image/gif;base64,${gifBase64})\n\nFull results available in artifacts.`
      });
```

## Summary

As GitHub Copilot reviewing Love2D PRs:

✅ **DO**: Run `/run-and-record.sh` to capture video, GIF, and screenshots
✅ **DO**: Post the animated GIF inline in PR comments for immediate visual feedback
✅ **DO**: Post individual screenshots to highlight specific frames or issues
✅ **DO**: Describe visual observations and compare with expected behavior
✅ **DO**: Reference full MP4 video in artifacts for detailed analysis

❌ **DON'T**: Skip visual capture when reviewing game rendering or behavior changes
❌ **DON'T**: Post only text descriptions when visual output is available
❌ **DON'T**: Forget to embed the animated GIF inline (not just as a link)

This approach ensures comprehensive visual feedback that's immediately accessible to developers and reviewers.
