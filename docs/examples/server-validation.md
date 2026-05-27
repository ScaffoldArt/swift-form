# Server Validation

This example shows an async field validation rule that first validates the email format locally, then checks the email on a server.

```swift
import SwiftUI
import SAForm

private func checkExistEmail(email: String) async -> Bool {
    try? await Task.sleep(nanoseconds: 3_000_000_000)

    let existingEmails = [
        "test@gmail.com",
        "john.doe@example.com",
        "maria.smith@testmail.org",
        "alex_ivanov@demo.net",
        "user123@mydomain.co"
    ]

    return !existingEmails.contains(email)
}

@SAForm
private struct LoginFormFields: SAFormFields {
    var login = SAFormField(value: "") { value in
        let validationResult = await SAFormValidationRules()
            .string()
            .trimmed()
            .notEmpty()
            .email()
            .validate(value: value)

        guard case .success(let validatedEmail) = validationResult else {
            return validationResult
        }

        let isValidEmail = await checkExistEmail(email: validatedEmail)

        if isValidEmail {
            return .success(value: validatedEmail)
        }

        return .failure(errors: .init(["Email already exists"]))
    }

    var password = SAFormField(value: "") { value in
        await SAFormValidationRules()
            .string()
            .trimmed()
            .notEmpty()
            .validate(value: value)
    }
}

struct ServerValidationFormView: View {
    @State private var loginForm = SAForm(fields: LoginFormFields())

    private func handleLogin(
        data: SAFormValidatedFields<LoginFormFields>
    ) async {
        let login: String = data.login
        let password: String = data.password

        print(login)
        print(password)
    }

    var body: some View {
        VStack(spacing: 12) {
            SAFormView(formConfig: loginForm) {
                SAFormControllerView(
                    formConfig: loginForm,
                    key: \.login
                ) { value, field in
                    TextField("Email", text: value)
                        .textFieldStyle(.roundedBorder)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError)
                            .foregroundStyle(.red)
                    }

                    Text("Is validating: \(String(field.isValidating))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                SAFormControllerView(
                    formConfig: loginForm,
                    key: \.password
                ) { value, field in
                    SecureField("Password", text: value)
                        .textFieldStyle(.roundedBorder)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError)
                            .foregroundStyle(.red)
                    }
                }
            }

            Button("Login", action: loginForm.handleSubmit(onSuccess: handleLogin))
                .disabled(loginForm.formState.isSubmitting)
        }
    }
}
```

## Key Idea

Validation rules are async, so they can call your backend.
Run cheap local checks first, then call the server only after the value has already passed local validation.
