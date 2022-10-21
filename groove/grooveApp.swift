import AppleScriptObjC
import DSFDockTile
import MediaPlayer
import SwiftUI

@main
struct grooveApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      ZStack {
        ContentView()
      }
    }
  }
}

struct DockData {
  let artist: String
  let album: String
  let song: String
  let artwork: NSImage
}

struct DockImage: View {
  let data: DockData

  var body: some View {
    VStack {
      ZStack {
        Image(nsImage: data.artwork).interpolation(.high).antialiased(true).resizable().cornerRadius(12).shadow(color: .black.opacity(0.36), radius: 1, x: 1, y: 2)
        RoundedRectangle(cornerRadius: 12).fill(.black).opacity(0.3)
        Text("\(data.song) - \(data.artist)").foregroundColor(.white).font(Font.body.weight(.semibold)).padding(4)
      }
    }.padding(12)
  }
}

class DockViewController: NSViewController {
  var dockData: DockData?

  override func loadView() {
    view = NSView()
    if let data = dockData {
      let view = NSHostingView(rootView: DockImage(data: data))
      view.frame = NSRect(x: 0, y: 0, width: 128, height: 128)
      self.view.addSubview(view)
    }
  }

  func update(_ dockData: DockData) {
    self.dockData = dockData
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  var iTunesBridge: iTunesBridge

  var dockViewController = DockViewController()

  lazy var updateDockTile: DSFDockTile.View = {
    dockViewController.loadView()
    return DSFDockTile.View(dockViewController)
  }()

  override init() {
    Bundle.main.loadAppleScriptObjectiveCScripts()
    let iTunesBridgeClass: AnyClass = NSClassFromString("iTunesBridge")!
    self.iTunesBridge = iTunesBridgeClass.alloc() as! iTunesBridge
    super.init()
  }

  func applicationDidFinishLaunching(_: Notification) {
    if let song = iTunesBridge.trackInfo {
      let artist = song["trackArtist"] as! String
      let album = song["trackAlbum"] as! String
      let name = song["trackName"] as! String
      if let artwork = iTunesBridge.artwork {
        dockViewController.update(DockData(artist: artist, album: album, song: name, artwork: artwork))
      }
    }

    updateDockTile.display()
  }

  func applicationWillTerminate(_: Notification) {}
}
