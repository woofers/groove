import SwiftUI

postfix operator ~
postfix func ~ (string: String) -> String {
  return NSLocalizedString(string, comment: "")
}

extension String {
  func trimmingLeadingAndTrailingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
    return trimmingCharacters(in: characterSet)
  }

  func encodeText(_ key: Int) -> String {
    var result = ""
    for c in self.unicodeScalars {
      result.append(Character(UnicodeScalar(UInt32(Int(c.value) + key))!))
    }
    return result
  }
  
  func truncate(_ amount: Int, after: String = "") -> String {
    let sub = self.prefix(amount)
    return String(sub).trimmingLeadingAndTrailingSpaces() + after
  }
}
