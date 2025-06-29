import SwiftUI

struct CopyFeedbackView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundStyle(.green)
                .symbolEffect(.bounce)
            
            Text("Copied to clipboard!")
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 10)
    }
}