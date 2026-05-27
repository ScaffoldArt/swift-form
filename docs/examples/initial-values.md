# Initial values

This example shows how to load existing data, set it as the form default, and submit only later user changes.

```swift
import SwiftUI
import SAForm

private struct PlayerService {
    struct PlayerDTO {
        let firstName: String
        let lastName: String
    }

    func fetchPlayer() async -> PlayerDTO {
        try? await Task.sleep(nanoseconds: 3_000_000_000)

        return .init(firstName: "First name", lastName: "Last name")
    }

    func updatePlayer(player: PlayerDTO) async {
        try? await Task.sleep(nanoseconds: 3_000_000_000)
    }
}

@SAForm
private struct FormFields: SAFormFields {
    var firstName = SAFormField(value: "") { value in
        await SAFormValidationRules()
            .string()
            .notEmpty()
            .validate(value: value)
    }

    var lastName = SAFormField(value: "") { value in
        await SAFormValidationRules()
            .string()
            .notEmpty()
            .validate(value: value)
    }
}

struct InitialValuesFormView: View {
    @State private var form = SAForm(fields: FormFields())
    private let playerService = PlayerService()

    private func updatePlayer(data: SAFormValidatedFields<FormFields>) async {
        let firstName: String = data.firstName
        let lastName: String = data.lastName

        await playerService.updatePlayer(
            player: .init(
                firstName: firstName,
                lastName: lastName
            )
        )
    }

    func onTask() async {
        let data = await playerService.fetchPlayer()

        form.setDefaultValues(
            (\.firstName, data.firstName),
            (\.lastName, data.lastName)
        )
    }

    var body: some View {
        VStack {
            SAFormView(formConfig: form) {
                SAFormControllerView(
                    formConfig: form,
                    key: \.firstName
                ) { value, field in
                    TextField("First name", text: value)
                        .textFieldStyle(.roundedBorder)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError)
                            .foregroundStyle(.red)
                    }
                }

                SAFormControllerView(
                    formConfig: form,
                    key: \.lastName
                ) { value, field in
                    TextField("Last name", text: value)
                        .textFieldStyle(.roundedBorder)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError)
                            .foregroundStyle(.red)
                    }
                }
            }

            Button("Update", action: form.handleSubmit(onSuccess: updatePlayer))
                .disabled(form.formState.isSubmitting)
        }
        .task { await onTask() }
    }
}
```

## Key Idea

Use `setDefaultValues` after loading data from your backend.
It updates both the current value and the dirty-state baseline, so fetched values do not count as user edits.
