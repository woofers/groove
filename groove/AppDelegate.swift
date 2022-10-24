import AppleScriptObjC
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
  var dock: DockController?
  
  func applicationDidBecomeActive(_: Notification) {

  }

  func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
    self.dock?.click()
    return true
  }

  func applicationDidFinishLaunching(_: Notification) {
    self.dock = DockController()
  }

  func applicationWillTerminate(_: Notification) {}
}
