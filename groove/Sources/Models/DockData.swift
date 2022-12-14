import SwiftUI

class DockData: ObservableObject, Identifiable {
  @Published var artist: String
  @Published var album: String
  @Published var song: String
  @Published var artwork: NSImage?
  @Published var playing: Bool

  public var id: String {
    get {
      "[\(song) - \(artist) - \(album) | \(playing ? "Playing" : "Paused") \(artwork.hashValue)]"
    }
  }
  
  public var description: String {
    if isEmpty() { return "No track playing" }
    return "\(song) - \(artist) - \(album)"
  }
  
  init(artist: String, album: String, song: String, artwork: NSImage? = nil, playing: Bool) {
    self.artist = artist
    self.album = album
    self.song = song
    self.playing = playing
    self.artwork = artwork
  }

  @MainActor
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
  
  func isEmpty() -> Bool {
    return !playing && song == ""
  }
}
