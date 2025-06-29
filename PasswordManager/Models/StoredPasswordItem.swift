import Foundation

struct StoredPasswordItem: Identifiable, Hashable {
    let id = UUID()
    let account: String
    let service: String
    let dateCreated: Date
    let dateModified: Date
    
    init(account: String, service: String = "PasswordManager") {
        self.account = account
        self.service = service
        self.dateCreated = Date()
        self.dateModified = Date()
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: dateModified, relativeTo: Date())
    }
}