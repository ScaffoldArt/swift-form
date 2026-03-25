# Custom

Use `custom()` / `custom(T.self)` when built-in validators (`string`, `integer`, `floating`, `decimal`, `boolean`) are not enough.

## Why use it

- To validate domain models (`User`, `Address`, `Money`, etc.).
- To validate arrays and complex nested payloads.
- To support external value types that are not built into FormCraft.

## When to use it

- Cross-field/domain-specific checks inside one value object.
- Business rules that cannot be expressed by built-in scalar rules.
- Validation for custom wrappers and third-party types.

## Example

```swift
struct User: Sendable {
  let firstName: String
  let age: Int
}

let userValidation = FormCraftValidationRules()
  .custom(User.self)
  .addRule { user in
    if user.firstName.isEmpty {
      return .failure(errors: .init(["First name is required"]))
    }

    return .success(value: user)
  }
  .addRule { user in
    if user.age < 18 {
      return .failure(errors: .init(["You must be at least 18"]))
    }

    return .success(value: user)
  }

let result = await userValidation.validate(value: .init(firstName: "Alex", age: 21))
```

## Using `FormCraftValidationRules` inside `addRule`

```swift
struct User: Sendable {
  let email: String
  let age: Int
}

let validator = FormCraftValidationRules()
  .custom(User.self)
  .addRule { user in
    let emailResult = await FormCraftValidationRules()
      .string()
      .notEmpty()
      .email()
      .validate(value: user.email)

    if let errors = emailResult.errors {
      return .failure(errors: errors)
    }

    return .success(value: user)
  }
  .addRule { user in
    let ageResult = await FormCraftValidationRules()
      .integer()
      .gte(num: 18)
      .validate(value: user.age)

    if let errors = ageResult.errors {
      return .failure(errors: errors)
    }

    return .success(value: user)
  }
```

## Notes

- `T` must conform to `Sendable`.
- Rules are executed in order.
- Validation stops on the first failure.
- Use `.custom(MyType.self)` when you want explicit type.
