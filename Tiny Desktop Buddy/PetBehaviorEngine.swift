import AppKit
import Combine
import SwiftUI

enum RoamingMode: String, CaseIterable, Identifiable {
    case freeRoam = "Free Roam"
    case menuBar = "Main Menu Bar"
    case bottomScreen = "Bottom Screen"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .freeRoam: return "Free Roam"
        case .menuBar: return "Main Menu Bar 🍎"
        case .bottomScreen: return "Bottom Screen"
        }
    }
}

@MainActor
final class PetBehaviorEngine: ObservableObject {

    static let shared = PetBehaviorEngine()

    @Published var currentAnimation: PetAnimation = .idle
    @Published var isFacingLeft: Bool = false
    @Published var isAutoMode: Bool = true
    @Published var roamingMode: RoamingMode = .freeRoam
    @Published var petScale: CGFloat = 3.5
    @Published var showMeowBubble: Bool = false

    weak var window: NSWindow?

    private var behaviorTimer: Timer?
    private var moveTimer: Timer?

    private var targetPosition: CGPoint?
    private var walkSpeed: CGFloat = 2.0
    private var isDragging: Bool = false

    init() {
        startBehaviorLoop()
    }

    func startBehaviorLoop() {
        scheduleNextAction(delay: 2.0)
    }

    func moveToMainMenu() {
        roamingMode = .menuBar
        isAutoMode = true
        moveTimer?.invalidate()
        moveTimer = nil
        targetPosition = nil

        guard let window = window, let screen = window.screen ?? NSScreen.main else { return }
        let screenFrame = screen.frame
        let windowWidth = window.frame.width
        let windowHeight = window.frame.height

        let petSize = 50 * petScale
        let padX = (windowWidth - petSize) / 2

        let targetY = screenFrame.maxY - (windowHeight / 2) - 14
        let targetX = screenFrame.minX - padX + 50

        startWalkingTo(target: CGPoint(x: targetX, y: targetY), isRunning: false)
    }

    func setRoamingMode(_ mode: RoamingMode) {
        roamingMode = mode
        isAutoMode = true
        moveTimer?.invalidate()
        moveTimer = nil
        targetPosition = nil
        startWalking(isRunning: false)
    }

    func userStartedDragging() {
        isDragging = true
        moveTimer?.invalidate()
        moveTimer = nil
        targetPosition = nil
        currentAnimation = .walk
    }

    func userStoppedDragging() {
        isDragging = false
        currentAnimation = .idle
        scheduleNextAction(delay: 3.0)
    }

    func pokePet() {
        guard !isDragging else { return }
        moveTimer?.invalidate()
        moveTimer = nil
        targetPosition = nil

        currentAnimation = .meow
        showMeowBubble = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { [weak self] in
            guard let self = self else { return }
            self.showMeowBubble = false
            self.scheduleNextAction(delay: 2.0)
        }
    }

    func toggleAutoMode() {
        isAutoMode.toggle()
        if isAutoMode {
            scheduleNextAction(delay: 1.0)
        } else {
            behaviorTimer?.invalidate()
            moveTimer?.invalidate()
            moveTimer = nil
            targetPosition = nil
            currentAnimation = .idle
        }
    }

    func setManualAnimation(_ anim: PetAnimation) {
        isAutoMode = false
        behaviorTimer?.invalidate()
        moveTimer?.invalidate()
        moveTimer = nil
        targetPosition = nil
        currentAnimation = anim
    }

    func scheduleNextAction(delay: Double? = nil) {
        behaviorTimer?.invalidate()
        guard isAutoMode, !isDragging else { return }

        let waitTime = delay ?? Double.random(in: 2.5...5.0)

        behaviorTimer = Timer.scheduledTimer(withTimeInterval: waitTime, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.performRandomAction()
            }
        }
    }

    private func performRandomAction() {
        guard isAutoMode, !isDragging else { return }

        let roll = Int.random(in: 1...100)

        switch roll {
        case 1...40:
            startWalking(isRunning: false)

        case 41...52:
            startWalking(isRunning: true)

        case 53...66:
            currentAnimation = .idle
            scheduleNextAction(delay: Double.random(in: 3.0...6.0))

        case 67...76:
            currentAnimation = .stretching
            scheduleNextAction(delay: 3.5)

        case 77...84:
            currentAnimation = .itch
            scheduleNextAction(delay: 2.5)

        case 85...92:
            currentAnimation = Bool.random() ? .licking1 : .licking2
            scheduleNextAction(delay: 3.0)

        case 93...97:
            currentAnimation = .laying
            scheduleNextAction(delay: Double.random(in: 4.0...8.0))

        default:
            pokePet()
        }
    }

    private func startWalking(isRunning: Bool) {
        guard let window = window, let screen = window.screen ?? NSScreen.main else {
            scheduleNextAction(delay: 2.0)
            return
        }

        let screenFrame = screen.frame
        let windowWidth = window.frame.width
        let windowHeight = window.frame.height

        let petSize = 50 * petScale
        let padX = (windowWidth - petSize) / 2
        let padY = (windowHeight - petSize) / 2

        let minX = screenFrame.minX - padX
        let maxX = screenFrame.maxX - windowWidth + padX

        var targetX = CGFloat.random(in: minX...maxX)
        var targetY: CGFloat

        switch roamingMode {
        case .menuBar:
            targetY = screenFrame.maxY - (windowHeight / 2) - 14
            targetX = CGFloat.random(in: minX...maxX)

        case .bottomScreen:
            targetY = screenFrame.minY - padY
            targetX = CGFloat.random(in: minX...maxX)

        case .freeRoam:
            let minY = screenFrame.minY - padY
            let maxY = screenFrame.maxY - (windowHeight / 2) - 14
            targetY = CGFloat.random(in: minY...max(minY, maxY))
        }

        startWalkingTo(target: CGPoint(x: targetX, y: targetY), isRunning: isRunning)
    }

    private func startWalkingTo(target: CGPoint, isRunning: Bool) {
        guard let window = window else { return }

        self.targetPosition = target

        let currentOrigin = window.frame.origin
        let dx = target.x - currentOrigin.x
        isFacingLeft = dx < 0

        currentAnimation = isRunning ? .run : .walk
        walkSpeed = isRunning ? 4.5 : 2.2

        moveTimer?.invalidate()
        moveTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] timer in
            Task { @MainActor in
                self?.stepMovement(timer: timer)
            }
        }
    }

    private func stepMovement(timer: Timer) {
        guard let window = window, let target = targetPosition, !isDragging, isAutoMode else {
            timer.invalidate()
            return
        }

        let currentOrigin = window.frame.origin
        let dx = target.x - currentOrigin.x
        let dy = target.y - currentOrigin.y
        let distance = hypot(dx, dy)

        if distance < walkSpeed {
            window.setFrameOrigin(target)
            timer.invalidate()
            moveTimer = nil
            targetPosition = nil
            currentAnimation = .idle
            scheduleNextAction(delay: Double.random(in: 2.5...5.0))
        } else {
            let angle = atan2(dy, dx)
            let newX = currentOrigin.x + cos(angle) * walkSpeed
            let newY = currentOrigin.y + sin(angle) * walkSpeed
            window.setFrameOrigin(CGPoint(x: newX, y: newY))
        }
    }
}
