import SwiftUI
import ReplayKit

struct ScreenRecordingPreview:
UIViewControllerRepresentable {
    
    let previewController: RPPreviewViewController
    
    func makeUIViewController(
        context: Context
    ) -> RPPreviewViewController {
        
        previewController
    }
    
    func updateUIViewController(
        _ uiViewController: RPPreviewViewController,
        context: Context
    ) {
    }
}
