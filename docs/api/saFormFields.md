---
pageClass: api-reference-page
---

# SAFormFields <Badge type="tip" text="Protocol" />

Use `SAFormFields` to define the fields used by an `SAForm` instance.

## Methods

Use these methods to expose field metadata and form-level validation.

### getAccessNames

Returns field names mapped to field key paths.

```swift
func getAccessNames() -> [String: PartialKeyPath<Self>]
```

#### Returns

| Description | Type |
| --- | --- |
| Field names mapped to field key paths. | `[String: PartialKeyPath<Self>]` |

### getAccessOrder

Returns field names in declaration order.

```swift
func getAccessOrder() -> [String]
```

#### Returns

| Description | Type |
| --- | --- |
| Field names in declaration order. | `[String]` |

### getField

Returns the field object at a key path.

```swift
func getField(by keyPath: PartialKeyPath<Self>) -> any SAFormFieldConfigurable
```

#### Parameters

| Name | Description | Type |
| --- | --- | --- |
| `keyPath` | Field key path. | `PartialKeyPath<Self>` |

#### Returns

| Description | Type |
| --- | --- |
| Field object at the key path. | `any SAFormFieldConfigurable` |

### refine

Runs form-level validation.

```swift
func refine(form: SAForm<Self>) async -> [PartialKeyPath<Self>: SAFormFailure?]
```

#### Parameters

| Name | Description | Type |
| --- | --- | --- |
| `form` | Form instance. | `SAForm<Self>` |

#### Returns

| Description | Type |
| --- | --- |
| Field key paths mapped to optional errors. | `[PartialKeyPath<Self>: SAFormFailure?]` |

## Example

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
