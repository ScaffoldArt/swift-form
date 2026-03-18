import SwiftUI

public struct FormCraftControllerView<
    FormConfig: FormCraftConfig,
    FormField: FormCraftFieldConfigurable,
    Content: View
>: View {
    public typealias Value = FormField.Value

    @Bindable var formConfig: FormConfig
    private let content: (_ value: Binding<Value>, _ formField: FormField) -> Content
    private let key: WritableKeyPath<FormConfig.Fields, FormField>

    public init(
        formConfig: FormConfig,
        key: WritableKeyPath<FormConfig.Fields, FormField>,
        @ViewBuilder content: @escaping (_ value: Binding<Value>, _ formField: FormField) -> Content
    ) {
        self.formConfig = formConfig
        self.content = content
        self.key = key
    }

    public var body: some View {
        @Bindable var field = formConfig.fields[keyPath: key]

        content($field.value, formConfig.fields[keyPath: key])
        .onAppear {
            formConfig.fields[keyPath: key].mounted = true
        }
        .onDisappear {
            formConfig.fields[keyPath: key].mounted = false
        }
        .onChange(of: field.value) {
            if field.isDirty == false && field.value != field.defaultValue {
                field.isDirty = true
            }

            if !field.isDirty {
                return
            }

            Task {
                await formConfig.validateField(key: key)
            }
        }
    }
}
