import Foundation
import Testing
@testable import SAForm

struct SAFormStringValidationTests {
    let rules = SAFormValidationRules()

    // MARK: - notEmpty

    @Test("notEmpty: succeeds for non-empty string")
    func notEmptySuccess() async {
        await assertValidationSuccess(rules.string().notEmpty(), value: "hello")
    }

    @Test("notEmpty: fails for empty string")
    func notEmptyFailure() async {
        await assertValidationFailure(rules.string().notEmpty(), value: "")
    }

    // MARK: - trimmed

    @Test("trimmed: succeeds for string without leading/trailing whitespace")
    func trimmedSuccess() async {
        await assertValidationSuccess(rules.string().trimmed(), value: "hello")
    }

    @Test("trimmed: fails for string with leading whitespace")
    func trimmedFailsLeading() async {
        await assertValidationFailure(rules.string().trimmed(), value: " hello")
    }

    @Test("trimmed: fails for string with trailing whitespace")
    func trimmedFailsTrailing() async {
        await assertValidationFailure(rules.string().trimmed(), value: "hello ")
    }

    @Test("trimmed: fails for string with leading and trailing whitespace")
    func trimmedFailsBoth() async {
        await assertValidationFailure(rules.string().trimmed(), value: " hello ")
    }

    @Test("trimmed: fails for string with newline characters")
    func trimmedFailsNewlines() async {
        await assertValidationFailure(rules.string().trimmed(), value: "\nhello\n")
    }

    // MARK: - email

    @Test("email: succeeds for valid emails", arguments: [
        "test@example.com",
        "user.name@domain.org",
        "user+tag@sub.domain.com",
    ])
    func emailSuccess(value: String) async {
        await assertValidationSuccess(rules.string().email(), value: value)
    }

    @Test("email: fails for invalid emails", arguments: [
        "",
        "plainaddress",
        "@missinglocal.com",
        "user@",
        "user@.com",
    ])
    func emailFailure(value: String) async {
        await assertValidationFailure(rules.string().email(), value: value)
    }

    // MARK: - uuid

    @Test("uuid: succeeds for valid UUID", arguments: [
        "550e8400-e29b-41d4-a716-446655440000",
        "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
    ])
    func uuidSuccess(value: String) async {
        await assertValidationSuccess(rules.string().uuid(), value: value)
    }

    @Test("uuid: fails for invalid UUID", arguments: [
        "",
        "not-a-uuid",
        "550e8400e29b41d4a716446655440000",
        "550e8400-e29b-41d4-a716-44665544000",
    ])
    func uuidFailure(value: String) async {
        await assertValidationFailure(rules.string().uuid(), value: value)
    }

    // MARK: - cuid

    @Test("cuid: succeeds for valid CUID", arguments: [
        "clh3am1s30000qf08fke6e4al",
        "cjld2cyuq0000t3rmniod1foy",
    ])
    func cuidSuccess(value: String) async {
        await assertValidationSuccess(rules.string().cuid(), value: value)
    }

    @Test("cuid: fails for invalid CUID", arguments: [
        "",
        "not-a-cuid",
        "alh3am1s30000qf08fke6e4al",
    ])
    func cuidFailure(value: String) async {
        await assertValidationFailure(rules.string().cuid(), value: value)
    }

    // MARK: - cuid2

    @Test("cuid2: succeeds for valid CUID2", arguments: [
        "tz4a98xxat96iws9zmbrgj3a",
    ])
    func cuid2Success(value: String) async {
        await assertValidationSuccess(rules.string().cuid2(), value: value)
    }

    @Test("cuid2: fails for invalid CUID2", arguments: [
        "",
        "123",
        "Tz4a98xxat96iws9zmbrgj3a",
    ])
    func cuid2Failure(value: String) async {
        await assertValidationFailure(rules.string().cuid2(), value: value)
    }

    // MARK: - ulid

    @Test("ulid: succeeds for valid ULID", arguments: [
        "01ARZ3NDEKTSV4RRFFQ69G5FAV",
    ])
    func ulidSuccess(value: String) async {
        await assertValidationSuccess(rules.string().ulid(), value: value)
    }

    @Test("ulid: fails for invalid ULID", arguments: [
        "",
        "not-a-ulid",
        "01ARZ3NDEKTSV4RRFFQ69G5FA",
    ])
    func ulidFailure(value: String) async {
        await assertValidationFailure(rules.string().ulid(), value: value)
    }

    // MARK: - nanoId

    @Test("nanoId: succeeds for valid NanoID", arguments: [
        "V1StGXR8_Z5jdHi6B-myT",
    ])
    func nanoIdSuccess(value: String) async {
        await assertValidationSuccess(rules.string().nanoId(), value: value)
    }

