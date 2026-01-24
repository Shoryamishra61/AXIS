// CameraView.swift
// Axis - The Invisible Posture Companion
// Alignment Mirror with Body Pose Detection for Swift Student Challenge 2026

// NOTE: NSCameraUsageDescription must be present in Info.plist for camera access permission.

import SwiftUI
import AVFoundation
import Vision
import Combine

struct CameraView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var cameraController = CameraController()
    
    @State private var showPoseOverlay = true
    @State private var alignmentScore: Double = 0.0
    @State private var feedbackMessage = "Checking alignment..."
    
    var body: some View {
        ZStack {
            // Camera preview or permission prompt
            Group {
                if cameraController.authorized {
                    CameraPreviewLayer(session: cameraController.session)
                        .ignoresSafeArea()
                } else {
                    VStack(spacing: 12) {
                        Text("Camera access is required to show the alignment mirror.")
                            .font(.axisInstruction)
                            .foregroundStyle(.secondary)
                        Text("Enable it in Settings > Privacy > Camera")
                            .font(.axisCaption)
                            .foregroundStyle(.tertiary)
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            
            // Pose overlay
            if showPoseOverlay, let pose = cameraController.detectedPose {
                PoseOverlayView(pose: pose)
                    .ignoresSafeArea()
            }
            
            // Alignment guide lines
            alignmentGuides
            
            // UI Overlay
            VStack {
                // Header
                headerBar
                
                Spacer()
                
                // Feedback card
                feedbackCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            if cameraController.authorized { cameraController.startSession() }
        }
        .onChange(of: cameraController.authorized) { isAuthorized in
            if isAuthorized { cameraController.startSession() } else { cameraController.stopSession() }
        }
        .onDisappear {
            cameraController.stopSession()
        }
        .onChange(of: cameraController.detectedPose) { _ in
            updateAlignmentFeedback()
        }
    }
    
    // MARK: - Header Bar
    
    private var headerBar: some View {
        HStack {
            // Close button
            Button {
                coordinator.returnHome()
                AxisHaptic.tick()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
            
            Spacer()
            
            // Title
            Text("Alignment Mirror")
                .font(.axisButton)
                .foregroundStyle(.white)
            
            Spacer()
            
            // Toggle pose lines
            Button {
                showPoseOverlay.toggle()
                AxisHaptic.tick()
            } label: {
                Image(systemName: showPoseOverlay ? "figure.stand" : "figure.stand.line.dotted.figure.stand")
                    .foregroundStyle(showPoseOverlay ? AxisColor.primary : .white.opacity(0.7))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
        .padding(.horizontal)
        .padding(.top, 60)
    }
    
    // MARK: - Alignment Guides
    
    private var alignmentGuides: some View {
        GeometryReader { geo in
            let centerX = geo.size.width / 2
            
            // Vertical center line
            Path { path in
                path.move(to: CGPoint(x: centerX, y: 0))
                path.addLine(to: CGPoint(x: centerX, y: geo.size.height))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [10, 5]))
            .foregroundStyle(AxisColor.primary.opacity(0.5))
            
            // Horizontal guide (shoulders)
            Path { path in
                path.move(to: CGPoint(x: 0, y: geo.size.height * 0.35))
                path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height * 0.35))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [10, 5]))
            .foregroundStyle(AxisColor.secondary.opacity(0.3))
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - Feedback Card
    
    private var feedbackCard: some View {
        VStack(spacing: 16) {
            // Score circle
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 6)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .trim(from: 0, to: alignmentScore)
                    .stroke(
                        AxisColor.accuracy(alignmentScore),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.3), value: alignmentScore)
                
                Text("\(Int(alignmentScore * 100))")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            // Feedback message
            Text(feedbackMessage)
                .font(.axisInstruction)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            // Tips
            if let pose = cameraController.detectedPose {
                postureTips(for: pose)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }
    
    // MARK: - Posture Tips
    
    @ViewBuilder
    private func postureTips(for pose: DetectedPose) -> some View {
        VStack(spacing: 8) {
            if !pose.shouldersLevel {
                TipRow(icon: "arrow.up.and.down", text: "Level your shoulders")
            }
            if !pose.headCentered {
                TipRow(icon: "arrow.left.and.right", text: "Center your head")
            }
            if !pose.neckStraight {
                TipRow(icon: "arrow.up", text: "Lift your chin slightly")
            }
        }
    }
    
    // MARK: - Update Feedback
    
    private func updateAlignmentFeedback() {
        guard let pose = cameraController.detectedPose else {
            alignmentScore = 0
            feedbackMessage = "Position yourself in frame"
            return
        }
        
        // Calculate score based on pose
        var score: Double = 0
        var issues: [String] = []
        
        if pose.shouldersLevel {
            score += 0.33
        } else {
            issues.append("shoulders")
        }
        
        if pose.headCentered {
            score += 0.33
        } else {
            issues.append("head")
        }
        
        if pose.neckStraight {
            score += 0.34
        } else {
            issues.append("neck")
        }
        
        alignmentScore = score
        
        // Generate feedback message
        if score >= 0.9 {
            feedbackMessage = "Excellent alignment! ✓"
        } else if score >= 0.6 {
            feedbackMessage = "Good posture. Minor adjustments needed."
        } else if !issues.isEmpty {
            feedbackMessage = "Adjust your \(issues.joined(separator: " and "))."
        } else {
            feedbackMessage = "Keep adjusting..."
        }
    }
}

// MARK: - Tip Row

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(AxisColor.warning)
                .font(.caption)
            Text(text)
                .font(.axisCaption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Detected Pose Model

struct DetectedPose: Equatable {
    let leftShoulder: CGPoint?
    let rightShoulder: CGPoint?
    let nose: CGPoint?
    let leftEar: CGPoint?
    let rightEar: CGPoint?
    
    var shouldersLevel: Bool {
        guard let left = leftShoulder, let right = rightShoulder else { return true }
        return abs(left.y - right.y) < 30
    }
    
    var headCentered: Bool {
        guard let nose = nose, let left = leftShoulder, let right = rightShoulder else { return true }
        let shoulderCenter = (left.x + right.x) / 2
        return abs(nose.x - shoulderCenter) < 40
    }
    
    var neckStraight: Bool {
        guard let nose = nose, let left = leftShoulder, let right = rightShoulder else { return true }
        let shoulderCenter = CGPoint(x: (left.x + right.x) / 2, y: (left.y + right.y) / 2)
        let expectedNoseY = shoulderCenter.y - 80 // Expected distance
        return nose.y <= expectedNoseY
    }
}

// MARK: - Camera Controller

class CameraController: NSObject, ObservableObject {
    let session = AVCaptureSession()
    @Published var detectedPose: DetectedPose?
    @Published var authorized: Bool = false
    
    private let poseRequest = VNDetectHumanBodyPoseRequest()
    private var videoOutput: AVCaptureVideoDataOutput?
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    override init() {
        super.init()
        checkPermission()
    }
    
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async { self.authorized = true }
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { self.authorized = granted }
                if granted { self.setupCamera() }
            }
        default:
            DispatchQueue.main.async { self.authorized = false }
            break
        }
    }
    
    private func setupCamera() {
        sessionQueue.async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            // Robust Camera Discovery (Fixes "No Camera" bugs)
            // Searches for TrueDepth (FaceID), Dual, or Wide cameras
            let discovery = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
                mediaType: .video,
                position: .front
            )
            
            guard let camera = discovery.devices.first else {
                print("Front camera not available")
                DispatchQueue.main.async { self.authorized = false } // Downgrade auth if HW missing
                self.session.commitConfiguration()
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                } else {
                    print("Cannot add camera input")
                }

                // Video output for Vision processing
                let output = AVCaptureVideoDataOutput()
                output.alwaysDiscardsLateVideoFrames = true
                output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "pose.detection"))

                if self.session.canAddOutput(output) {
                    self.session.addOutput(output)
                } else {
                    print("Cannot add video output")
                }
                self.videoOutput = output

                if let connection = output.connection(with: .video) {
                    if connection.isVideoOrientationSupported { connection.videoOrientation = .portrait }
                    if connection.isVideoMirroringSupported {
                        connection.automaticallyAdjustsVideoMirroring = false
                        connection.isVideoMirrored = true
                    }
                }
            } catch {
                print("Camera setup error: \(error)")
            }

            self.session.commitConfiguration()
        }
    }
    
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, self.authorized else { return }
            if !self.session.isRunning {
                NotificationCenter.default.addObserver(self, selector: #selector(self.sessionRuntimeError(_:)), name: .AVCaptureSessionRuntimeError, object: self.session)
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning { self.session.stopRunning() }
            NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionRuntimeError, object: self.session)
        }
    }
    
    @objc private func sessionRuntimeError(_ notification: Notification) {
        if let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError {
            print("AVCaptureSession runtime error: \(error)")
        } else {
            print("AVCaptureSession runtime error occurred")
        }
    }
}

