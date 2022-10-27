import SwiftUI
import AppleScriptObjC
import MusicPlayer

class MusicInfo {
  
  private var player: MusicPlayers.Scriptable?
  private var data: DockData
  private var didFetch = false
 
  nonisolated init() {
    self.player = MusicPlayers.Scriptable(name: .appleMusic)
    self.data = DockData(artist: "", album: "", song: "", artwork: nil, playing: false)
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
  
  func fetch() async -> DockData {
    let task = Task {
      do {
        await getTrackInfo()
        let newData = DockData(artist: getArtist(), album: getAlbum(), song: getSong(), artwork: getArtwork(), playing: getPlaybackStatus())
        await self.data.update(other: newData)
        didFetch = true
      }
    }
    _ = await task.result
    return self.data
  }

  private func getTrackInfo() async {
    do {
      let loader = ArtworkLoader.default
      try await loader.getArtworkAsync()
    } catch {
      print(error)
    }
  }
}

