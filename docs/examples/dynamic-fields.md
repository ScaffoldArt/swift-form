# Dynamic Fields

Use dynamic fields when the user can add or remove repeated sections.
`SAFormCollection` stores the list and gives each item the same typed field behavior as the rest of the form.

This example uses a travel booking form where the user can manage passengers.

```swift
import SwiftUI
import SAForm

@SAForm
private struct BookingFields: SAFormFields {
    struct Passenger: SAFormCollectionItem {
        var fullName = SAFormField(value: "") { value in
            await SAFormValidationRules()
                .string()
                .notEmpty()
                .validate(value: value)
        }

        var age = SAFormField<String, Int>(value: "") { value in
            guard let age = Int(value) else {
                return .failure(errors: .init(["Age must be a number"]))
            }

            return await SAFormValidationRules()
                .integer()
                .gte(num: 0)
                .validate(value: age)
        }
    }

    var passengers = SAFormCollection { Passenger() }
}

struct BookingView: View {
    @State private var form = SAForm(fields: BookingFields())

    var body: some View {
        VStack(spacing: 16) {
            SAFormView(formConfig: form) {
                ForEach(form.fields.passengers.indices, id: \.self) { index in
                    GroupBox("Passenger \(index + 1)") {
                        VStack(spacing: 12) {
                            SAFormControllerView(formConfig: form, key: \.passengers[index].fullName) { value, field in
                                TextField("Full Name", text: value)

                                if let firstError = field.errors?.messages.first {
                                    Text(firstError)
                                        .foregroundStyle(.red)
                                }
                            }

                            SAFormControllerView(formConfig: form, key: \.passengers[index].age) { value, field in
                                TextField("Age", text: value)

                                if let firstError = field.errors?.messages.first {
                                    Text(firstError)
                                        .foregroundStyle(.red)
                                }
                            }

                            Button("Remove Passenger") {
                                form.fields.passengers.remove(at: index)
                            }
                        }
                    }
                }
            }

            HStack {
                Button("Add") {
                    form.fields.passengers.add()
                }

                Button("Add First") {
                    form.fields.passengers.insert(BookingFields.Passenger(), at: 0)
                }

                Button("Add Custom") {
                    form.fields.passengers.add(BookingFields.Passenger())
                }

                Button("Remove All") {
                    form.fields.passengers.removeAll()
                }
            }

            Button("Book Trip", action: form.handleSubmit { data in
                let passengers = data.passengers.map { passenger in
                    let fullName: String = passenger.fullName
                    let age: Int = passenger.age

                    return (fullName: fullName, age: age)
                }

                await bookTrip(passengers: passengers)
            })
            .disabled(form.formState.isSubmitting)
        }
    }
}
```

## Key Idea

Use `add()` when the collection has an item factory, `add(_:)` when you already have an item, `insert(_:at:)` when order matters, `remove(at:)` for one item, and `removeAll()` to clear the collection.
Collection values are still validated and returned as typed submit data.
