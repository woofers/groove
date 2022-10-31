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

struct If<T: View>: View {
  let data: Bool
  let content: T

  init?(_ data: Bool, @ViewBuilder content: () -> T) {
    self.data = data
    self.content = content()
  }

  var body: some View {
    if (data) {
      content
    } else {
      EmptyView()
    }
  }
}
