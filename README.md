# StreamGate iOS App

StreamGate is an open-source native iOS application designed as a technical showcase for capturing and uploading video content directly to the cloud. Built purely for developers, it demonstrates how to handle complex mobile media workflows — such as camera capture, background screen recording, and reliable direct-to-cloud resumable uploads using FastPix infrastructure.

Once an upload completes, StreamGate generates an instant, shareable playback link.

---

## Core Features & Architecture

StreamGate is built using a modern iOS tech stack (100% Swift, SwiftUI, ReplayKit, AVFoundation) and focuses on the following core capabilities:

1. **Camera Capture**: Integrates `UIImagePickerController` for native video recording directly within the app.
2. **Screen Recording**: Uses Apple's `ReplayKit` Broadcast Extension with `AVAssetWriter` to capture device-wide screen activity reliably in a separate sandboxed process.
3. **Direct Cloud Uploading**: Utilizes the FastPix iOS Upload SDK to push large media files securely to the cloud in resumable chunks without routing them through an intermediary backend server.
4. **Local Playback / Preview**: Integrates `AVPlayer` to preview the recorded video locally before the shareable link is generated.
5. **Auto Cleanup**: Automatically deletes previous recordings before each new session to keep on-device storage usage low.

---

## Tech Stack & Dependencies

* **Language**: Swift
* **UI Framework**: SwiftUI
* **Screen Capture**: ReplayKit (`RPBroadcastSampleHandler`, `RPSystemBroadcastPickerView`)
* **Video Encoding**: AVFoundation (`AVAssetWriter`, H.264)
* **Inter-process Communication**: App Groups (shared `UserDefaults` + shared filesystem)
* **Uploading**: FastPix iOS Upload SDK (resumable chunked uploads)
* **Build Constraints**: `iOS 16.0+`, Xcode 15+, real device required

---

## Setup & Build Instructions

Because StreamGate requires a FastPix API key to initialize uploads, and uses an App Group shared container for inter-process communication between the main app and the broadcast extension, you must configure your environment before building.

### 1. Prerequisites

You will need:
* A **FastPix Account** (to retrieve your API Token ID and Secret Key).
* **Xcode 15** or later.
* A **real iOS device** — ReplayKit Broadcast Extensions do not work reliably on Simulator.

### 2. Configure App Groups

Both targets must share the same App Group identifier. In Xcode:

1. Select the **StreamGate** target → Signing & Capabilities → **+ App Groups**
   Add: `group.com.streamgate.broadcast`

2. Select the **ScreenBroadcastExtension** target → Signing & Capabilities → **+ App Groups**
   Add: `group.com.streamgate.broadcast`

> If the identifiers do not match exactly, the extension and main app write and read from different sandboxed directories, and no recorded file will ever be detected by the main app.

### 3. Add your FastPix credentials

Open your `UploadViewModel.swift` and supply your FastPix API Token ID and Secret Key:

```swift
let tokenId     = "YOUR_FASTPIX_TOKEN_ID"
let secretKey   = "YOUR_FASTPIX_SECRET_KEY"
```

*Never commit credentials to version control. Use `local.xcconfig` or environment variables for production builds.*

### 4. Add required Info.plist keys

In the main target's `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Used to record camera video.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Used to record audio with video.</string>
```

### 5. Build & Run

```
Product → Destination → [Your iPhone]
Cmd + R
```

Alternatively from the terminal:

```bash
# Clone the repository
git clone https://github.com/your-org/streamgate-ios.git
cd streamgate-ios

# Open in Xcode
open StreamGate.xcodeproj
```

Then select your device and hit **Run**.

---

## Important Reference Links

* FastPix Platform: [fastpix.io](https://fastpix.io/)
* FastPix Access Token Guide: [Activate Your Account](https://fastpix.io/docs/getting-started/activate-your-account)
* FastPix VOD Upload API Docs: [Direct Upload Video Media](https://fastpix.io/docs/video-on-demand-api/upload-and-import-videos/direct-upload-video-media)
* FastPix iOS Upload SDK: [fastpix-ios-upload-sdk](https://github.com/FastPix/fastpix-ios-upload-sdk)
* Apple ReplayKit Docs: [ReplayKit — Apple Developer](https://developer.apple.com/documentation/replaykit)

---

## License

StreamGate is licensed under the MIT License.
