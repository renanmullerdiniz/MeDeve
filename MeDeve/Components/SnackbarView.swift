import SwiftUI

struct SnackbarView: View {

    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Text(message)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(
            Capsule()
                .fill(Color(red: 0.18, green: 0.72, blue: 0.38))
                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 4)
        )
    }
}
