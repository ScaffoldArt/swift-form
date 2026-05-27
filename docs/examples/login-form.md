# Login Form

This example shows the smallest useful SAForm setup: define fields, bind them to SwiftUI controls, show errors, and submit typed validated data.

```swift
import SwiftUI
import SAForm

@SAForm
private struct LoginFormFields: SAFormFields {
    var login = SAFormField(value: "") { value in
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
            .trimmed()
            .notEmpty()
            .validate(value: value)
    }
}

struct LoginFormView: View {
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

`handleSubmit` validates every field before running `handleLogin`.
Inside the submit closure, `data.login` and `data.password` are typed validated values.