// MARK: - Video Delegate

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored)
        
        do {
            try handler.perform([poseRequest])
            
            if let observation = poseRequest.results?.first {
                let pose = extractPose(from: observation)
                
                DispatchQueue.main.async {
                    self.detectedPose = pose
                }
            }
        } catch {
            // Pose detection failed - silently continue
        }
    }
    
    private func extractPose(from observation: VNHumanBodyPoseObservation) -> DetectedPose? {
        func point(for joint: VNHumanBodyPoseObservation.JointName) -> CGPoint? {
            guard let point = try? observation.recognizedPoint(joint),
                  point.confidence > 0.3 else { return nil }
            // Convert to view coordinates
            return CGPoint(x: point.location.x * 400, y: (1 - point.location.y) * 600)
        }
        
        return DetectedPose(
            leftShoulder: point(for: .leftShoulder),
            rightShoulder: point(for: .rightShoulder),
            nose: point(for: .nose),
            leftEar: point(for: .leftEar),
            rightEar: point(for: .rightEar)
        )
    }
}

// MARK: - Camera Preview Layer

struct CameraPreviewLayer: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        // previewLayer.frame = UIScreen.main.bounds  // removed per instructions
        
        // Mirror for front camera
        previewLayer.connection?.automaticallyAdjustsVideoMirroring = false
        previewLayer.connection?.isVideoMirrored = true
        
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
            if let connection = previewLayer.connection, connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
                if connection.isVideoMirroringSupported {
                    connection.automaticallyAdjustsVideoMirroring = false
                    connection.isVideoMirrored = true
                }
            }
        }
    }
}

