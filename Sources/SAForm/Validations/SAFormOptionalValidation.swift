public extension SAFormValidationTypeRules {
    /// Wraps the current validation rules to allow `nil` values.
    ///
    /// - Returns: An optional validation builder that applies the base rules only when a value is present.
    func optional() -> SAFormOptionalValidation<Self> {
        .init(base: self)
    }
}

/// A validation builder that makes any underlying validator optional.
///
/// The wrapped `base` validation is executed only when the value is non-`nil`.
public struct SAFormOptionalValidation<Base: SAFormValidationTypeRules>: SAFormValidationTypeRules {
    public typealias Value = Base.Value?

    public var rules: [(Value) async -> SAFormValidationResponse<Value>] = []

    public let base: Base

    /// Validates an optional value by applying the `base` validator when a value is present.
    ///
    /// - Parameter value: The value to validate.
    /// - Returns: A `SAFormValidationResponse<Value>` that is either:
    ///   - `.success` if the value is `nil` or if the non-`nil` value passes the base validation, or
    ///   - `.error` with the message from the base validation when it fails.
    public func validate(value: Value) async -> SAFormValidationResponse<Value> {
        if let value {
            let result = await base.validate(value: value)

            switch result {
            case .success(let value):
                return .success(value: value)
            case .failure(let failure):
                return .failure(errors: failure)
            }
        }

        return .success(value: value)
    }
}
