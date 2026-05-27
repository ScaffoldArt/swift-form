---
pageClass: api-reference-page
---

# SAFormControllerView <Badge type="tip" text="Struct" />

Use `SAFormControllerView` to connect a SwiftUI input to one field in a form.

```swift
SAFormControllerView(formConfig: form, key: \.email) { value, field in
    TextField("Email", text: value)

    if let firstError = field.errors?.messages.first {
        Text(firstError)
            .foregroundStyle(.red)
    }
}
```

```swift
init(
    formConfig: FormConfig,
    key: WritableKeyPath<FormConfig.Fields, FormField>,
    @ViewBuilder content: @MainActor @escaping (_ value: Binding<Value>, _ formField: FormField) -> Content
)
```

#### Parameters

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `formConfig` | Form object or custom type conforming to `SAFormConfig`. | `FormConfig` | None |
| `key` | Field key path in `formConfig.fields`. | `WritableKeyPath<FormConfig.Fields, FormField>` | None |
| `content` | View builder that receives a value binding and the field object. | `(Binding<Value>, FormField) -> Content` | None |

## Type Aliases

| Name | Description | Type |
| --- | --- | --- |
| `Value` | Value type used by the field binding. | `FormField.Value` |
