#if canImport(Combine) || canImport(OpenCombine)
import Foundation
#if canImport(Combine)
import Combine
#else
@_exported import OpenCombine
#endif

@propertyWrapper
public struct ObservedObject<T: ObservableObject>: AnyObservedObject {
    public let initialValue: T

    public init(initialValue: T) {
        self.initialValue = initialValue
    }

    public init(wrappedValue: T) {
        self.initialValue = wrappedValue
    }

    public var wrappedValue: T {
        get { initialValue }
    }

    func subscribe(_ action: @escaping () -> Void) -> AnyCancellable {
        initialValue.objectWillChange.sink(receiveValue: { _ in action() })
    }
}

protocol AnyObservedObject {
    func subscribe(_ action: @escaping () -> Void) -> AnyCancellable
}

#endif
