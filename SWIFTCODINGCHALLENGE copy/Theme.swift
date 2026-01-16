//
//  Theme.swift
//  SWIFTCODINGCHALLENGE
//
//  Created by admin67 on 12/01/26.
//
import SwiftUI

extension Font {
    static let axisTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let axisTechnical = Font.system(.caption, design: .monospaced).weight(.medium)
    static let axisInstruction = Font.custom("New York", size: 20, relativeTo: .title2)
}

struct AxisColor {
    static func semantic(for angle: Double) -> Color {
        let absoluteAngle = abs(angle)
        if absoluteAngle <= 10 { return .green }
        if absoluteAngle <= 20 { return .orange }
        return .red
    }
    
    static let backgroundGradient = RadialGradient(
        colors: [Color("1A2A3A"), .black],
        center: .center,
        startRadius: 5,
        endRadius: 700
    )
}
