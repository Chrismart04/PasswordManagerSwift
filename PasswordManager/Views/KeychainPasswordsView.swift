import SwiftUI

struct KeychainPasswordsView: View {
    @State private var storedPasswords: [StoredPasswordItem] = []
    @State private var showingAddPassword = false
    @State private var newAccountName = ""
    @State private var newPassword = ""
    @State private var copyFeedback = false
    
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Contraseñas Guardadas")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button(action: {
                    showingAddPassword = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
            
            if storedPasswords.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    
                    Text("No hay contraseñas guardadas")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text("Guarda contraseñas generadas para acceder fácilmente")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(storedPasswords) { item in
                            KeychainPasswordRow(
                                item: item,
                                onCopy: { copyPassword(for: item) },
                                onDelete: { deletePassword(item) }
                            )
                        }
                    }
                }
                .frame(maxHeight: 300)
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
        .glassEffectID("keychain-passwords", in: namespace)
        .onAppear {
            loadStoredPasswords()
        }
        .onReceive(NotificationCenter.default.publisher(for: .keychainUpdated)) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                loadStoredPasswords()
            }
        }
        .sheet(isPresented: $showingAddPassword) {
            AddPasswordSheet(
                accountName: $newAccountName,
                password: $newPassword,
                onSave: saveNewPassword
            )
        }
        .overlay(
            Group {
                if copyFeedback {
                    Text("¡Copiado!")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue, in: .capsule)
                        .foregroundStyle(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
        .animation(.easeInOut(duration: 0.2), value: copyFeedback)
    }
    
    // MARK: - Keychain Operations
    private func loadStoredPasswords() {
        let accounts = KeychainService.shared.getAllStoredAccounts()
        storedPasswords = accounts.map { account in
            StoredPasswordItem(account: account)
        }
    }
    
    private func saveNewPassword() {
        guard !newAccountName.isEmpty && !newPassword.isEmpty else { return }
        
        let success = KeychainService.shared.savePassword(newPassword, for: newAccountName)
        if success {
            // Notificar que se actualizó el keychain
            NotificationCenter.default.post(name: .keychainUpdated, object: nil)
            
            newAccountName = ""
            newPassword = ""
            showingAddPassword = false
        }
    }
    
    private func copyPassword(for item: StoredPasswordItem) {
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
    
    private func deletePassword(_ item: StoredPasswordItem) {
        let success = KeychainService.shared.deletePassword(for: item.account)
        if success {
            NotificationCenter.default.post(name: .keychainUpdated, object: nil)
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let keychainUpdated = Notification.Name("keychainUpdated")
}

struct KeychainPasswordRow: View {
    let item: StoredPasswordItem
    let onCopy: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.account)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text("Guardado \(item.timeAgo)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: onCopy) {
                    Image(systemName: "doc.on.doc.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                
                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }
}

struct AddPasswordSheet: View {
    @Binding var accountName: String
    @Binding var password: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Guardar Nueva Contraseña")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nombre de la cuenta")
                        .font(.headline)
                    
                    TextField("Ej: Gmail, Facebook, etc.", text: $accountName)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contraseña")
                        .font(.headline)
                    
                    SecureField("Contraseña", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
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
                .disabled(accountName.isEmpty || password.isEmpty)
            }
        }
        .padding()
        .frame(width: 400, height: 250)
    }
}
