import Foundation
import Testing
@testable import FormCraft

struct FormCraftUnionValidationTests {
    let rules = FormCraftValidationRules()

    @Test("union: succeeds for first matching rule")
    func unionFirstSuccess() async {
        let result = await rules.union("hello", rules.string().notEmpty(), rules.integer().gt(num: 0))
        switch result {
        case .success(let tuple):
            #expect(tuple.0 == "hello")
            #expect(tuple.1 == nil)
        case .failure:
            Issue.record("Expected success for string")
        }
    }

    @Test("union: succeeds for second matching rule")
    func unionSecondSuccess() async {
        let result = await rules.union(42, rules.string().notEmpty(), rules.integer().gt(num: 0))
        switch result {
        case .success(let tuple):
            #expect(tuple.0 == nil)
            #expect(tuple.1 == 42)
        case .failure:
            Issue.record("Expected success for integer")
        }
    }

    @Test("union: fails when no rules match")
    func unionFailure() async {
        let result = await rules.union("", rules.string().notEmpty(), rules.integer().gt(num: 0))
        switch result {
        case .success:
            Issue.record("Expected failure")
        case .failure(let errors):
            #expect(!errors.messages.isEmpty)
        }
    }
}
