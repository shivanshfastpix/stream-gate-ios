import SwiftUI

struct RecordCameraSection:View {
    var body: some View {
        VStack{
            Button{
                print("Screen Recording tapped")
            } label:{
                HStack(spacing: 14) {
                                        
                                        Image(systemName: "video")
                                            .font(.system(size: 28, weight: .semibold))
                                        
                                        Text("Record Camera")
                                            .font(.system(size: 22, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 110)
                                    .background(
                                        RoundedRectangle(cornerRadius: 28)
                                            .fill(Color(.systemGray6).opacity(0.12))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                                    )
                                }
            
        }
        }
    }


#Preview{
    RecordScreenSection()
}

