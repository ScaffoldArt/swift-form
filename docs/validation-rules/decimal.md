# Decimal

Use decimal validation when you need base-10 precision (for example money and amounts) and want to avoid binary floating-point rounding effects.

## gt

Strictly greater than the specified number.

**Parameters**
- `num: Decimal` - exclusive lower bound
- `message: ((Decimal) -> LocalizedStringResource)?` - optional custom error message builder

```swift
let greaterThan = SAFormValidationRules()
  .decimal()
  .gt(num: 10)

greaterThan.validate(value: 15) // ✅ is valid
greaterThan.validate(value: 5)  // ❌ is not valid
```

## gte

Greater than or equal to the specified number.

**Parameters**
- `num: Decimal` - inclusive lower bound
- `message: ((Decimal) -> LocalizedStringResource)?` - optional custom error message builder

```swift
let greaterOrEqual = SAFormValidationRules()
  .decimal()
  .gte(num: 10)

greaterOrEqual.validate(value: 10) // ✅ is valid
greaterOrEqual.validate(value: 5)  // ❌ is not valid
```

## lt

Strictly less than the specified number.

**Parameters**
- `num: Decimal` - exclusive upper bound
- `message: ((Decimal) -> LocalizedStringResource)?` - optional custom error message builder

```swift
let lessThan = SAFormValidationRules()
  .decimal()
  .lt(num: 100)

lessThan.validate(value: 50)   // ✅ is valid
lessThan.validate(value: 150)  // ❌ is not valid
```

## lte

Less than or equal to the specified number.

**Parameters**
- `num: Decimal` - inclusive upper bound
- `message: LocalizedStringResource?` - error message if the value is greater

```swift
let lessOrEqual = SAFormValidationRules()
  .decimal()
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
  .decimal()
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
  .decimal()
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
  .decimal()
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
  .decimal()
  .nonPositive()

nonPositive.validate(value: 0)  // ✅ is valid
nonPositive.validate(value: 10) // ❌ is not valid
```

## multipleOf

Checks that the value is divisible by the specified multiplier.

**Parameters**
- `mult: Decimal` - multiplier (divisor). If zero, validation fails
- `message: ((Decimal) -> LocalizedStringResource)?` - optional custom error message builder

```swift
let multipleOf = SAFormValidationRules()
  .decimal()
  .multipleOf(mult: 5)

multipleOf.validate(value: 20) // ✅ is valid
multipleOf.validate(value: 7)  // ❌ is not valid
```
