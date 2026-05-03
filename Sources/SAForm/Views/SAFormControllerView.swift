import SwiftUI

public struct SAFormControllerView<
    FormConfig: SAFormConfig,
    FormField: SAFormFieldConfigurable,
    Content: View
>: View {
    public typealias Value = FormField.Value

    @Bindable var formConfig: FormConfig
    @FocusState private var isFocused: Bool
    private let content: (_ value: Binding<Value>, _ formField: FormField) -> Content
    private let key: WritableKeyPath<FormConfig.Fields, FormField>

    public init(
        formConfig: FormConfig,
        key: WritableKeyPath<FormConfig.Fields, FormField>,
        @ViewBuilder content: @MainActor @escaping (_ value: Binding<Value>, _ formField: FormField) -> Content
    ) {
        self.formConfig = formConfig
        self.content = content
        self.key = key
    }

    public var body: some View {
        @Bindable var field = formConfig.fields[keyPath: key]

        content($field.value, formConfig.fields[keyPath: key])
            .focused($isFocused)
            .disabled(formConfig.formState.isDisabled)
            .onAppear {
                formConfig.fields[keyPath: key].mounted = true
                isFocused = formConfig.formState.focusedFieldKey == key
            }
            .onDisappear {
                formConfig.fields[keyPath: key].mounted = false
            }
            .onChange(of: formConfig.formState.focusedFieldKey) {
                isFocused = formConfig.formState.focusedFieldKey == key
            }
            .onChange(of: isFocused) {
                if !isFocused && formConfig.formState.focusedFieldKey == key {
                    formConfig.formState.focusedFieldKey = nil
                }
            }
            .onChange(of: field.value) {
                field.isDirty = field.value != field.defaultValue

                if !field.isDirty {
                    return
                }

                Task {
                    await formConfig.validateFieldOnChange(key: key)
                }
            }
    }
}
