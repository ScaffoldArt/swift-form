# String

`string()` validates text values.

Use string rules for common inputs like emails, phone numbers, IDs, IPs, and custom regex patterns.

## notEmpty

Value must not be an empty string.

**Parameters**
- `message: LocalizedStringResource?` – optional custom error message if empty

```swift
let notEmpty = SAFormValidationRules()
  .string()
  .notEmpty()

notEmpty.validate(value: "text") // ✅ is valid
notEmpty.validate(value: "")     // ❌ is not valid
```

## trimmed

No leading or trailing whitespace is allowed.

**Parameters**
- `message: LocalizedStringResource?` – optional custom error message if whitespace is found

```swift
let trimmed = SAFormValidationRules()
  .string()
  .trimmed()

trimmed.validate(value: "hello")     // ✅ is valid
trimmed.validate(value: " hello ")   // ❌ is not valid
```

## min

Minimum length requirement.

**Parameters**
- `min: Int` – minimum number of characters  
- `message: ((Int) -> LocalizedStringResource)?` – optional custom error message builder

```swift
let minRule = SAFormValidationRules()
  .string()
  .min(min: 3)

minRule.validate(value: "hey") // ✅ is valid
minRule.validate(value: "hi")  // ❌ is not valid
```

## max

Maximum length limit.

**Parameters**
- `max: Int` – maximum number of characters  
- `message: ((Int) -> LocalizedStringResource)?` – optional custom error message builder

```swift
let maxRule = SAFormValidationRules()
  .string()
  .max(max: 5)

maxRule.validate(value: "short")   // ✅ is valid
maxRule.validate(value: "too long") // ❌ is not valid
```

## length

Exact length requirement.

**Parameters**
- `length: Int` – required number of characters  
- `message: ((Int) -> LocalizedStringResource)?` – optional custom error message builder

```swift
let lengthRule = SAFormValidationRules()
  .string()
  .length(length: 6)

lengthRule.validate(value: "ABC123") // ✅ is valid
lengthRule.validate(value: "ABC12")  // ❌ is not valid
```

## equals

Value must be equal to the given string.

**Parameters**
- `to: String` – the string to compare against  
- `message: ((String, String) -> LocalizedStringResource)?` – optional custom error message builder

```swift
let equalsRule = SAFormValidationRules()
  .string()
  .equals(to: "secret")

equalsRule.validate(value: "secret") // ✅ is valid
equalsRule.validate(value: "SECRET") // ❌ is not valid
```

## regex

Validation against a custom regex pattern.

**Parameters**
- `pattern: Regex<Substring>` – regex to validate against  
- `message: LocalizedStringResource?` – optional custom error message if pattern does not match

```swift
let code4Digits = SAFormValidationRules()
  .string()
  .regex(pattern: /^[0-9]{4}$/)

code4Digits.validate(value: "1234") // ✅ is valid
code4Digits.validate(value: "12a4") // ❌ is not valid
```

## cuid

Value must be a valid CUID.

**Parameters**
- `message: LocalizedStringResource?` – optional custom error message if invalid

```swift
let cuidRule = SAFormValidationRules()
  .string()
  .cuid()

cuidRule.validate(value: "ckjq8y3nj0001x9m5h8b9kqzg") // ✅ is valid
cuidRule.validate(value: "invalid-cuid")              // ❌ is not valid
```

## cuid2

Value must be a valid CUID2.

**Parameters**
- `message: LocalizedStringResource?` – optional custom error message if invalid

```swift
let cuid2Rule = SAFormValidationRules()
  .string()
  .cuid2()

cuid2Rule.validate(value: "a1b2c3d4e5f6") // ✅ is valid
cuid2Rule.validate(value: "A1B2C3")       // ❌ is not valid
```

## ulid

Value must be a valid ULID.

**Parameters**
- `message: LocalizedStringResource?` – optional custom error message if invalid

```swift
let ulidRule = SAFormValidationRules()
  .string()
  .ulid()

ulidRule.validate(value: "01ARZ3NDEKTSV4RRFFQ69G5FAV") // ✅ is valid
ulidRule.validate(value: "01ARZ3NDEKTSV4RRFFQ69G5FA!") // ❌ is not valid
```

## uuid

Value must be a valid UUID.

**Parameters**
- `message: LocalizedStringResource?` – optional custom error message if invalid

```swift
let uuidRule = SAFormValidationRules()
  .string()
  .uuid()

uuidRule.validate(value: "123e4567-e89b-12d3-a456-426614174000") // ✅ is valid
uuidRule.validate(value: "invalid-uuid")                        // ❌ is not valid
```

## nanoId

Value must be a valid NanoID (21 chars).

**Parameters**
- `message: LocalizedStringResource?` – optional custom error message if invalid

```swift
let nanoIdRule = SAFormValidationRules()
  .string()
  .nanoId()

nanoIdRule.validate(value: "abcde12345_fghij-67890") // ✅ is valid
nanoIdRule.validate(value: "ABC-123")                // ❌ is not valid
```

