import Foundation
import Testing
@testable import FormCraft

struct FormCraftIntegerValidationTests {
    let rules = FormCraftValidationRules()

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
}
