public extension SAFormValidationRules {
    /// Creates a validation builder for a custom value type.
    ///
    /// Use this to build rules for any type that conforms to `Sendable`.
    ///
    /// - Returns: A custom type validation builder for chaining rules.
    func custom<CustomType>() -> SAFormCustomTypeValidation<CustomType> {
        .init()
    }

    /// Creates a validation builder for a specific custom value type.
    ///
    /// Use this overload when you want to pass the type explicitly.
    ///
    /// - Parameter type: The custom type to validate (for example, `User.self`).
    /// - Returns: A custom type validation builder for chaining rules.
    func custom<CustomType>(_ type: CustomType.Type) -> SAFormCustomTypeValidation<CustomType> {
        .init()
    }

}

/// A validation builder for arbitrary value types.
public struct SAFormCustomTypeValidation<CustomType: Sendable>: SAFormValidationTypeRules {
    public var rules: [(_ value: CustomType) async -> SAFormValidationResponse<CustomType>] = []
}
