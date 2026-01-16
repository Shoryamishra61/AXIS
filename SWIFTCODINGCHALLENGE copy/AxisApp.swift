//
//  AxisApp.swift
//  SWIFTCODINGCHALLENGE
//
//  Created by admin67 on 12/01/26.
//


import SwiftUI

@main
struct AxisApp: App {
    // Single Source of Truth
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(coordinator)
                .preferredColorScheme(.dark) // Liquid Glass requirement
                .onAppear {
                    // Pre-warm the sensors for Zero-Context ready-state
                    MotionManager.shared.startUpdates()
                }
        }
    }
}