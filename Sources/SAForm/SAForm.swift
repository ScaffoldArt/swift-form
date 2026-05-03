import SwiftUI

@attached(member, names: named(getAccessNames), named(getAccessOrder))
public macro SAForm() = #externalMacro(module: "SAFormMacros", type: "SAForm")

@MainActor
public protocol SAFormConfig: Observable, AnyObject {
    associatedtype Fields: SAFormFields
    typealias Name = String

    var fields: Fields { get set }
    var options: SAFormOptions { get }
    var formState: SAFormFormState<Fields> { get set }

    func setErrors<each Field: SAFormFieldConfigurable>(
        _ pairs: repeat (KeyPath<Fields, each Field>, SAFormFailure),
        options: SAFormSetErrorsOptions
    )
    func setErrors(
        errors: [Name: [String]],
        options: SAFormSetErrorsOptions
    )
    func clearError<Field: SAFormFieldConfigurable>(key: KeyPath<Fields, Field>)
    func clearErrors()
    func setDefaultValue<Field: SAFormFieldConfigurable>(
        key: WritableKeyPath<Fields, Field>,
        value: Field.Value
    )
    func setDefaultValues<each Field: SAFormFieldConfigurable>(
        _ pairs: repeat (WritableKeyPath<Fields, each Field>, (each Field).Value)
    )
    func setFocus<Field: SAFormFieldConfigurable>(key: KeyPath<Fields, Field>?)
    func validateFieldOnChange<Field: SAFormFieldConfigurable>(key: KeyPath<Fields, Field>) async -> Bool
    func validateFields(
        _ keys: PartialKeyPath<Fields>...,
        options: SAFormValidateFieldsOptions
    ) async -> Bool
    func handleSubmit(
        onSuccess: @escaping (_ data: SAFormValidatedFields<Fields>) async -> Void,
        options: SAFormHandleSubmitOptions
    ) -> () -> Void
}

public struct SAFormOptions {
    public let shouldFocusError: Bool

    public init(
        shouldFocusError: Bool = true,
    ) {
        self.shouldFocusError = shouldFocusError
    }
}

public struct SAFormSetErrorsOptions {
    public let shouldFocusError: Bool?

    public init(
        shouldFocusError: Bool? = nil
    ) {
        self.shouldFocusError = shouldFocusError
    }
}

public struct SAFormValidateFieldsOptions {
    public let shouldFocusError: Bool?
    public let shouldDisable: Bool?

    public init(
        shouldFocusError: Bool? = nil,
        shouldDisable: Bool? = nil
    ) {
        self.shouldFocusError = shouldFocusError
        self.shouldDisable = shouldDisable
    }
}

public struct SAFormHandleSubmitOptions {
    public let shouldDisable: Bool?

    public init(
        shouldDisabled: Bool? = nil
    ) {
        self.shouldDisable = shouldDisabled
    }
}

@MainActor
@Observable
public final class SAFormFormState<Fields: SAFormFields> {
    private let fields: Fields

    public package(set) var isSubmitting: Bool
    public package(set) var isSubmitted: Bool
    public package(set) var isSubmitSuccessful: Bool
    public package(set) var focusedFieldKey: PartialKeyPath<Fields>?
    public var isDisabled: Bool
    public var isValidating: Bool {
        fields.getAccessNames().contains {
            fields.getField(by: $0.value).isValidating
        }
    }
    public var isDirty: Bool {
        fields.getAccessNames().contains {
            fields.getField(by: $0.value).isDirty
        }
    }

    public init(
        fields: Fields,
        isSubmitting: Bool,
        isSubmitted: Bool,
        isSubmitSuccessful: Bool,
        focusedFieldKey: PartialKeyPath<Fields>?,
        isDisabled: Bool
    ) {
        self.fields = fields
        self.isSubmitting = isSubmitting
        self.isSubmitted = isSubmitted
        self.isSubmitSuccessful = isSubmitSuccessful
        self.focusedFieldKey = focusedFieldKey
        self.isDisabled = isDisabled
    }
}

@dynamicMemberLookup @MainActor
public struct SAFormValidatedFields<Fields> {
    private let underlyingFields: Fields

    init(
        fields: Fields
    ) {
        self.underlyingFields = fields
    }

    public subscript<Field: SAFormFieldConfigurable>(
        dynamicMember fieldKeyPath: KeyPath<Fields, Field>
    ) -> Field.ValidatedValue {
        underlyingFields[keyPath: fieldKeyPath].validatedValue!
    }

