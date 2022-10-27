import AppleScriptObjC
import MusicPlayer
import SwiftUI

class MusicInfo {
  private var player: MusicPlayers.Scriptable?
  private var data: DockData
  private var loader: ArtworkLoader
  private var didFetch = false
  private var playing = false
  private var hasPlayingStatus = false
  
  enum Action {
    case skip, playPause, none
  }
  
  enum PlayerApp: String {
    case appleMusic = "Music"
    case spotify = "Spotify"
    
    func getInternalPlayer() -> MusicPlayerName {
      switch self {
      case .spotify:
        return .spotify
      case .appleMusic:
        return .appleMusic
      }
    }
  }
   
  init() {
    let player = MusicInfo.getPlayer()
    self.data = DockData(artist: "", album: "", song: "", artwork: nil, playing: false)
    self.player = MusicPlayers.Scriptable(name: player.getInternalPlayer())
    self.loader = ArtworkLoader(player: player)
  }
  
  private func unwrapAsString(_ value: AnyObject?) -> String {
    if let casted = value as? String {
      return casted
    }
    return ""
  }
  
  static func getPlayer() -> PlayerApp {
    return .spotify
  }
  
  func getPlayer() -> PlayerApp {
    return MusicInfo.getPlayer()
  }
  
  func isSpotify() -> Bool {
    return getPlayer() == .spotify
  }
  
  func isAppleMusic() -> Bool {
    return getPlayer() == .appleMusic
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
    return self.loader.getArtwork()
  }
  
  func getPlaybackStatus() -> Bool {
    return internalPlaybackStatus()
  }
  
  func getData() -> DockData {
    return data
  }
  
  func playPause() {
    player?.playPause()
  }
  
  func nextTrack() {
    player?.skipToNextItem()
    if !getPlaybackStatus() && isAppleMusic() {
      player?.playPause()
    }
  }
  
  func perform(_ action: Action) async {
    if action == .playPause {
      playPause()
      try? await Task.sleep(nanoseconds: 50_000_000)
    } else if action == .skip {
      nextTrack()
      // Acount for time for Spotify/Apple Music to update
      try? await Task.sleep(nanoseconds: 100_000_000)
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
    return data
  }

  private func getTrackInfo() async {
    do {
      try await self.loader.getArtworkAsync()
    } catch {
      print(error)
    }
    if !hasPlayingStatus {
      playing = internalPlaybackStatus()
      hasPlayingStatus = true
    }
  }
  
  private func internalPlaybackStatus() -> Bool {
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
}
