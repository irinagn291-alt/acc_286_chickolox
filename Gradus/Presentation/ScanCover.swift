import AVFoundation
import SwiftUI
import UIKit

/// Full-screen desk QR cover. One capture preview, a SwiftUI reticle, no shader.
struct ScanCover: View {
    @Environment(PracticeStore.self) private var practice
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @State private var manual = ""
    @State private var notice = ""
    @State private var running = true

    var body: some View {
        ZStack {
            DesignTokens.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: Measure.s4) {
                HStack {
                    Text("Desk code")
                        .font(Ramp.title())
                        .foregroundStyle(DesignTokens.ink)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(Ramp.body())
                            .foregroundStyle(DesignTokens.ink)
                            .frame(width: Measure.hit, height: Measure.hit)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Close")
                }
                preview
                TextField("Type desk digits", text: $manual)
                    .font(Ramp.body())
                    .keyboardType(.numberPad)
                    .padding(Measure.s3)
                    .frame(minHeight: Measure.hit)
                    .background(DesignTokens.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Measure.Radius.chip, style: .continuous))
                    .foregroundStyle(DesignTokens.ink)
                Button("Open desk") { resolve(manual) }
                    .buttonStyle(VerbButtonStyle(prominent: false, loading: false))
                if !notice.isEmpty {
                    Text(notice)
                        .font(Ramp.caption())
                        .foregroundStyle(DesignTokens.muted)
                }
                simulatorChips
                Spacer(minLength: 0)
            }
            .padding(Measure.s4)
        }
        .onChange(of: scenePhase) { _, phase in
            running = phase == .active
        }
        .onDisappear { running = false }
    }

    @ViewBuilder
    private var preview: some View {
        #if targetEnvironment(simulator)
        reticle
            .overlay {
                Text("Type a desk code, or tap a chip.")
                    .font(Ramp.caption())
                    .foregroundStyle(DesignTokens.muted)
            }
        #else
        switch status {
        case .authorized:
            ZStack {
                if running {
                    DeskPreview { code in
                        resolve(code)
                    }
                }
                reticle
            }
            .frame(height: Measure.s16 * 6)
            .clipShape(RoundedRectangle(cornerRadius: Measure.Radius.plate, style: .continuous))
        case .notDetermined:
            VStack(alignment: .leading, spacing: Measure.s3) {
                Text("A desk code can open the matching board.")
                    .font(Ramp.body())
                    .foregroundStyle(DesignTokens.ink)
                Button("Continue") {
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        Task { @MainActor in
                            status = granted ? .authorized : .denied
                        }
                    }
                }
                .buttonStyle(VerbButtonStyle(prominent: false, loading: false))
            }
        case .denied, .restricted:
            VStack(alignment: .leading, spacing: Measure.s3) {
                Text("The camera is off for Gradus. Open Settings, or type the digits.")
                    .font(Ramp.body())
                    .foregroundStyle(DesignTokens.ink)
                Button("Open Settings") {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                }
                .buttonStyle(VerbButtonStyle(prominent: false, loading: false))
            }
        @unknown default:
            Text("The camera is not available. Type the digits instead.")
                .font(Ramp.body())
                .foregroundStyle(DesignTokens.muted)
        }
        #endif
    }

    private var reticle: some View {
        Reticle()
            .stroke(DesignTokens.ink, lineWidth: Measure.hairline)
            .frame(height: Measure.s16 * 4)
            .padding(Measure.s6)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var simulatorChips: some View {
        #if targetEnvironment(simulator)
        VStack(alignment: .leading, spacing: Measure.s2) {
            ForEach(practice.coachees) { coachee in
                Button(coachee.name) { resolve(coachee.deskDigits) }
                    .buttonStyle(PlateButtonStyle(focused: false, loading: false, failed: false, selected: false))
            }
        }
        #endif
    }

    private func resolve(_ raw: String) {
        if let coachee = practice.coachee(matching: raw) {
            practice.focus(coacheeID: coachee.id)
            dismiss()
            return
        }
        guard let digits = DeskLookup.digitRun(from: raw) else {
            notice = "That code is not on this device."
            return
        }
        let stored = digits.count == 12 ? "0" + digits : digits
        let label = "Client " + Figures.whole(practice.coachees.count + 1)
        _ = practice.addCoachee(name: label, deskDigits: stored)
        dismiss()
    }
}

private struct Reticle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let arm = min(rect.width, rect.height) * 0.18
        let corners = [
            CGPoint(x: rect.minX, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.maxY)
        ]
        let signs: [(CGFloat, CGFloat)] = [(1, 1), (-1, 1), (-1, -1), (1, -1)]
        for index in corners.indices {
            let point = corners[index]
            let sign = signs[index]
            path.move(to: CGPoint(x: point.x + sign.0 * arm, y: point.y))
            path.addLine(to: point)
            path.addLine(to: CGPoint(x: point.x, y: point.y + sign.1 * arm))
        }
        return path
    }
}

struct DeskPreview: UIViewRepresentable {
    var onCode: (String) -> Void

    func makeUIView(context: Context) -> DeskCameraView {
        let view = DeskCameraView()
        view.onCode = onCode
        view.start()
        return view
    }

    func updateUIView(_ uiView: DeskCameraView, context: Context) {
        uiView.onCode = onCode
    }

    static func dismantleUIView(_ uiView: DeskCameraView, coordinator: ()) {
        uiView.stop()
    }
}

final class DeskCameraView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    var onCode: ((String) -> Void)?
    private let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "grd.desk.capture")
    private var layerPreview: AVCaptureVideoPreviewLayer?
    private var lastPayload = ""
    private var lastInstant = Date.distantPast

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layerPreview?.frame = bounds
    }

    func start() {
        queue.async { [weak self] in
            self?.configureAndRun()
        }
    }

    func stop() {
        queue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    private func configureAndRun() {
        guard session.inputs.isEmpty else {
            if !session.isRunning { session.startRunning() }
            return
        }
        session.beginConfiguration()
        session.sessionPreset = .high
        guard
            let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else {
            session.commitConfiguration()
            return
        }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: queue)
        output.metadataObjectTypes = [.qr, .ean13, .ean8, .upce]
        session.commitConfiguration()
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            preview.frame = self.bounds
            self.layer.insertSublayer(preview, at: 0)
            self.layerPreview = preview
        }
        session.startRunning()
    }

    nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        let value = metadataObjects.compactMap { $0 as? AVMetadataMachineReadableCodeObject }.first?.stringValue
        guard let value else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let now = Date()
            if value == self.lastPayload, now.timeIntervalSince(self.lastInstant) < 1.6 {
                return
            }
            self.lastPayload = value
            self.lastInstant = now
            self.onCode?(value)
        }
    }
}
