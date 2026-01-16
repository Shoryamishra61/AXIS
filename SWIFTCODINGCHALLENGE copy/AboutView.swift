import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Why Axis Exists")
                    .font(.headline)
                
                Text("Prolonged sedentary work causes stiffness and 'tech neck.' Axis was built to solve this without requiring gym equipment or public embarrassment.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                
                Divider()
                
                Text("Privacy First")
                    .font(.headline)
                
                Text("• Camera used only for snapshots.\n• Motion data processed on-device.\n• No tracking or history.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("About Axis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
