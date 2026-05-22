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
* **Uploading**: [FastPix iOS Uploads SDK](https://github.com/FastPix/iOS-Uploads)
* **Build Constraints**: `iOS 16.0+`, Xcode 15+, real device required

---

## Project Structure

```
StreamGate/
├── StreamGate/                        # Main app target
│   ├── Constants/
│   ├── Models/
│   ├── Services/
│   ├── ViewModels/
│   └── Views/
│       ├── RecordScreen/              # Screen + camera recording UI
│       └── UploadScreen/
│           └── Components/
│               ├── HeaderSection
│               ├── RecordButton
│               ├── SeparatorSection
│               └── UploadDropZone
│
└── ScreenBroadcastExtension/          # Broadcast extension target
    ├── SampleHandler.swift
    ├── Info.plist
    └── ScreenBroadcastExtension.entitlements
```

---

## Setup & Build Instructions

### Prerequisites

Before building the project, ensure you have:

* Xcode 15+
* iOS 16.0+
* Physical iPhone device (ReplayKit Broadcast Extensions do not work reliably on Simulator)
* Apple Developer Account
* FastPix API credentials

---

### 1. Clone Repository

```bash
git clone <repository-url>
cd StreamGate
open StreamGate.xcodeproj
```

---

### 2. Add FastPix iOS Uploads SDK

StreamGate uses the [FastPix iOS Uploads SDK](https://github.com/FastPix/iOS-Uploads) for resumable chunked uploads.

**Via Swift Package Manager:**

1. In Xcode go to **File → Add Package Dependencies**
2. Enter the package URL:
   ```
   https://github.com/FastPix/iOS-Uploads
   ```
3. Select the latest version and add it to the **StreamGate** main target

After adding, verify the SDK appears under the main target's **Frameworks, Libraries, and Embedded Content** alongside `ScreenBroadcastExtension.appex`:

```
Frameworks, Libraries, and Embedded Content
├── fp-swift-upload-sdk
└── ScreenBroadcastExtension.appex    →  Embed Without Signing
```

> `ScreenBroadcastExtension.appex` must be set to **Embed Without Signing** so iOS bundles the extension inside the main app at install time. Without this the broadcast picker will show no available extension.

---

### 3. Configure App Groups

Enable the same App Group for both targets:

**Main App Target**

```
Signing & Capabilities
→ App Groups
→ group.com.streamgate.broadcast
```

**ScreenBroadcastExtension Target**

```
Signing & Capabilities
→ App Groups
→ group.com.streamgate.broadcast
```

> The App Group identifier must match exactly on both targets. If they differ, the extension and main app write and read from different sandboxed directories and no recorded file will ever be detected.

---

### 4. Configure Broadcast Extension

Verify the Broadcast Extension Bundle Identifier:

```
com.streamgate.StreamGate.ScreenBroadcastExtension
```

And ensure the same identifier is referenced in `BroadcastPickerView.swift`:

```swift
picker.preferredExtension = "com.streamgate.StreamGate.ScreenBroadcastExtension"
```

---

### 5. Configure FastPix Credentials

Add your FastPix credentials in `UploadViewModel.swift`:

```swift
let tokenId   = "YOUR_TOKEN_ID"
let secretKey = "YOUR_SECRET_KEY"
```

For production builds, store credentials securely using environment variables or `xcconfig` files. Never commit credentials to version control.

---

### 6. Required Permissions

Add the following permissions to the main application's `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Used to record videos.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Used to record audio.</string>
```

---

### 7. Build & Run

1. Select a physical iPhone as the run destination
2. Build and run the app (`Cmd + R`)
3. Open the **Record Screen** section
4. Tap **Record Screen**
5. Select `ScreenBroadcastExtension` from the ReplayKit broadcast picker
6. Start recording
7. Stop recording when finished
8. The generated MP4 file will be detected and uploaded through the FastPix Upload SDK

---

## Screen Recording Flow

```
User starts screen recording
        ↓
ReplayKit Broadcast Extension captures screen
        ↓
AVAssetWriter generates MP4 file
        ↓
Recording file path shared with main app via App Group
        ↓
Main app detects completed recording
        ↓
Video preview displayed
        ↓
FastPix Upload SDK uploads video
        ↓
Playback URL generated
```

---

## Important Reference Links

* FastPix Platform: [fastpix.io](https://fastpix.io/)
* FastPix Access Token Guide: [Activate Your Account](https://fastpix.io/docs/getting-started/activate-your-account)
* FastPix VOD Upload API Docs: [Direct Upload Video Media](https://fastpix.io/docs/video-on-demand-api/upload-and-import-videos/direct-upload-video-media)
* FastPix iOS Uploads SDK: [FastPix/iOS-Uploads](https://github.com/FastPix/iOS-Uploads)
* Apple ReplayKit Docs: [ReplayKit — Apple Developer](https://developer.apple.com/documentation/replaykit)

---

## License

StreamGate is licensed under the MIT License.
