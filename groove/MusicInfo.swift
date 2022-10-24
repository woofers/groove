import SwiftUI
import AppleScriptObjC

class MusicInfo {
  
  private var data = DockData(artist: "", album: "", song: "", artwork: nil, playing: false)

  private var ready = false
  private var didFetch = false
  
  private var trackInfo: [NSString : AnyObject] = [:]
  private var bridge: iTunesBridge?
 
  init() async {
    await setup()
  }
  
  func getArtist() -> String {
    return trackInfo["trackArtist"] as! String
  }
  
  func getAlbum() -> String {
    return trackInfo["trackAlbum"] as! String
  }
  
  func getSong() -> String {
    return trackInfo["trackName"] as! String
  }
  
  func getArtwork() -> NSImage? {
    return bridge?.artwork
  }
  
  func getPlaybackStatus() -> Bool {
    return (bridge?.playerState ?? .paused) == .playing
  }
  
  func getData() -> DockData {
    return self.data
  }
  
  func playPause() {
    bridge?.playPause()
  }
  
  func nextTrack() {
    bridge?.gotoNextTrack()
    if !getPlaybackStatus() {
      bridge?.playPause()
    }
  }
  
  func fetch() -> DockData {
    getTrackInfo()
    let newData = DockData(artist: getArtist(), album: getAlbum(), song: getSong(), artwork: getArtwork(), playing: getPlaybackStatus())
    
    self.data.update(other: newData)
    didFetch = true
    return self.data
  }
  
  private func setup() async {
    let task = Task { [weak self] in
      do {
        self?.bridge = await self?.loadApplescript()
        self?.ready = true
      }
    }
    _ = await task.result
  }
  
  private func loadApplescript() async -> iTunesBridge {
    Bundle.main.loadAppleScriptObjectiveCScripts()
    let iTunesBridgeClass: AnyClass = NSClassFromString("iTunesBridge")!
    let bridge = iTunesBridgeClass.alloc() as! iTunesBridge
    return bridge
  }
  
  private func getTrackInfo() {
    if let song = bridge?.trackInfo {
      self.trackInfo = song
    }
  }
}

