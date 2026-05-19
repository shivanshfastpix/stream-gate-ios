import Foundation
import ReplayKit
import Combine

final class ScreenRecordingService: NSObject, ObservableObject {
    
    static let shared = ScreenRecordingService()
    
    @Published var isRecording = false
    
    private let recorder = RPScreenRecorder.shared()
    
    func startRecording() {
        
        guard recorder.isAvailable else {
            print("Screen recording not available")
            return
        }
        
        recorder.startRecording { error in
            
            DispatchQueue.main.async {
                
                if let error = error {
                    print("Start recording error:", error)
                    return
                }
                
                self.isRecording = true
                
                print("Screen recording started")
            }
        }
    }
    
    func stopRecording(
        completion: @escaping (RPPreviewViewController?) -> Void
    ) {
        
        recorder.stopRecording { preview, error in
            
            DispatchQueue.main.async {
                
                self.isRecording = false
                
                if let error = error {
                    print("Stop recording error:", error)
                    completion(nil)
                    return
                }
                
                completion(preview)
            }
        }
    }
}
