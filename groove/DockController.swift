import SwiftUI
import DSFDockTile

class DockController {

  var dockViewController = DockViewController()
  var info: MusicInfo?

  lazy var updateDockTile: DSFDockTile.View = {
    dockViewController.loadView()
    return DSFDockTile.View(dockViewController)
  }()
  
  init() {
    Task {
      do {
        self.info = await MusicInfo()
        self.updateTile()
      }
    }
  }
  
  func updateTile() {
    self.dockViewController.update(info?.fetch())
    DispatchQueue.main.async { [weak self] in
      self?.updateDockTile.display()
    }
  }
  
  func click() {
    self.info?.playPause()
    self.updateTile()
  }
}
