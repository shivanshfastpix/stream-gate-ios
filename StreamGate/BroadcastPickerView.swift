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

// it is working
//
//import SwiftUI
//import ReplayKit
//
//struct BroadcastPickerView: UIViewRepresentable {
//    
//    func makeUIView(
//        context: Context
//    ) -> RPSystemBroadcastPickerView {
//        
//        let picker =
//        RPSystemBroadcastPickerView(
//            frame: CGRect(
//                x: 0,
//                y: 0,
//                width: 300,
//                height: 70
//            )
//        )
//        
//        picker.preferredExtension =
//        "com.streamgate.StreamGate.ScreenBroadcastExtension"
//        
//        picker.showsMicrophoneButton = false
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
    
    static weak var pickerView: RPSystemBroadcastPickerView?
    
    func makeUIView(
        context: Context
    ) -> RPSystemBroadcastPickerView {
        
        let picker = RPSystemBroadcastPickerView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 44,
                height: 44
            )
        )
        
        picker.preferredExtension =
        "com.streamgate.StreamGate.ScreenBroadcastExtension"
        
        picker.showsMicrophoneButton = false
        
        BroadcastPickerView.pickerView = picker
        
        return picker
    }
    
    func updateUIView(
        _ uiView: RPSystemBroadcastPickerView,
        context: Context
    ) {
    }
}

// MARK: - Trigger Helper

extension BroadcastPickerView {
    
    static func trigger() {
        
        guard let picker = pickerView else {
            return
        }
        
        guard let button = picker.subviews.first(
            where: { $0 is UIButton }
        ) as? UIButton else {
            return
        }
        
        button.sendActions(
            for: .touchUpInside
        )
    }
}
