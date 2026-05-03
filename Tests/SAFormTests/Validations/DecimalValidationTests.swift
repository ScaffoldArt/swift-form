import Foundation
import Testing
@testable import SAForm

struct SAFormDecimalValidationTests {
    let rules = SAFormValidationRules()

    // MARK: - gt
    @Test("gt: succeeds when value > num")
    func gtSuccess() async {
        await assertValidationSuccess(rules.decimal().gt(num: 5.5), value: 6.0)
    }
    @Test("gt: fails when value <= num")
    func gtFailure() async {
        await assertValidationFailure(rules.decimal().gt(num: 5.5), value: 5.5)
        await assertValidationFailure(rules.decimal().gt(num: 5.5), value: 5.0)
    }

    // MARK: - gte
    @Test("gte: succeeds when value >= num")
    func gteSuccess() async {
        await assertValidationSuccess(rules.decimal().gte(num: 5.5), value: 5.5)
        await assertValidationSuccess(rules.decimal().gte(num: 5.5), value: 6.0)
    }
    @Test("gte: fails when value < num")
    func gteFailure() async {
        await assertValidationFailure(rules.decimal().gte(num: 5.5), value: 5.0)
    }

    // MARK: - lt
    @Test("lt: succeeds when value < num")
    func ltSuccess() async {
        await assertValidationSuccess(rules.decimal().lt(num: 5.5), value: 5.0)
    }
    @Test("lt: fails when value >= num")
    func ltFailure() async {
        await assertValidationFailure(rules.decimal().lt(num: 5.5), value: 5.5)
        await assertValidationFailure(rules.decimal().lt(num: 5.5), value: 6.0)
    }

    // MARK: - lte
    @Test("lte: succeeds when value <= num")
    func lteSuccess() async {
        await assertValidationSuccess(rules.decimal().lte(num: 5.5), value: 5.5)
        await assertValidationSuccess(rules.decimal().lte(num: 5.5), value: 5.0)
    }
    @Test("lte: fails when value > num")
    func lteFailure() async {
        await assertValidationFailure(rules.decimal().lte(num: 5.5), value: 6.0)
    }

    // MARK: - positive
    @Test("positive: succeeds for value > 0")
    func positiveSuccess() async {
        await assertValidationSuccess(rules.decimal().positive(), value: 0.1)
        await assertValidationSuccess(rules.decimal().positive(), value: 100.0)
    }
    @Test("positive: fails for value <= 0")
    func positiveFailure() async {
        await assertValidationFailure(rules.decimal().positive(), value: 0.0)
        await assertValidationFailure(rules.decimal().positive(), value: -1.0)
    }

    // MARK: - nonNegative
    @Test("nonNegative: succeeds for value >= 0")
    func nonNegativeSuccess() async {
        await assertValidationSuccess(rules.decimal().nonNegative(), value: 0.0)
        await assertValidationSuccess(rules.decimal().nonNegative(), value: 1.0)
    }
    @Test("nonNegative: fails for value < 0")
    func nonNegativeFailure() async {
        await assertValidationFailure(rules.decimal().nonNegative(), value: -0.1)
    }

    // MARK: - negative
    @Test("negative: succeeds for value < 0")
    func negativeSuccess() async {
        await assertValidationSuccess(rules.decimal().negative(), value: -0.1)
    }
    @Test("negative: fails for value >= 0")
    func negativeFailure() async {
        await assertValidationFailure(rules.decimal().negative(), value: 0.0)
        await assertValidationFailure(rules.decimal().negative(), value: 1.0)
    }

    // MARK: - nonPositive
    @Test("nonPositive: succeeds for value <= 0")
    func nonPositiveSuccess() async {
        await assertValidationSuccess(rules.decimal().nonPositive(), value: 0.0)
        await assertValidationSuccess(rules.decimal().nonPositive(), value: -1.0)
    }
    @Test("nonPositive: fails for value > 0")
    func nonPositiveFailure() async {
        await assertValidationFailure(rules.decimal().nonPositive(), value: 0.1)
    }

    // MARK: - multipleOf
    @Test("multipleOf: succeeds for values divisible by multiplier")
    func multipleOfSuccess() async {
        await assertValidationSuccess(rules.decimal().multipleOf(mult: 0.1), value: 0.3)
        await assertValidationSuccess(rules.decimal().multipleOf(mult: 2), value: 10)
    }
    @Test("multipleOf: fails for non-divisible values")
    func multipleOfFailure() async {
        await assertValidationFailure(rules.decimal().multipleOf(mult: 0.1), value: 0.31)
        await assertValidationFailure(rules.decimal().multipleOf(mult: 2), value: 3)
    }
    @Test("multipleOf: fails for zero multiplier")
    func multipleOfZeroFailure() async {
        await assertValidationFailure(rules.decimal().multipleOf(mult: 0), value: 1)
    }
}
