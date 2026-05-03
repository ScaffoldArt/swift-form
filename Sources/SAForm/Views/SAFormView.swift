import SwiftUI

public struct SAFormView<
    FormConfig: SAFormConfig,
    Content: View
>: View {
    private let formConfig: FormConfig
    @ViewBuilder private var content: Content

    public init(
        formConfig: FormConfig,
        @ViewBuilder content: () -> Content
    ) {
        self.formConfig = formConfig
        self.content = content()
    }

    public var body: some View {
        content
    }
}
