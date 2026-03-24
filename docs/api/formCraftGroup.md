# FormCraftGroup <Badge type="tip" text="Protocol" />

`FormCraftGroup` is a marker protocol for nested groups of fields inside a [`FormCraftFields`](/api/formCraftFields) schema.

Use it when you want to split a large form into logical nested sections while keeping typed access.

Example:

```swift
@FormCraft
private struct LoginFields: FormCraftFields {
    struct Credentials: FormCraftGroup {
        var email = FormCraftField(value: "") { value in
            await FormCraftValidationRules()
                .string()
                .notEmpty()
                .email()
                .validate(value: value)
        }

        var password = FormCraftField(value: "") { value in
            await FormCraftValidationRules()
                .string()
                .notEmpty()
                .min(min: 8)
                .validate(value: value)
        }
    }

    var credentials = Credentials()
}
```

With validated submit data you can access nested values:

```swift
form.handleSubmit { data in
    print(data.credentials.email)
    print(data.credentials.password)
}
```

## Requirements

`FormCraftGroup` has no required methods or properties.

```swift
@MainActor
public protocol FormCraftGroup {}
```

## Notes

- A group can contain both `FormCraftField` properties and other `FormCraftGroup` properties.
- You can declare groups:
  - nested inside the `@FormCraft` fields struct
  - as top-level structs in the same file
- For automatic nested key-path generation by the macro, keep related groups in the same file as the `@FormCraft` schema.

## Top-level Group Example (Same File)

```swift
struct DeepPropertiesFields: FormCraftGroup {
    var property1 = FormCraftField(value: "") { value in
        await FormCraftValidationRules()
            .string()
            .notEmpty()
            .validate(value: value)
    }
}

@FormCraft
private struct LoginFields: FormCraftFields {
    var login = FormCraftField(value: "") { value in
        await FormCraftValidationRules()
            .string()
            .notEmpty()
            .validate(value: value)
    }

    var deepProperties = DeepPropertiesFields()
}
```
