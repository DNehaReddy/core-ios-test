# Introduction:

The FastPix iOS Video Data Core SDK is the official Swift-based SDK designed for integration with iOS-supported video players. It serves as a foundation for collecting and processing player analytics when used with FastPix-supported iOS Player Analytics SDKs. This SDK facilitates the gathering of video performance metrics, which can be accessed on the FastPix dashboard for monitoring and analysis. While the SDK is developed in Swift, the currently published SPM package includes only Swift support.

# Key Features:

- **Track Viewer Engagement:** Gain insights into how users interact with your videos.
- **Monitor Playback Quality:** Ensure video streaming by monitoring real-time metrics, including bitrate, buffering, startup performance, render quality, and playback failure errors.
- **Error Management:** Identify and resolve playback failures quickly with detailed error reports.
- **Customizable Tracking:** Flexible configuration to match your specific monitoring needs.
- **Centralized Dashboard:** Visualize and compare metrics on the [FastPix dashboard](https://dashboard.fastpix.io) to make data-driven decisions.

# Step 1: Installation and Setup:

To get started with the **FastPix iOS Video Data Core SDK**, you can integrate it into your project using **Swift Package Manager (SPM)**. Follow these steps to add the package to your iOS project.

1. **Open your Xcode project** and navigate to:
   ```
   File → Add Packages…
   ```

2. **Enter the repository URL** for the FastPix SDK:
   ```
   https://github.com/fastpix/iOS-video-data-core.git
   ```

3. **Choose the latest stable version** and click `Add Package`.

4. **Select the target** where you want to use the SDK and click `Add Package`.

Now, **FastPix Video Data Core SDK** is integrated into your project.


# Step 2: Basic Integration

To integrate the FastPix iOS Video Data Core SDK into your project, follow these steps:

## Import the SDK:

First, import the FastPix Data SDK into your Swift project:

```swift
import fp_data_sdk
```

##  Initialize and Configure the SDK:

Create an instance of FastpixMetrix and configure it with a unique player ID to track each player instance individually. The configuration method also accepts metadata as a second argument to provide additional details about the video.

```swift
let fpMetrix = FastpixMetrix()

fpMetrix.configure(
    "player1",  // Unique player identifier
    [
        "video_title": "NEW_VIDEO",
        "video_id": "video12345",
        "workspace_id": "1524672387675645346",
        "player_name": "Sample Player"
    ]
)
```

## Dispatch Events:

The SDK allows you to track various player-related events supported by FastPix using the dispatch function. It accepts two arguments:

- Event Name: The event type supported by FastPix.
- Event Metadata: Additional parameters related to the event.

```swift
fpMetrix.dispatch("EVENT_NAME", eventMetadata)
```                 
