import Foundation
import Testing
@testable import SAForm

struct SAFormIntegerValidationTests {
    let rules = SAFormValidationRules()

    @Test("integer(type): supports explicit integer type")
    func explicitIntegerType() async {
        let validator = rules.integer(Int64.self).gte(num: 5)

        await assertValidationSuccess(validator, value: 5)
        await assertValidationFailure(validator, value: 4)
    }

    @Test("integer(type): supports unsigned integer type for applicable rules")
    func explicitUnsignedIntegerType() async {
        let validator = rules.integer(UInt.self).positive().multipleOf(num: 2)

        await assertValidationSuccess(validator, value: 2)
        await assertValidationFailure(validator, value: 0)
        await assertValidationFailure(validator, value: 3)
    }

    // MARK: - gt
    @Test("gt: succeeds when value > num")
    func gtSuccess() async {
        await assertValidationSuccess(rules.integer().gt(num: 5), value: 6)
    }
    @Test("gt: fails when value <= num")
    func gtFailure() async {
        await assertValidationFailure(rules.integer().gt(num: 5), value: 5)
        await assertValidationFailure(rules.integer().gt(num: 5), value: 4)
    }

    // MARK: - gte
    @Test("gte: succeeds when value >= num")
    func gteSuccess() async {
        await assertValidationSuccess(rules.integer().gte(num: 5), value: 5)
        await assertValidationSuccess(rules.integer().gte(num: 5), value: 6)
    }
    @Test("gte: fails when value < num")
    func gteFailure() async {
        await assertValidationFailure(rules.integer().gte(num: 5), value: 4)
    }

    // MARK: - lt
    @Test("lt: succeeds when value < num")
    func ltSuccess() async {
        await assertValidationSuccess(rules.integer().lt(num: 5), value: 4)
    }
    @Test("lt: fails when value >= num")
    func ltFailure() async {
        await assertValidationFailure(rules.integer().lt(num: 5), value: 5)
        await assertValidationFailure(rules.integer().lt(num: 5), value: 6)
    }

    // MARK: - lte
    @Test("lte: succeeds when value <= num")
    func lteSuccess() async {
        await assertValidationSuccess(rules.integer().lte(num: 5), value: 5)
        await assertValidationSuccess(rules.integer().lte(num: 5), value: 4)
    }
    @Test("lte: fails when value > num")
    func lteFailure() async {
        await assertValidationFailure(rules.integer().lte(num: 5), value: 6)
    }

    // MARK: - positive
    @Test("positive: succeeds for value > 0")
    func positiveSuccess() async {
        await assertValidationSuccess(rules.integer().positive(), value: 1)
        await assertValidationSuccess(rules.integer().positive(), value: 100)
    }
    @Test("positive: fails for value <= 0")
    func positiveFailure() async {
        await assertValidationFailure(rules.integer().positive(), value: 0)
        await assertValidationFailure(rules.integer().positive(), value: -1)
    }

    // MARK: - nonNegative
    @Test("nonNegative: succeeds for value >= 0")
    func nonNegativeSuccess() async {
        await assertValidationSuccess(rules.integer().nonNegative(), value: 0)
        await assertValidationSuccess(rules.integer().nonNegative(), value: 1)
    }
    @Test("nonNegative: fails for value < 0")
    func nonNegativeFailure() async {
        await assertValidationFailure(rules.integer().nonNegative(), value: -1)
    }

    // MARK: - negative
    @Test("negative: succeeds for value < 0")
    func negativeSuccess() async {
        await assertValidationSuccess(rules.integer().negative(), value: -1)
    }
    @Test("negative: fails for value >= 0")
    func negativeFailure() async {
        await assertValidationFailure(rules.integer().negative(), value: 0)
        await assertValidationFailure(rules.integer().negative(), value: 1)
    }

    // MARK: - nonPositive
    @Test("nonPositive: succeeds for value <= 0")
    func nonPositiveSuccess() async {
        await assertValidationSuccess(rules.integer().nonPositive(), value: 0)
        await assertValidationSuccess(rules.integer().nonPositive(), value: -1)
    }
    @Test("nonPositive: fails for value > 0")
    func nonPositiveFailure() async {
        await assertValidationFailure(rules.integer().nonPositive(), value: 1)
    }

    // MARK: - multipleOf
    @Test("multipleOf: succeeds for divisible values")
    func multipleOfSuccess() async {
        await assertValidationSuccess(rules.integer().multipleOf(num: 3), value: 12)
        await assertValidationSuccess(rules.integer().multipleOf(num: 5), value: -10)
    }
    @Test("multipleOf: fails for non-divisible values")
    func multipleOfFailure() async {
        await assertValidationFailure(rules.integer().multipleOf(num: 4), value: 10)
    }
    @Test("multipleOf: fails for zero divisor")
    func multipleOfZeroFailure() async {
        await assertValidationFailure(rules.integer().multipleOf(num: 0), value: 10)
    }
}
