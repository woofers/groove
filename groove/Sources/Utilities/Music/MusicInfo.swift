import AppleScriptObjC
import Combine
import MusicPlayer
import SwiftUI

class MusicInfo {
  private var player: MusicPlayers.Scriptable?
  private var data: DockData
  private var loader: ArtworkLoader
  private var didFetch = false
  private var updateView: () -> Void

  private var subs = Set<AnyCancellable>()

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

  init(_ updateView: @escaping () -> Void) {
    let player = MusicInfo.getPlayer()
    self.data = DockData(artist: "", album: "", song: "", artwork: nil, playing: false)
    self.player = MusicPlayers.Scriptable(name: player.getInternalPlayer())
    self.loader = ArtworkLoader(player: player)
    self.updateView = updateView
    if let controller = self.player {
      Publishers.CombineLatest(controller.currentTrackWillChange, controller.playbackStateWillChange)
        .throttle(for: .milliseconds(200),
                  scheduler: DispatchQueue.main,
                  latest: true)
        .sink { [weak self] event in
          print(event)
          self?.update()
        }
        .store(in: &subs)
    }
  }
  
  func update() {
    Task { [weak self] in
      do {
        await self?.fetch()
        self?.updateView()
      }
    }
  }
  
  func destroy() {
    for sub in subs { sub.cancel() }
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
    return loader.getArtwork()
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
    if !getPlaybackStatus(), isAppleMusic() {
      player?.playPause()
    }
  }

  func perform(_ action: Action) {
    if action == .playPause {
      playPause()
    } else if action == .skip {
      nextTrack()
    }
  }

  @discardableResult
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

  private func delay(_ delay: TimeInterval) async {
    let nano = UInt64(delay * 1_000_000_000)
    try? await Task.sleep(nanoseconds: nano)
  }

  private func getTrackInfo() async {
    do {
      try await loader.getArtworkAsync()
    } catch {
      print(error)
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
