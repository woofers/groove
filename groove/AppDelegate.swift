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
  var action: MusicInfo.Action = .none
  
  static let DOUBLE_CLICK = 0.3
  static let IGNORE_CLICK = 0.09

  lazy var updateDockTile: DSFDockTile.View = {
    dockViewController.loadView()
    return DSFDockTile.View(dockViewController)
  }()

  func updateTile() {
    Task { [weak self] in
      let data = await info?.fetch()
      await self?.dockViewController.update(data)
      DispatchQueue.main.async { [weak self] in
        self?.updateDockTile.display()
      }
    }
  }

  func applicationDidBecomeActive(_: Notification) {

  }

  func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
    let lastClick = self.lastClicked
    let now = ProcessInfo.processInfo.systemUptime
    let clickTime = now - lastClick
    if clickTime > AppDelegate.IGNORE_CLICK {
      if clickTime <= AppDelegate.DOUBLE_CLICK {
        action = .skip
        self.lastClickType = .double
      } else {
        action = .playPause
        self.lastClickType = .normal
      }
      print("Type: \(self.lastClickType) Delta: \(clickTime)")
      self.lastClicked = now
    }
    
    Task { [weak self] in
      do {
        let action = self?.action ?? .none
        await self?.info?.perform(action)
        self?.updateTile()
      }
    }
    return true
  }

  func applicationDidFinishLaunching(_: Notification) {
    self.info = MusicInfo()
    self.updateTile()
  }

  func applicationWillTerminate(_: Notification) {}
}