    @Test("nanoId: fails for invalid NanoID", arguments: [
        "",
        "too-short",
        "V1StGXR8_Z5jdHi6B-myTT",
    ])
    func nanoIdFailure(value: String) async {
        await assertValidationFailure(rules.string().nanoId(), value: value)
    }

    // MARK: - ipv4

    @Test("ipv4: succeeds for valid IPv4", arguments: [
        "192.168.1.1",
        "0.0.0.0",
        "255.255.255.255",
    ])
    func ipv4Success(value: String) async {
        await assertValidationSuccess(rules.string().ipv4(), value: value)
    }

    @Test("ipv4: fails for invalid IPv4", arguments: [
        "",
        "256.1.1.1",
        "192.168.1",
        "192.168.1.1.1",
    ])
    func ipv4Failure(value: String) async {
        await assertValidationFailure(rules.string().ipv4(), value: value)
    }

    // MARK: - ipv6

    @Test("ipv6: succeeds for valid IPv6", arguments: [
        "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
        "::1",
        "fe80::1%eth0",
    ])
    func ipv6Success(value: String) async {
        await assertValidationSuccess(rules.string().ipv6(), value: value)
    }

    @Test("ipv6: fails for invalid IPv6", arguments: [
        "",
        "not-an-ipv6",
        "2001:db8:85a3::8a2e:370:7334:extra:field",
    ])
    func ipv6Failure(value: String) async {
        await assertValidationFailure(rules.string().ipv6(), value: value)
    }

    // MARK: - cidrv4

    @Test("cidrv4: succeeds for valid CIDR v4", arguments: [
        "192.168.0.0/24",
        "10.0.0.0/8",
        "0.0.0.0/0",
    ])
    func cidrv4Success(value: String) async {
        await assertValidationSuccess(rules.string().cidrv4(), value: value)
    }

    @Test("cidrv4: fails for invalid CIDR v4", arguments: [
        "",
        "192.168.0.0",
        "192.168.0.0/33",
    ])
    func cidrv4Failure(value: String) async {
        await assertValidationFailure(rules.string().cidrv4(), value: value)
    }

    // MARK: - cidrv6

    @Test("cidrv6: succeeds for valid CIDR v6", arguments: [
        "2001:db8::/32",
        "::1/128",
    ])
    func cidrv6Success(value: String) async {
        await assertValidationSuccess(rules.string().cidrv6(), value: value)
    }

    @Test("cidrv6: fails for invalid CIDR v6", arguments: [
        "",
        "2001:db8::",
        "2001:db8::/129",
    ])
    func cidrv6Failure(value: String) async {
        await assertValidationFailure(rules.string().cidrv6(), value: value)
    }

    // MARK: - isoDate

    @Test("isoDate: succeeds for valid ISO date", arguments: [
        "2024-01-15",
        "2024-02-29",
        "2023-12-31",
    ])
    func isoDateSuccess(value: String) async {
        await assertValidationSuccess(rules.string().isoDate(), value: value)
    }

    @Test("isoDate: fails for invalid ISO date", arguments: [
        "",
        "2024/01/15",
        "2023-02-29",
        "2024-13-01",
        "2024-01-32",
    ])
    func isoDateFailure(value: String) async {
        await assertValidationFailure(rules.string().isoDate(), value: value)
    }

    // MARK: - e164phoneNumber

    @Test("e164phoneNumber: succeeds for valid phone numbers", arguments: [
        "+14155552671",
        "14155552671",
        "+79001234567",
    ])
    func e164phoneNumberSuccess(value: String) async {
        await assertValidationSuccess(rules.string().e164phoneNumber(), value: value)
    }

    @Test("e164phoneNumber: fails for invalid phone numbers", arguments: [
        "",
        "123",
        "+1-415-555-2671",
        "phone",
    ])
    func e164phoneNumberFailure(value: String) async {
        await assertValidationFailure(rules.string().e164phoneNumber(), value: value)
    }

    // MARK: - regex

    @Test("regex: succeeds when value matches pattern")
    func regexSuccess() async {
        let validator = rules.string().regex(pattern: /^[A-Z]{3}$/)
        await assertValidationSuccess(validator, value: "ABC")
    }

    @Test("regex: fails when value does not match pattern")
    func regexFailure() async {
        let validator = rules.string().regex(pattern: /^[A-Z]{3}$/)
        await assertValidationFailure(validator, value: "abc")
        await assertValidationFailure(validator, value: "AB")
    }

    // MARK: - equals

