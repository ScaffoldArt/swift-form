import SwiftUI

@attached(member, names: named(getAccessNames))
public macro FormCraft() = #externalMacro(module: "FormCraftMacros", type: "FormCraft")

@MainActor
public protocol FormCraftConfig: Observable, AnyObject {
    associatedtype Fields: FormCraftFields
    typealias Name = String
    typealias Key = PartialKeyPath<Fields>

    var fields: Fields { get set }
    var formState: FormCraftFormState { get set }

    func setErrors(errors: [Key: FormCraftFailure])
    func setErrors(errors: [Name: [String]])
    func clearError(key: Key)
    func clearErrors() async
    func setDefaultValues<Field: FormCraftFieldConfigurable>(
        values: [WritableKeyPath<Fields, Field>: Field.Value]
    )
    func validateField(key: Key) async -> Bool
    func validateFields() async -> Bool
    func handleSubmit(onSuccess: @escaping (_ data: FormCraftValidatedFields<Fields>) async -> Void) -> () -> Void
}

public struct FormCraftFormState {
    public var isSubmitting: Bool

    public init(isSubmitting: Bool) {
        self.isSubmitting = isSubmitting
    }
}

public struct FormCraftSetValueConfig {
    public let shouldValidate: Bool

    public init(shouldValidate: Bool) {
        self.shouldValidate = shouldValidate
    }
}

@dynamicMemberLookup @MainActor
public struct FormCraftValidatedFields<Fields> {
    private let underlyingFields: Fields

    public init(
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
    public typealias Key = PartialKeyPath<Fields>

    public var fields: Fields
    public var formState = FormCraftFormState(
        isSubmitting: false
    )

    public init(fields: Fields) {
        self.fields = fields
    }


    public func setErrors(errors: [Key: FormCraftFailure]) {
        errors.forEach { error in
            guard let field = fields[keyPath: error.key] as? FormCraftFieldConfigurable else {
                return
            }

            field.errors = error.value
        }
    }

    public func setErrors(errors: [String: [String]]) {
        errors.forEach { error in
            guard let fieldKey = fields.getAccessNames()[error.key] else {
                return
            }

            guard let field = fields[keyPath: fieldKey] as? FormCraftFieldConfigurable else {
                return
            }

            field.errors = .init(error.value.compactMap { .init($0) })
        }
    }

    public func clearError(key: Key) {
        guard let field = fields[keyPath: key] as? FormCraftFieldConfigurable else {
            return
        }

        field.errors = nil
    }

    public func clearErrors() {
        fields.getAccessNames().mapValues { fieldKey in
            if let field = fields[keyPath: fieldKey] as? FormCraftFieldConfigurable {
                field.errors = nil
            }
        }
    }

    public func setDefaultValues<Field: FormCraftFieldConfigurable>(
        values: [WritableKeyPath<Fields, Field> : Field.Value]
    ) {
        values.forEach { item in
            fields[keyPath: item.key].defaultValue = item.value
            fields[keyPath: item.key].isDirty = false
            fields[keyPath: item.key].value = item.value
        }
    }

    public func validateField(key: Key) async -> Bool {
        guard let field = fields[keyPath: key] as? FormCraftFieldConfigurable else {
            return true
        }

        field.taskValidation?.cancel()

        let task = Task {
            field.isValidation = true

            if field.delayValidation.seconds > 0 {
                try? await Task.sleep(for: .seconds(field.delayValidation.seconds))

                if Task.isCancelled {
                    return
                }
            }

            async let asyncFieldValidated = field.validate()
            let refineValidated = await fields.refine(form: self)
            let fieldValidated = await asyncFieldValidated

            if Task.isCancelled {
                return
            }

            field.errors = fieldValidated

            refineValidated.forEach {
                guard let field = fields[keyPath: $0.key] as? FormCraftFieldConfigurable else {
                    return
                }

                if $0.key == key, let errors = field.errors {
//                    errors.errors += $0.value?.errors ?? []

                    return
                }

//                field.
            }
        }

        field.taskValidation = task

        await task.value

//        async let fieldValidated = field.validate()
//        async let refineValidated = fields.refine(form: self)


        return true
    }

    public func validateFields() async -> Bool {
        let fieldsByName = fields.getAccessNames().flatMap { (name, key) in
            [name: fields[keyPath: key] as? any FormCraftFieldConfigurable]
        }

        clearErrors()

        async let asyncPerFieldValidationFailures = withTaskGroup(of: [Name: FormCraftFailure?].self) { group in
            for (name, field) in fieldsByName {
                group.addTask {
                    let failure = await field?.validate()

                    return [name: failure]
                }
            }

            var collected: [Name: FormCraftFailure?] = [:]
            for await partial in group {
                collected.merge(partial, uniquingKeysWith: { _, new in new })
            }

            return collected.compactMapValues { $0 }
        }

        let refineFailuresByKeyPath: [Key: FormCraftFailure] = await fields
            .refine(form: self)
            .compactMapValues { $0 }

        let perFieldValidationFailures = await asyncPerFieldValidationFailures 

        var failuresByKeyPath: [Key: FormCraftFailure] = Dictionary(
            uniqueKeysWithValues: perFieldValidationFailures.compactMap { name, failure in
                guard let keyPath = fields.getAccessNames()[name] else { return nil }

                return (keyPath, failure)
            }
        )

        failuresByKeyPath.merge(
            refineFailuresByKeyPath,
            uniquingKeysWith: { lhs, rhs in .init(lhs.errors + rhs.errors) }
        )

        failuresByKeyPath.forEach { keyPath, failure in
            guard let field = fields[keyPath: keyPath] as? any FormCraftFieldConfigurable else { return }

            field.errors = failure
        }

        return perFieldValidationFailures.isEmpty
    }

    public func handleSubmit(
        onSuccess: @escaping (_ data: FormCraftValidatedFields<Fields>) async -> Void
    ) -> () -> Void {
        {
            self.formState.isSubmitting = true

            Task { [weak self] in
                guard let self else { return }

                let isValid = await self.validateFields()

                if isValid {
                    await onSuccess(FormCraftValidatedFields(
                        fields: self.fields
                    ))
                }

                self.formState.isSubmitting = false
            }
        }
    }
}
