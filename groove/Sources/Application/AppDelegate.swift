import SwiftUI

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
      let title = $0.rawValue
      let player = NSMenuItem()
      player.title = "\(title)"~
      player.action = #selector(open)
      player.target = self
      player.indentationLevel = 1
      return player
    }
    menu.items = topMenu + [label] + players
    return menu
  }
  
  @objc func open() {
    
  }
  
  @objc func playPause() {
    self.dockController?.playPause()
  }
}
