# SAFormField <Badge type="tip" text="Class" />

`SAFormField<Value, ValidatedValue>` describes one form field.
It stores raw value, validation state, and async validation rule.

This type is typically used inside a [`SAFormFields`](/api/saFormFields) schema.

## Constructor

```swift
init(
    value: Value,
    delayValidation: SAFormDelayValidation = .immediate,
    rule: @escaping (_ value: Value) async -> SAFormValidationResponse<ValidatedValue>
)
```

### Arguments
- **`value: Value`** - initial/current value of the field.
- **`delayValidation: SAFormDelayValidation`** - delay before validation starts.
- **`rule`** - async validation rule.

## Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `value` | `Value` | value passed to init | Current field value. |
| `validatedValue` | `ValidatedValue?` | `nil` | Last successful validated value. |
| `defaultValue` | `Value` | same as initial `value` | Baseline value for dirty state comparison. |
| `mounted` | `Bool` | `false` | Whether this field is currently mounted in UI. |
| `errors` | `SAFormFailure?` | `nil` | Current field validation errors. |
| `isValidating` | `Bool` | `false` | Whether validation is in progress. |
| `taskValidation` | `Task<Void, Never>?` | `nil` | Active validation task reference. |
| `isDirty` | `Bool` | `false` | Whether current value differs from `defaultValue`. |
| `isError` | `Bool` | computed | Convenience flag (`errors != nil`). |
| `delayValidation` | `SAFormDelayValidation` | `.immediate` | Delay policy before validation. |
| `rule` | `(Value) async -> SAFormValidationResponse<ValidatedValue>` | required | Validation function. |

## Methods

### validate

```swift
func validate() async -> SAFormFailure?
```

Runs field rule with current `value`.
- Returns `nil` on success.
- Returns `SAFormFailure` on failure.
