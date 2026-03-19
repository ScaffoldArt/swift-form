import SwiftUI

@attached(member, names: named(getAccessNames), named(_formCraftAccessNamesCache))
public macro FormCraft() = #externalMacro(module: "FormCraftMacros", type: "FormCraft")

@MainActor
public protocol FormCraftConfig: Observable, AnyObject {
    associatedtype Fields: FormCraftFields
    typealias Name = String

    var fields: Fields { get set }
    var formState: FormCraftFormState { get set }

    func setErrors<each Field: FormCraftFieldConfigurable>(
        _ pairs: repeat (KeyPath<Fields, each Field>, FormCraftFailure)
    )
    func setErrors(errors: [Name: [String]])
    func clearError<Field: FormCraftFieldConfigurable>(key: KeyPath<Fields, Field>)
    func clearErrors()
    func setDefaultValues<each Field: FormCraftFieldConfigurable>(
        _ pairs: repeat (WritableKeyPath<Fields, each Field>, (each Field).Value)
    )
    func validateField<Field: FormCraftFieldConfigurable>(key: KeyPath<Fields, Field>) async -> Bool
    func validateFields() async -> Bool
    func handleSubmit(onSuccess: @escaping (_ data: FormCraftValidatedFields<Fields>) async -> Void) -> () -> Void
}

public struct FormCraftFormState {
    public var isSubmitting: Bool

    public init(isSubmitting: Bool) {
        self.isSubmitting = isSubmitting
    }
}

@dynamicMemberLookup @MainActor
public struct FormCraftValidatedFields<Fields> {
    private let underlyingFields: Fields

    init(
        fields: Fields
    ) {
        self.underlyingFields = fields
    }

    public subscript<Field: FormCraftFieldConfigurable>(
        dynamicMember fieldKeyPath: KeyPath<Fields, Field>
    ) -> Field.ValidatedValue {
        underlyingFields[keyPath: fieldKeyPath].validatedValue!
    }
}

@Observable
public final class FormCraft<Fields: FormCraftFields>: FormCraftConfig {
    public typealias Name = String

    private var taskRefine: Task<FormCraftFailure?, Never>? = nil

    public var fields: Fields
    public var formState = FormCraftFormState(
        isSubmitting: false
    )

    public init(fields: Fields) {
        self.fields = fields
    }

    public func setErrors<each Field: FormCraftFieldConfigurable>(
        _ pairs: repeat (KeyPath<Fields, each Field>, FormCraftFailure)
    ) {
        func apply<F: FormCraftFieldConfigurable>(_ key: KeyPath<Fields, F>, _ failure: FormCraftFailure) {
            fields[keyPath: key].errors = failure
        }

        repeat apply((each pairs).0, (each pairs).1)
    }

    public func setErrors(errors: [String: [String]]) {
        errors.forEach { error in
            guard let fieldKey = fields.getAccessNames()[error.key] else {
                return
            }

            fields.getField(by: fieldKey).errors = .init(error.value.compactMap { .init($0) })
        }
    }

    public func clearError<Field: FormCraftFieldConfigurable>(key: KeyPath<Fields, Field>) {
        let field = fields[keyPath: key]

        field.errors = nil
    }

    public func clearErrors() {
        fields.getAccessNames().forEach { _, fieldKey in
            fields.getField(by: fieldKey).errors = nil
        }
    }

    public func setDefaultValues<each Field: FormCraftFieldConfigurable>(
        _ pairs: repeat (WritableKeyPath<Fields, each Field>, (each Field).Value)
    ) {
        func apply<F: FormCraftFieldConfigurable>(_ key: WritableKeyPath<Fields, F>, _ value: F.Value) {
            fields[keyPath: key].defaultValue = value
            fields[keyPath: key].isDirty = false
            fields[keyPath: key].value = value
        }
        repeat apply((each pairs).0, (each pairs).1)
    }

    private func validateRefine() async -> [PartialKeyPath<Fields>: FormCraftFailure] {
        taskRefine?.cancel()

        if Task.isCancelled {
            return [:]
        }

        let refineValidated = await fields.refine(form: self)

        if Task.isCancelled {
            return [:]
        }

        return refineValidated.compactMapValues { $0 }
    }

    public func validateField<Field: FormCraftFieldConfigurable>(key: KeyPath<Fields, Field>) async -> Bool {
        let field = fields[keyPath: key]

        field.taskValidation?.cancel()

        let task = Task {
            if field.delayValidation.seconds > 0 {
                try? await Task.sleep(for: .seconds(field.delayValidation.seconds))

                if Task.isCancelled {
                    return
                }
            }

            async let asyncFieldValidated = field.validate()
            let fieldValidated = await asyncFieldValidated

            if Task.isCancelled {
                return
            }

            if let fieldValidated {
                field.errors = fieldValidated
            } else {
                field.errors = nil
            }
        }

        field.taskValidation = task

        await task.value

        return field.errors == nil
    }

    public func validateFields() async -> Bool {
        let accessNames = fields.getAccessNames()
        let fieldsByName = Dictionary(
            uniqueKeysWithValues: accessNames.map { (name, keyPath) in
                (name, fields.getField(by: keyPath))
            }
        )

        fieldsByName.values.forEach { field in
            field.taskValidation?.cancel()
            field.taskValidation = nil
        }

        clearErrors()

        async let asyncPerFieldValidationFailures = withTaskGroup(of: (Name, FormCraftFailure?).self) { group in
            for (name, field) in fieldsByName {
                group.addTask {
                    (name, await field.validate())
                }
            }

            var collected: [Name: FormCraftFailure?] = [:]
            for await (name, failure) in group {
                collected[name] = failure
            }

            return collected.compactMapValues { $0 }
        }

        let refineFailuresByKeyPath = await validateRefine()

        let perFieldValidationFailures = await asyncPerFieldValidationFailures 

        var failuresByKeyPath: [PartialKeyPath<Fields>: FormCraftFailure] = Dictionary(
            uniqueKeysWithValues: perFieldValidationFailures.compactMap { name, failure in
                guard let keyPath = accessNames[name] else { return nil }

                return (keyPath, failure)
            }
        )

        failuresByKeyPath.merge(
            refineFailuresByKeyPath,
            uniquingKeysWith: { lhs, rhs in .init(lhs.messages + rhs.messages) }
        )

        failuresByKeyPath.forEach { keyPath, failure in
            fields.getField(by: keyPath).errors = failure
        }

        return failuresByKeyPath.isEmpty
    }

    public func handleSubmit(
        onSuccess: @escaping (_ data: FormCraftValidatedFields<Fields>) async -> Void
    ) -> () -> Void {
        { [weak self] in
            guard let self else { return }

            self.formState.isSubmitting = true

            Task { [weak self] in
                guard let self else { return }

                defer { self.formState.isSubmitting = false }

                let isValid = await self.validateFields()

                guard isValid else { return }

                await onSuccess(
                    FormCraftValidatedFields(fields: self.fields)
                )
            }
        }
    }
}
