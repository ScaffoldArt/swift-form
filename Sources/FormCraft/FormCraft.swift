import SwiftUI

@attached(member, names: named(getAccessNames), named(getAccessOrder), named(_formCraftAccessNamesCache))
public macro FormCraft() = #externalMacro(module: "FormCraftMacros", type: "FormCraft")

@MainActor
public protocol FormCraftConfig: Observable, AnyObject {
    associatedtype Fields: FormCraftFields
    typealias Name = String

    var fields: Fields { get set }
    var options: FormCraftOptions { get }
    var formState: FormCraftFormState<Fields> { get set }

    func setErrors<each Field: FormCraftFieldConfigurable>(
        _ pairs: repeat (KeyPath<Fields, each Field>, FormCraftFailure),
        options: FormCraftSetErrorsOptions
    )
    func setErrors(
        errors: [Name: [String]],
        options: FormCraftSetErrorsOptions
    )
    func clearError<Field: FormCraftFieldConfigurable>(key: KeyPath<Fields, Field>)
    func clearErrors()
    func setDefaultValues<each Field: FormCraftFieldConfigurable>(
        _ pairs: repeat (WritableKeyPath<Fields, each Field>, (each Field).Value)
    )
    func setFocus<Field: FormCraftFieldConfigurable>(key: KeyPath<Fields, Field>?)
    func validateField<Field: FormCraftFieldConfigurable>(key: KeyPath<Fields, Field>) async -> Bool
    func validateFields() async -> Bool
    func handleSubmit(onSuccess: @escaping (_ data: FormCraftValidatedFields<Fields>) async -> Void) -> () -> Void
}

public struct FormCraftOptions {
    public let shouldFocusError: Bool

    public init(
        shouldFocusError: Bool = true
    ) {
        self.shouldFocusError = shouldFocusError
    }
}

public struct FormCraftSetErrorsOptions {
    public let shouldFocusError: Bool?

    public init(
        shouldFocusError: Bool? = nil
    ) {
        self.shouldFocusError = shouldFocusError
    }
}

@Observable
public final class FormCraftFormState<Fields> {
    public var isSubmitting: Bool
    public var focusedFieldKey: PartialKeyPath<Fields>?

    public init(isSubmitting: Bool, focusedFieldKey: PartialKeyPath<Fields>? = nil) {
        self.isSubmitting = isSubmitting
        self.focusedFieldKey = focusedFieldKey
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

    public subscript<Group: FormCraftGroup>(
        dynamicMember nestedKeyPath: KeyPath<Fields, Group>
    ) -> FormCraftValidatedFields<Group> {
        .init(fields: underlyingFields[keyPath: nestedKeyPath])
    }
}

@Observable
public final class FormCraft<Fields: FormCraftFields>: FormCraftConfig {
    public typealias Name = String

    private var taskRefine: Task<FormCraftFailure?, Never>? = nil

    public var fields: Fields
    public var options: FormCraftOptions
    public var formState = FormCraftFormState<Fields>(
        isSubmitting: false,
        focusedFieldKey: nil
    )

    public init(
        fields: Fields,
        options: FormCraftOptions = .init()
    ) {
        self.fields = fields
        self.options = options
    }

    public func setErrors<each Field: FormCraftFieldConfigurable>(
        _ pairs: repeat (KeyPath<Fields, each Field>, FormCraftFailure),
        options: FormCraftSetErrorsOptions = .init()
    ) {
        func apply<F: FormCraftFieldConfigurable>(_ key: KeyPath<Fields, F>, _ failure: FormCraftFailure) {
            fields[keyPath: key].errors = failure
        }

        repeat apply((each pairs).0, (each pairs).1)

        if options.shouldFocusError ?? self.options.shouldFocusError {
            Task {
                await focusFirstError()
            }
        }
    }

    public func setErrors(
        errors: [String: [String]],
        options: FormCraftSetErrorsOptions = .init()
    ) {
        errors.forEach { error in
            guard let fieldKey = fields.getAccessNames()[error.key] else {
                return
            }

            fields.getField(by: fieldKey).errors = .init(error.value.compactMap { .init($0) })
        }

        if options.shouldFocusError ?? self.options.shouldFocusError {
            Task {
                await focusFirstError()
            }
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
            fields[keyPath: key].errors = nil
            fields[keyPath: key].defaultValue = value
            fields[keyPath: key].isDirty = false
            fields[keyPath: key].value = value
        }
        repeat apply((each pairs).0, (each pairs).1)
    }

    public func setFocus<Field: FormCraftFieldConfigurable>(key: KeyPath<Fields, Field>?) {
        if formState.focusedFieldKey == key {
            return
        }

        formState.focusedFieldKey = key
    }

    private func focusFirstError() async {
        formState.focusedFieldKey = nil

        await Task.yield()

        let order = fields.getAccessOrder()
        let accessNames = fields.getAccessNames()

        for name in order {
            guard let keyPath = accessNames[name] else {
                continue
            }

            let field = fields.getField(by: keyPath)
            if field.mounted && field.errors != nil {
                formState.focusedFieldKey = keyPath

                return
            }
        }

        formState.focusedFieldKey = nil
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

                if !isValid && self.options.shouldFocusError {
                    await focusFirstError()
                }

                guard isValid else { return }

                await onSuccess(
                    FormCraftValidatedFields(fields: self.fields)
                )
            }
        }
    }
}
