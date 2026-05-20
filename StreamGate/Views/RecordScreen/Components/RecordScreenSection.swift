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

/// it is working
//import SwiftUI
//
//struct RecordScreenSection: View {
//    
//    var body: some View {
//        
//        HStack(spacing: 14) {
//            
//            BroadcastPickerView()
//                .frame(width: 44, height: 44)
//            
//            Text("Start Recording")
//                .foregroundColor(.white)
//                .font(.headline)
//            
//            Spacer()
//        }
//        .padding(.horizontal, 20)
//        .frame(width: 300, height: 70)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(Color.red)
//        )
//    }
//}

import SwiftUI

struct RecordScreenSection: View {
    
    var body: some View {
        
        HStack(spacing: 14) {
            
            BroadcastPickerView()
                .frame(width: 44, height: 44)
            
            
            Text("Screen Recording")
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold))
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(width: 300, height: 70)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.red)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            BroadcastPickerView.trigger()
        }
    }
}

#Preview {
    RecordScreenSection()
}
