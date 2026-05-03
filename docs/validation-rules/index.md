# Validation Rules

## Example usage

SAForm includes built-in validation rules out of the box.
You can also define your own custom rules when needed.

SAForm provides `SAFormValidationRules` with rule builders like `.string()`, `.integer()`, `.floating()`, `.decimal()`, `.boolean()`, `.custom()`, and others.

```swift
await SAFormValidationRules()
  .string()
  .notEmpty()
  .email()
  .optional()
  .validate(value: "test@gmail.com")
```

For cases where input can be one of several shapes, use [`union`](/validation-rules/union).

::: info RULE EXECUTION ORDER
Rules run in order.
If any rule fails, remaining rules are not executed.

`.optional()` wraps the current validator and short-circuits when value is `nil`.
That means for `nil`, inner rules are skipped.

Rules can also transform values on success.
For example, `.trimmed()` can enforce normalized input before later checks.
:::

## The `.validate(raw: Any?)` and `.validate(value: Value)` methods

All validation rules provide two method signatures:

```swift
func validate(raw: Any?) async -> SAFormValidationResponse<Value>
func validate(value: Value) async -> SAFormValidationResponse<Value>
```

`Value` is inferred from the rule type.
For example, `.string()` gives `String`, `.integer()` gives `Int`, `.floating()` gives `Float`, etc.

Use `validate(raw: Any?)` when you have an untyped value at runtime.
Use `validate(value: Value)` when value type is already known.

`validate` returns `SAFormValidationResponse<Value>`:
- `.success(value: Value)` — validation passed
- `.failure(errors: SAFormFailure)` — validation failed

::: info
`validate` is asynchronous.
:::

## Extending with custom rules

Most real-world projects need custom validation logic.
You can extend existing rule types or create completely new ones.

### Adding a custom rule to an existing type (e.g., `.string`)

Example: check if email already exists in your backend.

```swift
extension SAFormStringValidation {
  func checkDuplicateEmail(
    message: LocalizedStringResource = "Email already exists"
  ) -> Self {
    addRule { value in
      let isFreeEmail = await self.checkDuplicateEmailServer(email: value)

      if !isFreeEmail {
        return .failure(errors: .init([message]))
      }

      return .success(value: value)
    }
  }

  private func checkDuplicateEmailServer(email: String) async -> Bool {
    // Call your backend
    true
  }
}
```

Usage:

```swift
let result = await SAFormValidationRules()
  .string()
  .notEmpty()
  .email()
  .checkDuplicateEmail()
  .optional()
  .validate(value: "test@gmail.com")

switch result {
case .failure(let failure):
  print(failure.messages)
case .success(let value):
  print(value)
}
```

Sequential execution prevents unnecessary calls:
if `.email()` fails, `.checkDuplicateEmail()` is not executed.

### Adding a new custom type with rules

You can define custom validators for your own types.

```swift
struct User: Sendable {
  let firstName: String
  let lastName: String
  let age: Int
}

extension SAFormValidationRules {
  func userValidation() -> UserValidation {
    .init()
  }
}

struct UserValidation: SAFormValidationTypeRules {
  var rules: [(_ value: User) async -> SAFormValidationResponse<User>] = []

  func checkAge(message: LocalizedStringResource = "You must be over 21") -> Self {
    addRule { value in
      if value.age < 21 {
        return .failure(errors: .init([message]))
      }

      return .success(value: value)
    }
  }

  func checkFirstName(
    message: LocalizedStringResource = "First name must be longer than 6 characters."
  ) -> Self {
    addRule { value in
      if value.firstName.count < 6 {
        return .failure(errors: .init([message]))
      }

      return .success(value: value)
    }
  }
}
```

Now use it like any built-in validator:

```swift
await SAFormValidationRules()
  .userValidation()
  .checkAge()
  .checkFirstName()
  .validate(value: user)
```
