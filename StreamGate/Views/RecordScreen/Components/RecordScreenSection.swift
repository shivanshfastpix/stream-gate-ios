//import SwiftUI
//
//struct RecordScreenSection: View {
//    
//    var body: some View {
//        
//        VStack(spacing: 20) {
//            
//            Text("Global Screen Recording")
//                .foregroundColor(.white)
//                .font(.title3.bold())
//            
//            ZStack {
//                
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(Color.red)
//                    .frame(width: 220, height: 60)
//                
//                Text("Start Recording")
//                    .foregroundColor(.white)
//                    .font(.headline)
//                
//                BroadcastPickerView()
//                    .frame(width: 220, height: 60)
//                    .opacity(0.02)
//            }
//        }
//    }
//}

import SwiftUI

struct RecordScreenSection: View {
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            Text("Global Screen Recording")
                .foregroundColor(.white)
                .font(.title3.bold())
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.red)
                    .frame(width: 220, height: 60)
                
                Text("Start Recording")
                    .foregroundColor(.white)
                    .font(.headline)
                
                BroadcastPickerView()
                    .frame(width: 220, height: 60)
            }
        }
    }
}