    @Test("equals: succeeds when values match")
    func equalsSuccess() async {
        await assertValidationSuccess(rules.string().equals(to: "hello"), value: "hello")
    }

    @Test("equals: fails when values differ")
    func equalsFailure() async {
        await assertValidationFailure(rules.string().equals(to: "hello"), value: "world")
    }

    // MARK: - min

    @Test("min: succeeds when length >= minimum")
    func minSuccess() async {
        await assertValidationSuccess(rules.string().min(min: 3), value: "abc")
        await assertValidationSuccess(rules.string().min(min: 3), value: "abcd")
    }

    @Test("min: fails when length < minimum")
    func minFailure() async {
        await assertValidationFailure(rules.string().min(min: 3), value: "ab")
        await assertValidationFailure(rules.string().min(min: 1), value: "")
    }

    // MARK: - max

    @Test("max: succeeds when length <= maximum")
    func maxSuccess() async {
        await assertValidationSuccess(rules.string().max(max: 5), value: "hello")
        await assertValidationSuccess(rules.string().max(max: 5), value: "hi")
    }

    @Test("max: fails when length > maximum")
    func maxFailure() async {
        await assertValidationFailure(rules.string().max(max: 3), value: "hello")
    }

    // MARK: - length

    @Test("length: succeeds when length matches exactly")
    func lengthSuccess() async {
        await assertValidationSuccess(rules.string().length(length: 5), value: "hello")
    }

    @Test("length: fails when length does not match")
    func lengthFailure() async {
        await assertValidationFailure(rules.string().length(length: 5), value: "hi")
        await assertValidationFailure(rules.string().length(length: 5), value: "hello!")
    }

    // MARK: - startsWith

    @Test("startsWith: succeeds when string has prefix")
    func startsWithSuccess() async {
        await assertValidationSuccess(rules.string().startsWith(prefix: "he"), value: "hello")
    }

    @Test("startsWith: fails when string does not have prefix")
    func startsWithFailure() async {
        await assertValidationFailure(rules.string().startsWith(prefix: "he"), value: "world")
    }

    // MARK: - endsWith

    @Test("endsWith: succeeds when string has suffix")
    func endsWithSuccess() async {
        await assertValidationSuccess(rules.string().endsWith(suffix: "lo"), value: "hello")
    }

    @Test("endsWith: fails when string does not have suffix")
    func endsWithFailure() async {
        await assertValidationFailure(rules.string().endsWith(suffix: "lo"), value: "world")
    }

    // MARK: - includes

    @Test("includes: succeeds when string contains substring")
    func includesSuccess() async {
        await assertValidationSuccess(rules.string().includes(substring: "ell"), value: "hello")
    }

    @Test("includes: fails when string does not contain substring")
    func includesFailure() async {
        await assertValidationFailure(rules.string().includes(substring: "xyz"), value: "hello")
    }

    // MARK: - uppercase

    @Test("uppercase: succeeds for uppercase string")
    func uppercaseSuccess() async {
        await assertValidationSuccess(rules.string().uppercase(), value: "HELLO")
    }

    @Test("uppercase: fails for non-uppercase string")
    func uppercaseFailure() async {
        await assertValidationFailure(rules.string().uppercase(), value: "Hello")
        await assertValidationFailure(rules.string().uppercase(), value: "hello")
    }

    // MARK: - lowercase

    @Test("lowercase: succeeds for lowercase string")
    func lowercaseSuccess() async {
        await assertValidationSuccess(rules.string().lowercase(), value: "hello")
    }

    @Test("lowercase: fails for non-lowercase string")
    func lowercaseFailure() async {
        await assertValidationFailure(rules.string().lowercase(), value: "Hello")
        await assertValidationFailure(rules.string().lowercase(), value: "HELLO")
    }

    // MARK: - Chaining

    @Test("chaining: multiple rules compose correctly")
    func chainingSuccess() async {
        let validator = rules.string()
            .notEmpty()
            .trimmed()
            .min(min: 3)
            .max(max: 10)

        await assertValidationSuccess(validator, value: "hello")
    }

    @Test("chaining: first failing rule stops validation")
    func chainingFailsOnFirst() async {
        let validator = rules.string()
            .notEmpty()
            .min(min: 5)

        await assertValidationFailure(validator, value: "")
    }

    // MARK: - Custom messages

    @Test("custom message is returned on failure")
    func customMessage() async {
        let customMessage: LocalizedStringResource = "Field is required"
        let validator = rules.string().notEmpty(message: customMessage)

        let result = await validator.validate(value: "")

        switch result {
        case .success:
            Issue.record("Expected failure")
        case .failure(let errors):
            #expect(errors.messages.first?.key == customMessage.key)
        }
    }
}
