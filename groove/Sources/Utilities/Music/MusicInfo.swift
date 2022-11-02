import Combine
import MusicPlayer
import SwiftUI

class MusicInfo {
  private var name: PlayerApp
  private var data: DockData
  
  private var player: MusicPlayers.Scriptable?
  private var loader: ArtworkLoader?
  
  private var updateView: () -> Void

  private var subs = Set<AnyCancellable>()

  enum Action {
    case skip, playPause, none
  }

  enum PlayerApp: String {
    case appleMusic = "Music"
    case spotify = "Spotify"

    static let allCases: [PlayerApp] = [.spotify, .appleMusic]

    func getAppId() -> String {
      switch self {
      case .spotify:
        return "com.spotify.client"
      case .appleMusic:
        if #available(OSX 10.15, *) {
          return "com.apple.Music"
        } else {
          return "com.apple.itunes"
        }
      }
    }
    
    func getInternalPlayer() -> MusicPlayerName {
      switch self {
      case .spotify:
        return .spotify
      case .appleMusic:
        return .appleMusic
      }
    }

    static func from(_ value: String) -> PlayerApp {
      switch value {
      case spotify.rawValue:
        return .spotify
      case appleMusic.rawValue:
        return .appleMusic
      default:
        return .spotify
      }
    }
  }

  init(_ updateView: @escaping () -> Void) {
    let player = MusicInfo.getPlayer()
    self.name = player
    self.data = DockData(artist: "", album: "", song: "", artwork: nil, playing: false)
    self.updateView = updateView
    NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)
    setUpPlayer()
  }
  
  private func setUpPlayer() {
    self.player = MusicPlayers.Scriptable(name: name.getInternalPlayer())
    self.loader = ArtworkLoader(player: name)
    
    if let controller = self.player {
      Publishers.CombineLatest(controller.currentTrackWillChange, controller.playbackStateWillChange)
        .throttle(for: .milliseconds(200),
                  scheduler: DispatchQueue.main,
                  latest: true)
        .sink { [weak self] event in
          let next = event.0
          let state = event.1
          if (state == .stopped || (next == nil && state == .playing(time: 0))) && (self?.isSpotify() ?? false) {
            return
          }
          self?.update()
        }
        .store(in: &subs)
    }
  }
  
  private func tearDownPlayer() {
    for sub in subs { sub.cancel() }
  }
  
  private func resetPlayer() {
    tearDownPlayer()
    setUpPlayer()
  }
  
  @objc func userDefaultsDidChange(_ notification: Notification) {
    self.name = AppSettings.default.player()
    resetPlayer()
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
    tearDownPlayer()
    NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
  }

  static func getPlayer() -> PlayerApp {
    return AppSettings.default.player()
  }

  func getPlayer() -> PlayerApp {
    return name
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
    return loader?.getArtwork()
  }

  func getPlaybackStatus() -> Bool {
    return internalPlaybackStatus()
  }

  func getData() -> DockData {
    return data
  }
  
  func isEmpty() -> Bool {
    return getData().isEmpty()
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
        if !isAppleMusic() || newData.song != "Connecting…" {
          await self.data.update(other: newData)
        }
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
      try await loader?.getArtworkAsync()
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
