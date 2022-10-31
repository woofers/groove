import SwiftUI

struct DockOverlay: View {
  var body: some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(.black)
  }
}

struct DockImage: View {
  @EnvironmentObject var data: DockData

  func getFallbackIcon() -> NSImage {
    let player = AppSettings.default.player()
    if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: player.getAppId()) {
      return NSWorkspace.shared.icon(forFile: url.path)
    }
    if let app = NSRunningApplication.runningApplications(withBundleIdentifier: player.getAppId()).first,
       let icon = app.icon {
        return icon
    }
    return NSImage(systemSymbolName: "rectangle.portrait.and.arrow.right.fill", accessibilityDescription: nil)!
  }

  func getIcon() -> NSImage {
    if let artwork = data.artwork {
      return artwork
    }
    return getFallbackIcon()
  }
  
  func hasInfo() -> Bool {
    return !data.isEmpty()
  }
  
  func hasArtwork() -> Bool {
    return data.artwork != nil
  }

  var body: some View {
    VStack {
      If(hasInfo()) {
        VStack {
          ZStack {
            If(hasArtwork()) {
              Image(nsImage: getIcon())
                .interpolation(.high)
                .antialiased(true)
                .resizable()
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.36), radius: 1, x: 1, y: 2)
                DockOverlay().opacity(0.3)
            }
            If(!hasArtwork()) {
              DockOverlay()
            }
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
      If(!hasInfo()) {
        VStack {
          Image(nsImage: getFallbackIcon())
            .interpolation(.high)
            .antialiased(true)
            .resizable()
        }
      }
    }
  }
}
