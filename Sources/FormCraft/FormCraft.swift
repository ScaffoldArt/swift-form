import SwiftUI

@attached(member, names: named(getAccessNames))
public macro FormCraft() = #externalMacro(module: "FormCraftMacros", type: "FormCraft")

@MainActor
public protocol FormCraftConfig: Observable, AnyObject {
    associatedtype Fields: FormCraftFields
    typealias Name = String
    typealias Key = PartialKeyPath<Fields>

    var fields: Fields { get set }
    var registeredFields: [Name] { get set }
    var formState: FormCraftFormState { get set }

    func setErrors(errors: [Key: FormCraftFailure])
    func setErrors(errors: [Name: [String]])
    func clearError(key: Key)
    func clearErrors() async
    func setDefaultValues<Field: FormCraftFieldConfigurable>(
        values: [WritableKeyPath<Fields, Field>: Field.Value]
    )
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
    private let fields: Fields

    public init(
        fields: Fields
    ) {
        self.fields = fields
    }

    public subscript<Field: FormCraftFieldConfigurable>(
        dynamicMember keyPath: KeyPath<Fields, Field>
    ) -> Field.ValidatedValue {
        fields[keyPath: keyPath].validatedValue!
    }
}

@Observable
public final class FormCraft<Fields: FormCraftFields>: FormCraftConfig {
    public typealias Name = String
    public typealias Key = PartialKeyPath<Fields>

    public var fields: Fields
    public var registeredFields: [Name] = []
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

    public func validateFields() async -> Bool {
        let fieldsToValidate = fields.getAccessNames().compactMap { (_, key) in
            fields[keyPath: key] as? any FormCraftFieldConfigurable
        }

        return await withTaskGroup(of: Bool.self) { group in
            for field in fieldsToValidate {
                group.addTask {
                    await field.validate()
                }
            }

            var allValid = true
            for await isValid in group where !isValid {
                allValid = false
            }
            return allValid
        }
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
