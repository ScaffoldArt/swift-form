---
pageClass: api-reference-page saform-api-page
---

# SAForm <Badge type="tip" text="Class" />

Use `SAForm` to create a form instance from your field definitions and access form state, validation, errors, focus, and submit helpers.

Initialize `SAForm` with a fields object. Pass `options` when you want to change form-level behavior.

```swift
init(
    fields: Fields,
    options: SAFormOptions = .init()
)
```

#### Parameters

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `fields` | Fields object used by the form. | `Fields` | None |
| `options` | Form-level configuration. | `SAFormOptions` | `.init()` |
| <span class="api-nested-prop">`options.shouldFocusError`</span> | Requests focus for the first field with an error. | `Bool` | `true` |

#### Example

```swift
@State private var form = SAForm(
    fields: LoginFields(),
    options: .init(shouldFocusError: false)
)
```

## Properties

Properties available on the `SAForm` instance.

| Name | Description | Type |
| --- | --- | --- |
| `fields` | Current fields object. | `Fields` |
| `options` | Form options. | `SAFormOptions` |
| <span class="api-nested-prop">`options.shouldFocusError`</span> | Requests focus for the first field with an error. | `Bool` |
| `formState` | Current form state. | `SAFormFormState<Fields>` |
| <span class="api-nested-prop">`formState.isSubmitting`</span> | `true` while submit is running. | `Bool` |
| <span class="api-nested-prop">`formState.isSubmitted`</span> | `true` after submit was requested. | `Bool` |
| <span class="api-nested-prop">`formState.isSubmitSuccessful`</span> | `true` after successful submit. | `Bool` |
| <span class="api-nested-prop">`formState.focusedFieldKey`</span> | Field key requested for focus. | `PartialKeyPath<Fields>?` |
| <span class="api-nested-prop">`formState.isDisabled`</span> | Disables fields controlled by [`SAFormControllerView`](/api/saFormControllerView). | `Bool` |
| <span class="api-nested-prop">`formState.isValidating`</span> | `true` while at least one field is validating. | `Bool` |
| <span class="api-nested-prop">`formState.isDirty`</span> | `true` while at least one field differs from its default value. | `Bool` |

## Methods

Use these methods to work with the `SAForm` instance from your SwiftUI views and async handlers.

### handleSubmit

Creates an action closure for submit buttons.

```swift
func handleSubmit(
    onSuccess: @escaping (_ data: SAFormValidatedFields<Fields>) async -> Void,
    options: SAFormHandleSubmitOptions = .init()
) -> () -> Void
```

#### Parameters

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `onSuccess` | Called with typed values after validation. | `(SAFormValidatedFields<Fields>) async -> Void` | None |
| `options` | Submit configuration. | `SAFormHandleSubmitOptions` | `.init()` |
| <span class="api-nested-prop">`options.shouldDisable`</span> | Sets `formState.isDisabled` during submit when `true`. | `Bool?` | `nil` |

#### Example

```swift
Button("Login", action: form.handleSubmit { data in
    let email: String = data.email
    let password: String = data.password

    await login(email: email, password: password)
})
.disabled(form.formState.isSubmitting)
```

### validateFields

Runs validation manually.

```swift
func validateFields(
    _ keys: PartialKeyPath<Fields>...,
    options: SAFormValidateFieldsOptions = .init()
) async -> Bool
```

#### Parameters

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `keys` | Fields to validate. Omit to validate all fields. | `PartialKeyPath<Fields>...` | None |
| `options` | Validation configuration. | `SAFormValidateFieldsOptions` | `.init()` |
| <span class="api-nested-prop">`options.shouldFocusError`</span> | Overrides `SAFormOptions.shouldFocusError` for this call. | `Bool?` | `nil` |
| <span class="api-nested-prop">`options.shouldDisable`</span> | Reserved option. | `Bool?` | `nil` |

#### Returns

| Description | Type |
| --- | --- |
| `true` when validation passes. | `Bool` |

#### Example

```swift
let isValid = await form.validateFields()
let isAccountValid = await form.validateFields(\.email, \.password)
```

### validateFieldOnChange

Runs validation for a field after its value changes in the UI.

```swift
func validateFieldOnChange<Field: SAFormFieldConfigurable>(
    key: KeyPath<Fields, Field>
) async -> Bool
```

#### Parameters

| Name | Description | Type |
| --- | --- | --- |
| `key` | Field to validate. | `KeyPath<Fields, Field>` |

#### Returns

