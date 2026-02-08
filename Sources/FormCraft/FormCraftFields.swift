//
//  FormCraftFields.swift
//  FormCraft
//
//  Created by Артем Дробышев on 18.01.2026.
//

import SwiftUI

public struct FormCraftFailure: Sendable {
    public let errors: [LocalizedStringResource]

    public init(_ errors: [LocalizedStringResource]) {
        self.errors = errors
    }

    public init(_ errors: [String]) {
        self.errors = errors.map { .init(stringLiteral: $0) }
    }
}

@MainActor
public protocol FormCraftFields {
    func getAccessNames() -> [String: PartialKeyPath<Self>]
    func refine(form: FormCraft<Self>) async -> [FormCraft<Self>.Key: FormCraftFailure?]
}

public extension FormCraftFields {
    func refine(form: FormCraft<Self>) async -> [FormCraft<Self>.Key: FormCraftFailure?] {
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
    var isValidation: Bool { get }
    var isDirty: Bool { get set }
    var delayValidation: FormCraftDelayValidation { get }
    var rule: (_ value: Value) async -> FormCraftValidationResponse<ValidatedValue> { get }

    func validate() async -> Bool
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
    public var isDirty: Bool = false
    public let delayValidation: FormCraftDelayValidation
    public let rule: (_ value: Value) async -> FormCraftValidationResponse<ValidatedValue>

    private var taskValidation: Task<Bool, Never>? = nil

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

    public func validate() async -> Bool {
        taskValidation?.cancel()

        let task = Task { () -> Bool in
            isValidation = true

            if delayValidation.seconds > 0 {
                try? await Task.sleep(for: .seconds(delayValidation.seconds))

                if Task.isCancelled {
                    return false
                }
            }

            let validationResponse = await rule(value)

            if Task.isCancelled {
                return false
            }

            switch validationResponse {
            case .success(let validatedValue):
                self.validatedValue = validatedValue
                self.errors = nil
                self.isValidation = false
                return true

            case .failure(let failure):
                self.errors = failure
                self.isValidation = false
                return false
            }
        }

        taskValidation = task

        return await task.value
    }
}
