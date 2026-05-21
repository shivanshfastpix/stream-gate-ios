
import SwiftUI

struct RecordScreenSection: View {
    let onTap: () -> Void
    
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
            onTap()
            BroadcastPickerView.trigger()
        }
    }
}

#Preview {
    RecordScreenSection(){
        
    }
}
