# SAFormView <Badge type="tip" text="Struct" />

`SAFormView` is a lightweight container for form content.
It accepts a form config object and renders custom SwiftUI layout.

## Constructor

```swift
init(
    formConfig: FormConfig,
    @ViewBuilder content: () -> Content
)
```

### Arguments
- **`formConfig: FormConfig`** - form configuration object (`SAForm` or custom type conforming to `SAFormConfig`).
- **`content`** - form content builder.

Example:

```swift
SAFormView(formConfig: form) {
    SAFormControllerView(formConfig: form, key: \.email) { value, _ in
        TextField("Email", text: value)
    }
}
```
