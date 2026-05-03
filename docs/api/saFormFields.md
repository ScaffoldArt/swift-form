# SAFormFields <Badge type="tip" text="Protocol" />

`SAFormFields` defines a form schema used by [`SAForm`](/api/saform).
Your fields type should conform to this protocol.

In practice, you usually annotate your fields struct with `@SAForm`, and the required access methods are generated automatically.

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
```

## Methods

### getAccessNames

```swift
func getAccessNames() -> [String: PartialKeyPath<Self>]
```

Returns mapping between field names and field key paths.

### getAccessOrder

```swift
func getAccessOrder() -> [String]
```

Returns field names in declaration order.

### refine

```swift
func refine(form: SAForm<Self>) async -> [PartialKeyPath<Self>: SAFormFailure?]
```

Performs form-level (cross-field) validation.
- Key: field key path.
- Value: `SAFormFailure?` (`nil` means no error for that field).

If not implemented, default behavior returns no refine errors.

Simple example:

```swift
@SAForm
private struct RegisterFields: SAFormFields {
    var password = SAFormField(value: "") { value in
        await SAFormValidationRules()
            .string()
            .notEmpty()
            .validate(value: value)
    }

    var confirmPassword = SAFormField(value: "") { value in
        await SAFormValidationRules()
            .string()
            .notEmpty()
            .validate(value: value)
    }

    func refine(form: SAForm<Self>) async -> [PartialKeyPath<Self>: SAFormFailure?] {
        if password.value != confirmPassword.value {
            return [\.confirmPassword: .init(["Passwords do not match"])]
        }

        return [:]
    }
}
```

Advanced async example (`async let`):

```swift
@SAForm
private struct SignupFields: SAFormFields {
    var email = SAFormField(value: "") { value in
        await SAFormValidationRules()
            .string()
            .notEmpty()
            .email()
            .validate(value: value)
    }

    var username = SAFormField(value: "") { value in
        await SAFormValidationRules()
            .string()
            .notEmpty()
            .min(min: 3)
            .validate(value: value)
    }

    func refine(form: SAForm<Self>) async -> [PartialKeyPath<Self>: SAFormFailure?] {
        async let isEmailTaken = checkEmailTaken(email.value)
        async let isUsernameTaken = checkUsernameTaken(username.value)

        let (emailTaken, usernameTaken) = await (isEmailTaken, isUsernameTaken)

        var failures: [PartialKeyPath<Self>: SAFormFailure?] = [:]

        if emailTaken {
            failures[\.email] = .init(["Email is already taken"])
        }

        if usernameTaken {
            failures[\.username] = .init(["Username is already taken"])
        }

        return failures
    }

    private func checkEmailTaken(_ email: String) async -> Bool {
        // API call
        false
    }

    private func checkUsernameTaken(_ username: String) async -> Bool {
        // API call
        false
    }
}
```
