import SwiftUI

class AppSettings {
  static let `default` = AppSettings()
  
  private init() {}
  
  static func player() -> String? {
    UserDefaults.standard.string(forKey: "player")
  }
  
  static func resetSettings() {
    let domain = Bundle.main.bundleIdentifier
    guard let id = domain else { return }
    UserDefaults.standard.removePersistentDomain(forName: id)
    UserDefaults.standard.synchronize()
  }
  
  private func readPropertyList() -> [String: Any]? {
    if let plistPath = Bundle.main.path(forResource: "DefaultValues", ofType: "plist") {
      if let plistData = FileManager.default.contents(atPath: plistPath) {
        do {
          let data = try PropertyListSerialization.propertyList(from: plistData, format: nil)
          let asDict = data as? [String: Any]
          return asDict
        } catch {
          print(error)
        }
      }
    }
    return nil
  }
  
  func setDefaults() {
    let userDefaults = UserDefaults.standard
    if let defaultValues = readPropertyList() {
      userDefaults.register(defaults: defaultValues)
    }
  }
}
