import Foundation

struct PasswordHistoryItem: Identifiable, Hashable {
    let id = UUID()
    let password: String
    let length: Int
    let timestamp: Date
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}