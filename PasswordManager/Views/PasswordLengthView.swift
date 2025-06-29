import SwiftUI

struct PasswordLengthView: View {
    @Binding var passwordLength: Double
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Password Length")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(Int(passwordLength))")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .monospacedDigit()
            }
            
            Slider(value: $passwordLength, in: 4...50, step: 1) {
                Text("Password Length")
            } minimumValueLabel: {
                Text("4")
                    .font(.caption)
            } maximumValueLabel: {
                Text("50")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .tint(.blue)
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
        .glassEffectID("length-slider", in: namespace)
    }
}
