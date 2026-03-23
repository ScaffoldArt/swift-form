import Foundation
import Testing
@testable import FormCraft

struct FormCraftBooleanValidationTests {
    let rules = FormCraftValidationRules()

    @Test("checked: succeeds for true")
    func checkedSuccess() async {
        await assertValidationSuccess(rules.boolean().checked(), value: true)
    }

    @Test("checked: fails for false")
    func checkedFailure() async {
        await assertValidationFailure(rules.boolean().checked(), value: false)
    }

    @Test("checked: custom message on failure")
    func checkedCustomMessage() async {
        let customMessage: LocalizedStringResource = "Must be checked"
        let validator = rules.boolean().checked(message: customMessage)
        let result = await validator.validate(value: false)
        switch result {
        case .success:
            Issue.record("Expected failure")
        case .failure(let errors):
            #expect(errors.messages.first?.key == customMessage.key)
        }
    }
}
