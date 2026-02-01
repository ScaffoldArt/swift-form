import SwiftUI

@MainActor
public protocol FormCraftConfig: Observable, AnyObject {
    associatedtype Fields: FormCraftFields
    typealias Name = String
    typealias Key = PartialKeyPath<Fields>

    var fields: Fields { get set }
    var registeredFields: [Name] { get set }
    var formState: FormCraftFormState { get set }

    func registerField(key: Key, name: Name)
    func unregisterField(key: Key)
//    func setError(key: Key, errors: FormCraftFailure)
//    func setErrors(errors: [Key: FormCraftFailure])
//    func setErrors(errors: [Name: [String]])
//    func clearError(key: Key)
//    func clearErrors()
//    func validateField(key: Key) async
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
        fields[keyPath: keyPath].validatedValue as! Field.ValidatedValue
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

    private var fieldNameByKeyPath: [Key: Name] = [:]

    public init(fields: Fields) {
        self.fields = fields
    }

    public func registerField(key: Key, name: Name) {
        fieldNameByKeyPath[key] = name

        if registeredFields.contains(name) {
            return
        }

        registeredFields.append(name)
    }

    public func unregisterField(key: Key) {
        guard let name = fieldNameByKeyPath[key] else { return }

        fieldNameByKeyPath.removeValue(forKey: key)

        registeredFields.removeAll(where: { $0 == name })
    }

//    public func setError(key: Key, errors: FormCraftFailure) {
//        guard let name = fieldNameByKeyPath[key] else { return }
//
//        errorFields[name] = errors
//    }
//
//    public func setErrors(errors: [Key: FormCraftFailure]) {
//        errors.forEach { error in
//            setError(key: error.key, errors: error.value)
//        }
//    }
//
//    public func setErrors(errors: [String: [String]]) {
//        errorFields = errors.mapValues { .init($0) }
//    }
//
//    public func clearError(key: Key) {
//        guard let name = fieldNameByKeyPath[key] else { return }
//
//        errorFields.removeValue(forKey: name)
//    }
//
//    public func clearErrors() {
//        errorFields.removeAll()
//    }
//
//    private func refineErrors() async -> [Name: FormCraftFailure] {
//        let results = await fields.refine(form: self)
//
//        let pairs: [(Name, FormCraftFailure)] = results.compactMap { (key, result) in
//            guard
//                case let .failure(errors) = result,
//                let name = fieldNameByKeyPath[key]
//            else {
//                return nil
//            }
//
//            return (name, errors)
//        }
//
//        return Dictionary(pairs, uniquingKeysWith: { _, new in new })
//    }
//
//    public func validateField(key: Key) async {
//        validationFields[key]?.cancel()
//
//        guard let field = fields[keyPath: key] as? any FormCraftFieldConfigurable else { return }
//
//        validationFields[key] = Task {
//            if field.delayValidation.seconds > 0 {
//                try? await Task.sleep(for: .seconds(field.delayValidation.seconds))
//
//                if Task.isCancelled {
//                    return
//                }
//            }
//
//            async let validation = field.validate()
//            async let refinedErrors = refineErrors()
//
//            let (validationResult, refinedResult) = await (validation, refinedErrors)
//            let (validatedValue, validatedErrors) = validationResult
//            let fieldErrors =
//                (fieldNameByKeyPath[key].flatMap { refinedResult[$0] }?.errors ?? []) +
//                (validatedErrors?.errors ?? [])
//
//            if Task.isCancelled {
//                return
//            }
//
//            if !fieldErrors.isEmpty {
//                setError(
//                    key: key,
//                    errors: .init(fieldErrors)
//                )
//            } else {
//                validatedFields[key] = validatedValue
//                clearError(key: key)
//            }
//
//            validationFields.removeValue(forKey: key)
//        }
//
//        await validationFields[key]?.value
//    }

    public func validateFields() async -> Bool {
        var isValid = true

        for key in fieldNameByKeyPath.keys {
            guard let field = fields[keyPath: key] as? any FormCraftFieldConfigurable else {
                continue
            }

            let result = await field.validate()

            if isValid {
                isValid = result
            }
        }

        return isValid
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
