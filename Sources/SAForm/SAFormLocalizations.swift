//
//  SAFormLocalizations.swift
//  SAForm
//
//  Created by Артем Дробышев on 29.09.2025.
//

import SwiftUI

public struct SAFormLocalizations {
    public var required: LocalizedStringResource
    public var gt: (String) -> LocalizedStringResource
    public var gte: (String) -> LocalizedStringResource
    public var lt: (String) -> LocalizedStringResource
    public var lte: (String) -> LocalizedStringResource
    public var positive: LocalizedStringResource
    public var nonNegative: LocalizedStringResource
    public var negative: LocalizedStringResource
    public var nonPositive: LocalizedStringResource
    public var multipleOf: (String) -> LocalizedStringResource
    public var trimmed: LocalizedStringResource
    public var cuid: LocalizedStringResource
    public var cuid2: LocalizedStringResource
    public var ulid: LocalizedStringResource
    public var uuid: LocalizedStringResource
    public var nanoId: LocalizedStringResource
    public var ipv4: LocalizedStringResource
    public var ipv6: LocalizedStringResource
    public var cidrv4: LocalizedStringResource
    public var cidrv6: LocalizedStringResource
    public var isoDate: LocalizedStringResource
    public var email: LocalizedStringResource
    public var e164phoneNumber: LocalizedStringResource
    public var regex: LocalizedStringResource
    public var equals: (String, String) -> LocalizedStringResource
    public var minLength: (String) -> LocalizedStringResource
    public var maxLength: (String) -> LocalizedStringResource
    public var length: (String) -> LocalizedStringResource
    public var startsWith: (String) -> LocalizedStringResource
    public var endsWith: (String) -> LocalizedStringResource
    public var includes: (String) -> LocalizedStringResource
    public var uppercase: LocalizedStringResource
    public var lowercase: LocalizedStringResource
    public var invalidType: (String, String) -> LocalizedStringResource

    public init(
        required: LocalizedStringResource? = nil,
        gt: ((String) -> LocalizedStringResource)? = nil,
        gte: ((String) -> LocalizedStringResource)? = nil,
        lt: ((String) -> LocalizedStringResource)? = nil,
        lte: ((String) -> LocalizedStringResource)? = nil,
        positive: LocalizedStringResource? = nil,
        nonNegative: LocalizedStringResource? = nil,
        negative: LocalizedStringResource? = nil,
        nonPositive: LocalizedStringResource? = nil,
        multipleOf: ((String) -> LocalizedStringResource)? = nil,
        trimmed: LocalizedStringResource? = nil,
        cuid: LocalizedStringResource? = nil,
        cuid2: LocalizedStringResource? = nil,
        ulid: LocalizedStringResource? = nil,
        uuid: LocalizedStringResource? = nil,
        nanoId: LocalizedStringResource? = nil,
        ipv4: LocalizedStringResource? = nil,
        ipv6: LocalizedStringResource? = nil,
        cidrv4: LocalizedStringResource? = nil,
        cidrv6: LocalizedStringResource? = nil,
        isoDate: LocalizedStringResource? = nil,
        email: LocalizedStringResource? = nil,
        e164phoneNumber: LocalizedStringResource? = nil,
        regex: LocalizedStringResource? = nil,
        equals: ((String, String) -> LocalizedStringResource)? = nil,
        minLength: ((String) -> LocalizedStringResource)? = nil,
        maxLength: ((String) -> LocalizedStringResource)? = nil,
        length: ((String) -> LocalizedStringResource)? = nil,
        startsWith: ((String) -> LocalizedStringResource)? = nil,
        endsWith: ((String) -> LocalizedStringResource)? = nil,
        includes: ((String) -> LocalizedStringResource)? = nil,
        uppercase: LocalizedStringResource? = nil,
        lowercase: LocalizedStringResource? = nil,
        invalidType: ((String, String) -> LocalizedStringResource)? = nil
    ) {
        self.required = required ?? l10n("required")
        self.gt = gt ?? { l10n("gt \($0)") }
        self.gte = gte ?? { l10n("gte \($0)") }
        self.lt = lt ?? { l10n("lt \($0)") }
        self.lte = lte ?? { l10n("lte \($0)") }
        self.positive = positive ?? l10n("positive")
        self.nonNegative = nonNegative ?? l10n("nonNegative")
        self.negative = negative ?? l10n("negative")
        self.nonPositive = nonPositive ?? l10n("nonPositive")
        self.multipleOf = multipleOf ?? { l10n("multipleOf \($0)") }
        self.trimmed = trimmed ?? l10n("trimmed")
        self.cuid = cuid ?? l10n("cuid")
        self.cuid2 = cuid2 ?? l10n("cuid2")
        self.ulid = ulid ?? l10n("ulid")
        self.uuid = uuid ?? l10n("uuid")
        self.nanoId = nanoId ?? l10n("nanoId")
        self.ipv4 = ipv4 ?? l10n("ipv4")
        self.ipv6 = ipv6 ?? l10n("ipv6")
        self.cidrv4 = cidrv4 ?? l10n("cidrv4")
        self.cidrv6 = cidrv6 ?? l10n("cidrv6")
        self.isoDate = isoDate ?? l10n("isoDate")
        self.email = email ?? l10n("email")
        self.e164phoneNumber = e164phoneNumber ?? l10n("e164PhoneNumber")
        self.regex = regex ?? l10n("regex")
        self.equals = equals ?? { l10n("equals \($0) \($1)") }
        self.minLength = minLength ?? { l10n("minLength \($0)") }
        self.maxLength = maxLength ?? { l10n("maxLength \($0)") }
        self.length = length ?? { l10n("length \($0)") }
        self.startsWith = startsWith ?? { l10n("startsWith \($0)") }
        self.endsWith = endsWith ?? { l10n("endsWith \($0)") }
        self.includes = includes ?? { l10n("includes \($0)") }
        self.uppercase = uppercase ?? l10n("uppercase")
        self.lowercase = lowercase ?? l10n("lowercase")
        self.invalidType = invalidType ?? { expected, actual in
            l10n("invalidType \(expected) \(actual)")
        }
    }
}

private func l10n(_ key: String.LocalizationValue) -> LocalizedStringResource {
    LocalizedStringResource(key, bundle: .atURL(Bundle.module.bundleURL))
}
