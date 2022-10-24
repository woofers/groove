import AppleScriptObjC
import DSFDockTile
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
  var dockViewController = DockViewController()
  var info: MusicInfo?

  lazy var updateDockTile: DSFDockTile.View = {
    dockViewController.loadView()
    return DSFDockTile.View(dockViewController)
  }()

  func updateTile() {
    self.dockViewController.update(info?.fetch())
    self.updateDockTile.display()
  }

  func applicationDidBecomeActive(_: Notification) {

  }

  func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
    self.info?.playPause()
    self.updateTile()
    return true
  }

  func applicationDidFinishLaunching(_: Notification) {
    Task {
      do {
        self.info = await MusicInfo()
        self.updateTile()
      }
    }
  }

  func applicationWillTerminate(_: Notification) {}
}
