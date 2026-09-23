import SwiftUI

struct ContentView: View {

    @ObservedObject var engine: PetBehaviorEngine

    var body: some View {
        let size = 50 * engine.petScale

        VStack(spacing: 4) {
            // Meow Bubble / VFX
            if engine.showMeowBubble {
                HStack(spacing: 4) {
                    Text("Meow! 🐾")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.95))
                                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                        )
                }
                .transition(.scale.combined(with: .opacity))
            }

            SpriteAnimationView(animation: engine.currentAnimation)
                .scaleEffect(
                    x: engine.isFacingLeft ? -engine.petScale : engine.petScale,
                    y: engine.petScale
                )
                .frame(width: size, height: size)
                .background(Color.clear)
                .contentShape(Rectangle())
                .onTapGesture(count: 2) {
                    engine.pokePet()
                }
                .contextMenu {
                    Button(action: {
                        engine.toggleAutoMode()
                    }) {
                        Text(engine.isAutoMode ? "✓ Auto Roam (Active)" : "Auto Roam (Paused)")
                    }

                    Menu("Roaming Mode 📍") {
                        ForEach(RoamingMode.allCases) { mode in
                            Button(action: {
                                engine.setRoamingMode(mode)
                            }) {
                                Text(engine.roamingMode == mode ? "✓ \(mode.rawValue)" : mode.rawValue)
                            }
                        }
                    }

                    Button("Meow! 🐾") {
                        engine.pokePet()
                    }

                    Divider()

                    Menu("Change Size") {
                        Button("Small (2x)") { engine.petScale = 2.0 }
                        Button("Medium (2.5x)") { engine.petScale = 2.5 }
                        Button("Large (3.5x)") { engine.petScale = 3.5 }
                        Button("Extra Large (4.5x)") { engine.petScale = 4.5 }
                        Button("Giant (5x)") { engine.petScale = 5.0 }
                    }

                    Divider()

                    Menu("Manual Animations") {
                        ForEach(PetAnimation.allCases) { anim in
                            Button(action: {
                                engine.setManualAnimation(anim)
                            }) {
                                Text(anim.title)
                            }
                        }
                    }
                }
        }
        .animation(.easeInOut(duration: 0.2), value: engine.showMeowBubble)
    }
}
