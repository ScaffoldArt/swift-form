import Foundation
import Testing
@testable import SAForm

struct SAFormFloatingValidationTests {
    let rules = SAFormValidationRules()

    @Test("floating(type): supports explicit floating-point type")
    func explicitFloatingType() async {
        let validator = rules.floating(Double.self).gte(num: 5)

        await assertValidationSuccess(validator, value: 5)
        await assertValidationFailure(validator, value: 4.9)
    }

    // MARK: - gt
    @Test("gt: succeeds when value > num")
    func gtSuccess() async {
        await assertValidationSuccess(rules.floating().gt(num: 5), value: 6)
    }
    @Test("gt: fails when value <= num")
    func gtFailure() async {
        await assertValidationFailure(rules.floating().gt(num: 5), value: 5)
        await assertValidationFailure(rules.floating().gt(num: 5), value: 4.9)
    }

    // MARK: - gte
    @Test("gte: succeeds when value >= num")
    func gteSuccess() async {
        await assertValidationSuccess(rules.floating().gte(num: 5), value: 5)
        await assertValidationSuccess(rules.floating().gte(num: 5), value: 6)
    }
    @Test("gte: fails when value < num")
    func gteFailure() async {
        await assertValidationFailure(rules.floating().gte(num: 5), value: 4.9)
    }

    // MARK: - lt
    @Test("lt: succeeds when value < num")
    func ltSuccess() async {
        await assertValidationSuccess(rules.floating().lt(num: 5), value: 4.9)
    }
    @Test("lt: fails when value >= num")
    func ltFailure() async {
        await assertValidationFailure(rules.floating().lt(num: 5), value: 5)
        await assertValidationFailure(rules.floating().lt(num: 5), value: 6)
    }

    // MARK: - lte
    @Test("lte: succeeds when value <= num")
    func lteSuccess() async {
        await assertValidationSuccess(rules.floating().lte(num: 5), value: 5)
        await assertValidationSuccess(rules.floating().lte(num: 5), value: 4.9)
    }
    @Test("lte: fails when value > num")
    func lteFailure() async {
        await assertValidationFailure(rules.floating().lte(num: 5), value: 5.1)
    }

    // MARK: - positive
    @Test("positive: succeeds for value > 0")
    func positiveSuccess() async {
        await assertValidationSuccess(rules.floating().positive(), value: 0.1)
        await assertValidationSuccess(rules.floating().positive(), value: 100)
    }
    @Test("positive: fails for value <= 0")
    func positiveFailure() async {
        await assertValidationFailure(rules.floating().positive(), value: 0)
        await assertValidationFailure(rules.floating().positive(), value: -0.1)
    }

    // MARK: - nonNegative
    @Test("nonNegative: succeeds for value >= 0")
    func nonNegativeSuccess() async {
        await assertValidationSuccess(rules.floating().nonNegative(), value: 0)
        await assertValidationSuccess(rules.floating().nonNegative(), value: 1.5)
    }
    @Test("nonNegative: fails for value < 0")
    func nonNegativeFailure() async {
        await assertValidationFailure(rules.floating().nonNegative(), value: -0.1)
    }

    // MARK: - negative
    @Test("negative: succeeds for value < 0")
    func negativeSuccess() async {
        await assertValidationSuccess(rules.floating().negative(), value: -0.1)
    }
    @Test("negative: fails for value >= 0")
    func negativeFailure() async {
        await assertValidationFailure(rules.floating().negative(), value: 0)
        await assertValidationFailure(rules.floating().negative(), value: 0.1)
    }

    // MARK: - nonPositive
    @Test("nonPositive: succeeds for value <= 0")
    func nonPositiveSuccess() async {
        await assertValidationSuccess(rules.floating().nonPositive(), value: 0)
        await assertValidationSuccess(rules.floating().nonPositive(), value: -0.1)
    }
    @Test("nonPositive: fails for value > 0")
    func nonPositiveFailure() async {
        await assertValidationFailure(rules.floating().nonPositive(), value: 0.1)
    }

    // MARK: - multipleOf
    @Test("multipleOf: succeeds for divisible values")
    func multipleOfSuccess() async {
        await assertValidationSuccess(rules.floating().multipleOf(num: 0.25), value: 0.75)
        await assertValidationSuccess(rules.floating().multipleOf(num: 2), value: 10)
    }
    @Test("multipleOf: fails for non-divisible values")
    func multipleOfFailure() async {
        await assertValidationFailure(rules.floating().multipleOf(num: 0.25), value: 0.7)
        await assertValidationFailure(rules.floating().multipleOf(num: 2), value: 3)
    }
    @Test("multipleOf: fails for zero divisor")
    func multipleOfZeroFailure() async {
        await assertValidationFailure(rules.floating().multipleOf(num: 0), value: 1)
    }
}
