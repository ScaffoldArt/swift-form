import Testing
@testable import FormCraft

struct FormCraftBooleanValidationTests {

}

struct FormCraftStringValidationTests {
    let rules = FormCraftValidationRules()

    @Test("notEmpty fails for empty string and succeeds for non-empty")
    func testNotEmpty() async {
        let validator = rules.string().notEmpty()

        let failResult = await validator.validate(value: "")
        switch failResult {
        case .success:
            Issue.record("Expected failure for empty string")
        case .failure:
            break
        }

        let successResult = await validator.validate(value: "hello")
        switch successResult {
        case .success(let value):
            #expect(value == "hello")
        case .failure:
            Issue.record("Expected success for non-empty string")
        }
    }
}
