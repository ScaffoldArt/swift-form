import Foundation

public extension SAFormValidationRules {
    /// Creates a validation builder for `Decimal` values.
    ///
    /// - Returns: A decimal validation builder for chaining rules.
    func decimal() -> SAFormDecimalValidation {
        .init()
    }
}

/// A validation builder for `Decimal` values that supports composing multiple rules.
public struct SAFormDecimalValidation: SAFormValidationTypeRules {
    public var rules: [(_ value: Decimal) async -> SAFormValidationResponse<Decimal>] = []

    /// Validates that the value is strictly greater than the specified number.
    ///
    /// - Parameters:
    ///   - num: The exclusive lower bound.
    ///   - message: The error message returned when the value is not greater than `num`.
    /// - Returns: The validation builder for chaining.
    public func gt(
        num: Decimal,
        message: ((Decimal) -> LocalizedStringResource)? = nil
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
        num: Decimal,
        message: ((Decimal) -> LocalizedStringResource)? = nil
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
        num: Decimal,
        message: ((Decimal) -> LocalizedStringResource)? = nil
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
        num: Decimal,
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            if value > num {
                return .failure(errors: .init([message ?? localizations.lte(String(describing: num))]))
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
    ) -> Self {
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
    ) -> Self {
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
    ) -> Self {
        addRule { value in
            if value > 0 {
                return .failure(errors: .init([message ?? localizations.nonPositive]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is evenly divisible by the specified multiplier.
    ///
    /// - Parameters:
    ///   - mult: The multiplier (divisor). If zero, validation fails.
    ///   - message: The error message returned when the value is not a multiple of `mult`.
    /// - Returns: The validation builder for chaining.
    public func multipleOf(
        mult: Decimal,
        message: ((Decimal) -> LocalizedStringResource)? = nil
    ) -> Self {
        addRule { value in
            let errorMessage = message?(mult) ?? localizations.multipleOf(String(describing: mult))

            guard mult != 0 else {
                return .failure(errors: .init([errorMessage]))
            }

            let quotient = value / mult
            let truncated = Decimal(Double(trunc(Double(truncating: quotient as NSNumber))))

            if value - (mult * truncated) != 0 {
                return .failure(errors: .init([errorMessage]))
            }

            return .success(value: value)
        }
    }
}
