// SimulatorDetection.swift

// Utility to detect if the target environment is a simulator.

import Foundation

enum SimulatorDetection {
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    static var isSimulatorOrSandbox: Bool {
        if isSimulator { return true }
        
        #if !targetEnvironment(simulator)
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return true
        }
        if Bundle.main.bundleIdentifier == nil {
            return true
        }
        #endif
        
        return false
    }
}
