import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
  var dockController: DockController?
  var dockMenuController: DockMenuController?

  func applicationDidBecomeActive(_: Notification) {
    
  }

  func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
    self.dockController?.click()
    return true
  }

  func applicationDidFinishLaunching(_: Notification) {
    AppSettings.default.setDefaults()
    let controller = DockController()
    self.dockController = controller
    self.dockMenuController = DockMenuController(controller: controller)
  }

  func applicationWillTerminate(_: Notification) {
    self.dockController?.destroy()
  }
  
  func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
    return self.dockMenuController?.getMenu()
  }
}
