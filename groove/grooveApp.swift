import AppleScriptObjC
import DSFDockTile
import MediaPlayer
import SwiftUI

class DockData: ObservableObject {
  @Published var artist: String
  @Published var album: String
  @Published var song: String
  @Published var artwork: NSImage?
  @Published var playing: Bool

  init(artist: String, album: String, song: String, artwork: NSImage? = nil, playing: Bool) {
    self.artist = artist
    self.album = album
    self.song = song
    self.artwork = artwork
    self.playing = playing
  }

  func update(other: DockData) {
    self.artist = other.artist
    self.album = other.album
    self.song = other.song
    self.artwork = other.artwork
    self.playing = other.playing
  }
  
  func isEqual(other: DockData) -> Bool {
    let artist = self.artist == other.artist
    let album = self.album == other.album
    let song = self.song == other.song
    let artwork = self.artwork?.isEqual(to: other.artwork) ?? true
    let playing = self.playing == other.playing
    return artist && album && song && artwork && playing
  }
}

struct DockImage: View {
  @EnvironmentObject var data: DockData

  var body: some View {
    VStack {
      ZStack {
        Image(nsImage: data.artwork!)
          .interpolation(.high)
          .antialiased(true)
          .resizable()
          .cornerRadius(16)
          .shadow(color: .black.opacity(0.36), radius: 1, x: 1, y: 2)
        RoundedRectangle(cornerRadius: 16)
          .fill(.black)
          .opacity(0.3)
        VStack {
          Text("\(data.song)").foregroundColor(.white).font(Font.body.weight(.semibold))
          Text("\(data.artist)").foregroundColor(.white).font(Font.body.weight(.semibold))
        }
        .padding(4).opacity(data.playing ? 1 : 0)
        Image(systemName: data.playing ? "pause.fill" : "play.fill")
          .interpolation(.high)
          .antialiased(true)
          .resizable()
          .shadow(color: .black.opacity(0.36), radius: 1, x: 1, y: 2)
          .frame(width: 32, height: 32)
          .foregroundColor(.white)
          .opacity(!data.playing ? 0.85 : 0)
      }
    }.padding(12)
  }
}

class DockViewController: NSViewController {
  var dockData: DockData?
  override func loadView() {
    view = NSView()
    if let data = dockData {
      let content = DockImage().environmentObject(data)
      let view = NSHostingView(rootView: content)
      view.frame = NSRect(x: 0, y: 0, width: 128, height: 128)
      self.view.addSubview(view)
    }
  }

  func update(_ dockData: DockData) {
    self.dockData = dockData
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  var iTunesBridge: iTunesBridge?
  var dockViewController = DockViewController()
  var data = DockData(artist: "", album: "", song: "", artwork: nil, playing: false)

  lazy var updateDockTile: DSFDockTile.View = {
    dockViewController.loadView()
    return DSFDockTile.View(dockViewController)
  }()

  func loadApplescript() async -> iTunesBridge {
    Bundle.main.loadAppleScriptObjectiveCScripts()
    let iTunesBridgeClass: AnyClass = NSClassFromString("iTunesBridge")!
    let iTunesBridge = iTunesBridgeClass.alloc() as! iTunesBridge
    return iTunesBridge
  }

  func getDockData() -> DockData? {
    guard let bridge = iTunesBridge else { return nil }
    if let song = bridge.trackInfo {
      let artist = song["trackArtist"] as! String
      let album = song["trackAlbum"] as! String
      let name = song["trackName"] as! String
      let playing = bridge.playerState == .playing
      let artwork = bridge.artwork
      return DockData(artist: artist, album: album, song: name, artwork: artwork, playing: playing)
    }
    return nil
  }

  func updateTile() {
    if let newData = getDockData() {
      self.data.update(other: newData)
      self.dockViewController.update(self.data)
      self.updateDockTile.display()
    }
  }

  func applicationDidBecomeActive(_: Notification) {
    // print("active")
    // iTunesBridge?.playPause()
  }

  func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
    print("reopen")
    self.iTunesBridge?.playPause()
    self.updateTile()

    return true
  }

  func applicationDidFinishLaunching(_: Notification) {
    Task { [weak self] in
      do {
        self?.iTunesBridge = await self?.loadApplescript()
        self?.updateTile()
      }
    }
  }

  func applicationWillTerminate(_: Notification) {}
}
