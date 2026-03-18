import Foundation

public extension FormCraftValidationRules {
    /// Creates a validation builder for `String` values.
    ///
    /// - Returns: A string validation builder for chaining rules.
    func string() -> FormCraftStringValidation {
        .init()
    }
}

/// A validation builder for `String` values that supports composing multiple rules.
public struct FormCraftStringValidation: FormCraftValidationTypeRules {
    public var rules: [(_ value: String) async -> FormCraftValidationResponse<String>] = []

    /// Validates that the value is not empty.
    ///
    /// - Parameter message: The error message returned when the value is empty.
    /// - Returns: The validation builder for chaining.
    public func notEmpty(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            if value.isEmpty {
                return .failure(errors: .init([message ?? localizations.required]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value does not start or end with whitespace characters.
    ///
    /// See: https://en.wikipedia.org/wiki/Whitespace_character
    ///
    /// - Parameter message: The error message returned when leading or trailing whitespace is present.
    /// - Returns: The validation builder for chaining.
    public func trimmed(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            let t = value.trimmingCharacters(in: .whitespacesAndNewlines)

            return (t == value) ? .success(value: value) : .failure(errors: .init([message ?? localizations.trimmed]))
        }
    }

    /// Validates that the value is a valid CUID.
    ///
    /// - Parameter message: The error message returned when the value is not a valid CUID.
    /// - Returns: The validation builder for chaining.
    public func cuid(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            let pattern = /^c[^\s-]{8,}$/
            let isMatch = (try? pattern.wholeMatch(in: value)) != nil

            guard isMatch else {
                return .failure(errors: .init([message ?? localizations.cuid]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is a valid CUID2.
    ///
    /// - Parameter message: The error message returned when the value is not a valid CUID2.
    /// - Returns: The validation builder for chaining.
    public func cuid2(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            let pattern = /^[a-z][a-z0-9]{23,}$/
            let isMatch = (try? pattern.wholeMatch(in: value)) != nil

            guard isMatch else {
                return .failure(errors: .init([message ?? localizations.cuid2]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is a valid ULID.
    ///
    /// - Parameter message: The error message returned when the value is not a valid ULID.
    /// - Returns: The validation builder for chaining.
    public func ulid(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            let pattern = /^[0-9A-HJKMNP-TV-Z]{26}$/
            let isMatch = (try? pattern.wholeMatch(in: value)) != nil

            guard isMatch else {
                return .failure(errors: .init([message ?? localizations.ulid]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is a valid UUID.
    ///
    /// - Parameter message: The error message returned when the value is not a valid UUID.
    /// - Returns: The validation builder for chaining.
    public func uuid(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            // swiftlint:disable line_length
            let pattern = /^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/
            // swiftlint:enable line_length
            let isMatch = (try? pattern.wholeMatch(in: value)) != nil

            guard isMatch else {
                return .failure(errors: .init([message ?? localizations.uuid]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is a valid NanoID.
    ///
    /// - Parameter message: The error message returned when the value is not a valid NanoID.
    /// - Returns: The validation builder for chaining.
    public func nanoId(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            let pattern = /^[A-Za-z0-9_-]{21}$/
            let isMatch = (try? pattern.wholeMatch(in: value)) != nil

            guard isMatch else {
                return .failure(errors: .init([message ?? localizations.nanoId]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is a valid IPv4 address.
    ///
    /// - Parameter message: The error message returned when the value is not a valid IPv4 address.
    /// - Returns: The validation builder for chaining.
    public func ipv4(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            // swiftlint:disable line_length
            let pattern = /^(?:(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])$/
            // swiftlint:enable line_length
            let isMatch = (try? pattern.wholeMatch(in: value)) != nil

            guard isMatch else {
                return .failure(errors: .init([message ?? localizations.ipv4]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is a valid IPv6 address.
    ///
    /// - Parameter message: The error message returned when the value is not a valid IPv6 address.
    /// - Returns: The validation builder for chaining.
    public func ipv6(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            // swiftlint:disable line_length
            let pattern = /^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$/
            // swiftlint:enable line_length
            let isMatch = (try? pattern.wholeMatch(in: value)) != nil

            guard isMatch else {
                return .failure(errors: .init([message ?? localizations.ipv6]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is a valid IPv4 CIDR notation.
    ///
    /// - Parameter message: The error message returned when the value is not a valid IPv4 CIDR.
    /// - Returns: The validation builder for chaining.
    public func cidrv4(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            // swiftlint:disable line_length
            let pattern = /^(?:(?:25[0-5]|2[0-4]\d|1?\d?\d)\.){3}(?:25[0-5]|2[0-4]\d|1?\d?\d)\/(?:[0-9]|[12]\d|3[0-2])$/
            // swiftlint:enable line_length
            let isMatch = (try? pattern.wholeMatch(in: value)) != nil

            guard isMatch else {
                return .failure(errors: .init([message ?? localizations.cidrv4]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is a valid IPv6 CIDR notation.
    ///
    /// - Parameter message: The error message returned when the value is not a valid IPv6 CIDR.
    /// - Returns: The validation builder for chaining.
    public func cidrv6(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            // swiftlint:disable line_length
            let pattern = /^((([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4})|(([0-9a-fA-F]{1,4}:){1,7}:)|(([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4})|(([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2})|(([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3})|(([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4})|(([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5})|([0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6}))|(:((:[0-9a-fA-F]{1,4}){1,7}|:))|(fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,})|(::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))|(([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])))\/(?:[0-9]|[1-9]\d|1[01]\d|12[0-8])$/
            // swiftlint:enable line_length
            let isMatch = (try? pattern.wholeMatch(in: value)) != nil

            guard isMatch else {
                return .failure(errors: .init([message ?? localizations.cidrv6]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is a valid ISO date string in the format `YYYY-MM-DD`.
    ///
    /// - Parameter message: The error message returned when the value is not a valid ISO date.
    /// - Returns: The validation builder for chaining.
    public func isoDate(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            // swiftlint:disable line_length
            let pattern = /^((\d\d[2468][048]|\d\d[13579][26]|\d\d0[48]|[02468][048]00|[13579][26]00)-02-29|\d{4}-((0[13578]|1[02])-(0[1-9]|[12]\d|3[01])|(0[469]|11)-(0[1-9]|[12]\d|30)|(02)-(0[1-9]|1\d|2[0-8])))$/
            // swiftlint:enable line_length
            let isMatch = (try? pattern.wholeMatch(in: value)) != nil

            guard isMatch else {
                return .failure(errors: .init([message ?? localizations.isoDate]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value is a valid email address.
    ///
    /// - Parameter message: The error message returned when the value is not a valid email address.
    /// - Returns: The validation builder for chaining.
    public func email(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            // swiftlint:disable line_length
            let pattern = #"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"#
            // swiftlint:enable line_length

            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)

            guard predicate.evaluate(with: value) else {
                return .failure(errors: .init([message ?? localizations.email]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value resembles an E.164 phone number.
    ///
    /// Note: This is a basic format check only. For strict validation, consider a third‑party library via a custom rule.
    /// See: https://en.wikipedia.org/wiki/E.164
    ///
    /// - Parameter message: The error message returned when the value is not a valid phone number.
    /// - Returns: The validation builder for chaining.
    public func e164phoneNumber(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            let pattern = #"^\+?[0-9]{7,15}$"#
            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)

            guard predicate.evaluate(with: value) else {
                return .failure(errors: .init([message ?? localizations.e164phoneNumber]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value matches the provided regular expression.
    ///
    /// - Parameters:
    ///   - pattern: The regular expression tested against the value.
    ///   - message: The error message returned when the value does not match the pattern.
    /// - Returns: The validation builder for chaining.
    public func regex(
        pattern: Regex<Substring>,
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            let isMatches = (try? pattern.wholeMatch(in: value)) != nil

            guard isMatches else {
                return .failure(errors: .init([message ?? localizations.regex]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value equals the specified string.
    ///
    /// - Parameters:
    ///   - to: The string to compare against.
    ///   - message: The error message returned when the values do not match.
    /// - Returns: The validation builder for chaining.
    public func equals(
        to: String,
        message: ((String, String) -> LocalizedStringResource)? = nil
    ) -> Self {
        addRule { value in
            if value != to {
                return .failure(errors: .init([message?(value, to) ?? localizations.equals(value, to)]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value length is at least the specified minimum number of characters.
    ///
    /// - Parameters:
    ///   - min: The minimum allowed character count.
    ///   - message: The error message returned when the value is shorter than the minimum.
    /// - Returns: The validation builder for chaining.
    public func min(
        min: Int,
        message: ((Int) -> LocalizedStringResource)? = nil
    ) -> Self {
        addRule { value in
            if value.count < min {
                return .failure(errors: .init([message?(min) ?? localizations.minLength(String(describing: min))]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value length is at most the specified maximum number of characters.
    ///
    /// - Parameters:
    ///   - max: The maximum allowed character count.
    ///   - message: The error message returned when the value is longer than the maximum.
    /// - Returns: The validation builder for chaining.
    public func max(
        max: Int,
        message: ((Int) ->LocalizedStringResource)? = nil
    ) -> Self {
        addRule { value in
            if value.count > max {
                return .failure(errors: .init([message?(max) ?? localizations.maxLength(String(describing: max))]))
            }

            return .success(value: value)
        }
    }

    /// Validates that the value length equals the specified number of characters.
    ///
    /// - Parameters:
    ///   - length: The required character count.
    ///   - message: The error message returned when the value length does not match.
    /// - Returns: The validation builder for chaining.
    public func length(
        length: Int,
        message: ((Int) -> LocalizedStringResource)? = nil
    ) -> Self {
        addRule { value in
            if value.count != length {
                return .failure(errors: .init([message?(length) ?? localizations.length(String(describing: length))]))
            }

            return .success(value: value)
        }
    }

    public func startsWith(
        prefix: String,
        message: ((String) -> LocalizedStringResource)? = nil
    ) -> Self {
        addRule { value in
            if !value.hasPrefix(prefix) {
                return .failure(errors: .init([message?(prefix) ?? localizations.startsWith(prefix)]))
            }

            return .success(value: value)
        }
    }

    public func endsWith(
        suffix: String,
        message: ((String) -> LocalizedStringResource)? = nil
    ) -> Self {
        addRule { value in
            if !value.hasSuffix(suffix) {
                return .failure(errors: .init([message?(suffix) ?? localizations.endsWith(suffix)]))
            }
            return .success(value: value)
        }
    }

    public func includes(
        substring: String,
        message: ((String) -> LocalizedStringResource)? = nil
    ) -> Self {
        addRule { value in
            if !value.contains(substring) {
                return .failure(errors: .init([message?(substring) ?? localizations.includes(substring)]))
            }
            return .success(value: value)
        }
    }

    public func uppercase(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            if value != value.uppercased() {
                return .failure(errors: .init([message ?? localizations.uppercase]))
            }
            return .success(value: value)
        }
    }

    public func lowercase(
        message: LocalizedStringResource? = nil
    ) -> Self {
        addRule { value in
            if value != value.lowercased() {
                return .failure(errors: .init([message ?? localizations.lowercase]))
            }
            return .success(value: value)
        }
    }
}
