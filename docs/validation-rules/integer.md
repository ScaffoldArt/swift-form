# Integer

Use integer validation for numeric fields that must contain whole numbers (`Int`, `Int64`, `UInt`, etc.).

::: warning Type Defaults
By default it uses `Int`.  
Use `integer(Int64.self)` (or another integer type) when you need explicit type control.
:::

## gt

Strictly greater than the specified number.

**Parameters**
- `num: T` - exclusive lower bound
- `message: ((T) -> LocalizedStringResource)?` - optional custom error message builder

```swift
let greaterThan = SAFormValidationRules()
  .integer()
  .gt(num: 10)

greaterThan.validate(value: 15) // ✅ is valid
greaterThan.validate(value: 5)  // ❌ is not valid
```

## gte

Greater than or equal to the specified number.

**Parameters**
- `num: T` - inclusive lower bound
- `message: ((T) -> LocalizedStringResource)?` - optional custom error message builder

```swift
let greaterOrEqual = SAFormValidationRules()
  .integer()
  .gte(num: 10)

greaterOrEqual.validate(value: 10) // ✅ is valid
greaterOrEqual.validate(value: 5)  // ❌ is not valid
```

## lt

Strictly less than the specified number.

**Parameters**
- `num: T` - exclusive upper bound
- `message: ((T) -> LocalizedStringResource)?` - optional custom error message builder

```swift
let lessThan = SAFormValidationRules()
  .integer()
  .lt(num: 100)

lessThan.validate(value: 50)   // ✅ is valid
lessThan.validate(value: 150)  // ❌ is not valid
```

## lte

Less than or equal to the specified number.

**Parameters**
- `num: T` - inclusive upper bound
- `message: ((T) -> LocalizedStringResource)?` - optional custom error message builder

```swift
let lessOrEqual = SAFormValidationRules()
  .integer()
  .lte(num: 100)

lessOrEqual.validate(value: 100) // ✅ is valid
lessOrEqual.validate(value: 101) // ❌ is not valid
```

## positive

Positive number (greater than zero).

**Parameters**
- `message: LocalizedStringResource?` - error message if the value is not positive

```swift
let positive = SAFormValidationRules()
  .integer()
  .positive()

positive.validate(value: 42)   // ✅ is valid
positive.validate(value: -10)  // ❌ is not valid
```

## nonNegative

Zero or positive.

**Parameters**
- `message: LocalizedStringResource?` - error message if the value is negative

```swift
let nonNegative = SAFormValidationRules()
  .integer()
  .nonNegative()

nonNegative.validate(value: 0)   // ✅ is valid
nonNegative.validate(value: -1)  // ❌ is not valid
```

## negative

Negative number (less than zero).

**Parameters**
- `message: LocalizedStringResource?` - error message if the value is not negative

```swift
let negative = SAFormValidationRules()
  .integer()
  .negative()

negative.validate(value: -5) // ✅ is valid
negative.validate(value: 5)  // ❌ is not valid
```

## nonPositive

Zero or negative.

**Parameters**
- `message: LocalizedStringResource?` - error message if the value is positive

```swift
let nonPositive = SAFormValidationRules()
  .integer()
  .nonPositive()

nonPositive.validate(value: 0)  // ✅ is valid
nonPositive.validate(value: 10) // ❌ is not valid
```

## multipleOf

Checks that the value is divisible by the specified number.

**Parameters**
- `num: T` - divisor. If zero, validation fails
- `message: ((T) -> LocalizedStringResource)?` - optional custom error message builder

```swift
let multipleOf = SAFormValidationRules()
  .integer()
  .multipleOf(num: 5)

multipleOf.validate(value: 20) // ✅ is valid
multipleOf.validate(value: 7)  // ❌ is not valid
```
