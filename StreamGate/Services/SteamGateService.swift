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
        
        // print("returned response : \(response)")
        
        // Print Status Code
        
        guard let httpResponse = response as? HTTPURLResponse else{
            throw URLError(.badServerResponse)
        }
        
            guard (200...299).contains(httpResponse.statusCode) else {

                let errorResponse = String(
                    data: data,
                    encoding: .utf8
                )

                print("API Error:", errorResponse ?? "")

                throw URLError(.badServerResponse)
            }

           // Print Raw Response

//           if let responseString = String(
//               data: data,
//               encoding: .utf8
//           ) {
//
//               print("Response:")
//               print(responseString)
//           }
        
        let decodedSessionResponse = try JSONDecoder().decode( UploadResponse.self, from: data)
        print("response id : \(decodedSessionResponse.uploadId)")
        print("response session url : \(decodedSessionResponse.url)")
        
        let sessionUrl = decodedSessionResponse.url
        
        /// send request for signed url
       let signedUrl = try await getSignedUrl(sessionURL:sessionUrl);
        print("signed url is : \(signedUrl)")
        
        
    }
    
    func getSignedUrl(
        sessionURL: String
    ) async throws -> String {

        guard let url = URL(string: sessionURL) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue(
            "start",
            forHTTPHeaderField: "x-goog-resumable"
        )

        request.setValue(
            "application/octet-stream",
            forHTTPHeaderField: "Content-Type"
        )

        let (_, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard let uploadURL = httpResponse.value(
            forHTTPHeaderField: "Location"
        ) else {
            throw URLError(.badServerResponse)
        }
        return uploadURL
    }
    
}
