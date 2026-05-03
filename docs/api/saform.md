# SAForm <Badge type="tip" text="Class" />

`SAForm` is the main form controller in the library.
It coordinates form state and validation, and provides the public API for working with a form.

## Constructor

```swift
init(
  fields: Fields,
  options: SAFormOptions = .init()
)
```

### Arguments
- **`fields: Fields`** - a structure conforming to [`SAFormFields`](/api/saFormFields).
- **`options: SAFormOptions`** - global form behavior options.

`SAFormOptions`:

| Property | Type | Default | Description |
|---|---|---|---|
| `shouldFocusError` | `Bool` | `true` | Focuses the first mounted field with an error after validation/setErrors. |

## Properties

- **`fields: Fields`** - current form fields.
- **`options: SAFormOptions`** - form options.
- **`formState: SAFormFormState<Fields>`** - aggregated form state.

`formState` includes:

| Property | Type | Description |
|---|---|---|
| `isSubmitting` | `Bool` | `true` while submit action is running. |
| `isSubmitted` | `Bool` | `true` after first submit attempt. |
| `isSubmitSuccessful` | `Bool` | `true` after successful submit. |
| `focusedFieldKey` | `PartialKeyPath<Fields>?` | Field currently requested for focus. |
| `isDisabled` | `Bool` | Disables all controlled fields in `SAFormControllerView`. |
| `isValidating` | `Bool` | `true` when at least one field is validating. |
| `isDirty` | `Bool` | `true` when at least one field differs from its default value. |

## Methods

### Defaults

- **`setDefaultValue(key:value:)`** - updates one field's `value` and `defaultValue`, clears errors, resets `isDirty`.
- **`setDefaultValues(_:)`** - same for multiple fields.

### Errors

- **`setErrors(_ pairs: repeat (KeyPath<Fields, Field>, SAFormFailure), options: SAFormSetErrorsOptions = .init())`** - sets errors by key paths.
- **`setErrors(errors: [String: [String]], options: SAFormSetErrorsOptions = .init())`** - sets errors by field names (`"group.field"` paths are supported).
- **`clearError(key:)`** - clears one field error.
- **`clearErrors()`** - clears all field errors.

`SAFormSetErrorsOptions`:

| Property | Type | Default | Description |
|---|---|---|---|
| `shouldFocusError` | `Bool?` | `nil` | Overrides `SAFormOptions.shouldFocusError` for this call. |

### Focus

- **`setFocus(key:)`** - sets requested focus to a specific field key path or clears focus with `nil`.

### Validation

- **`validateFieldOnChange(key:) async -> Bool`** - validates one field with its `delayValidation` policy.
- **`validateFields(_ keys: PartialKeyPath<Fields>..., options: SAFormValidateFieldsOptions = .init()) async -> Bool`** - validates all fields or only selected keys.

`SAFormValidateFieldsOptions`:

| Property | Type | Default | Description |
|---|---|---|---|
| `shouldFocusError` | `Bool?` | `nil` | Overrides default focus-on-error behavior. |
| `shouldDisable` | `Bool?` | `nil` | This option is available in the API; in the current version, `validateFields` does not use it. |

### Submit

- **`handleSubmit(onSuccess:options:) -> () -> Void`** - returns submit action closure; validates fields first, calls `onSuccess` only on valid data.

`SAFormHandleSubmitOptions`:

| Property | Type | Default | Description |
|---|---|---|---|
| `shouldDisable` | `Bool?` | `nil` | Temporarily sets `formState.isDisabled = true` during submit. |

Example:

```swift
@SAForm
private struct LoginFields: SAFormFields {
    var email = SAFormField(value: "") { value in
        await SAFormValidationRules()
            .string()
            .notEmpty()
            .email()
            .validate(value: value)
    }
}

@State private var form = SAForm(fields: LoginFields())

private func onSubmit(
    data: SAFormValidatedFields<LoginFields>
) async {
    // `data.email` is validated and typed
    print(data.email)
}

Button("Submit", action: form.handleSubmit(onSuccess: onSubmit))
```
