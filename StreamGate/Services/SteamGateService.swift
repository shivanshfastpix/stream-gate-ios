import SwiftUI

final class StreamGateServices{
    
    // api url
    private var apiUrl: String = "https://streamgate.dev/api/uploads"
    
    
    // getting the signUrl from the streamGate backend
    
    func sendUploadRequest()async throws{
        
        // get the url
        guard let url = URL(
             string: apiUrl
         ) else {
             throw URLError(.badURL)
         }
        
        // create the request
        
        var request = URLRequest(url : url)
        
        request.httpMethod = "POST"
        
        request.setValue(
                    "application/json",
                    forHTTPHeaderField: "Content-Type"
                )

        // Example Request Body

       let body: [String: Any] = [
           "title": "My Video"
       ]

       request.httpBody = try JSONSerialization.data(
           withJSONObject: body
       )
        
        // Execute Request

           let (data, response) = try await URLSession.shared.data(
               for: request
           )
        
        // Print Status Code

           if let httpResponse = response as? HTTPURLResponse {

               print("Status Code:", httpResponse.statusCode)
           }

           // Print Raw Response

           if let responseString = String(
               data: data,
               encoding: .utf8
           ) {

               print("Response:")
               print(responseString)
           }
        
    }
    
}
