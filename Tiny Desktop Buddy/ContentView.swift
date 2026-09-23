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
                    Button {
                        engine.pokePet()
                    } label: {
                        Label("Meow", systemImage: "bubble.left")
                    }

                    Button {
                        engine.toggleAutoMode()
                    } label: {
                        if engine.isAutoMode {
                            Label("Auto Roam (Active)", systemImage: "checkmark.circle.fill")
                        } else {
                            Label("Auto Roam (Paused)", systemImage: "pause.circle")
                        }
                    }

                    Divider()

                    Menu {
                        ForEach(RoamingMode.allCases) { mode in
                            Button {
                                engine.setRoamingMode(mode)
                            } label: {
                                if engine.roamingMode == mode {
                                    Text("✓ \(mode.title)")
                                } else {
                                    Text(mode.title)
                                }
                            }
                        }
                    } label: {
                        Label("Mode", systemImage: "location")
                    }

                    Menu {
                        Button("Small (2x)") { engine.petScale = 2.0 }
                        Button("Medium (2.5x)") { engine.petScale = 2.5 }
                        Button("Large (3.5x)") { engine.petScale = 3.5 }
                        Button("Giant (4.5x)") { engine.petScale = 4.5 }
                    } label: {
                        Label("Size", systemImage: "arrow.up.left.and.arrow.down.right")
                    }

                    Menu {
                        ForEach(PetAnimation.allCases) { anim in
                            Button(anim.title) {
                                engine.setManualAnimation(anim)
                            }
                        }
                    } label: {
                        Label("Action", systemImage: "figure.walk")
                    }

                    Divider()

                    Button(role: .destructive) {
                        NSApplication.shared.terminate(nil)
                    } label: {
                        Label("Quit Buddy", systemImage: "power")
                    }
                }
        }
        .animation(.easeInOut(duration: 0.2), value: engine.showMeowBubble)
    }
}
