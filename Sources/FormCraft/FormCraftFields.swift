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
    func refine(form: FormCraft<Self>) async -> [FormCraft<Self>.Key: FormCraftValidationResponse<Sendable>]
}

public extension FormCraftFields {
    func refine(form: FormCraft<Self>) async -> [FormCraft<Self>.Key: FormCraftValidationResponse<Sendable>] {
        [:]
    }
}

@MainActor
public protocol FormCraftFieldConfigurable: Observable, AnyObject {
    associatedtype Value: Equatable & Sendable
    associatedtype ValidatedValue: Sendable

    var name: String { get }
    var value: Value { get set }
    var validatedValue: ValidatedValue? { get }
    var defaultValue: Value { get }
    var mounted: Bool { get set }
    var errors: FormCraftFailure? { get }
    var isValidation: Bool { get }
    var isDirty: Bool { get set }
    var delayValidation: FormCraftDelayValidation { get }
    var rule: (_ value: Value) async -> FormCraftValidationResponse<ValidatedValue> { get }

    func validate() async -> Bool
}

public enum FormCraftValidationResponse<Value: Sendable> {
    case success(value: Value)
    case failure(errors: FormCraftFailure)

    public var errors: [LocalizedStringResource]? {
        if case .failure(let failure) = self {
            return failure.errors
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
    public let name: String
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
        name: String,
        value: Value,
        delayValidation: FormCraftDelayValidation = .immediate,
        rule: @escaping (_ value: Value) async -> FormCraftValidationResponse<ValidatedValue>
    ) {
        self.name = name
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
