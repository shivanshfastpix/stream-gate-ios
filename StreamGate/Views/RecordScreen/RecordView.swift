import SwiftUI

struct RecordView: View{
    var body:some View{
        
        NavigationStack{
            
            ZStack{
                
                Color.black.ignoresSafeArea()
                ScrollView(showsIndicators: false)
                {
                    VStack(spacing: 60){
                        // Header section
                        HeaderRecordSection()
                        
                        VStack(spacing: 25){
                            // Record screen
                            RecordCameraSection()
                            
                            // Record Camera
                            RecordScreenSection()
                            
                        }
                        
                        
                    }
                    
                }
                
            }
        }
       
       
      
    }
    
}


#Preview {
    RecordView()
}
