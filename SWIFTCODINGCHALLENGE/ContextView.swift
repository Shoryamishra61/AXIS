import SwiftUI

struct ContextView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedPosition = "Sitting"
    @State private var selectedDuration = 2.0
    
    // This will trigger the actual session later
    @State private var isSessionActive = false
    
    let positions = ["Sitting", "Standing", "Lying Down"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // 1. Position Selector
                VStack(alignment: .leading) {
                    Text("Position")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Picker("Position", selection: $selectedPosition) {
                        ForEach(positions, id: \.self) { position in
                            Text(position).tag(position)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // 2. Duration Selector
                VStack(alignment: .leading) {
                    HStack {
                        Text("Duration")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(selectedDuration)) min")
                            .bold()
                    }
                    
                    Slider(value: $selectedDuration, in: 2...5, step: 1)
                }
                
                Spacer()
                
                // 3. Start Action
                Button {
                    isSessionActive = true
                } label: {
                    Text("Begin Movement")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .navigationTitle("Setup Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            // Logic placeholder for the next phase
            .fullScreenCover(isPresented: $isSessionActive) {
                Text("Phase 4: Session View goes here")
            }
        }
    }
}
