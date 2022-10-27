import DSFDockTile
import SwiftUI

class DockController {
  var dockViewController = DockViewController()
  var info: MusicInfo?

  lazy var updateDockTile: DSFDockTile.View = {
    dockViewController.loadView()
    return DSFDockTile.View(dockViewController)
  }()

  init() {
    self.info = MusicInfo(self.updateTile)
    self.updateTile()
  }

  func updateTile() {
    /*
    self.dockViewController.update(self.info?.fetch())
    DispatchQueue.main.async { [weak self] in
      self?.updateDockTile.display()
    }
     */
  }

  func click() {
    self.info?.playPause()
    self.updateTile()
  }
}
