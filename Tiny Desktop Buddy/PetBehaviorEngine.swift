import AppKit
import Combine
import SwiftUI

@MainActor
final class PetBehaviorEngine: ObservableObject {

    @Published var currentAnimation: PetAnimation = .idle
    @Published var isFacingLeft: Bool = false
    @Published var isAutoMode: Bool = true
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

        // Weighted random action selection
        let roll = Int.random(in: 1...100)

        switch roll {
        case 1...40:
            // Walk somewhere
            startWalking(isRunning: false)

        case 41...52:
            // Zoomies / Run
            startWalking(isRunning: true)

        case 53...66:
            // Stand idle / Look around
            currentAnimation = .idle
            scheduleNextAction(delay: Double.random(in: 3.0...6.0))

        case 67...76:
            // Big stretch
            currentAnimation = .stretching
            scheduleNextAction(delay: 3.5)

        case 77...84:
            // Scratch an itch
            currentAnimation = .itch
            scheduleNextAction(delay: 2.5)

        case 85...92:
            // Groom paws
            currentAnimation = Bool.random() ? .licking1 : .licking2
            scheduleNextAction(delay: 3.0)

        case 93...97:
            // Take a short nap
            currentAnimation = .laying
            scheduleNextAction(delay: Double.random(in: 4.0...8.0))

        default:
            // Meow
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

        // Random target anywhere on the screen
        let minX = screenFrame.minX + 20
        let maxX = screenFrame.maxX - windowWidth - 20
        let minY = screenFrame.minY + 40
        let maxY = screenFrame.maxY - windowHeight - 10

        guard maxX > minX, maxY > minY else {
            scheduleNextAction(delay: 2.0)
            return
        }

        let targetX = CGFloat.random(in: minX...maxX)
        let targetY = CGFloat.random(in: minY...maxY)

        let target = CGPoint(x: targetX, y: targetY)
        self.targetPosition = target

        let currentOrigin = window.frame.origin
        let dx = target.x - currentOrigin.x
        isFacingLeft = dx < 0

        currentAnimation = isRunning ? .run : .walk
        walkSpeed = isRunning ? 4.5 : 2.0

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
            // Reached destination
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
