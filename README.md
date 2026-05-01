# Form Craft

<img src="docs/public/form-craft-start-logo.png" alt="FormCraft" width="256" height="256" />

![GitHub Release](https://img.shields.io/github/v/release/ArtyCodingart/form-craft?color=%239a60fe)
![Static Badge](https://img.shields.io/badge/iOS-17%2B-test?logo=apple)
![GitHub License](https://img.shields.io/github/license/ArtyCodingart/form-craft)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ArtyCodingart/form-craft/tests.yml?branch=main)
[![DOCS](https://img.shields.io/badge/DOCS-8A2BE2)](https://artycodingart.github.io/form-craft/)


Build better forms with a simple and flexible validation library for Swift and SwiftUI.

## Key Features

- 🚀 **Faster Time to Release**: Launch form-heavy flows faster without compromising quality.
- ✅ **Trusted Results**: Turn raw input into clean, reliable data for your business logic.
- ⚡️ **Smooth Performance**: Keep forms fast and responsive even as validation logic grows.
- 🧩 **Built to Scale**: Start simple and grow into complex product flows without rewriting from scratch.
- 🔌 **Easy Adoption**: Integrate into existing SwiftUI screens and improve forms incrementally.
- ❤️ **Consistent User Experience**: Give users clear feedback, predictable validation behavior, and smoother form completion.

## Basic example

```swift
import SwiftUI
import FormCraft

@FormCraft
private struct LoginFormFields: FormCraftFields {
    var login = FormCraftField(value: "") { value in
        await FormCraftValidationRules()
            .string()
            .trimmed()
            .notEmpty()
            .email()
            .validate(value: value)
    }

    var password = FormCraftField(value: "") { value in
        await FormCraftValidationRules()
            .string()
            .trimmed()
            .notEmpty()
            .validate(value: value)
    }
}

struct LoginFormView: View {
    @State private var loginForm = FormCraft(fields: LoginFormFields())

    private func handleLogin(
        data: FormCraftValidatedFields<LoginFormFields>
    ) async {
        print(data.login)
        print(data.password)
    }

    var body: some View {
        VStack(spacing: 12) {
            FormCraftView(formConfig: loginForm) {
                FormCraftControllerView(
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

                FormCraftControllerView(
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

## CHANGELOG

[CHANGELOG](/CHANGELOG.md)

## License

[MIT](/LICENSE)
