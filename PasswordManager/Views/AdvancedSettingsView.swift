import SwiftUI

struct AdvancedSettingsView: View {
    @Binding var includeNumbers: Bool
    @Binding var includeUppercase: Bool
    @Binding var includeLowercase: Bool
    @Binding var excludeSimilar: Bool
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "gearshape.fill")
                    .foregroundStyle(.blue)
                
                Text("Advanced Options")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                
                AdvancedToggleView(
                    title: "Numbers",
                    subtitle: "0-9",
                    isOn: $includeNumbers,
                    icon: "textformat.123",
                    color: .green,
                    namespace: namespace,
                    id: "numbers-toggle"
                )
                
                AdvancedToggleView(
                    title: "Uppercase",
                    subtitle: "A-Z",
                    isOn: $includeUppercase,
                    icon: "textformat.abc",
                    color: .orange,
                    namespace: namespace,
                    id: "uppercase-toggle"
                )
                
                AdvancedToggleView(
                    title: "Lowercase",
                    subtitle: "a-z",
                    isOn: $includeLowercase,
                    icon: "textformat.abc.dottedunderline",
                    color: .purple,
                    namespace: namespace,
                    id: "lowercase-toggle"
                )
                
                AdvancedToggleView(
                    title: "Exclude Similar",
                    subtitle: "0,O,1,l,I",
                    isOn: $excludeSimilar,
                    icon: "eye.slash",
                    color: .red,
                    namespace: namespace,
                    id: "exclude-toggle"
                )
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
}

struct AdvancedToggleView: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let icon: String
    let color: Color
    let namespace: Namespace.ID
    let id: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(isOn ? color : .secondary)
                .symbolEffect(.bounce, value: isOn)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .tint(color)
                .scaleEffect(0.8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
        .glassEffectID(id, in: namespace)
        .opacity(isOn ? 1.0 : 0.7)
        .animation(.easeInOut(duration: 0.2), value: isOn)
        .help(title)
    }
}