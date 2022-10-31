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

class AppDelegate: NSObject, NSApplicationDelegate {
  var dockController: DockController?

  func applicationDidBecomeActive(_: Notification) {
    
  }

  func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
    self.dockController?.click()
    return true
  }

  func applicationDidFinishLaunching(_: Notification) {
    AppSettings.default.setDefaults()
    self.dockController = DockController()
  }

  func applicationWillTerminate(_: Notification) {
    self.dockController?.destroy()
  }
  
  func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
    let menu = NSMenu()
    
    var topMenu: [NSMenuItem] = []
    if let nowPlaying = dockController?.getData() {
      if !nowPlaying.isEmpty() {
        let playingLabel = NSMenuItem()
        playingLabel.title = nowPlaying.playing ? "Now Playing"~ : "Paused"~
        let songLabel = NSMenuItem()
        songLabel.title = nowPlaying.description
        songLabel.target = self
        songLabel.action = #selector(playPause)
        songLabel.indentationLevel = 1
        topMenu = [playingLabel, songLabel, NSMenuItem.separator()]
      }
    }
    
    let label = NSMenuItem()
    label.title = "Music Player"~
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
      player.target = self
      player.indentationLevel = 1
      return player
    }
    menu.items = topMenu + [label] + players
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
    self.dockController?.playPause()
  }
}
