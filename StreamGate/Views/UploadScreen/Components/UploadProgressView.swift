import SwiftUI

struct UploadProgressView: View {

    let progress: Double

    var body: some View {

        VStack(spacing: 16) {

            ProgressView(value: progress)

            Text("\(Int(progress * 100))% Uploaded")
                .foregroundStyle(.white)
        }
        .padding()
    }
}
