---
pageClass: api-reference-page
---

# SAFormView <Badge type="tip" text="Struct" />

Use `SAFormView` as a SwiftUI container for controls connected to the same form instance.
It keeps field controllers inside one form scope, so inputs, validation, focus, disabled state, and submit behavior are coordinated through the same `SAForm` object.

```swift
init(
    formConfig: FormConfig,
    @ViewBuilder content: () -> Content
)
```

#### Parameters

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `formConfig` | Form object or custom type conforming to `SAFormConfig`. | `FormConfig` | None |
| `content` | SwiftUI content rendered inside the form container. | `() -> Content` | None |

## Example

Create a login form with two controlled fields and a submit button.

```swift{26}
import SwiftUI

@SAForm
private struct LoginFields: SAFormFields {
    var email = SAFormField(value: "") { value in
        await SAFormValidationRules()
            .string()
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
}

struct LoginView: View {
    @State private var form = SAForm(fields: LoginFields())

    var body: some View {
        SAFormView(formConfig: form) {
            VStack(spacing: 12) {
                SAFormControllerView(formConfig: form, key: \.email) { value, field in
                    TextField("Email", text: value)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError)
                            .foregroundStyle(.red)
                    }
                }

                SAFormControllerView(formConfig: form, key: \.password) { value, field in
                    SecureField("Password", text: value)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError)
                            .foregroundStyle(.red)
                    }
                }

                Button("Login", action: form.handleSubmit { data in
                    let email: String = data.email
                    let password: String = data.password

                    await login(email: email, password: password)
                })
                .disabled(form.formState.isSubmitting)
            }
        }
    }
}
```
