# Union

Use union validation when one input value can match different validator types.

## union

`union` validates one raw value against multiple validators and succeeds when at least one validator passes.

Internally, each validator is executed with `validate(raw: Any?)`.

On success, `union` returns a tuple of optional values:
- each tuple position corresponds to the validator at the same position in arguments
- position is non-`nil` when that validator passed
- position is `nil` when that validator failed

Important: more than one position can be non-`nil` if multiple validators accept the same input.

If no validators pass, `union` returns `.failure` with merged errors from all validators.

**Parameters**
- `value: Any` - raw value to validate
- `rules: repeat each Rule` - variadic validators conforming to `SAFormValidationTypeRules`

**Signature**

```swift
func union<each Rule: SAFormValidationTypeRules>(
  _ value: Any,
  _ rules: repeat each Rule
) async -> SAFormValidationResponse<(repeat ((each Rule).Value)?)>
```

For two rules (`string`, `integer`), success type is inferred as:

```swift
SAFormValidationResponse<(String?, Int?)>
```

### Example: first rule passes

```swift
let result = await SAFormValidationRules().union(
  "hello@example.com",
  SAFormValidationRules().string().email(),
  SAFormValidationRules().integer().gt(num: 0)
)

switch result {
case .success(let (email, intValue)):
  if let email {
    print("Email:", email)
  }

  // `intValue` is `Int?` and will be `nil` here.
  if let intValue {
    print("Int:", intValue)
  }
case .failure(let errors):
  print(errors.messages)
}
```

### Example: second rule passes

```swift
let result = await SAFormValidationRules().union(
  42,
  SAFormValidationRules().string().notEmpty(),
  SAFormValidationRules().integer().positive()
)

switch result {
case .success(let (stringValue, intValue)):
  // `stringValue` is `String?` and will be `nil` here.
  if let stringValue {
    print("String:", stringValue)
  }

  if let intValue {
    print("Int:", intValue) // 42
  }
case .failure(let errors):
  print(errors.messages)
}
```

### Example: multiple rules pass

```swift
let result = await SAFormValidationRules().union(
  "42",
  SAFormValidationRules().string().notEmpty(),
  SAFormValidationRules().string().regex(/^\d+$/)
)

switch result {
case .success(let (raw, digitsOnly)):
  // Both are non-nil because both validators passed.
  print(raw ?? "")
  print(digitsOnly ?? "")
case .failure(let errors):
  print(errors.messages)
}
```
