import SwiftUI
import AppKit

struct ContentView: View {
    @Namespace private var glassNamespace
    @State private var passwordLength: Double = 12
    @State private var includeSpecialCharacters: Bool = true
    @State private var includeNumbers: Bool = true
    @State private var includeUppercase: Bool = true
    @State private var includeLowercase: Bool = true
    @State private var excludeSimilar: Bool = false
    @State private var generatedPassword: String = ""
    @State private var isGenerating: Bool = false
    @State private var settingsExpanded: Bool = false
    @State private var passwordHistory: [PasswordHistoryItem] = []
    @State private var showingHistory: Bool = false
    @State private var copyFeedback: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.15),
                    Color.purple.opacity(0.10),
                    Color.pink.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .backgroundExtensionEffect()
            
            VStack(spacing: 30) {
                TitleView(namespace: glassNamespace)
                
                GlassEffectContainer(spacing: 25.0) {
                    VStack(spacing: 25) {
                        
                        PasswordLengthView(
                            passwordLength: $passwordLength,
                            namespace: glassNamespace
                        )
                        
                        MainToggleView(
                            includeSpecialCharacters: $includeSpecialCharacters,
                            namespace: glassNamespace
                        )
                        
                        if settingsExpanded {
                            AdvancedSettingsView(
                                includeNumbers: $includeNumbers,
                                includeUppercase: $includeUppercase,
                                includeLowercase: $includeLowercase,
                                excludeSimilar: $excludeSimilar,
                                namespace: glassNamespace
                            )
                            .glassEffectID("advanced-settings", in: glassNamespace)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.9)),
                                removal: .opacity.combined(with: .scale(scale: 1.1))
                            ))
                        }
                        
                        PasswordDisplayView(
                            generatedPassword: generatedPassword,
                            copyFeedback: $copyFeedback,
                            namespace: glassNamespace
                        )
                        
                        ButtonsContainerView(
                            isGenerating: $isGenerating,
                            settingsExpanded: $settingsExpanded,
                            showingHistory: $showingHistory,
                            generatedPassword: generatedPassword,
                            generatePassword: generatePassword,
                            copyToClipboard: copyToClipboard,
                            namespace: glassNamespace
                        )
                    }
                }
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                
                if showingHistory && !passwordHistory.isEmpty {
                    PasswordHistoryView(
                        passwordHistory: passwordHistory,
                        namespace: glassNamespace
                    )
                    .glassEffectID("password-history", in: glassNamespace)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                }
                
                Spacer()
            }
            .padding()
            
            if copyFeedback {
                CopyFeedbackView()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.bouncy, value: settingsExpanded)
        .animation(.easeInOut, value: showingHistory)
        .animation(.easeInOut(duration: 0.3), value: copyFeedback)
    }
    
    private func generatePassword() {
        withAnimation(.bouncy(duration: 0.6)) {
            isGenerating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let newPassword = createPassword()
            generatedPassword = newPassword
            
            let historyItem = PasswordHistoryItem(
                password: newPassword,
                length: Int(passwordLength),
                timestamp: Date()
            )
            passwordHistory.insert(historyItem, at: 0)
            
            if passwordHistory.count > 10 {
                passwordHistory = Array(passwordHistory.prefix(10))
            }
            
            isGenerating = false
        }
    }
    
    private func createPassword() -> String {
        var characters = ""
        
        if includeLowercase {
            characters += excludeSimilar ? "abcdefghijkmnopqrstuvwxyz" : "abcdefghijklmnopqrstuvwxyz"
        }
        
        if includeUppercase {
            characters += excludeSimilar ? "ABCDEFGHJKLMNPQRSTUVWXYZ" : "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
        
        if includeNumbers {
            characters += excludeSimilar ? "23456789" : "0123456789"
        }
        
        if includeSpecialCharacters {
            characters += "!@#$%^&*()_+-=[]{}|;:,.<>?"
        }
        
        guard !characters.isEmpty else { return "Error: No character types selected" }
        
        return String((0..<Int(passwordLength)).map { _ in
            characters.randomElement()!
        })
    }
    
    private func copyToClipboard() {
        guard !generatedPassword.isEmpty else { return }
        
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
    }
}


#Preview {
    ContentView()
}
