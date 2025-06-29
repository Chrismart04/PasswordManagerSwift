import SwiftUI

struct MenuBarContentView: View {
    @State private var passwordLength: Double = 12
    @State private var includeSpecialCharacters: Bool = true
    @State private var includeNumbers: Bool = true
    @State private var includeUppercase: Bool = true
    @State private var includeLowercase: Bool = true
    @State private var generatedPassword: String = ""
    @State private var storedPasswords: [StoredPasswordItem] = []
    @State private var showingPasswords: Bool = false
    @State private var copyFeedback: Bool = false
    @State private var showingSaveDialog: Bool = false
    @State private var accountNameToSave: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "key.fill")
                    .foregroundStyle(.blue)
                    .font(.title2)
                
                Text("Password Manager")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Password Length Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Longitud")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(Int(passwordLength))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }
                
                Slider(value: $passwordLength, in: 6...50, step: 1)
                    .tint(.blue)
            }
            .padding(.horizontal)
            
            // Options
            VStack(spacing: 8) {
                Toggle("Caracteres especiales", isOn: $includeSpecialCharacters)
                Toggle("Números", isOn: $includeNumbers)
                Toggle("Mayúsculas", isOn: $includeUppercase)
                Toggle("Minúsculas", isOn: $includeLowercase)
            }
            .font(.caption)
            .padding(.horizontal)
            
            // Generated Password Display
            if !generatedPassword.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contraseña generada:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Text(generatedPassword)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .padding(8)
                            .background(.ultraThinMaterial, in: .rect(cornerRadius: 6))
                            .lineLimit(3)
                        
                        VStack(spacing: 4) {
                            Button(action: copyPassword) {
                                Image(systemName: "doc.on.doc.fill")
                                    .font(.caption)
                            }
                            .buttonStyle(.borderless)
                            .foregroundStyle(.blue)
                            
                            Button(action: { showingSaveDialog = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.caption)
                            }
                            .buttonStyle(.borderless)
                            .foregroundStyle(.green)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Generate Button
            Button(action: generatePassword) {
                HStack {
                    Image(systemName: "key.radiowaves.forward.fill")
                    Text("Generar")
                        .fontWeight(.medium)
                }
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.blue, in: .rect(cornerRadius: 8))
            }
            .buttonStyle(.borderless)
            
            Divider()
            
            // Stored Passwords Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Contraseñas guardadas")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button(action: {
                        showingPasswords.toggle()
                        if showingPasswords {
                            loadStoredPasswords()
                        }
                    }) {
                        Image(systemName: showingPasswords ? "chevron.up" : "chevron.down")
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                }
                
                if showingPasswords {
                    if storedPasswords.isEmpty {
                        Text("No hay contraseñas guardadas")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 4) {
                                ForEach(storedPasswords.prefix(5)) { item in
                                    MenuBarPasswordRow(
                                        item: item,
                                        onCopy: { copyStoredPassword(for: item) }
                                    )
                                }
                            }
                        }
                        .frame(maxHeight: 120)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Footer with main app button
            Button("Abrir App Principal") {
                openMainApp()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .buttonStyle(.borderless)
            .padding(.bottom)
        }
        .frame(width: 350, height: 500)
        .background(.regularMaterial)
        .onAppear {
            loadStoredPasswords()
        }
        .sheet(isPresented: $showingSaveDialog) {
            MenuBarSaveSheet(
                password: generatedPassword,
                accountName: $accountNameToSave,
                onSave: saveToKeychain
            )
        }
        .overlay(
            Group {
                if copyFeedback {
                    Text("¡Copiado!")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue, in: .capsule)
                        .foregroundStyle(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
        .animation(.easeInOut(duration: 0.2), value: copyFeedback)
    }
    
    // MARK: - Functions
    private func generatePassword() {
        var characters = ""
        
        if includeLowercase {
            characters += "abcdefghijklmnopqrstuvwxyz"
        }
        
        if includeUppercase {
            characters += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
        
        if includeNumbers {
            characters += "0123456789"
        }
        
        if includeSpecialCharacters {
            characters += "!@#$%^&*()_+-=[]{}|;:,.<>?"
        }
        
        guard !characters.isEmpty else { 
            generatedPassword = "Error: No character types selected"
            return 
        }
        
        generatedPassword = String((0..<Int(passwordLength)).map { _ in
            characters.randomElement()!
        })
    }
    
    private func copyPassword() {
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
    
    private func copyStoredPassword(for item: StoredPasswordItem) {
        if let password = KeychainService.shared.getPassword(for: item.account) {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(password, forType: .string)
            
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
    
    private func saveToKeychain() {
        guard !accountNameToSave.isEmpty && !generatedPassword.isEmpty else { return }
        
        let success = KeychainService.shared.savePassword(generatedPassword, for: accountNameToSave)
        if success {
            loadStoredPasswords()
            accountNameToSave = ""
            showingSaveDialog = false
            
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
    
    private func loadStoredPasswords() {
        let accounts = KeychainService.shared.getAllStoredAccounts()
        storedPasswords = accounts.map { account in
            StoredPasswordItem(account: account)
        }
    }
    
    private func openMainApp() {
        NSApp.activate(ignoringOtherApps: true)
        // Aquí podrías mostrar la ventana principal si está oculta
    }
}

struct MenuBarPasswordRow: View {
    let item: StoredPasswordItem
    let onCopy: () -> Void
    
    var body: some View {
        HStack {
            Text(item.account)
                .font(.caption)
                .lineLimit(1)
            
            Spacer()
            
            Button(action: onCopy) {
                Image(systemName: "doc.on.doc.fill")
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 4))
    }
}

struct MenuBarSaveSheet: View {
    let password: String
    @Binding var accountName: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Guardar contraseña")
                .font(.headline)
            
            TextField("Nombre de la cuenta", text: $accountName)
                .textFieldStyle(.roundedBorder)
            
            HStack {
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
        .frame(width: 250, height: 120)
    }
}