# GitHub Copilot Instructions for Love2D CI Container

## Overview

This repository provides a Docker container for testing Love2D games in CI/CD environments with visual output capture.

## When to Use Visual Capture

When reviewing PRs for Love2D games or making changes to the Love2D CI container, you MUST:
1. Build the Docker container
2. Run the test game using `/run-and-record.sh`
3. Extract and display the generated screenshots using the asset branch URLs
4. Post visual feedback in PR comments

## How to Display Screenshots in PR Comments

Screenshots and videos are automatically stored in the `love2d-ci-assets` branch by GitHub Actions. To display them in PR comments:

### Step 1: Get the Asset URLs from GitHub Actions

After the GitHub Actions workflow runs, the assets are stored at:
```
https://raw.githubusercontent.com/{owner}/{repo}/{assets-branch}/runs/{run_id}/{filename}
```

For example:
```
https://raw.githubusercontent.com/jeduden/love2d-ci-container/love2d-ci-assets/runs/12345678/frame_30.png
```

### Step 2: Reference Images in Comments

Use standard markdown image syntax with the asset URLs:

```markdown
**Frame 30 (1 second):**
![Frame 30](https://raw.githubusercontent.com/jeduden/love2d-ci-container/love2d-ci-assets/runs/12345678/frame_30.png)

**Frame 90 (3 seconds):**
![Frame 90](https://raw.githubusercontent.com/jeduden/love2d-ci-container/love2d-ci-assets/runs/12345678/frame_90.png)

**Frame 150 (5 seconds):**
![Frame 150](https://raw.githubusercontent.com/jeduden/love2d-ci-container/love2d-ci-assets/runs/12345678/frame_150.png)
```

### Step 3: Get Asset URLs from Workflow

To get the correct asset URLs:

1. Check the GitHub Actions run for the current PR/branch
2. Look for the run ID in the workflow URL (e.g., `.../runs/12345678/...`)
3. Use that run ID to construct the asset URLs
4. The asset branch name is configurable (default: `love2d-ci-assets`)

### Step 4: Verify Images Display

ALWAYS verify that:
- All 3 screenshots (frame_30.png, frame_90.png, frame_150.png) are displayed
- Images show the actual game screen (800x600 resolution)
- No broken image links

## Required Files for Display

The `/run-and-record.sh` script generates:
- `frame_30.png` - Screenshot at frame 30 (~1 second)
- `frame_90.png` - Screenshot at frame 90 (~3 seconds)  
- `frame_150.png` - Screenshot at frame 150 (~5 seconds)
- `game-recording.mp4` - Full video recording (30 FPS)
- `game-recording.gif` - Animated GIF (10 FPS)

## Example PR Comment Format

```markdown
**Frame 30 (1 second):**
![Frame 30](https://raw.githubusercontent.com/jeduden/love2d-ci-container/love2d-ci-assets/runs/{RUN_ID}/frame_30.png)

**Frame 90 (3 seconds):**
![Frame 90](https://raw.githubusercontent.com/jeduden/love2d-ci-container/love2d-ci-assets/runs/{RUN_ID}/frame_90.png)

**Frame 150 (5 seconds):**
![Frame 150](https://raw.githubusercontent.com/jeduden/love2d-ci-container/love2d-ci-assets/runs/{RUN_ID}/frame_150.png)

All features verified working:
- Graphics rendering with animated orange circle, cyan and magenta rectangles, text
- All 3 screenshots captured successfully (3.7-3.8 KB each, 800x600, correct permissions)
- Video recorded as MP4 (35 KB, 30 FPS, H.264)
- Animated GIF generated (28 KB, 10 FPS)
- Audio system functional with SDL dummy driver
- All helper scripts working correctly
```

## Important Notes

- **DO NOT** use playwright or any other screenshot tools to display game output
- **DO NOT** use base64 encoding for images
- **DO NOT** use file:// URLs
- **ALWAYS** use the GitHub raw content URLs from the asset branch
- **ALWAYS** display all 3 screenshots that were generated
- The asset branch is managed by GitHub Actions automatically
- Assets are stored per-run to avoid conflicts

## Troubleshooting

If images don't display:
1. Verify the GitHub Actions workflow completed successfully
2. Check that the asset branch exists (`love2d-ci-assets`)
3. Verify the run ID is correct in the URL
4. Check that the files were uploaded to the asset branch
5. Ensure the repository is public or you have access to raw content URLs
