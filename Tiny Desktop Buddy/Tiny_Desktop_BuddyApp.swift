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
            CommandMenu("Buddy") {
                Button("Meow") {
                    PetBehaviorEngine.shared.pokePet()
                }
                .keyboardShortcut("m", modifiers: [.command])

                Button(PetBehaviorEngine.shared.isAutoMode ? "Pause Auto Roam" : "Resume Auto Roam") {
                    PetBehaviorEngine.shared.toggleAutoMode()
                }
                .keyboardShortcut("a", modifiers: [.command])

                Divider()

                Menu("Mode") {
                    ForEach(RoamingMode.allCases) { mode in
                        Button(mode.title) {
                            PetBehaviorEngine.shared.setRoamingMode(mode)
                        }
                    }
                }

                Menu("Size") {
                    Button("Small") { PetBehaviorEngine.shared.petScale = 2.0 }
                    Button("Medium") { PetBehaviorEngine.shared.petScale = 2.5 }
                    Button("Large") { PetBehaviorEngine.shared.petScale = 3.5 }
                    Button("Giant") { PetBehaviorEngine.shared.petScale = 4.5 }
                }

                Menu("Action") {
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