// MARK: - Pose Overlay View

struct PoseOverlayView: View {
    let pose: DetectedPose
    
    var body: some View {
        Canvas { context, size in
            // Draw shoulder line
            if let left = pose.leftShoulder, let right = pose.rightShoulder {
                var path = Path()
                path.move(to: left)
                path.addLine(to: right)
                
                context.stroke(
                    path,
                    with: .color(pose.shouldersLevel ? AxisColor.success : AxisColor.warning),
                    lineWidth: 3
                )
                
                // Shoulder dots
                drawJoint(context: context, at: left, color: .white)
                drawJoint(context: context, at: right, color: .white)
            }
            
            // Draw neck line
            if let left = pose.leftShoulder, let right = pose.rightShoulder, let nose = pose.nose {
                let shoulderCenter = CGPoint(x: (left.x + right.x) / 2, y: (left.y + right.y) / 2)
                
                var neckPath = Path()
                neckPath.move(to: shoulderCenter)
                neckPath.addLine(to: nose)
                
                context.stroke(
                    neckPath,
                    with: .color(pose.headCentered ? AxisColor.success : AxisColor.warning),
                    lineWidth: 2
                )
                
                // Nose dot
                drawJoint(context: context, at: nose, color: AxisColor.primary)
            }
        }
    }
    
    private func drawJoint(context: GraphicsContext, at point: CGPoint, color: Color) {
        let rect = CGRect(x: point.x - 6, y: point.y - 6, width: 12, height: 12)
        context.fill(Path(ellipseIn: rect), with: .color(color))
    }
}
