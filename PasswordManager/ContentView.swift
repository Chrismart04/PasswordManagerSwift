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
    @State private var showingKeychain: Bool = false
    @State private var showingSaveDialog: Bool = false
    @State private var accountNameToSave: String = ""
    
    var body: some View {
        GeometryReader { geometry in
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
                
                ScrollView {
                    VStack(spacing: adaptiveSpacing(for: geometry.size.height)) {
                        TitleView(namespace: glassNamespace)
                        
                        GlassEffectContainer(spacing: 20.0) {
                            VStack(spacing: 20) {
                                
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
                                    showingKeychain: $showingKeychain,
                                    generatedPassword: generatedPassword,
                                    generatePassword: generatePassword,
                                    copyToClipboard: copyToClipboard,
                                    saveToKeychain: saveToKeychain,
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
                        
                        if showingKeychain {
                            KeychainPasswordsView(namespace: glassNamespace)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .move(edge: .bottom).combined(with: .opacity)
                                ))
                        }
                    }
                    .padding(.horizontal, adaptivePadding(for: geometry.size.width))
                    .padding(.vertical, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if copyFeedback {
                    CopyFeedbackView()
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .frame(minWidth: 400, idealWidth: 480, maxWidth: .infinity,
               minHeight: 600, idealHeight: 680, maxHeight: .infinity)
        .animation(.bouncy, value: settingsExpanded)
        .animation(.easeInOut, value: showingHistory)
        .animation(.easeInOut, value: showingKeychain)
        .animation(.easeInOut(duration: 0.3), value: copyFeedback)
        .sheet(isPresented: $showingSaveDialog) {
            SavePasswordSheet(
                password: generatedPassword,
                accountName: $accountNameToSave,
                onSave: performSaveToKeychain
            )
        }
    }
    
    // MARK: - Adaptive Sizing Functions
    private func adaptiveSpacing(for height: CGFloat) -> CGFloat {
        if height < 600 {
            return 20
        } else if height < 800 {
            return 25
        } else {
            return 30
        }
    }
    
    private func adaptivePadding(for width: CGFloat) -> CGFloat {
        if width < 450 {
            return 16
        } else if width < 600 {
            return 20
        } else {
            return 24
        }
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
    
    private func saveToKeychain() {
        guard !generatedPassword.isEmpty else { return }
        showingSaveDialog = true
    }
    
    private func performSaveToKeychain() {
        guard !accountNameToSave.isEmpty && !generatedPassword.isEmpty else { return }
        
        let success = KeychainService.shared.savePassword(generatedPassword, for: accountNameToSave)
        if success {
            // Show success feedback
            withAnimation(.easeInOut(duration: 0.2)) {
                copyFeedback = true
            }
            
            // Trigger keychain view update with notification
            NotificationCenter.default.post(name: .keychainUpdated, object: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    copyFeedback = false
                }
            }
        }
        
        accountNameToSave = ""
        showingSaveDialog = false
    }
}


struct SavePasswordSheet: View {
    let password: String
    @Binding var accountName: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Guardar en Keychain")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Nombre de la cuenta")
                    .font(.headline)
                
                TextField("Ej: Gmail, Facebook, etc.", text: $accountName)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Contraseña generada")
                    .font(.headline)
                
                Text(password)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 16) {
                Button("Cancelar") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Guardar") {
                    onSave()
                }
                .buttonStyle(.borderedProminent)
                .disabled(accountName.isEmpty)
            }
        }
        .padding()
        .frame(width: 400, height: 250)
    }
}


#Preview {
    ContentView()
}
