import Foundation
import Testing
@testable import SAForm

struct SAFormOptionalValidationTests {
    let rules = SAFormValidationRules()

    // MARK: - Optional string (notEmpty)
    @Test("optional: succeeds for nil value")
    func optionalNilSuccess() async {
        let validator = rules.string().notEmpty().optional()
        await assertValidationSuccess(validator, value: nil)
    }

    @Test("optional: succeeds for valid non-nil value")
    func optionalNonNilSuccess() async {
        let validator = rules.string().notEmpty().optional()
        await assertValidationSuccess(validator, value: "hello")
    }

    @Test("optional: fails for invalid non-nil value")
    func optionalNonNilFailure() async {
        let validator = rules.string().notEmpty().optional()
        await assertValidationFailure(validator, value: "")
    }

    // MARK: - Optional integer (gt)
    @Test("optional: succeeds for nil integer")
    func optionalIntNilSuccess() async {
        let validator = rules.integer().gt(num: 0).optional()
        await assertValidationSuccess(validator, value: nil)
    }

    @Test("optional: succeeds for valid non-nil integer")
    func optionalIntNonNilSuccess() async {
        let validator = rules.integer().gt(num: 0).optional()
        await assertValidationSuccess(validator, value: 1)
    }

    @Test("optional: fails for invalid non-nil integer")
    func optionalIntNonNilFailure() async {
        let validator = rules.integer().gt(num: 0).optional()
        await assertValidationFailure(validator, value: 0)
    }
}
