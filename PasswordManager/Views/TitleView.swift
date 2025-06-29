import SwiftUI

struct TitleView: View {
    let namespace: Namespace.ID
    
    var body: some View {
        HStack {
            Image(systemName: "key.fill")
                .font(.title)
                .foregroundStyle(.blue)
            
            Text("Password Generator")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text("macOS 26")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .glassEffect()
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
        .glassEffectID("title", in: namespace)
    }
}
