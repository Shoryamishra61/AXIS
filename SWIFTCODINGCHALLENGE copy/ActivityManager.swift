//
//  ActivityManager.swift
//  SWIFTCODINGCHALLENGE
//
//  Created by admin67 on 12/01/26.
//


import CoreMotion
import Combine
import Foundation
import CoreMotion

class ActivityManager: ObservableObject {
    private let activityManager = CMMotionActivityManager()
    @Published var detectedContext: String = "Sitting"
    
    func startActivityDetection() {
        if CMMotionActivityManager.isActivityAvailable() {
            activityManager.startActivityUpdates(to: .main) { [weak self] activity in
                guard let self = self, let activity = activity else { return }
                
                if activity.walking || activity.running {
                    self.detectedContext = "Standing"
                } else if activity.stationary {
                    self.detectedContext = "Sitting"
                }
            }
        }
    }
    
    func stopActivityDetection() {
        activityManager.stopActivityUpdates()
    }
}
