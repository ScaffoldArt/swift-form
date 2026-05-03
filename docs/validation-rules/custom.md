# Custom

Use custom validation when field value is not a simple scalar and you need domain-specific validation logic.

Use it for domain objects and custom value types that are not covered by built-in validators.

## Why Use It

- To validate domain models (`User`, `Address`, `Money`, etc.).
- To support external value types that are not built into SAForm.

## When to use it

- When one value contains multiple properties and should be validated as a whole object.
- When business rules cannot be expressed by built-in scalar rules.
- When you want to keep domain validation close to the domain type.

## Basic Example

```swift
struct User: Sendable {
  let firstName: String
  let age: Int
}

let userValidation = SAFormValidationRules()
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

## Reusing Built-In Rules Inside `addRule`

You can call `SAFormValidationRules` inside `addRule` and map nested validation errors back to the current custom value.

```swift
struct User: Sendable {
  let email: String
  let age: Int
}

let validator = SAFormValidationRules()
  .custom(User.self)
  .addRule { user in
    let emailResult = await SAFormValidationRules()
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
    let ageResult = await SAFormValidationRules()
      .integer()
      .gte(num: 18)
      .validate(value: user.age)

    if let errors = ageResult.errors {
      return .failure(errors: errors)
    }

    return .success(value: user)
  }
```
