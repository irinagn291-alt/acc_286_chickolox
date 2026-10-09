import SwiftUI

/// Quadrant-locked chrome. The board stays at the root. Other surfaces are sheets or a cover.
struct BoardRoot: View {
    @Environment(PracticeStore.self) private var practice
    @State private var sheet: CoverSheet?
    @State private var showScan = false
    @State private var reviewRead = false

    var body: some View {
        Group {
            if !practice.didLoad {
                ProgressView()
                    .tint(DesignTokens.ink)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(DesignTokens.bg.ignoresSafeArea())
            } else if !practice.onboardingComplete {
                OnboardingPages {
                    practice.finishOnboarding()
                }
            } else {
                CanvasView(
                    openClients: { sheet = .clients },
                    openProgress: { sheet = .progress },
                    openSettings: { sheet = .settings },
                    openScan: { showScan = true },
                    openLadder: { sheet = .ladder }
                )
            }
        }
        .sheet(item: $sheet) { item in
            switch item {
            case .clients:
                ClientsView { showScan = true }
            case .progress:
                ProgressScreen()
            case .settings:
                SettingsView()
            case .ladder:
                LadderSheet()
            }
        }
        .fullScreenCover(isPresented: $showScan) {
            ScanCover()
        }
        .onChange(of: practice.didLoad) { _, loaded in
            if loaded { readReviewOnce() }
        }
        .onChange(of: practice.onboardingComplete) { _, done in
            if done { readReviewOnce() }
        }
    }

    private func readReviewOnce() {
        guard practice.didLoad, practice.onboardingComplete, !reviewRead else { return }
        reviewRead = true
        switch ReviewLaunch.screen {
        case "today":
            break
        case "log":
            sheet = .progress
        case "goals":
            sheet = .clients
        case "settings":
            sheet = .settings
        case "scan":
            showScan = true
        default:
            break
        }
    }
}

enum CoverSheet: String, Identifiable {
    case clients
    case progress
    case settings
    case ladder

    var id: String { rawValue }
}
