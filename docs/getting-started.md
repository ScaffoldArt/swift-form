# Getting Started

## Installation

FormCraft is distributed via Swift Package Manager.

Supported platforms:
- iOS 17+
- macOS 13+

### Add with Xcode

1. Open your project in Xcode.
2. Go to `File -> Add Package Dependencies...`
3. Paste:

```txt
https://github.com/ArtyCodingart/form-craft
```

4. Add `FormCraft` to your app target.

### Add with `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/ArtyCodingart/form-craft", from: "x.y.z")
]
```

## First Form

```swift
import SwiftUI
import FormCraft

@FormCraft
private struct LoginFields: FormCraftFields {
    var email = FormCraftField(value: "", delayValidation: .fast) { value in
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
            .min(min: 8)
            .validate(value: value)
    }
}

struct LoginFormView: View {
    @State private var form = FormCraft(fields: LoginFields())

    var body: some View {
        VStack(spacing: 12) {
            FormCraftView(formConfig: form) {
                FormCraftControllerView(formConfig: form, key: \.email) { value in
                    TextField("Email", text: value)
                        .textFieldStyle(.roundedBorder)
                }

                if let firstError = form.fields.email.errors?.errors.first {
                    Text(firstError)
                        .foregroundStyle(.red)
                }

                FormCraftControllerView(formConfig: form, key: \.password) { value in
                    SecureField("Password", text: value)
                        .textFieldStyle(.roundedBorder)
                }

                if let firstError = form.fields.password.errors?.errors.first {
                    Text(firstError)
                        .foregroundStyle(.red)
                }
            }

            Button(
                "Login",
                action: form.handleSubmit { fields in
                    // fields.email and fields.password are validated values
                    print(fields.email)
                    print(fields.password)
                }
            )
            .disabled(form.formState.isSubmitting)
        }
        .padding()
    }
}
```

## Next Steps

- Learn the built-in validators in `overview.md`
- Add cross-field checks with `refine(form:)`
- Customize error messages with `FormCraftLocalizations`
