import SwiftUI
import AppleScriptObjC
import MusicPlayer

//public typealias Image = NSImage

class MusicInfo {
  
  private var player: MusicPlayers.Scriptable?
  
  private var data = DockData(artist: "", album: "", song: "", artwork: nil, playing: false)

  private var didFetch = false
 
  init() {
    self.player = MusicPlayers.Scriptable(name: .appleMusic)
    getTrackInfo()
  }
  
  private func unwrapAsString(_ value: AnyObject?) -> String {
    if let casted = value as? String {
      return casted
    }
    return ""
  }
  
  func getArtist() -> String {
    return player?.currentTrack?.artist ?? ""
  }
  
  func getAlbum() -> String {
    return player?.currentTrack?.album ?? ""
  }
  
  func getSong() -> String {
    return player?.currentTrack?.title ?? ""
  }
  
  func getArtwork() -> NSImage? {
    return ArtworkLoader.default.getArtwork()
  }
  
  func getPlaybackStatus() -> Bool {
    if let state = player?.playbackState {
      switch state {
        case .playing:
          return true
      default:
        return false
      }
    }
    return false
  }
  
  func getData() -> DockData {
    return self.data
  }
  
  func playPause() {
    player?.playPause()
  }
  
  func nextTrack() {
    player?.skipToNextItem()
    if !getPlaybackStatus() {
      player?.playPause()
    }
  }
  
  func fetch() -> DockData {
    getTrackInfo()
    let newData = DockData(artist: getArtist(), album: getAlbum(), song: getSong(), artwork: getArtwork(), playing: getPlaybackStatus())
    self.data.update(other: newData)
    didFetch = true
    return self.data
  }

  private func getTrackInfo() {
    ArtworkLoader.default.fetchArtwork()
  }
}

