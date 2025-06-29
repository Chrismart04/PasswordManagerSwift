import SwiftUI
import AppKit

struct PasswordHistoryView: View {
    let passwordHistory: [PasswordHistoryItem]
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "clock")
                    .foregroundStyle(.purple)
                
                Text("Recent Passwords")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(passwordHistory.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .glassEffect(.regular, in: .capsule)
            }
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(passwordHistory) { item in
                        PasswordHistoryRow(item: item)
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
}

struct PasswordHistoryRow: View {
    let item: PasswordHistoryItem
    @State private var isRevealed: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(isRevealed ? item.password : String(repeating: "•", count: item.length))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.primary)
                
                Text("\(item.length) chars • \(item.timeAgo)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(isRevealed ? "Hide" : "Show") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isRevealed.toggle()
                    }
                }
                .buttonStyle(.borderless)
                .font(.caption)
                .help(isRevealed ? "Hide password" : "Show password")
                
                Button("Copy") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(item.password, forType: .string)
                }
                .buttonStyle(.borderless)
                .font(.caption)
                .help("Copy this password")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassEffect(.regular, in: .rect(cornerRadius: 8))
    }
}
