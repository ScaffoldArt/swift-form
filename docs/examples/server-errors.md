# Server Errors

```swift
import SwiftUI
import SAForm

private struct ServerError: LocalizedError {
    let code: Int
    let errors: [String: [String]]

    var errorDescription: String? { "Server error \(code)" }
}

private struct PlayerRepository {
    struct PlayerDTO {
        let firstName: String
        let lastName: String
    }

    func fetchPlayer() async -> PlayerDTO {
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        return .init(firstName: "First name", lastName: "Last name")
    }

    func updatePlayer(player: PlayerDTO) async -> Result<PlayerDTO, ServerError> {
        try? await Task.sleep(nanoseconds: 3_000_000_000)

        if player.firstName.count > 4 {
            return .failure(
                .init(
                    code: 400,
                    errors: ["firstName": ["First name must be 4 characters or fewer."]]
                )
            )
        }

        return .success(player)
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

struct ServerErrorsFormView: View {
    @State private var form = SAForm(fields: FormFields())
    private let playerService = PlayerRepository()

    private func handleSubmit(data: SAFormValidatedFields<FormFields>) async {
        let response = await playerService.updatePlayer(
            player: .init(
                firstName: data.firstName,
                lastName: data.lastName
            )
        )

        switch response {
        case .success:
            print("Profile updated.")
        case .failure(let serverError):
            form.setErrors(
                errors: serverError.errors,
                options: .init(shouldFocusError: false)
            )
        }
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

            Button("Save", action: form.handleSubmit(onSuccess: handleSubmit))
                .disabled(form.formState.isSubmitting)
        }
        .task { await onTask() }
    }
}
```
