import SwiftUI

struct ButtonsContainerView: View {
    @Binding var isGenerating: Bool
    @Binding var settingsExpanded: Bool
    @Binding var showingHistory: Bool
    @Binding var showingKeychain: Bool
    let generatedPassword: String
    let generatePassword: () -> Void
    let copyToClipboard: () -> Void
    let saveToKeychain: () -> Void
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 15) {
            Button(action: generatePassword) {
                HStack {
                    Image(systemName: isGenerating ? "key.radiowaves.forward.fill" : "key.fill")
                        .symbolEffect(.bounce, value: isGenerating)
                    Text("Generate Password")
                        .fontWeight(.semibold)
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
            .tint(.blue)
            .glassEffectID("generate-button", in: namespace)
            .scaleEffect(isGenerating ? 1.02 : 1.0)
            .help("Generate a new password (⏎)")
            
            HStack(spacing: 15) {
                Button(action: copyToClipboard) {
                    HStack {
                        Image(systemName: "doc.on.doc.fill")
                        Text("Copy")
                    }
                    .font(.headline)
                    .foregroundStyle(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
                .glassEffectID("copy-button", in: namespace)
                .disabled(generatedPassword.isEmpty)
                .keyboardShortcut("c", modifiers: .command)
                .help("Copy password to clipboard (⌘C)")
                
                Button(action: saveToKeychain) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                        Text("Save")
                    }
                    .font(.headline)
                    .foregroundStyle(.green)
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
                .glassEffectID("save-button", in: namespace)
                .disabled(generatedPassword.isEmpty)
                .keyboardShortcut("s", modifiers: .command)
                .help("Save password to Keychain (⌘S)")
            }
            
            HStack(spacing: 15) {
                Button(action: {
                    withAnimation(.bouncy) {
                        settingsExpanded.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: settingsExpanded ? "gearshape.fill" : "gearshape")
                            .symbolEffect(.rotate, value: settingsExpanded)
                        Text("Settings")
                    }
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
                .glassEffectID("settings-button", in: namespace)
                .keyboardShortcut(",", modifiers: .command)
                .help("Toggle advanced settings (⌘,)")
                
                Button(action: {
                    withAnimation(.easeInOut) {
                        showingHistory.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "clock")
                        Text("History")
                    }
                    .font(.headline)
                    .foregroundStyle(.purple)
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
                .glassEffectID("history-button", in: namespace)
                .keyboardShortcut("h", modifiers: .command)
                .help("Show password history (⌘H)")
                
                Button(action: {
                    withAnimation(.easeInOut) {
                        showingKeychain.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "key.viewfinder")
                        Text("Keychain")
                    }
                    .font(.headline)
                    .foregroundStyle(.orange)
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
                .glassEffectID("keychain-button", in: namespace)
                .keyboardShortcut("k", modifiers: .command)
                .help("Show saved passwords (⌘K)")
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
        .glassEffectID("buttons-container", in: namespace)
    }
}
