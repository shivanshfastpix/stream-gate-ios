import SwiftUI

struct RecordView: View{
    var body:some View{
        
        if #available(iOS 16.0, *) {
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
        } else {
            // Fallback on earlier versions
        }
       
       
      
    }
    
}


#Preview {
    RecordView()
}
