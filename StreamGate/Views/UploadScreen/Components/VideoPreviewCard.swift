import SwiftUI
struct VideoPreviewCard: View {

    let playbackURL: String

    var body: some View {

        VStack(spacing: 20) {

            Text("Upload Complete")
                .font(.title2)
                .foregroundStyle(.white)

            Text(playbackURL)
                .foregroundStyle(.blue)
                .multilineTextAlignment(.center)

            Button("Copy Link") {

                UIPasteboard.general.string = playbackURL
            }
            .padding()
            .background(Color.orange)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding()
    }
}
