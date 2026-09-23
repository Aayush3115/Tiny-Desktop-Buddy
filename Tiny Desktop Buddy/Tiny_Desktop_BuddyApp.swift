import SwiftUI

@main
struct Tiny_Desk_BuddyApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
        .commands {
            CommandMenu("Buddy 🐱") {
                Menu("Roaming Mode 📍") {
                    ForEach(RoamingMode.allCases) { mode in
                        Button(mode.rawValue) {
                            PetBehaviorEngine.shared.setRoamingMode(mode)
                        }
                    }
                }

                Button("Toggle Auto Roam") {
                    PetBehaviorEngine.shared.toggleAutoMode()
                }
                .keyboardShortcut("a", modifiers: [.command])

                Button("Meow! 🐾") {
                    PetBehaviorEngine.shared.pokePet()
                }
                .keyboardShortcut("m", modifiers: [.command])

                Divider()

                Menu("Change Size 📏") {
                    Button("Small (2x)") { PetBehaviorEngine.shared.petScale = 2.0 }
                    Button("Medium (2.5x)") { PetBehaviorEngine.shared.petScale = 2.5 }
                    Button("Large (3.5x)") { PetBehaviorEngine.shared.petScale = 3.5 }
                    Button("Extra Large (4.5x)") { PetBehaviorEngine.shared.petScale = 4.5 }
                    Button("Giant (5x)") { PetBehaviorEngine.shared.petScale = 5.0 }
                }

                Divider()

                Menu("Play Animation 🎭") {
                    ForEach(PetAnimation.allCases) { anim in
                        Button(anim.title) {
                            PetBehaviorEngine.shared.setManualAnimation(anim)
                        }
                    }
                }
            }
        }
    }
}
