# Getting Started

## Installation

SAForm is distributed via Swift Package Manager (SPM).

Supported platforms:
- iOS 17+
- macOS 14+

### Add with Xcode

1. Open your project in Xcode.
2. Go to `File -> Add Package Dependencies...`
3. Paste:

```txt
https://github.com/ArtyCodingart/scaffold-art
```

4. Add `SAForm` to your app target.

### Add with `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/ArtyCodingart/scaffold-art", from: "x.y.z")
]
```

## First Form

This example shows the full happy path:
- define typed fields
- bind them to SwiftUI controls
- submit only validated data

```swift
import SwiftUI
import SAForm

@SAForm
private struct LoginFields: SAFormFields {
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
            .trimmed()
            .notEmpty()
            .min(min: 8)
            .validate(value: value)
    }
}

struct LoginFormView: View {
    @State private var form = SAForm(fields: LoginFields())

    var body: some View {
        VStack(spacing: 12) {
            SAFormView(formConfig: form) {
                SAFormControllerView(formConfig: form, key: \.email) { value, field in
                    TextField("Email", text: value)
                        .textFieldStyle(.roundedBorder)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError)
                            .foregroundStyle(.red)
                    }
                }

                SAFormControllerView(formConfig: form, key: \.password) { value, field in
                    SecureField("Password", text: value)
                        .textFieldStyle(.roundedBorder)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError)
                            .foregroundStyle(.red)
                    }
                }
            }

            Button(
                "Login",
                action: form.handleSubmit { data in
                    // `data` contains typed validated values.
                    print(data.email)
                    print(data.password)
                }
            )
            .disabled(form.formState.isSubmitting)
        }
        .padding()
    }
}
```
