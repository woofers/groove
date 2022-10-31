import SwiftUI

struct DockImage: View {
  @EnvironmentObject var data: DockData

  func getFallbackIcon() -> NSImage {
    return NSImage(systemSymbolName: "rectangle.portrait.and.arrow.right.fill", accessibilityDescription: nil)!
  }

  func getIcon() -> NSImage {
    if let artwork = data.artwork {
      return artwork
    }
    return getFallbackIcon()
  }

  var body: some View {
    VStack {
      ZStack {
        Image(nsImage: getIcon())
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
