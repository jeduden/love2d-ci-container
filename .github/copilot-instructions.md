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

3. **Post animated GIF and screenshots in PR comments:**
   - **MUST use browser/playwright to render and capture screenshots** for display
   - Create a minimal HTML page that displays ONLY the screenshot image
   - Use playwright's `browser_take_screenshot` to capture the rendered page
   - The HTML should contain NO text, headers, or descriptions - just the image
   - This ensures screenshots are properly visible in PR comments
   
   **Example HTML template for screenshot display:**
   ```html
   <!DOCTYPE html>
   <html>
   <head><meta charset="UTF-8"><style>body{margin:0;padding:0;background:#000;display:flex;align-items:center;justify-content:center;}</style></head>
   <body><img src="data:image/png;base64,BASE64_ENCODED_IMAGE" alt="Game Screenshot"></body>
   </html>
   ```
   
   **Steps to post screenshots:**
   1. Read the PNG file from `output/frame_*.png`
   2. Encode as base64
   3. Create minimal HTML with just the image (no text)
   4. Use playwright to navigate to the HTML and take screenshot
   5. Post the playwright screenshot in the PR comment
   
   **For animated GIFs:**
   1. Read `output/game-recording.gif`
   2. Encode as base64
   3. Create minimal HTML with just the GIF (no text)
   4. Use playwright to capture the first frame
   5. Post the screenshot showing the GIF

4. **Provide context with markdown text:**
   - Use markdown text to describe observations, separate from images
   - Explain what's shown in each screenshot
   - Note any visual issues or improvements
   
5. **Reference full video in artifacts:**
   - Mention that full quality MP4 is available in artifacts if needed
   - Provide download link for detailed frame-by-frame analysis

### Example PR Review Comment Format

When posting visual feedback:

1. Run the container and capture outputs
2. Create minimal HTML pages with just the images
3. Use playwright to render and screenshot each HTML page
4. Post the playwright screenshots in your comment
5. Add markdown text to describe what's shown

The screenshots should contain ONLY the game visual output - no surrounding text, headers, or formatting within the image itself.

### Best Practices

1. **Always capture visual output** when reviewing Love2D game PRs
2. **Use playwright to render screenshots** - create minimal HTML with just the image, then screenshot it
3. **Post clean game output only** - HTML should contain ONLY the image, no text or formatting
4. **Keep HTML minimal** - just display the image on a black background, centered
5. **Screenshot the rendered HTML** using playwright's `browser_take_screenshot`
6. **Describe observations separately** in markdown text, not within the screenshot
7. **Compare with previous versions** if available (visual regression testing)
8. **Note any rendering issues** (glitches, performance, incorrect visuals)
9. **Verify expected behavior** matches the visual output
10. **Use artifacts** for full quality video when detailed analysis is needed

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
✅ **DO**: Use playwright to render screenshots via minimal HTML pages
✅ **DO**: Create HTML with ONLY the image - no text, headers, or descriptions
✅ **DO**: Screenshot the rendered HTML page using `browser_take_screenshot`
✅ **DO**: Post the playwright screenshots in PR comments
✅ **DO**: Describe visual observations in markdown text separate from images
✅ **DO**: Compare with expected behavior and reference full MP4 video in artifacts

❌ **DON'T**: Post raw image files directly (they won't display)
❌ **DON'T**: Skip visual capture when reviewing game rendering or behavior changes
❌ **DON'T**: Add text, headers, or formatting within the screenshot HTML
❌ **DON'T**: Post formatted presentations or explanatory text around game output
❌ **DON'T**: Try to embed images with markdown img tags (use playwright instead)

This approach ensures screenshots are properly visible in PR comments and provide immediate visual feedback.
