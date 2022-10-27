//
//  ArtworkLoader.swift
//  groove
//
//  Created by Jaxson Van Doorn on 2022-10-27.
//

import SwiftUI

enum ArtworkError: Error {
  case noImageData
  case noImagePath
}

class ArtworkLoader {
  static let `default` = ArtworkLoader()
  
  var artwork: NSImage?
  
  private init() {}
  
  func getArtwork() -> NSImage? {
    return self.artwork
  }
  
  func fetchArtwork() {
   Task { [weak self] in
      do {
        self?.artwork = try await getArtworkAsync()
      } catch {
        print(error)
      }
    }
  }
  
  func getArtworkAsync() async throws -> NSImage {
    let data: NSImage = try await withCheckedThrowingContinuation { continuation in
      fetchArtworkFromAppleMusic { result in
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
    return data
  }
  
  private func fetchArtworkFromSpotify(completion: @escaping (Result<NSImage, Error>) -> Void) {
    let code = NSAppleScript.loadSpotifyAlbumArtwork()
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
    let code = NSAppleScript.itunesArtwork()
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
}
