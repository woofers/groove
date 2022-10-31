import SwiftUI

struct DockImage: View {
  @EnvironmentObject var data: DockData

  var body: some View {
    VStack {
      ZStack {
        OptionalView(data.artwork) { artwork in
          Image(nsImage: artwork)
            .interpolation(.high)
            .antialiased(true)
            .resizable()
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.36), radius: 1, x: 1, y: 2)
        }
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
