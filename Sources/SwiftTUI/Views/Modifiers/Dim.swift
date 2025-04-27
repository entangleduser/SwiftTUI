public extension View {
    func dim(_ isActive: Bool = true) -> some View {
        environment(\.dim, isActive)
    }
}

private struct DimEnvironmentKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

extension EnvironmentValues {
    var dim: Bool {
        get { self[DimEnvironmentKey.self] }
        set { self[DimEnvironmentKey.self] = newValue }
    }
}
