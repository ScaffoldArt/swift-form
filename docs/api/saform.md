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
- **fields: Fields** - a structure of fields conforming to [`SAFormFields`](/api/saFormFields). It describes all fields, their initial values, and validation rules.
- **options: SAFormOptions** - global form behavior options.

  | Property | Type | Default | Description |
  |---|---|---|---|
  | `shouldFocusError` | `Bool` | `true` | Enables automatic focus on the first mounted field that currently has validation errors. |

## Properties

- **`fields: Fields`** - current form fields state (provided via `init(fields: Fields, options: SAFormOptions)`).  
- **`options: SAFormOptions`** - global options used by the form controller.  

- **`formState: SAFormFormState<Fields>`** - overall form state.  
  Contains:  

  | Property | Type | Default | Description |
  |---|---|---|---|
  | `isSubmitting` | `Bool` | `false` | Indicates whether the submit flow is currently running. |
  | `focusedFieldKey` | `PartialKeyPath<Fields>?` | `nil` | Key path of the field that should be focused, or `nil`. |

## Methods

### Setting values

- **`setDefaultValues(_ pairs: repeat (WritableKeyPath<Fields, Field>, Field.Value))`** - updates default and current values for provided fields.  

---

### Errors

- **`setErrors(_ pairs: repeat (KeyPath<Fields, Field>, SAFormFailure), options: SAFormSetErrorsOptions = .init())`** - sets errors by key paths.  
- **`setErrors(errors: [String: [String]], options: SAFormSetErrorsOptions = .init())`** - sets errors by field names.  
  Supports nested field keys when you use [`SAFormGroup`](/api/saFormGroup), for example: `"delivery.zipCode"` or `"customer.email"`.
- **`clearError<Field: SAFormFieldConfigurable>(key: KeyPath<Fields, Field>)`** - clears the error of a specific field.  
- **`clearErrors()`** - clears all errors.  

---

### Focus

- **`setFocus<Field: SAFormFieldConfigurable>(key: KeyPath<Fields, Field>?)`** - sets or clears focused field key.

---

### Validation

- **`validateField<Field: SAFormFieldConfigurable>(key: KeyPath<Fields, Field>) async -> Bool`** - asynchronously validates a single field.  
- **`validateFields()`** - validates all fields and returns `true` if there are no errors.  

---

### Form submission

- **`handleSubmit(onSuccess: @escaping (_ data: SAFormValidatedFields<Fields>) async -> Void) -> () -> Void`** - returns a closure intended for submit actions (for example, a button action).  
  It validates form data and calls `onSuccess` only when the form is valid.

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