    public subscript<Group: SAFormGroup>(
        dynamicMember nestedKeyPath: KeyPath<Fields, Group>
    ) -> SAFormValidatedFields<Group> {
        .init(fields: underlyingFields[keyPath: nestedKeyPath])
    }

    public subscript<Item: SAFormCollectionItem>(
        dynamicMember collectionKeyPath: KeyPath<Fields, SAFormCollection<Item>>
    ) -> [SAFormValidatedFields<Item>] {
        underlyingFields[keyPath: collectionKeyPath].items.map {
            .init(fields: $0)
        }
    }
}

@Observable
public final class SAForm<Fields: SAFormFields>: SAFormConfig {
    public typealias Name = String

    private var taskRefine: Task<SAFormFailure?, Never>? = nil

    public var fields: Fields
    public var options: SAFormOptions
    public var formState: SAFormFormState<Fields>

    public init(
        fields: Fields,
        options: SAFormOptions
    ) {
        self.fields = fields
        self.options = options
        self.formState = .init(
            fields: fields,
            isSubmitting: false,
            isSubmitted: false,
            isSubmitSuccessful: false,
            focusedFieldKey: nil,
            isDisabled: false
        )
    }

    public func setErrors<each Field: SAFormFieldConfigurable>(
        _ pairs: repeat (KeyPath<Fields, each Field>, SAFormFailure),
        options: SAFormSetErrorsOptions = .init()
    ) {
        func apply<F: SAFormFieldConfigurable>(_ key: KeyPath<Fields, F>, _ failure: SAFormFailure) {
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
        options: SAFormSetErrorsOptions = .init()
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

    public func clearError<Field: SAFormFieldConfigurable>(key: KeyPath<Fields, Field>) {
        let field = fields[keyPath: key]

        field.errors = nil
    }

    public func clearErrors() {
        fields.getAccessNames().forEach { _, fieldKey in
            fields.getField(by: fieldKey).errors = nil
        }
    }

    public func setDefaultValue<Field: SAFormFieldConfigurable>(
        key: WritableKeyPath<Fields, Field>,
        value: Field.Value
    ) {
        fields[keyPath: key].errors = nil
        fields[keyPath: key].defaultValue = value
        fields[keyPath: key].isDirty = false
        fields[keyPath: key].value = value
    }

    public func setDefaultValues<each Field: SAFormFieldConfigurable>(
        _ pairs: repeat (WritableKeyPath<Fields, each Field>, (each Field).Value)
    ) {
        func apply<F: SAFormFieldConfigurable>(
            _ key: WritableKeyPath<Fields, F>,
            _ value: F.Value
        ) {
            setDefaultValue(key: key, value: value)
        }
        repeat apply((each pairs).0, (each pairs).1)
    }

    public func setFocus<Field: SAFormFieldConfigurable>(key: KeyPath<Fields, Field>?) {
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

    private func validateRefine() async -> [PartialKeyPath<Fields>: SAFormFailure] {
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

    public func validateFieldOnChange<Field: SAFormFieldConfigurable>(key: KeyPath<Fields, Field>) async -> Bool {
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
        options: SAFormValidateFieldsOptions = .init()
    ) async -> Bool {
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

        async let asyncPerFieldValidationFailures = withTaskGroup(of: (Name, SAFormFailure?).self) { group in
            for (name, field) in fieldsByName {
                group.addTask {
                    (name, await field.validate())
                }
            }

            var collected: [Name: SAFormFailure?] = [:]
            for await (name, failure) in group {
                collected[name] = failure
            }

            return collected.compactMapValues { $0 }
        }

        let refineFailuresByKeyPath = isFullValidation ? await validateRefine() : [:]

        let perFieldValidationFailures = await asyncPerFieldValidationFailures

        var failuresByKeyPath: [PartialKeyPath<Fields>: SAFormFailure] = Dictionary(
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
        onSuccess: @escaping (_ data: SAFormValidatedFields<Fields>) async -> Void,
        options: SAFormHandleSubmitOptions = .init()
    ) -> () -> Void {
        { [weak self] in
            guard let self else { return }

            self.formState.isSubmitting = true
            self.formState.isSubmitted = true

            if options.shouldDisable == true {
                self.formState.isDisabled = true
            }

            Task { [weak self] in
                guard let self else { return }

                defer {
                    self.formState.isSubmitting = false

                    if options.shouldDisable == true {
                        self.formState.isDisabled = false
                    }
                }

                let isValid = await self.validateFields()

                guard isValid else { return }

                await onSuccess(
                    SAFormValidatedFields(fields: self.fields)
                )

                self.formState.isSubmitSuccessful = true
            }
        }
    }
}
