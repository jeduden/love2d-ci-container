# GitHub Copilot Instructions for Love2D CI Container

## Overview

This repository provides a Docker container for testing Love2D games in CI/CD environments with visual output capture.

## When to Use Visual Capture

When reviewing PRs for Love2D games or making changes to the Love2D CI container, you MUST:
1. Build the Docker container
2. Run the test game using `/run-and-record.sh`
3. Check the GitHub Actions workflow run for visual outputs
4. Link to the Actions Summary in PR comments for visual feedback

## How to Display Visual Outputs in PR Comments

Screenshots and videos are automatically stored in the `love2d-ci-assets` branch by GitHub Actions and displayed in the Actions Summary.

### Step 1: Find the GitHub Actions Run

After running the test, find the GitHub Actions workflow run:
1. Navigate to the "Actions" tab in the repository
2. Find the most recent workflow run for your PR/branch
3. Note the run URL (e.g., `https://github.com/{owner}/{repo}/actions/runs/{run_id}`)

### Step 2: Link to the Actions Summary

In your PR comment, provide a direct link to the Actions Summary where all screenshots, animated GIF, and video information are displayed:

```markdown
Visual outputs from the test run are available in the GitHub Actions Summary:
https://github.com/jeduden/love2d-ci-container/actions/runs/{RUN_ID}

The summary displays:
- Animated GIF showing complete game execution (10 FPS)
- Individual screenshots at frames 30, 90, and 150
- Video file information (MP4, 30 FPS)
- File sizes and download links for artifacts
```

### Step 3: Provide Summary of Results

After linking to the Actions Summary, provide a brief textual summary of what was verified:

```markdown
All features verified working:
- Graphics rendering with animated orange circle, cyan and magenta rectangles, text
- All 3 screenshots captured successfully (3.7-3.8 KB each, 800x600, correct permissions)
- Video recorded as MP4 (35 KB, 30 FPS, H.264)
- Animated GIF generated (28 KB, 10 FPS)
- Audio system functional with SDL dummy driver
- All helper scripts working correctly
```

## Required Files Generated

The `/run-and-record.sh` script generates:
- `frame_30.png` - Screenshot at frame 30 (~1 second)
- `frame_90.png` - Screenshot at frame 90 (~3 seconds)  
- `frame_150.png` - Screenshot at frame 150 (~5 seconds)
- `game-recording.mp4` - Full video recording (30 FPS)
- `game-recording.gif` - Animated GIF (10 FPS)

All files are automatically:
1. Committed to the `love2d-ci-assets` branch under `runs/{run_id}/`
2. Uploaded as workflow artifacts
3. Displayed in the GitHub Actions Summary

## Example PR Comment Format

```markdown
Visual test results are available in the Actions Summary:
https://github.com/jeduden/love2d-ci-container/actions/runs/12345678

All features verified working:
- Graphics rendering with animated orange circle, cyan and magenta rectangles, text
- All 3 screenshots captured successfully (3.7-3.8 KB each, 800x600, correct permissions)
- Video recorded as MP4 (35 KB, 30 FPS, H.264)
- Animated GIF generated (28 KB, 10 FPS)
- Audio system functional with SDL dummy driver
- All helper scripts working correctly

The container successfully runs Love2D games with graphics/audio in headless mode, captures screenshots, records video, and generates animated GIFs for CI/CD workflows and automated PR reviews.
```

## Important Notes

- **ALWAYS** link to the GitHub Actions Summary for visual outputs
- **DO NOT** try to embed images directly in PR comments using raw URLs
- **DO NOT** use playwright or any other screenshot tools to display game output
- **DO NOT** use base64 encoding for images
- **DO NOT** use file:// URLs
- The Actions Summary requires the workflow to complete successfully before visuals are available
- The workflow may require approval for first-time contributors
- Assets are stored per-run to avoid conflicts

## Troubleshooting

If visual outputs don't appear:
1. Verify the GitHub Actions workflow completed successfully
2. Check that the workflow run was approved (if required)
3. Ensure the "Update Actions Summary" step completed in the workflow
4. Check that the asset branch (`love2d-ci-assets`) was created/updated
5. Verify artifacts were uploaded successfully
