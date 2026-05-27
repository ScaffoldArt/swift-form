# Cross-Field Validation

Use `refine` when a field is valid on its own, but the whole form needs an additional rule that compares multiple fields.

This example validates `password` and `confirmPassword` separately, then adds a form-level error when they do not match.

```swift
import SwiftUI
import SAForm

@SAForm
private struct RegisterFormFields: SAFormFields {
    var email = SAFormField(value: "") { value in
        await SAFormValidationRules()
            .string()
            .trimmed()
            .notEmpty()
            .email()
            .validate(value: value)
    }

    var password = SAFormField(value: "") { value in
        await SAFormValidationRules()
            .string()
            .notEmpty()
            .min(min: 8)
            .validate(value: value)
    }

    var confirmPassword = SAFormField(value: "") { value in
        await SAFormValidationRules()
            .string()
            .notEmpty()
            .validate(value: value)
    }

    func refine(form: SAForm<Self>) async -> [PartialKeyPath<Self>: SAFormFailure?] {
        guard password.value != confirmPassword.value else {
            return [:]
        }

        return [
            \.confirmPassword: .init(["Passwords do not match"])
        ]
    }
}

struct RegisterFormView: View {
    @State private var form = SAForm(fields: RegisterFormFields())

    private func handleRegister(
        data: SAFormValidatedFields<RegisterFormFields>
    ) async {
        let email: String = data.email
        let password: String = data.password

        print(email)
        print(password)
    }

    var body: some View {
        VStack(spacing: 12) {
            SAFormView(formConfig: form) {
                SAFormControllerView(
                    formConfig: form,
                    key: \.email
                ) { value, field in
                    TextField("Email", text: value)
                        .textFieldStyle(.roundedBorder)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError)
                            .foregroundStyle(.red)
                    }
                }

                SAFormControllerView(
                    formConfig: form,
                    key: \.password
                ) { value, field in
                    SecureField("Password", text: value)
                        .textFieldStyle(.roundedBorder)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError)
                            .foregroundStyle(.red)
                    }
                }

                SAFormControllerView(
                    formConfig: form,
                    key: \.confirmPassword
                ) { value, field in
                    SecureField("Confirm password", text: value)
                        .textFieldStyle(.roundedBorder)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError)
                            .foregroundStyle(.red)
                    }
                }
            }

            Button("Register", action: form.handleSubmit(onSuccess: handleRegister))
                .disabled(form.formState.isSubmitting)
        }
    }
}
```

## Key Idea

Field rules validate one value at a time.
`refine` runs during full form validation, so it is the right place for checks that need more than one field.
