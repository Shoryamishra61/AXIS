import CoreMotion

class ActivityManager: ObservableObject {
    private let activityManager = CMMotionActivityManager()
    @Published var detectedContext: String = "Sitting"
    
    init() {
        startActivityUpdates()
    }
    
    func startActivityUpdates() {
        if CMMotionActivityManager.isActivityAvailable() {
            activityManager.startActivityUpdates(to: .main) { [weak self] activity in
                guard let self = self, let activity = activity else { return }
                
                if activity.walking || activity.running {
                    self.detectedContext = "Standing"
                } else if activity.stationary {
                    self.detectedContext = "Sitting"
                }
                // Lying down is inferred via device orientation in MotionManager
            }
        }
    }
}