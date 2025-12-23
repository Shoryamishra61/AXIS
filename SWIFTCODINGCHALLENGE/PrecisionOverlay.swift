import SwiftUI

struct PrecisionOverlay: View {
    var pitch: Double
    var yaw: Double
    
    var body: some View {
        ZStack {
            // Target Rings
            ForEach([10, 20, 30], id: \.self) { angle in
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [2, 5]))
                    .foregroundStyle(.white.opacity(0.1))
                    .frame(width: CGFloat(angle * 10), height: CGFloat(angle * 10))
            }
            
            // Numeric Precision Display
            VStack {
                Spacer()
                HStack(spacing: 30) {
                    metricItem(label: "PITCH", value: pitch)
                    metricItem(label: "YAW", value: yaw)
                }
                .padding(.bottom, 100)
            }
        }
    }
    
    func metricItem(label: String, value: Double) -> some View {
        VStack(alignment: .leading) {
            Text(label).font(.axisTechnical).foregroundStyle(.secondary)
            Text("\(Int(value))°")
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .foregroundStyle(AxisColor.semantic(for: value))
        }
    }
}