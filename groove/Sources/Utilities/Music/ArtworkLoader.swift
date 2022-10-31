import SwiftUI

enum ArtworkError: Error {
  case noImageData
  case noImagePath
}

class ArtworkLoader {
  private var artwork: NSImage?
  private let player: MusicInfo.PlayerApp
  
  init(player: MusicInfo.PlayerApp) {
    self.player = player
  }
  
  func getArtwork() -> NSImage? {
    return self.artwork
  }
 
  @discardableResult
  func getArtworkAsync() async throws -> NSImage {
    let data: NSImage = try await withCheckedThrowingContinuation { continuation in
      fetchArtwork { result in
        switch result {
        case .success(let image):
          continuation.resume(returning: image)
          return
        case .failure(let error):
          continuation.resume(throwing: error)
          return
        }
      }
    }
    self.artwork = data
    return data
  }
  
  private func fetchArtworkFromSpotify(completion: @escaping (Result<NSImage, Error>) -> Void) {
    let code = NSAppleScript.loadSpotifyArtwork()
    var error: NSDictionary?
    let script = NSAppleScript(source: code)
    let output = script?.executeAndReturnError(&error)
    let path = output?.stringValue ?? ""
    if path != "" {
      if let imageURL = URL(string: path) {
        let task = URLSession.shared.dataTask(with: imageURL, completionHandler: { maybeData, _, error in
          guard let data = maybeData, error == nil else {
            completion(.failure(error!))
            return
          }
          if let image = NSImage(data: data) {
            completion(.success(image))
            return
          }
          completion(.failure(ArtworkError.noImageData))
        })
        task.resume()
        return
      }
    }
    completion(.failure(ArtworkError.noImagePath))
  }
  
  private func fetchArtworkFromAppleMusic(completion: @escaping (Result<NSImage, Error>) -> Void) {
    let code = NSAppleScript.loadAppleMusicArtwork()
    var error: NSDictionary?
    let script = NSAppleScript(source: code)
    if let output = script?.executeAndReturnError(&error) {
      if let image = NSImage(data: output.data) {
        completion(.success(image))
        return
      }
    }
    completion(.failure(ArtworkError.noImageData))
  }
  
  private func fetchArtwork(completion: @escaping (Result<NSImage, Error>) -> Void) {
    if player == .appleMusic {
      fetchArtworkFromAppleMusic(completion: completion)
    } else {
      fetchArtworkFromSpotify(completion: completion)
    }
  }
}
