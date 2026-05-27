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
| `content` | View builder used to render the controlled input. | `(Binding<Value>, FormField) -> Content` | None |
| <span class="api-nested-prop">`content.value`</span> | Binding used by a SwiftUI control to read and update the field value. | `Binding<Value>` | None |
| <span class="api-nested-prop">`content.formField`</span> | Field object passed to the content closure for reading errors, validation state, dirty state, and other field data. | `FormField` | None |
| <span class="api-nested-prop api-nested-prop-deep">`content.formField.value`</span> | Current field value. | `Value` | Current value |
| <span class="api-nested-prop api-nested-prop-deep">`content.formField.validatedValue`</span> | Last successfully validated value. | `FormField.ValidatedValue?` | `nil` |
| <span class="api-nested-prop api-nested-prop-deep">`content.formField.defaultValue`</span> | Value used as the dirty-state baseline. | `Value` | Initial value |
| <span class="api-nested-prop api-nested-prop-deep">`content.formField.errors`</span> | Current field errors. | `SAFormFailure?` | `nil` |
| <span class="api-nested-prop api-nested-prop-deep">`content.formField.isError`</span> | `true` when the field has errors. | `Bool` | Computed |
| <span class="api-nested-prop api-nested-prop-deep">`content.formField.isValidating`</span> | `true` while field validation is running. | `Bool` | `false` |
| <span class="api-nested-prop api-nested-prop-deep">`content.formField.isDirty`</span> | `true` when the field value differs from its default value. | `Bool` | `false` |
