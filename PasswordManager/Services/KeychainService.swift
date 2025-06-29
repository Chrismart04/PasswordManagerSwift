import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    private init() {}
    
    // MARK: - Save Password
    func savePassword(_ password: String, for account: String, service: String = "PasswordManager") -> Bool {
        print("🔐 Intentando guardar contraseña para cuenta: \(account)")
        let passwordData = password.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecValueData as String: passwordData
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        let success = status == errSecSuccess
        
        if success {
            print("✅ Contraseña guardada exitosamente en Keychain para: \(account)")
        } else {
            print("❌ Error al guardar contraseña. Status: \(status)")
        }
        
        return success
    }
    
    // MARK: - Retrieve Password
    func getPassword(for account: String, service: String = "PasswordManager") -> String? {
        print("🔍 Buscando contraseña para cuenta: \(account)")
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data,
               let password = String(data: data, encoding: .utf8) {
                print("✅ Contraseña encontrada para: \(account)")
                return password
            }
        }
        
        print("❌ No se encontró contraseña para: \(account). Status: \(status)")
        return nil
    }
    
    // MARK: - Delete Password
    func deletePassword(for account: String, service: String = "PasswordManager") -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    // MARK: - Get All Stored Accounts
    func getAllStoredAccounts(service: String = "PasswordManager") -> [String] {
        print("📋 Obteniendo todas las cuentas guardadas...")
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var items: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &items)
        
        if status == errSecSuccess,
           let itemsArray = items as? [[String: Any]] {
            let accounts = itemsArray.compactMap { item in
                item[kSecAttrAccount as String] as? String
            }
            print("✅ Encontradas \(accounts.count) cuentas: \(accounts)")
            return accounts
        }
        
        print("❌ No se encontraron cuentas. Status: \(status)")
        return []
    }
    
    // MARK: - Update Password
    func updatePassword(_ newPassword: String, for account: String, service: String = "PasswordManager") -> Bool {
        let passwordData = newPassword.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: passwordData
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        return status == errSecSuccess
    }
}
