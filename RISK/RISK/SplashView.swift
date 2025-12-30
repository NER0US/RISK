import SwiftUI
import AVFoundation
import AppKit

struct SplashView: View {

    @Binding var introComplete: Bool
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VideoPlayerView(
            videoName: "intro",
            videoExtension: "mp4"
        ) {
            introComplete = true
            openWindow(id: "main")
        }
        .frame(width: 360, height: 534)
        .background(WindowConfigurator())
        .ignoresSafeArea()
    }
}

//
// MARK: - AVPlayer Wrapper (NO FLASH, ROUNDED, FILLS WINDOW)
//

struct VideoPlayerView: NSViewRepresentable {

    let videoName: String
    let videoExtension: String
    let onFinished: () -> Void

    func makeNSView(context: Context) -> NSView {

        // Root container
        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.clear.cgColor

        // Masked view (this is what actually rounds)
        let maskView = NSView()
        maskView.wantsLayer = true
        maskView.layer?.cornerRadius = 16
        maskView.layer?.masksToBounds = true
        maskView.layer?.backgroundColor = NSColor.black.cgColor // 🔥 prevents flash

        container.addSubview(maskView)

        maskView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            maskView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            maskView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            maskView.topAnchor.constraint(equalTo: container.topAnchor),
            maskView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        guard let url = Bundle.main.url(
            forResource: videoName,
            withExtension: videoExtension
        ) else {
            fatalError("Missing video: \(videoName).\(videoExtension)")
        }

        let player = AVPlayer(url: url)

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.backgroundColor = NSColor.black.cgColor
        playerLayer.needsDisplayOnBoundsChange = true

        // 🔥 Prevent Core Animation from flashing default contents
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        maskView.layer?.addSublayer(playerLayer)
        CATransaction.commit()

        // Size sync
        DispatchQueue.main.async {
            playerLayer.frame = maskView.bounds
        }

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            onFinished()
        }

        player.play()
        return container
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard
            let maskView = nsView.subviews.first,
            let playerLayer = maskView.layer?.sublayers?.first
        else { return }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer.frame = maskView.bounds
        CATransaction.commit()
    }
}

//
// MARK: - Window Configuration (Intro Only)
//

struct WindowConfigurator: NSViewRepresentable {

    func makeNSView(context: Context) -> NSView {
        let view = NSView()

        DispatchQueue.main.async {
            guard let window = view.window else { return }

            window.styleMask = [.borderless]
            window.isOpaque = false
            window.backgroundColor = .clear
            window.isMovable = false
            window.level = .floating

            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
