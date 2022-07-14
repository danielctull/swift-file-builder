
public protocol EnvironmentKey {
    associatedtype Value
    static var defaultValue: Value { get }
}

public struct EnvironmentValues {

    private var values: [ObjectIdentifier: Any] = [:]

    public subscript<Key: EnvironmentKey>(key: Key.Type) -> Key.Value {
        get { values[ObjectIdentifier(key)] as? Key.Value ?? Key.defaultValue }
        set { values[ObjectIdentifier(key)] = newValue }
    }
}

// MARK: - Modifier

extension Content {

    public func environment<Value>(
        _ keyPath: WritableKeyPath<EnvironmentValues, Value>,
        _ value: Value
    ) -> some Content {
        EnvironmentModifier(content: self) { $0[keyPath: keyPath] = value }
    }
}

private struct EnvironmentModifier<C: Content>: Content {

    let content: C
    let modify: (inout EnvironmentValues) -> ()

    var body: some Content {
        Builtin { environment in
            var environment = environment
            modify(&environment)
            return content.generate(environment: environment)
        }
    }
}

// MARK: - Property Wrapper

@propertyWrapper
public struct Environment<Value> {
    private let keyPath: KeyPath<EnvironmentValues, Value>
    @Box private var environment: EnvironmentValues? = nil

    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
    }

    public var wrappedValue: Value {
        guard let environment else { fatalError("Environment not set.") }
        return environment[keyPath: keyPath]
    }
}

@propertyWrapper
private final class Box<A> {
    var wrappedValue: A
    init(wrappedValue: A) {
        self.wrappedValue = wrappedValue
    }
}

private protocol SetEnvironmentValues {
    func setEnvironmentValues(_ environment: EnvironmentValues)
}

extension Environment: SetEnvironmentValues {

    fileprivate func setEnvironmentValues(_ environment: EnvironmentValues) {
        self.environment = environment
    }
}

extension Content {

    func install(_ environment: EnvironmentValues) {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let property = child.value as? SetEnvironmentValues {
                property.setEnvironmentValues(environment)
            }
        }
    }
}