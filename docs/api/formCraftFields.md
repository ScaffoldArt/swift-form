# FormCraftFields <Badge type="tip" text="Protocol" />

`FormCraftFields` defines a form schema used by [`FormCraft`](/api/formCraft).
Your fields type should conform to this protocol.

In practice, you usually annotate your fields struct with `@FormCraft`, and the required access methods are generated automatically.

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
func refine(form: FormCraft<Self>) async -> [PartialKeyPath<Self>: FormCraftFailure?]
```

Performs form-level (cross-field) validation.
- Key: field key path.
- Value: `FormCraftFailure?` (`nil` means no error for that field).

If not implemented, default behavior returns no refine errors.

Simple example:

```swift
@FormCraft
private struct RegisterFields: FormCraftFields {
    var password = FormCraftField(value: "") { value in
        await FormCraftValidationRules()
            .string()
            .notEmpty()
            .validate(value: value)
    }

    var confirmPassword = FormCraftField(value: "") { value in
        await FormCraftValidationRules()
            .string()
            .notEmpty()
            .validate(value: value)
    }

    func refine(form: FormCraft<Self>) async -> [PartialKeyPath<Self>: FormCraftFailure?] {
        if password.value != confirmPassword.value {
            return [\.confirmPassword: .init(["Passwords do not match"])]
        }

        return [:]
    }
}
```

Advanced async example (`async let`):

```swift
@FormCraft
private struct SignupFields: FormCraftFields {
    var email = FormCraftField(value: "") { value in
        await FormCraftValidationRules()
            .string()
            .notEmpty()
            .email()
            .validate(value: value)
    }

    var username = FormCraftField(value: "") { value in
        await FormCraftValidationRules()
            .string()
            .notEmpty()
            .min(min: 3)
            .validate(value: value)
    }

    func refine(form: FormCraft<Self>) async -> [PartialKeyPath<Self>: FormCraftFailure?] {
        async let isEmailTaken = checkEmailTaken(email.value)
        async let isUsernameTaken = checkUsernameTaken(username.value)

        let (emailTaken, usernameTaken) = await (isEmailTaken, isUsernameTaken)

        var failures: [PartialKeyPath<Self>: FormCraftFailure?] = [:]

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
