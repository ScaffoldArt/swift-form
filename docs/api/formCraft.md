# FormCraft <Badge type="tip" text="Class" />

`FormCraft` is the main form controller in the library.
It coordinates form state and validation, and provides the public API for working with a form.


## Constructor

```swift
init(fields: Fields)
```

### Arguments
- **fields: Fields** - a structure of fields conforming to [`FormCraftFields`](/api/formCraftFields). It describes all fields, their initial values, and validation rules.

## Properties

- **`fields: Fields`** - current form fields state (provided via `init(fields:)`).  

- **`formState: FormCraftFormState<Fields>`** - overall form state.  
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

- **`setErrors(_ pairs: repeat (KeyPath<Fields, Field>, FormCraftFailure))`** - sets errors by key paths.  
- **`setErrors(errors: [String: [String]])`** - sets errors by field names.  
- **`clearError(key:)`** - clears the error of a specific field.  
- **`clearErrors()`** - clears all errors.  

---

### Focus

- **`setFocus(key:)`** - sets or clears focused field key.

---

### Validation

- **`validateField(key:)`** - asynchronously validates a single field.  
- **`validateFields()`** - validates all fields and returns `true` if there are no errors.  

---

### Form submission

- **`handleSubmit(onSuccess:)`** - returns a closure intended for submit actions (for example, a button action).  
  It validates form data and calls `onSuccess` only when the form is valid.

Example:

```swift
@FormCraft
private struct LoginFields: FormCraftFields {
    var email = FormCraftField(value: "") { value in
        await FormCraftValidationRules()
            .string()
            .notEmpty()
            .email()
            .validate(value: value)
    }
}

@State private var form = FormCraft(fields: LoginFields())

private func onSubmit(
    data: FormCraftValidatedFields<LoginFields>
) async {
    // `data.email` is validated and typed
    print(data.email)
}

Button("Submit", action: form.handleSubmit(onSuccess: onSubmit))
```
