import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var petWindowController: PetWindowController?

    func applicationDidFinishLaunching(
        _ notification: Notification
    ) {
        petWindowController = PetWindowController()
        petWindowController?.show()
    }
}
