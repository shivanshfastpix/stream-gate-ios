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
                            .frame(maxWidth: 300)
                            .frame(height: 70)
                            .background(
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(Color.orange)
                            )
                        }
       
    }
}

#Preview {
    RecordScreenSection()
}
