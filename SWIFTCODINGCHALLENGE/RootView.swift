import SwiftUI

struct RootView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            // Background is global to prevent white flashes during transitions
            Color(hex: "1A2A3A").ignoresSafeArea()
            
            // The Switchboard
            switch coordinator.appState {
            case .idle:
                ContentView() // Your polished Home Screen
                    .transition(.opacity)
                
            case .setup:
                ContextView() // Your polished Setup Screen
                    .transition(.move(edge: .bottom))
                
            case .alignmentCheck:
                CameraView() // Your Green-Line Camera
                    .transition(.opacity)
                
            case .sessionRunning:
                SessionView(
                    selectedPosture: coordinator.selectedPosture,
                    selectedDuration: coordinator.selectedDuration
                )
                .transition(.opacity)
                
            case .summary:
                SummaryView() // We need to build this simple screen
                    .transition(.scale)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: coordinator.appState)
    }
}
