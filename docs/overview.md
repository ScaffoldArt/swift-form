# Overview

FormCraft is often described as a practical validation-first library for SwiftUI forms. In more technical terms, it gives you a single model for collecting raw input, validating it (including async and cross-field rules), and submitting typed trusted data.

## Motivation

Most SwiftUI projects do not have one opinionated, end-to-end form pipeline. Because of that, teams usually mix local `@State`, view-level checks, and ad-hoc submit handlers.

That approach works at first, but form logic quickly becomes fragmented.

Unlike regular client state, form state has special challenges:

- You start with raw user input, but business logic needs validated typed values.
- Validation can be synchronous and asynchronous.
- Field-level rules and cross-field rules must work together.
- Errors must be user-friendly and localization-ready.
- Submit should run only when all fields are valid.

As forms grow, even more problems appear:

- Duplicated validation logic across screens
- Inconsistent error handling and messaging
- Race conditions during async checks
- Hard-to-test submit flows
- Refactors that break field wiring
- Unclear ownership of "where validation really lives"

If that sounds familiar, you are not doing anything wrong. Form handling is hard when there is no consistent system behind it.

FormCraft gives you that system. It works well with SwiftUI out of the box and scales from simple login forms to complex product flows.

FormCraft helps you:

- Replace scattered form code with a consistent typed flow
- Keep validation rules close to field definitions
- Run field-level and form-level validation in one pipeline
- Improve UX with predictable submit behavior
- Ship faster with less form-related regressions

Enough talk, show me some code already.

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

## You Talked Me Into It, So What Now?

- Start with [Getting Started](/getting-started)
- Learn available validators in [Validation Rules](/validation-rules/)
- Explore full API in [API Reference](/api/)
- Copy practical patterns from [Examples](/examples/)
