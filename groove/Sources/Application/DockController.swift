import DSFDockTile
import SwiftUI

enum ClickType {
  case normal, double, none
}

class DockController {
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

  init() {
    self.info = MusicInfo(self.updateTile)
    self.updateTile()
  }
  
  func destroy() {
    self.info?.destroy()
  }

  func updateTile() {
    let data = self.info?.getData()
    Task { [weak self] in
      await self?.dockViewController.update(data)
      DispatchQueue.main.async { [weak self] in
        self?.updateDockTile.display()
      }
    }
  }

  func click() {
    if self.info?.isEmpty() ?? false {
      if let player = self.info?.getPlayer() {
        let id = player.getAppId()
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: id) {
          DispatchQueue.main.async {
            NSWorkspace.shared.open(url)
          }
        }
      }
      return
    }
    
    let lastClick = self.lastClicked
    let now = ProcessInfo.processInfo.systemUptime
    let clickTime = now - lastClick
    var action: MusicInfo.Action = .none
    if clickTime > DockController.IGNORE_CLICK {
      if clickTime <= DockController.DOUBLE_CLICK {
        action = .skip
        self.lastClickType = .double
      } else {
        action = .playPause
        self.lastClickType = .normal
      }
      self.lastClicked = now
    }
    self.info?.perform(action)
  }
  
  func playPause() {
    self.info?.perform(.playPause)
  }
  
  func getData() -> DockData? {
    return self.info?.getData()
  }
}
