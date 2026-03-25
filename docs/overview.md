# Overview

FormCraft is a validation-first library for SwiftUI forms. It gives you one consistent flow: collect input, validate it (including async and cross-field checks), and submit typed trusted data.

## Why Teams Choose FormCraft

Many SwiftUI codebases do not have a single end-to-end form model. As a result, teams often combine local `@State`, view-level checks, and custom submit handlers.

This works for small forms, but complexity grows quickly.

Form state has its own constraints:

- You start with raw user input, but business logic needs validated typed values.
- Validation can be synchronous and asynchronous.
- Field-level rules and cross-field rules must work together.
- Errors must be user-friendly and localization-ready.
- Submit should run only when all fields are valid.

As forms become larger, common issues appear:

- Duplicated validation logic across screens
- Inconsistent error handling and messaging
- Race conditions during async checks
- Hard-to-test submit flows
- Refactors that break field wiring
- Unclear ownership of "where validation really lives"

These problems are common in product teams. Form behavior is difficult to keep stable without one clear pipeline.

FormCraft provides that pipeline. It works naturally with SwiftUI and scales from simple forms to complex flows.

With FormCraft, you can:

- Replace scattered form code with a consistent typed flow
- Keep validation rules close to field definitions
- Run field-level and form-level validation in one pipeline
- Improve UX with predictable submit behavior
- Ship faster with less form-related regressions

## Basic Example

```swift
import SwiftUI
import FormCraft

@FormCraft
private struct LoginFields: FormCraftFields {
    var email = FormCraftField(value: "") { value in
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

struct LoginView: View {
    @State private var form = FormCraft(fields: LoginFields())

    var body: some View {
        VStack(spacing: 12) {
            FormCraftView(formConfig: form) {
                FormCraftControllerView(formConfig: form, key: \.email) { value, field in
                    TextField("Email", text: value)
                        .textFieldStyle(.roundedBorder)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError).foregroundStyle(.red)
                    }
                }

                FormCraftControllerView(formConfig: form, key: \.password) { value, field in
                    SecureField("Password", text: value)
                        .textFieldStyle(.roundedBorder)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError).foregroundStyle(.red)
                    }
                }
            }

            Button("Sign In", action: form.handleSubmit { data in
                // `data` contains typed validated values.
                print(data.email)
                print(data.password)
            })
            .disabled(form.formState.isSubmitting)
        }
        .padding()
    }
}
```

## Continue Reading

- Start with [Getting Started](/getting-started)
- Learn available validators in [Validation Rules](/validation-rules/)
- Explore full API in [API Reference](/api/)
- Copy practical patterns from [Examples](/examples/)
