import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
  var dockController: DockController?

  func applicationDidBecomeActive(_: Notification) {
    
  }

  func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
    self.dockController?.click()
    return true
  }

  func applicationDidFinishLaunching(_: Notification) {
    self.dockController = DockController()
  }

  func applicationWillTerminate(_: Notification) {
    self.dockController?.destroy()
  }
}
