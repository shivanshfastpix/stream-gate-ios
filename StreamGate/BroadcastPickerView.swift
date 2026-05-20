//import SwiftUI
//import ReplayKit
//
//struct BroadcastPickerView:
//UIViewRepresentable {
//    
//    func makeUIView(context: Context)
//    -> RPSystemBroadcastPickerView {
//        
//        let picker =
//        RPSystemBroadcastPickerView()
//        
//        picker.preferredExtension =
//        "com.streamgate.StreamGate.ScreenBroadcastExtension"
//        
//        picker.showsMicrophoneButton = true
//        
//        return picker
//    }
//    
//    func updateUIView(
//        _ uiView:
//        RPSystemBroadcastPickerView,
//        context: Context
//    ) {
//    }
//}

import SwiftUI
import ReplayKit

struct BroadcastPickerView: UIViewRepresentable {
    
    func makeUIView(
        context: Context
    ) -> RPSystemBroadcastPickerView {
        
        let picker =
        RPSystemBroadcastPickerView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 220,
                height: 60
            )
        )
        
        picker.preferredExtension =
        "com.streamgate.StreamGate.ScreenBroadcastExtension"
        
        picker.showsMicrophoneButton = false
        
        return picker
    }
    
    func updateUIView(
        _ uiView:
        RPSystemBroadcastPickerView,
        context: Context
    ) {
    }
}
