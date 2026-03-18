# Overview

FormCraft is a SwiftUI-first form validation library focused on type-safe data, composable rules, and predictable form state.

It gives you one consistent model for:
- field-level validation
- cross-field validation with `refine(form:)`
- async validation flows
- validated output on submit

## Why FormCraft

SwiftUI forms usually become hard to maintain when validation grows:

- validation logic gets spread across views
- cross-field rules become ad-hoc
- async checks add race conditions
- submit handlers receive raw, partially trusted input

FormCraft centralizes this into a single form model.

## Core Building Blocks

- `FormCraftFields`  
  Your typed schema of fields, plus optional `refine(form:)` for form-level rules.

- `FormCraftField<Value, ValidatedValue>`  
  A field with raw value, validation state, and async rule.

- `FormCraft<Fields>`  
  Form controller that runs validation, manages errors, and handles submit.

- `FormCraftControllerView`  
  Connects SwiftUI inputs to a field using typed bindings.

- `FormCraftValidationRules`  
  Chainable, type-specific validators (`string`, `integer`, `decimal`, `boolean`, `customType`, `optional`, `union`).

## Key Capabilities

- **Type-safe validated output**  
  Submit with `FormCraftValidatedFields` instead of handling unchecked raw values.

- **Composable validation model**  
  Combine per-field rules with `refine(form:)` for domain constraints.

- **Async-ready flow**  
  Validation rules are async by default, so server-backed checks fit naturally.

- **Built-in validation timing control**  
  Fields can define delay behavior via `FormCraftDelayValidation`.

- **Localization-friendly errors**  
  Error messages are built around `LocalizedStringResource` with customizable `FormCraftLocalizations`.

## How Data Flows

1. Define fields and rules in a `FormCraftFields` type.
2. Bind UI controls with `FormCraftControllerView`.
3. Validate per field or entire form.
4. Submit with `handleSubmit`, receiving validated typed data.

---
