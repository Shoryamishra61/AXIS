import SwiftUI
import Vision
import AVFoundation

struct CameraView: View {
    // 1. Connect to the System Brain
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // 1. HARDWARE LOGIC SWITCH
            #if targetEnvironment(simulator)
            SimulatorCameraView() // Safe Fallback
            #else
            VisionCameraRepresentable() // The Real Engine
            #endif
            
            // 2. SHARED UI OVERLAY
            VStack {
                HStack {
                    // THE FIX IS HERE: The "X" Button
                    Button {
                        // Tell Coordinator to kill the camera state and return Home
                        coordinator.returnHome()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .shadow(radius: 4)
                    }
                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
    }
}

// MARK: - 1. SIMULATOR MOCK VIEW (What YOU see)
struct SimulatorCameraView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "face.smiling")
                .resizable()
                .scaledToFit()
                .frame(width: 150)
                .foregroundStyle(.gray)
                .opacity(0.5)
            
            Text("Simulator Mode Active")
                .font(.headline)
                .foregroundStyle(.white)
            
            Text("On a real device, this screen uses the Vision Framework to detect head tilt via the front camera.")
                .font(.caption)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// MARK: - 2. REAL DEVICE VISION ENGINE (What JUDGES see)
#if !targetEnvironment(simulator)
struct VisionCameraRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // Vision Request
    private let bodyPoseRequest = VNDetectHumanBodyPoseRequest()
    private var overlayLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupOverlay()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        overlayLayer.frame = view.bounds
    }
    
    private func setupOverlay() {
        overlayLayer.strokeColor = UIColor.green.cgColor
        overlayLayer.lineWidth = 3.0
        overlayLayer.fillColor = UIColor.clear.cgColor
        overlayLayer.lineCap = .round
        view.layer.addSublayer(overlayLayer)
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        captureSession.sessionPreset = .high
        if captureSession.canAddInput(input) { captureSession.addInput(input) }
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) { captureSession.addOutput(videoOutput) }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        if let layer = previewLayer { view.layer.addSublayer(layer) }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])
        
        do {
            try handler.perform([bodyPoseRequest])
            guard let observation = bodyPoseRequest.results?.first else {
                DispatchQueue.main.async { self.overlayLayer.path = nil }
                return
            }
            DispatchQueue.main.async { self.drawSkeleton(observation) }
        } catch {
            print("Vision Error: \(error)")
        }
    }
    
    private func drawSkeleton(_ observation: VNHumanBodyPoseObservation) {
        let path = UIBezierPath()
        let points: [VNHumanBodyPoseObservation.JointName] = [.leftEar, .rightEar, .leftShoulder, .rightShoulder]
        var screenPoints: [CGPoint] = []
        
        for joint in points {
            if let recognizedPoint = try? observation.recognizedPoint(joint), recognizedPoint.confidence > 0.3 {
                let normalizedPoint = CGPoint(x: recognizedPoint.location.x, y: 1 - recognizedPoint.location.y)
                let screenPoint = previewLayer?.layerPointConverted(fromCaptureDevicePoint: normalizedPoint) ?? .zero
                screenPoints.append(screenPoint)
            } else {
                screenPoints.append(.zero)
            }
        }
        
        if screenPoints[0] != .zero && screenPoints[1] != .zero {
            path.move(to: screenPoints[0])
            path.addLine(to: screenPoints[1])
        }
        if screenPoints[2] != .zero && screenPoints[3] != .zero {
            path.move(to: screenPoints[2])
            path.addLine(to: screenPoints[3])
        }
        overlayLayer.path = path.cgPath
    }
}
#endif
