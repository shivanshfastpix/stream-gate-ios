
import SwiftUI

struct ContentView: View {
    
    var body: some View {
        if #available(iOS 16.0, *) {
            UploadView()
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    ContentView()
        .frame(minWidth: 1200, minHeight: 1000)
}
