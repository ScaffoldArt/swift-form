import Testing
@testable import SAForm

/// Asserts that validation succeeds and returns the expected value.
///
/// - Parameters:
///   - validator: The validation builder to test.
///   - value: The value to validate.
///   - expected: The expected value after validation (defaults to the input value).
///   - sourceLocation: The source location for test failure reporting.
func assertValidationSuccess<V: SAFormValidationTypeRules>(
    _ validator: V,
    value: V.Value,
    expected: V.Value? = nil,
    sourceLocation: SourceLocation = #_sourceLocation
) async where V.Value: Equatable {
    let result = await validator.validate(value: value)

    switch result {
    case .success(let resultValue):
        #expect(resultValue == (expected ?? value), sourceLocation: sourceLocation)
    case .failure(let errors):
        Issue.record(
            "Expected success but got failure: \(errors.messages)",
            sourceLocation: sourceLocation
        )
    }
}

/// Asserts that validation fails for the given value.
///
/// - Parameters:
///   - validator: The validation builder to test.
///   - value: The value to validate.
///   - sourceLocation: The source location for test failure reporting.
func assertValidationFailure<V: SAFormValidationTypeRules>(
    _ validator: V,
    value: V.Value,
    sourceLocation: SourceLocation = #_sourceLocation
) async {
    let result = await validator.validate(value: value)

    switch result {
    case .success(let resultValue):
        Issue.record(
            "Expected failure but got success with value: \(resultValue)",
            sourceLocation: sourceLocation
        )
    case .failure:
        break
    }
}
