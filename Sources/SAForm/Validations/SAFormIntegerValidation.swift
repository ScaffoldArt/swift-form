import Foundation

public extension SAFormValidationRules {
    /// Creates a validation builder for `Int` values.
    ///
    /// - Returns: An integer validation builder for chaining rules.
    func integer() -> SAFormIntegerValidation<Int> {
        .init()
    }

    /// Creates a validation builder for a specific integer type.
    ///
    /// - Parameter type: The integer type to validate (for example, `Int64.self`).
    /// - Returns: An integer validation builder for chaining rules.
    func integer<T: BinaryInteger & Sendable>(_ type: T.Type) -> SAFormIntegerValidation<T> {
        .init()
    }
}

/// A validation builder for integer values that supports composing multiple rules.
public struct SAFormIntegerValidation<T: BinaryInteger & Sendable>: SAFormValidationTypeRules {
    public var rules: [(_ value: T) async -> SAFormValidationResponse<T>] = []

    /// Validates that the value is strictly greater than the specified number.
    ///
    /// - Parameters:
    ///   - num: The exclusive lower bound.
    ///   - message: The error message returned when the value is not greater than `num`.
    /// - Returns: The validation builder for chaining.
    public func gt(
        num: T,
        message: ((T) -> LocalizedStringResource)? = nil
    ) -> Self {
        addRule { value in
            if value <= num {
                return .failure(errors: .init([message?(num) ?? localizations.gt(String(describing: num))]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is greater than or equal to the specified number.
    ///
    /// - Parameters:
    ///   - num: The inclusive lower bound.
    ///   - message: The error message returned when the value is less than `num`.
    /// - Returns: The validation builder for chaining.
    public func gte(
        num: T,
        message: ((T) -> LocalizedStringResource)? = nil
    ) -> Self {
        addRule { value in
            if value < num {
                return .failure(errors: .init([message?(num) ?? localizations.gte(String(describing: num))]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is strictly less than the specified number.
    ///
    /// - Parameters:
    ///   - num: The exclusive upper bound.
    ///   - message: The error message returned when the value is not less than `num`.
    /// - Returns: The validation builder for chaining.
    public func lt(
        num: T,
        message: ((T) -> LocalizedStringResource)? = nil
    ) -> Self {
        addRule { value in
            if value >= num {
                return .failure(errors: .init([message?(num) ?? localizations.lt(String(describing: num))]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is less than or equal to the specified number.
    ///
    /// - Parameters:
    ///   - num: The inclusive upper bound.
    ///   - message: The error message returned when the value is greater than `num`.
    /// - Returns: The validation builder for chaining.
    public func lte(
        num: T,
        message: ((T) -> LocalizedStringResource)? = nil
    ) -> Self {
        addRule { value in
            if value > num {
                return .failure(errors: .init([message?(num) ?? localizations.lte(String(describing: num))]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is positive (greater than zero).
    ///
    /// - Parameter message: The error message returned when the value is not positive.
    /// - Returns: The validation builder for chaining.
    public func positive(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            if value <= 0 {
                return .failure(errors: .init([message ?? localizations.positive]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is zero or positive.
    ///
    /// - Parameter message: The error message returned when the value is negative.
    /// - Returns: The validation builder for chaining.
    public func nonNegative(
        message: LocalizedStringResource? = nil
    ) -> Self where T: SignedInteger {
        addRule { value in
            if value < 0 {
                return .failure(errors: .init([message ?? localizations.nonNegative]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is negative (less than zero).
    ///
    /// - Parameter message: The error message returned when the value is not negative.
    /// - Returns: The validation builder for chaining.
    public func negative(
        message: LocalizedStringResource? = nil
    ) -> Self where T: SignedInteger {
        addRule { value in
            if value >= 0 {
                return .failure(errors: .init([message ?? localizations.negative]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is zero or negative.
    ///
    /// - Parameter message: The error message returned when the value is positive.
    /// - Returns: The validation builder for chaining.
    public func nonPositive(
        message: LocalizedStringResource? = nil
    ) -> Self where T: SignedInteger {
        addRule { value in
            if value > 0 {
                return .failure(errors: .init([message ?? localizations.nonPositive]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is evenly divisible by the specified number.
    ///
    /// - Parameters:
    ///   - num: The divisor. If zero, validation fails.
    ///   - message: The error message returned when the value is not a multiple of `num`.
    /// - Returns: The validation builder for chaining.
    public func multipleOf(
        num: T,
        message: ((T) -> LocalizedStringResource)? = nil
    ) -> Self {
        addRule { value in
            if num == 0 || value % num != 0 {
                return .failure(errors: .init([message?(num) ?? localizations.multipleOf(String(describing: num))]))
            }

            return .success(value: value)
        }
    }
}
