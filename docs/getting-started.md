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
https://github.com/ScaffoldArt/swift-form
```

4. Add `SAForm` to your app target.

### Add with `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/ScaffoldArt/swift-form", from: "<latest-release>")
]
```

Replace `<latest-release>` with the latest release version from GitHub.
Swift Package Manager will then resolve the newest compatible release from that version requirement.

::: tip Want to start faster?
SAForm is small enough that you can often learn it by opening a working example first.
If you want to copy a real SwiftUI form and adapt it right away, start with the [examples](/examples/) page.
Each example focuses on one common workflow, so you can pick the closest one and use it as a starting point before reading the full guide.
:::

## Create Your First Form

This guide walks through a small SwiftUI login form. You will define typed fields, bind them to controls, show validation errors, and submit only validated data.

Start by importing SwiftUI and SAForm:

```swift
import SwiftUI
import SAForm
```

### 1. Define Fields

Create a fields type that conforms to `SAFormFields`.

`@SAForm` generates field access metadata used by `SAForm` for validation, focus handling, server errors, and typed submit data.

```swift
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
```

Each `SAFormField` stores the current raw value and an async validation rule.
Validation rules run in order and can transform values before submit.

::: info Note
Validation is async, so checks can await server requests or other work without blocking the main thread.
:::

### 2. Create Form State

Create one `SAForm` instance and keep it in SwiftUI state:

```swift
struct LoginFormView: View {
    @State private var form = SAForm(fields: LoginFields())

    var body: some View {
        // Form UI goes here.
    }
}
```

`SAForm` coordinates field state, validation, errors, focus, and submit behavior.

### 3. Bind Fields to SwiftUI

Use `SAFormView` as the form container and `SAFormControllerView` for each controlled field:

```swift
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
```

`SAFormControllerView` gives your SwiftUI control a binding to the field value, so the control can read and update that value directly.

### 4. Submit Validated Data

Use `handleSubmit` for submit actions:

```swift
Button(
    "Login",
    action: form.handleSubmit { data in
        let email: String = data.email
        let password: String = data.password

        await login(
            email: email,
            password: password
        )
    }
)
.disabled(form.formState.isSubmitting)
```

`handleSubmit` validates the whole form first.
The closure is async, so it can await a login request before continuing.

## Complete Example

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

    private func login(email: String, password: String) async {
        // Send credentials to your auth service.
    }

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
                    let email: String = data.email
                    let password: String = data.password

                    await login(
                        email: email,
                        password: password
                    )
                }
            )
            .disabled(form.formState.isSubmitting)
        }
        .padding()
    }
}
```
