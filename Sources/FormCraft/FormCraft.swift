import SwiftUI

@attached(member, names: named(getAccessNames), named(getAccessOrder))
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
    func setDefaultValue<Field: FormCraftFieldConfigurable>(
        key: WritableKeyPath<Fields, Field>,
        value: Field.Value
    )
    func setDefaultValues<each Field: FormCraftFieldConfigurable>(
        _ pairs: repeat (WritableKeyPath<Fields, each Field>, (each Field).Value)
    )
    func setFocus<Field: FormCraftFieldConfigurable>(key: KeyPath<Fields, Field>?)
    func validateFieldOnChange<Field: FormCraftFieldConfigurable>(key: KeyPath<Fields, Field>) async -> Bool
    func validateFields(
        _ keys: PartialKeyPath<Fields>...,
        options: FormCraftValidateFieldsOptions
    ) async -> Bool
    func handleSubmit(onSuccess: @escaping (_ data: FormCraftValidatedFields<Fields>) async -> Void) -> () -> Void
}

public struct FormCraftOptions {
    public let shouldFocusError: Bool
    public let shouldDisableOnSubmit: Bool

    public init(
        shouldFocusError: Bool,
        shouldDisableOnSubmit: Bool
    ) {
        self.shouldFocusError = shouldFocusError
        self.shouldDisableOnSubmit = shouldDisableOnSubmit
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

public struct FormCraftValidateFieldsOptions {
    public let shouldFocusError: Bool?

    public init(
        shouldFocusError: Bool? = nil
    ) {
        self.shouldFocusError = shouldFocusError
    }
}

@MainActor
@Observable
public final class FormCraftFormState<Fields: FormCraftFields> {
    private let fields: Fields

    public package(set) var isSubmitting: Bool
    public package(set) var isValidating: Bool
    public package(set) var focusedFieldKey: PartialKeyPath<Fields>?
    public var isDisabled: Bool
    public var isDirty: Bool {
        fields.getAccessNames().contains {
            fields.getField(by: $0.value).isDirty
        }
    }

    public init(
        fields: Fields,
        isSubmitting: Bool,
        isValidating: Bool,
        focusedFieldKey: PartialKeyPath<Fields>?,
        isDisabled: Bool
    ) {
        self.fields = fields
        self.isSubmitting = isSubmitting
        self.isValidating = isValidating
        self.focusedFieldKey = focusedFieldKey
        self.isDisabled = isDisabled
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

    public subscript<Item: FormCraftCollectionItem>(
        dynamicMember collectionKeyPath: KeyPath<Fields, FormCraftCollection<Item>>
    ) -> [FormCraftValidatedFields<Item>] {
        underlyingFields[keyPath: collectionKeyPath].items.map {
            .init(fields: $0)
        }
    }
}

@Observable
public final class FormCraft<Fields: FormCraftFields>: FormCraftConfig {
    public typealias Name = String

    private var taskRefine: Task<FormCraftFailure?, Never>? = nil

    public var fields: Fields
    public var options: FormCraftOptions
    public var formState: FormCraftFormState<Fields>

    public init(
        fields: Fields,
        options: FormCraftOptions = .init(
            shouldFocusError: true,
            shouldDisableOnSubmit: true
        )
    ) {
        self.fields = fields
        self.options = options
        self.formState = .init(
            fields: fields,
            isSubmitting: false,
            isValidating: false,
            focusedFieldKey: nil,
            isDisabled: false
        )
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

    public func setDefaultValue<Field: FormCraftFieldConfigurable>(
        key: WritableKeyPath<Fields, Field>,
        value: Field.Value
    ) {
        fields[keyPath: key].errors = nil
        fields[keyPath: key].defaultValue = value
        fields[keyPath: key].isDirty = false
        fields[keyPath: key].value = value
    }

    public func setDefaultValues<each Field: FormCraftFieldConfigurable>(
        _ pairs: repeat (WritableKeyPath<Fields, each Field>, (each Field).Value)
    ) {
        func apply<F: FormCraftFieldConfigurable>(
            _ key: WritableKeyPath<Fields, F>,
            _ value: F.Value
        ) {
            setDefaultValue(key: key, value: value)
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

    public func validateFieldOnChange<Field: FormCraftFieldConfigurable>(key: KeyPath<Fields, Field>) async -> Bool {
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

    public func validateFields(
        _ keys: PartialKeyPath<Fields>...,
        options: FormCraftValidateFieldsOptions = .init()
    ) async -> Bool {
        defer {
            self.formState.isValidating = false
        }

        self.formState.isValidating = true

        let accessNames = fields.getAccessNames()
        let isFullValidation = keys.isEmpty
        let targetKeys = isFullValidation ? Set(accessNames.values) : Set(keys)

        let fieldsByName = Dictionary(
            uniqueKeysWithValues: accessNames
                .filter { targetKeys.contains($0.value) }
                .map { (name, keyPath) in
                    (name, fields.getField(by: keyPath))
                }
        )

        fieldsByName.values.forEach { field in
            field.taskValidation?.cancel()
            field.taskValidation = nil
            field.errors = nil
        }

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

        let refineFailuresByKeyPath = isFullValidation ? await validateRefine() : [:]

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

        if !failuresByKeyPath.isEmpty && (options.shouldFocusError ?? self.options.shouldFocusError) {
            await focusFirstError()
        }

        return failuresByKeyPath.isEmpty
    }

    public func handleSubmit(
        onSuccess: @escaping (_ data: FormCraftValidatedFields<Fields>) async -> Void
    ) -> () -> Void {
        { [weak self] in
            guard let self else { return }

            self.formState.isSubmitting = true

            if self.options.shouldDisableOnSubmit {
                self.formState.isDisabled = true
            }

            Task { [weak self] in
                guard let self else { return }

                defer {
                    self.formState.isSubmitting = false

                    if self.options.shouldDisableOnSubmit {
                        self.formState.isDisabled = false
                    }
                }

                let isValid = await self.validateFields()

                guard isValid else { return }

                await onSuccess(
                    FormCraftValidatedFields(fields: self.fields)
                )
            }
        }
    }
}
