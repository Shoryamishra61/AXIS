import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            AxisColor.backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundStyle(.teal)
                
                Text("Session Complete")
                    .font(.axisTitle)
                
                VStack(spacing: 20) {
                    SummaryRow(label: "Alignment Accuracy", value: "94%")
                    SummaryRow(label: "Time in Target", value: "02:15")
                }
                .padding(30)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30))
                .padding(.horizontal)
                
                Spacer()
                
                Button("Done") { coordinator.returnHome() }
                    .font(.axisTechnical)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white, in: Capsule())
                    .foregroundStyle(.black)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
        }
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label).font(.axisInstruction).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.axisTechnical).foregroundStyle(.teal)
        }
    }
}