| Description | Type |
| --- | --- |
| `true` when validation passes. | `Bool` |

#### Example

```swift
let isValid = await form.validateFieldOnChange(key: \.email)
```

### setErrors

Applies field errors with key paths.

```swift
func setErrors<each Field: SAFormFieldConfigurable>(
    _ pairs: repeat (KeyPath<Fields, each Field>, SAFormFailure),
    options: SAFormSetErrorsOptions = .init()
)
```

#### Parameters

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `pairs` | Field keys and errors. | `repeat (KeyPath<Fields, Field>, SAFormFailure)` | None |
| `options` | Error configuration. | `SAFormSetErrorsOptions` | `.init()` |
| <span class="api-nested-prop">`options.shouldFocusError`</span> | Overrides `SAFormOptions.shouldFocusError` for this call. | `Bool?` | `nil` |

#### Example

```swift
form.setErrors(
    (\.email, .init(["Email is already taken"])),
    (\.password, .init(["Password is too weak"])),
    (\.billingAddress.street, .init(["Street is required"])),
    (\.emergencyContacts[0].phone, .init(["Phone is invalid"]))
)
```

### setErrors

Applies field errors by generated field name.

```swift
func setErrors(
    errors: [String: [String]],
    options: SAFormSetErrorsOptions = .init()
)
```

#### Parameters

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `errors` | Field names and error messages. | `[String: [String]]` | None |
| `options` | Error configuration. | `SAFormSetErrorsOptions` | `.init()` |
| <span class="api-nested-prop">`options.shouldFocusError`</span> | Overrides `SAFormOptions.shouldFocusError` for this call. | `Bool?` | `nil` |

#### Example

```swift
form.setErrors(
    errors: [
        "email": ["Email is already taken"],
        "password": ["Password is too weak"],
        "billingAddress.street": ["Street is required"],
        "emergencyContacts.[0].phone": ["Phone is invalid"]
    ]
)
```

### clearError

Clears errors from one field.

```swift
func clearError<Field: SAFormFieldConfigurable>(
    key: KeyPath<Fields, Field>
)
```

#### Parameters

| Name | Description | Type |
| --- | --- | --- |
| `key` | Field key. | `KeyPath<Fields, Field>` |

#### Example

```swift
form.clearError(key: \.email)
```

### clearErrors

Clears errors from every field.

```swift
func clearErrors()
```

#### Example

```swift
form.clearErrors()
```

### setDefaultValue

Updates one field's current value and default value.

```swift
func setDefaultValue<Field: SAFormFieldConfigurable>(
    key: WritableKeyPath<Fields, Field>,
    value: Field.Value
)
```

#### Parameters

| Name | Description | Type |
| --- | --- | --- |
| `key` | Field key. | `WritableKeyPath<Fields, Field>` |
| `value` | New value. | `Field.Value` |

#### Example

```swift
form.setDefaultValue(
    key: \.email,
    value: profile.email
)
```

### setDefaultValues

Updates multiple current values and default values.

```swift
func setDefaultValues<each Field: SAFormFieldConfigurable>(
    _ pairs: repeat (WritableKeyPath<Fields, each Field>, (each Field).Value)
)
```

#### Parameters

| Name | Description | Type |
| --- | --- | --- |
| `pairs` | Field keys and new values. | `repeat (WritableKeyPath<Fields, Field>, Field.Value)` |

#### Example

```swift
form.setDefaultValues(
    (\.email, profile.email),
    (\.displayName, profile.displayName)
)
```

### setFocus

Requests focus for a field, or clears the focus request.

```swift
func setFocus<Field: SAFormFieldConfigurable>(
    key: KeyPath<Fields, Field>?
)
```

#### Parameters

| Name | Description | Type |
| --- | --- | --- |
| `key` | Field key, or `nil`. | `KeyPath<Fields, Field>?` |

#### Example

```swift
form.setFocus(key: \.email)
form.setFocus(key: nil)
```

### SAFormValidatedFields

Typed values passed to `handleSubmit`.

```swift
@dynamicMemberLookup
struct SAFormValidatedFields<Fields>
```

#### Example

```swift
form.handleSubmit { data in
    let email: String = data.email
    let password: String = data.password
}
```

## Example

```swift{20}
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

@State private var form = SAForm(fields: LoginFields())

Button("Submit", action: form.handleSubmit { data in
    let email: String = data.email
    let password: String = data.password

    await login(email: email, password: password)
})
.disabled(form.formState.isSubmitting)
```