## ipv4

IPv4 address format validation.

**Parameters**
- `message: LocalizedStringResource?` – optional custom error message if invalid

```swift
let ipv4Rule = SAFormValidationRules()
  .string()
  .ipv4()

ipv4Rule.validate(value: "192.168.0.1") // ✅ is valid
ipv4Rule.validate(value: "999.168.0.1") // ❌ is not valid
```

## ipv6

IPv6 address format validation.

**Parameters**
- `message: LocalizedStringResource?` – optional custom error message if invalid

```swift
let ipv6Rule = SAFormValidationRules()
  .string()
  .ipv6()

ipv6Rule.validate(value: "2001:0db8:85a3:0000:0000:8a2e:0370:7334") // ✅ is valid
ipv6Rule.validate(value: "2001:::7334")                            // ❌ is not valid
```

## cidrv4

IPv4 CIDR notation validation.

**Parameters**
- `message: LocalizedStringResource?` – optional custom error message if invalid

```swift
let cidrv4Rule = SAFormValidationRules()
  .string()
  .cidrv4()

cidrv4Rule.validate(value: "192.168.1.0/24") // ✅ is valid
cidrv4Rule.validate(value: "192.168.1.0/33") // ❌ is not valid
```

## cidrv6

IPv6 CIDR notation validation.

**Parameters**
- `message: LocalizedStringResource?` – optional custom error message if invalid

```swift
let cidrv6Rule = SAFormValidationRules()
  .string()
  .cidrv6()

cidrv6Rule.validate(value: "2001:db8::/32")  // ✅ is valid
cidrv6Rule.validate(value: "2001:db8::/129") // ❌ is not valid
```

## isoDate

Date string in the format `YYYY-MM-DD` (leap-year aware).

**Parameters**
- `message: LocalizedStringResource?` – optional custom error message if invalid

```swift
let isoDateRule = SAFormValidationRules()
  .string()
  .isoDate()

isoDateRule.validate(value: "2024-02-29") // ✅ is valid
isoDateRule.validate(value: "2023-02-29") // ❌ is not valid
```

## email

Email format validation.

**Parameters**
- `message: LocalizedStringResource?` – optional custom error message if invalid

```swift
let emailRule = SAFormValidationRules()
  .string()
  .email()

emailRule.validate(value: "user@example.com") // ✅ is valid
emailRule.validate(value: "user@")            // ❌ is not valid
```

## e164phoneNumber

E.164-like phone number validation.

**Parameters**
- `message: LocalizedStringResource?` – optional custom error message if invalid

```swift
let phoneRule = SAFormValidationRules()
  .string()
  .e164phoneNumber()

phoneRule.validate(value: "+14155552671") // ✅ is valid
phoneRule.validate(value: "141-555-2671") // ❌ is not valid
```

## startsWith

Value must start with the given prefix.

**Parameters**
- `prefix: String` – required starting substring  
- `message: ((String) -> LocalizedStringResource)?` – optional custom error message builder

```swift
let startsWithRule = SAFormValidationRules()
  .string()
  .startsWith(prefix: "Hello")

startsWithRule.validate(value: "Hello World") // ✅ is valid
startsWithRule.validate(value: "World Hello") // ❌ is not valid
```

## endsWith

Value must end with the given suffix.

**Parameters**
- `suffix: String` – required ending substring
- `message: ((String) -> LocalizedStringResource)?` – optional custom error message builder

```swift
let endsWithRule = SAFormValidationRules()
  .string()
  .endsWith(suffix: ".com")

endsWithRule.validate(value: "example.com") // ✅ is valid
endsWithRule.validate(value: "example.org") // ❌ is not valid
```

## includes

Value must contain the given substring.

**Parameters**
- `substring: String` – required substring
- `message: ((String) -> LocalizedStringResource)?` – optional custom error message builder

```swift
let includesRule = SAFormValidationRules()
  .string()
  .includes(substring: "@")

includesRule.validate(value: "name@example.com") // ✅ is valid
includesRule.validate(value: "name.example.com") // ❌ is not valid
```

## uppercase

Value must be fully uppercase.

**Parameters**
- `message: LocalizedStringResource?` – optional custom error message if value is not uppercase

```swift
let uppercaseRule = SAFormValidationRules()
  .string()
  .uppercase()

uppercaseRule.validate(value: "ABC") // ✅ is valid
uppercaseRule.validate(value: "AbC") // ❌ is not valid
```

## lowercase

Value must be fully lowercase.

**Parameters**
- `message: LocalizedStringResource?` – optional custom error message if value is not lowercase

```swift
let lowercaseRule = SAFormValidationRules()
  .string()
  .lowercase()

lowercaseRule.validate(value: "abc") // ✅ is valid
lowercaseRule.validate(value: "aBc") // ❌ is not valid
```
