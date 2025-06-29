import SwiftUI
import AppKit

struct PasswordDisplayView: View {
    let generatedPassword: String
    @Binding var copyFeedback: Bool
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Generated Password")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if !generatedPassword.isEmpty {
                    Text("\(generatedPassword.count) chars")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .glassEffect(.regular, in: .capsule)
                }
            }
            
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(generatedPassword.isEmpty ? "No password generated yet" : generatedPassword)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundStyle(generatedPassword.isEmpty ? .secondary : .primary)
                        .textSelection(.enabled)
                        .padding(.horizontal, 4)
                }
                .frame(minHeight: 60)
                
                if !generatedPassword.isEmpty {
                    VStack(spacing: 8) {
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(generatedPassword, forType: .string)
                            
                            withAnimation(.easeInOut(duration: 0.2)) {
                                copyFeedback = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    copyFeedback = false
                                }
                            }
                        }) {
                            Image(systemName: copyFeedback ? "checkmark" : "doc.on.doc")
                                .foregroundStyle(copyFeedback ? .green : .blue)
                                .symbolEffect(.bounce, value: copyFeedback)
                        }
                        .buttonStyle(.borderless)
                        .help("Copy to clipboard")
                        
                        Button(action: {
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(.orange)
                        }
                        .buttonStyle(.borderless)
                        .help("Regenerate")
                    }
                }
            }
            .padding()
            .glassEffect(.regular, in: .rect(cornerRadius: 12))
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
        .glassEffectID("password-display", in: namespace)
    }
}