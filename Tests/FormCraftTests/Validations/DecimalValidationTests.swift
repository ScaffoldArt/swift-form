import Foundation
import Testing
@testable import FormCraft

struct FormCraftDecimalValidationTests {
    let rules = FormCraftValidationRules()

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
}
