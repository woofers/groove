import SwiftUI
import AnyCodable

extension URL {
  func append(path: String, isDirectory: Bool) -> URL {
    return self.appendingPathComponent(path, isDirectory: isDirectory)
  }
}

class Files {
  static let `default` = Files()
  
  private init() {
    
  }
  
  func getUserScopedPath(_ mask: FileManager.SearchPathDirectory) -> URL? {
    let results = FileManager.default.urls(for: mask, in: .userDomainMask)
    return results.first
  }
  
  func getLibraryPath() -> URL? {
    getUserScopedPath(.libraryDirectory)
  }

  func getPreferencesPath() -> URL? {
    if let root = getLibraryPath() {
      return root.append(path: "Preferences/", isDirectory: true)
    }
    return nil
  }
  
  func getDockInfoPath() -> URL? {
    if let prefs = getPreferencesPath() {
      return prefs.append(path: "com.apple.dock.plist", isDirectory: false)
    }
    return nil
  }

}
