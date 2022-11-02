import SwiftUI

class PlayerMenuItem: NSMenuItem {
  var player: MusicInfo.PlayerApp?

  override init(title string: String, action selector: Selector?, keyEquivalent charCode: String) {
    super.init(title: string, action: selector, keyEquivalent: charCode)
  }
  
  required init(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func setPlayer(_ player: MusicInfo.PlayerApp) {
    self.player = player
  }
}

class DockMenuController {
  let dockController: DockController
  let menu: NSMenu
  
  init(controller: DockController) {
    self.dockController = controller
    self.menu = NSMenu()
  }
  
  private func getTopMenu() -> [NSMenuItem] {
    if let nowPlaying = dockController.getData() {
      if !nowPlaying.isEmpty() {
        let playingLabel = NSMenuItem()
        playingLabel.title = nowPlaying.playing ? "Now Playing"~ : "Paused"~
        let songLabel = NSMenuItem()
        songLabel.title = nowPlaying.description
        songLabel.target = self
        songLabel.action = #selector(playPause)
        songLabel.indentationLevel = 1
        return [playingLabel, songLabel, NSMenuItem.separator()]
      }
    }
    return []
  }
  
  private func getLabelMenu() -> [NSMenuItem] {
    let label = NSMenuItem()
    label.title = "Music Player"~
    return [label]
  }
  
  private func getPlayersMenu() -> [NSMenuItem] {
    let target = self
    let players = MusicInfo.PlayerApp.allCases.map {
      let current = $0
      let title = current.rawValue
      let player = PlayerMenuItem()
      let isCurrent = AppSettings.default.player() == current
      player.state = isCurrent ? .on : .off
      player.image = NSImage(systemSymbolName: "checkmark", accessibilityDescription: nil)
      if !isCurrent { player.setPlayer($0) }
      player.title = "\(title)"~
      player.action = #selector(self.changePlayer(sender:))
      player.target = target
      player.indentationLevel = 1
      return player
    }
    return players
  }
  
  private func getInternalMenu() -> NSMenu {
    return self.menu
  }
  
  func getMenu() -> NSMenu? {
    let menu = getInternalMenu()
    let topMenu = getTopMenu()
    let label = getLabelMenu()
    let players = getPlayersMenu()
    menu.items = topMenu + label + players
    return menu
  }
  
  @objc func changePlayer(sender: Any) {
    if let item = sender as? PlayerMenuItem {
      if let player = item.player {
        AppSettings.default.setPlayer(player)
      }
    }
  }
  
  @objc func playPause() {
    self.dockController.playPause()
  }
}
