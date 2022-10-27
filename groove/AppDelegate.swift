import AppleScriptObjC
import DSFDockTile
import SwiftUI

enum ClickType {
  case normal, double, none
}

class AppDelegate: NSObject, NSApplicationDelegate {
  var dockViewController = DockViewController()
  var info: MusicInfo?
  var lastClicked = ProcessInfo.processInfo.systemUptime
  var lastClickType: ClickType = .none
  
  static let DOUBLE_CLICK = 0.3
  static let IGNORE_CLICK = 0.09

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
    let lastClick = self.lastClicked
    let now = ProcessInfo.processInfo.systemUptime
    let clickTime = now - lastClick
    if clickTime > AppDelegate.IGNORE_CLICK {
      if clickTime <= AppDelegate.DOUBLE_CLICK {
        self.info?.nextTrack()
        self.lastClickType = .double
      } else {
        self.info?.playPause()
        self.lastClickType = .normal
      }
      print("Type: \(self.lastClickType) Delta: \(clickTime)")
      self.lastClicked = now
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
      self.updateTile()
    }
    return true
  }

  func applicationDidFinishLaunching(_: Notification) {
    self.info = MusicInfo()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      self.updateTile()
    }
  }

  func applicationWillTerminate(_: Notification) {}
}
