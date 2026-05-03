# Boolean

Use boolean validation for fields that should contain only `true` or `false`.

## checked

Value must be `true`.  

**Parameters**
- `message: LocalizedStringResource` – error message if the value is `false`

```swift
let checked = SAFormValidationRules()
  .boolean()
  .checked()

checked.validate(value: true)  // ✅ is valid
checked.validate(value: false) // ❌ is not valid
```
