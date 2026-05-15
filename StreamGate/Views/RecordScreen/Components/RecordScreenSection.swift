import SwiftUI

struct RecordScreenSection:View{
    var body: some View{
        Button {
                            print("Record Screen tapped")
                        } label: {
                            
                            HStack(spacing: 14) {
                                
                                Image(systemName: "display")
                                    .font(.system(size: 28, weight: .semibold))
                                
                                Text("Record Screen")
                                    .font(.system(size: 22, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 110)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color.orange)
                            )
                        }
       
    }
}

#Preview {
    RecordCameraSection()
}
