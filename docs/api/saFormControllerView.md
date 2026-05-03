# SAFormControllerView <Badge type="tip" text="Struct" />

`SAFormControllerView` binds a SwiftUI input control to a specific form field.

It provides:
- typed binding to field value (`Binding<Field.Value>`)
- access to current field object (`Field`)
- automatic mounted/focus synchronization
- automatic per-field validation when value changes

## Constructor

```swift
init(
    formConfig: FormConfig,
    key: WritableKeyPath<FormConfig.Fields, FormField>,
    @ViewBuilder content: @escaping (_ value: Binding<Value>, _ formField: FormField) -> Content
)
```

### Arguments
- **`formConfig: FormConfig`** - form configuration object.
- **`key`** - key path to target field in `formConfig.fields`.
- **`content`** - builder that receives value binding and field object.

Example:

```swift
SAFormControllerView(formConfig: form, key: \.email) { value, field in
    TextField("Email", text: value)

    if let firstError = field.errors?.messages.first {
        Text(firstError)
            .foregroundStyle(.red)
    }
}
```
