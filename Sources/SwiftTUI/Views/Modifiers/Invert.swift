public extension View {
 func inverted(_ isActive: Bool = true) -> some View {
  environment(\.inverted, isActive)
 }
}

private struct InvertedEnvironmentKey: EnvironmentKey {
 static var defaultValue: Bool { false }
}

extension EnvironmentValues {
 var inverted: Bool {
  get { self[InvertedEnvironmentKey.self] }
  set { self[InvertedEnvironmentKey.self] = newValue }
 }
}
