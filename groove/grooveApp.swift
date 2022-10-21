//import DSFDockTile

import SwiftUI
import MediaPlayer

@main
struct grooveApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
      WindowGroup {
         ZStack {
            ContentView()
           /*
            DockTile(
               label: "3",
               content: ZStack {
                  Color.white
                  Text("hi")
               }
            )
            */
         }
      }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_: Notification) {
    let data = MPNowPlayingInfoCenter.default().nowPlayingInfo
    print("hi", data)
  }

  func toggleDock() {

  }

  func applicationWillTerminate(_: Notification) {

  }
}
