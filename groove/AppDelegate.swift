import AppleScriptObjC
import DSFDockTile
import MediaPlayer
import SwiftUI

struct OptionalView<Value, T: View>: View {
  let content: T

  init?(_ value: Value?, @ViewBuilder content: (Value) -> T) {
    guard let value = value else { return nil }
    self.content = content(value)
  }

  var body: some View {
    content
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  var dock: DockController?
  
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
    self.dock?.click()
    
    self.info?.playPause()
    self.updateTile()
    return true
  }

  func applicationDidFinishLaunching(_: Notification) {
    self.dock = DockController()
    Task {
      do {
        self.info = await MusicInfo()
        self.updateTile()
      }
    }
  }

  func applicationWillTerminate(_: Notification) {}
}
