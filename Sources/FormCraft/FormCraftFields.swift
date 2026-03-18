//
//  FormCraftFields.swift
//  FormCraft
//
//  Created by Артем Дробышев on 18.01.2026.
//

import SwiftUI

public struct FormCraftFailure: Sendable {
    public let messages: [LocalizedStringResource]

    public init(_ errors: [LocalizedStringResource]) {
        self.messages = errors
    }

    public init(_ errors: [String]) {
        self.messages = errors.map { .init(stringLiteral: $0) }
    }
}

@MainActor
public protocol FormCraftFields {
    func getAccessNames() -> [String: KeyPath<Self, any FormCraftFieldConfigurable>]
    func refine(form: FormCraft<Self>) async -> [PartialKeyPath<Self>: FormCraftFailure?]
}

public extension FormCraftFields {
    func refine(form: FormCraft<Self>) async -> [PartialKeyPath<Self>: FormCraftFailure?] {
        [:]
    }
}

@MainActor
public protocol FormCraftFieldConfigurable: Observable, AnyObject, Sendable {
    associatedtype Value: Equatable & Sendable
    associatedtype ValidatedValue: Sendable

    var value: Value { get set }
    var validatedValue: ValidatedValue? { get }
    var defaultValue: Value { get set }
    var mounted: Bool { get set }
    var errors: FormCraftFailure? { get set }
    var isValidation: Bool { get set }
    var taskValidation: Task<Void, Never>? { get set }
    var isDirty: Bool { get set }
    var isError: Bool { get }
    var delayValidation: FormCraftDelayValidation { get }
    var rule: (_ value: Value) async -> FormCraftValidationResponse<ValidatedValue> { get }

    func validate() async -> FormCraftFailure?
}

public enum FormCraftValidationResponse<Value: Sendable> {
    case success(value: Value)
    case failure(errors: FormCraftFailure)

    public var errors: FormCraftFailure? {
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

public enum FormCraftDelayValidation {
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
public final class FormCraftField<Value: Equatable & Sendable, ValidatedValue: Sendable>: FormCraftFieldConfigurable {
    public var value: Value
    public var validatedValue: ValidatedValue? = nil
    public var defaultValue: Value
    public var mounted: Bool = false
    public var errors: FormCraftFailure? = nil
    public var isValidation: Bool = false
    public var taskValidation: Task<Void, Never>? = nil
    public var isDirty: Bool = false
    public var isError: Bool { errors != nil }
    public let delayValidation: FormCraftDelayValidation
    public let rule: (_ value: Value) async -> FormCraftValidationResponse<ValidatedValue>

    public init(
        value: Value,
        delayValidation: FormCraftDelayValidation = .immediate,
        rule: @escaping (_ value: Value) async -> FormCraftValidationResponse<ValidatedValue>
    ) {
        self.value = value
        self.defaultValue = value
        self.delayValidation = delayValidation
        self.rule = rule
    }

    public func validate() async -> FormCraftFailure? {
        self.isValidation = true

        let validationResponse = await rule(value)

        switch validationResponse {
        case .success(let validatedValue):
            self.validatedValue = validatedValue
            self.isValidation = false

            return nil

        case .failure(let failure):
            self.isValidation = false

            return failure
        }
    }
}
