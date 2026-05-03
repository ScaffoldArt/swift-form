import Foundation

public extension SAFormValidationRules {
    /// Creates a validation builder for `Bool` values.
    ///
    /// - Returns: A boolean validation builder for chaining rules.
    func boolean() -> SAFormBooleanValidation {
        .init()
    }
}

/// A validation builder for `Bool` values that supports composing multiple rules.
public struct SAFormBooleanValidation: SAFormValidationTypeRules {
    public var rules: [(_ value: Bool) async -> SAFormValidationResponse<Bool>] = []

    /// Validates that the value is `true`.
    ///
    /// - Parameter LocalizedStringResource: The error message returned when the value is `false`.
    /// - Returns: The validation builder for chaining.
    public func checked(message: LocalizedStringResource? = nil) -> Self {
        addRule { value in
            if !value {
                return .failure(errors: .init([message ?? localizations.required]))
            }

            return .success(value: value)
        }
    }
}
