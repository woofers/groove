import SwiftUI

struct OptionalView<Value, T: View>: View {
  let content: T

  init?(_ value: Value?, @ViewBuilder content: (Value) -> T) {
    guard let value = value else { return nil }
    self.content = content(value)
  }

  var body: some View {
    content
  }
}
