---
pageClass: api-reference-page
---

# SAFormField <Badge type="tip" text="Class" />

Use `SAFormField` to define one typed form value and the async rule that validates it.
Fields are the smallest units in a form and provide the state needed to bind UI controls, validate user input, and show feedback.
You can place fields directly inside an `SAFormFields` type, inside an `SAFormGroup`, or inside an `SAFormCollectionItem`.

```swift
init(
    value: Value,
    delayValidation: SAFormDelayValidation = .immediate,
    rule: @escaping (_ value: Value) async -> SAFormValidationResponse<ValidatedValue>
)
```

#### Parameters

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `value` | Initial field value. | `Value` | None |
| `delayValidation` | Delay used by change validation. | `SAFormDelayValidation` | `.immediate` |
| `rule` | Async validation rule. | `(Value) async -> SAFormValidationResponse<ValidatedValue>` | None |

## Properties

Properties available on the `SAFormField` instance.

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `value` | Current field value. | `Value` | Initial `value` |
| `validatedValue` | Last successfully validated value. | `ValidatedValue?` | `nil` |
| `defaultValue` | Value used as the dirty-state baseline. | `Value` | Initial `value` |
| `mounted` | `true` while a controller view is mounted for this field. | `Bool` | `false` |
| `errors` | Current field errors. | `SAFormFailure?` | `nil` |
| `isValidating` | `true` while field validation is running. | `Bool` | `false` |
| `taskValidation` | Active validation task. | `Task<Void, Never>?` | `nil` |
| `isDirty` | `true` when `value` differs from `defaultValue`. | `Bool` | `false` |
| `isError` | `true` when `errors` is not `nil`. | `Bool` | Computed |
| `delayValidation` | Delay used by change validation. | `SAFormDelayValidation` | `.immediate` |
| `rule` | Async validation rule. | `(Value) async -> SAFormValidationResponse<ValidatedValue>` | None |

## Methods

Use these methods to work with a field instance.

### validate

Runs the field validation rule with the current value.

```swift
func validate() async -> SAFormFailure?
```

#### Returns

| Description | Type |
| --- | --- |
| `nil` when validation passes, or errors when validation fails. | `SAFormFailure?` |

#### Example

```swift
let failure = await fields.email.validate()
```

Use explicit generic types when the value bound to the UI is not the same type you want after validation.
In the example below, `TextField` works with a `String`, but submit receives `age` as an `Int`.
Writing `SAFormField<String, Int>` makes that conversion clear to Swift and keeps the validated submit data strongly typed.

## Example

Create a sign-up form with an inferred string field and an explicit generic field.

```swift{13}
import SwiftUI

@SAForm
private struct SignUpFields: SAFormFields {
    var email = SAFormField(value: "") { value in
        await SAFormValidationRules()
            .string()
            .notEmpty()
            .email()
            .validate(value: value)
    }

    var age = SAFormField<String, Int>(value: "") { value in
        guard let age = Int(value) else {
            return .failure(errors: .init(["Age must be a number"]))
        }

        return await SAFormValidationRules()
            .integer()
            .gte(num: 18)
            .validate(value: age)
    }
}

struct SignUpView: View {
    @State private var form = SAForm(fields: SignUpFields())

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

                SAFormControllerView(formConfig: form, key: \.age) { value, field in
                    TextField("Age", text: value)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError)
                            .foregroundStyle(.red)
                    }
                }

                Button("Create Account", action: form.handleSubmit { data in
                    let email: String = data.email
                    let age: Int = data.age

                    await createAccount(email: email, age: age)
                })
                .disabled(form.formState.isSubmitting)
            }
        }
    }
}
```
