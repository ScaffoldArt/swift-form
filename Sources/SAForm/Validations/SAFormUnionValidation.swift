//
//  SAFormUnionValidation.swift
//  SAForm
//
//  Created by Артем Дробышев on 05.09.2025.
//

import Foundation

public extension SAFormValidationRules {
    /// Validates a raw value against a union of validators using variadic generics.
    ///
    /// - Parameters:
    ///   - value: The untyped (raw) value to validate.
    ///   - rules: A variadic list of validators to attempt.
    /// - Returns: A `SAFormValidationResponse` that is either:
    ///   - `.success` with a tuple of optional validated values (one or more elements may be non-`nil`), or
    ///   - `.failure` with merged error messages if none of the validators accept the value.
    func union<
        each Rule: SAFormValidationTypeRules
    >(
        _ value: Any,
        _ rules: repeat each Rule
    ) async -> SAFormValidationResponse<(repeat ((each Rule).Value)?)> {
        let results = await (repeat (each rules).validate(raw: value))

        var errors: [LocalizedStringResource] = []
        for result in repeat each results {
            switch result {
            case .success:
                return .success(value: (repeat (each results).value))
            case .failure(let failure):
                errors += failure.messages
            }
        }

        return .failure(errors: .init(errors))
    }
}
