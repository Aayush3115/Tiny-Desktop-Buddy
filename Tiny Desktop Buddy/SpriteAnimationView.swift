import SwiftUI

enum PetAnimation: String, CaseIterable, Identifiable {
    case idle = "cat-1-Idle"
    case walk = "cat-1-Walk"
    case run = "Cat-1-Run"
    case itch = "Cat-1-Itch"
    case laying = "Cat-1-Laying"
    case licking1 = "Cat-1-Licking 1"
    case licking2 = "Cat-1-Licking 2"
    case meow = "Cat-1-Meow"
    case sitting = "Cat-1-Sitting"
    case sleeping1 = "Cat-1-Sleeping1"
    case sleeping2 = "Cat-1-Sleeping2"
    case stretching = "Cat-1-Stretching"
    case meowVFX = "Meow-VFX"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .idle: return "Idle"
        case .walk: return "Walk"
        case .run: return "Run"
        case .itch: return "Itch"
        case .laying: return "Laying"
        case .licking1: return "Licking (1)"
        case .licking2: return "Licking (2)"
        case .meow: return "Meow"
        case .sitting: return "Sitting"
        case .sleeping1: return "Sleeping (1)"
        case .sleeping2: return "Sleeping (2)"
        case .stretching: return "Stretching"
        case .meowVFX: return "Meow VFX"
        }
    }

    var frameCount: Int {
        switch self {
        case .idle: return 10
        case .walk, .run, .laying: return 8
        case .licking1, .licking2: return 5
        case .meow: return 4
        case .meowVFX: return 3
        case .itch: return 2
        case .sitting, .sleeping1, .sleeping2: return 1
        case .stretching: return 13
        }
    }

    var frameSize: CGFloat {
        switch self {
        case .meowVFX: return 16
        default: return 50
        }
    }

    var defaultFrameRate: Double {
        switch self {
        case .idle: return 6
        case .walk: return 8
        case .run: return 10
        case .stretching: return 6
        case .itch: return 4
        case .meow: return 5
        case .licking1, .licking2: return 5
        case .laying: return 4
        default: return 4
        }
    }
}

struct SpriteAnimationView: View {

    let imageName: String
    let frameCount: Int
    let frameSize: CGFloat
    let frameRate: Double

    @State private var currentFrame = 0
    @State private var timer: Timer?

    init(
        imageName: String,
        frameCount: Int,
        frameSize: CGFloat = 50,
        frameRate: Double = 6
    ) {
        self.imageName = imageName
        self.frameCount = max(1, frameCount)
        self.frameSize = frameSize
        self.frameRate = max(0.1, frameRate)
    }

    init(animation: PetAnimation, frameRate: Double? = nil) {
        self.init(
            imageName: animation.rawValue,
            frameCount: animation.frameCount,
            frameSize: animation.frameSize,
            frameRate: frameRate ?? animation.defaultFrameRate
        )
    }

    var body: some View {
        GeometryReader { _ in
            Image(imageName)
                .resizable()
                .interpolation(.none)
                .frame(
                    width: CGFloat(frameCount) * frameSize,
                    height: frameSize
                )
                .offset(
                    x: -CGFloat(currentFrame % frameCount) * frameSize
                )
                .frame(
                    width: frameSize,
                    height: frameSize,
                    alignment: .leading
                )
                .clipped()
        }
        .frame(
            width: frameSize,
            height: frameSize
        )
        .onAppear {
            restartAnimation()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .onChange(of: imageName) { _, _ in
            restartAnimation()
        }
        .onChange(of: frameCount) { _, _ in
            restartAnimation()
        }
        .onChange(of: frameRate) { _, _ in
            restartAnimation()
        }
    }

    private func restartAnimation() {
        timer?.invalidate()
        currentFrame = 0

        guard frameCount > 1 else { return }

        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0 / frameRate,
            repeats: true
        ) { _ in
            currentFrame = (currentFrame + 1) % frameCount
        }
    }
}
