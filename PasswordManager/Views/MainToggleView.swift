import SwiftUI

struct MainToggleView: View {
    @Binding var includeSpecialCharacters: Bool
    let namespace: Namespace.ID
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Include Special Characters")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text("!@#$%^&*()_+-=[]{}|;:,.<>?")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .opacity(includeSpecialCharacters ? 1.0 : 0.6)
                    
            }
            
            Spacer()
            
            Toggle("", isOn: $includeSpecialCharacters)
                .toggleStyle(.switch)
                .tint(.blue)
                .scaleEffect(1.1)
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
        .glassEffectID("special-chars-toggle", in: namespace)
        .animation(.easeInOut(duration: 0.2), value: includeSpecialCharacters)
    }
}
