//
//  SAFormFields.swift
//  SAForm
//
//  Created by Артем Дробышев on 18.01.2026.
//

import SwiftUI

public struct SAFormFailure: Sendable {
    public let messages: [LocalizedStringResource]

    public init(_ errors: [LocalizedStringResource]) {
        self.messages = errors
    }

    public init(_ errors: [String]) {
        self.messages = errors.map { .init(stringLiteral: $0) }
    }
}

@MainActor
public protocol SAFormFields {
    func getAccessNames() -> [String: PartialKeyPath<Self>]
    func getAccessOrder() -> [String]
    func refine(form: SAForm<Self>) async -> [PartialKeyPath<Self>: SAFormFailure?]
}

public extension SAFormFields {
    func getField(by keyPath: PartialKeyPath<Self>) -> any SAFormFieldConfigurable {
        guard let field = self[keyPath: keyPath] as? any SAFormFieldConfigurable else {
            preconditionFailure("SAForm: keyPath does not reference a SAFormFieldConfigurable field.")
        }

        return field
    }

    func refine(form: SAForm<Self>) async -> [PartialKeyPath<Self>: SAFormFailure?] {
        [:]
    }
}

@MainActor
public protocol SAFormFieldConfigurable: Observable, AnyObject, Sendable {
    associatedtype Value: Equatable & Sendable
    associatedtype ValidatedValue: Sendable

    var value: Value { get set }
    var validatedValue: ValidatedValue? { get }
    var defaultValue: Value { get set }
    var mounted: Bool { get set }
    var errors: SAFormFailure? { get set }
    var isValidating: Bool { get set }
    var taskValidation: Task<Void, Never>? { get set }
    var isDirty: Bool { get set }
    var isError: Bool { get }
    var delayValidation: SAFormDelayValidation { get }
    var rule: (_ value: Value) async -> SAFormValidationResponse<ValidatedValue> { get }

    func validate() async -> SAFormFailure?
}

public enum SAFormValidationResponse<Value: Sendable>: Sendable {
    case success(value: Value)
    case failure(errors: SAFormFailure)

    public var errors: SAFormFailure? {
        if case .failure(let failure) = self {
            return failure
        }

        return nil
    }

    public var value: Value? {
        if case .success(let value) = self {
            return value
        }

        return nil
    }
}

public enum SAFormDelayValidation {
    case immediate
    case fast
    case medium
    case slow
    case custom(seconds: Double)

    public var seconds: Double {
        switch self {
        case .immediate:
            return 0
        case .fast:
            return 0.2
        case .medium:
            return 0.5
        case .slow:
            return 1.0
        case .custom(let seconds):
            return seconds
        }
    }
}

@Observable
public final class SAFormField<Value: Equatable & Sendable, ValidatedValue: Sendable>: SAFormFieldConfigurable {
    public var value: Value
    public var validatedValue: ValidatedValue? = nil
    public var defaultValue: Value
    public var mounted: Bool = false
    public var errors: SAFormFailure? = nil
    public var isValidating: Bool = false
    public var taskValidation: Task<Void, Never>? = nil
    public var isDirty: Bool = false
    public var isError: Bool { errors != nil }
    public let delayValidation: SAFormDelayValidation
    public let rule: (_ value: Value) async -> SAFormValidationResponse<ValidatedValue>

    public init(
        value: Value,
        delayValidation: SAFormDelayValidation = .immediate,
        rule: @escaping (_ value: Value) async -> SAFormValidationResponse<ValidatedValue>
    ) {
        self.value = value
        self.defaultValue = value
        self.delayValidation = delayValidation
        self.rule = rule
    }

    public func validate() async -> SAFormFailure? {
        defer {
            self.isValidating = false
        }

        self.isValidating = true

        let validationResponse = await rule(value)

        switch validationResponse {
        case .success(let validatedValue):
            self.validatedValue = validatedValue

            return nil
        case .failure(let failure):
            return failure
        }
    }
}
