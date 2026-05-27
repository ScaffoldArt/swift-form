# Nested Fields

Use nested fields when a form has several logical sections.
`SAFormGroup` keeps the schema readable while preserving typed key paths for UI bindings and submit data.

This example uses a checkout form with customer, shipping, and billing sections.

```swift
import SwiftUI
import SAForm

@SAForm
private struct CheckoutFields: SAFormFields {
    struct Customer: SAFormGroup {
        var name = SAFormField(value: "") { value in
            await SAFormValidationRules()
                .string()
                .notEmpty()
                .validate(value: value)
        }

        var email = SAFormField(value: "") { value in
            await SAFormValidationRules()
                .string()
                .notEmpty()
                .email()
                .validate(value: value)
        }
    }

    struct Address: SAFormGroup {
        var street = SAFormField(value: "") { value in
            await SAFormValidationRules()
                .string()
                .notEmpty()
                .validate(value: value)
        }

        var city = SAFormField(value: "") { value in
            await SAFormValidationRules()
                .string()
                .notEmpty()
                .validate(value: value)
        }

        var postalCode = SAFormField(value: "") { value in
            await SAFormValidationRules()
                .string()
                .notEmpty()
                .validate(value: value)
        }
    }

    var customer = Customer()
    var shippingAddress = Address()
    var billingAddress = Address()
}

struct CheckoutView: View {
    @State private var form = SAForm(fields: CheckoutFields())

    var body: some View {
        VStack(spacing: 16) {
            SAFormView(formConfig: form) {
                GroupBox("Customer") {
                    VStack(spacing: 12) {
                        SAFormControllerView(formConfig: form, key: \.customer.name) { value, field in
                            TextField("Name", text: value)

                            if let firstError = field.errors?.messages.first {
                                Text(firstError)
                                    .foregroundStyle(.red)
                            }
                        }

                        SAFormControllerView(formConfig: form, key: \.customer.email) { value, field in
                            TextField("Email", text: value)

                            if let firstError = field.errors?.messages.first {
                                Text(firstError)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }

                GroupBox("Shipping Address") {
                    addressFields(\.shippingAddress)
                }

                GroupBox("Billing Address") {
                    addressFields(\.billingAddress)
                }
            }

            Button("Place Order", action: form.handleSubmit { data in
                let customerName: String = data.customer.name
                let customerEmail: String = data.customer.email
                let shippingCity: String = data.shippingAddress.city
                let billingCity: String = data.billingAddress.city

                await placeOrder(
                    customerName: customerName,
                    customerEmail: customerEmail,
                    shippingCity: shippingCity,
                    billingCity: billingCity
                )
            })
            .disabled(form.formState.isSubmitting)
        }
    }

    @ViewBuilder
    private func addressFields(
        _ keyPath: WritableKeyPath<CheckoutFields, CheckoutFields.Address>
    ) -> some View {
        VStack(spacing: 12) {
            SAFormControllerView(formConfig: form, key: keyPath.appending(path: \.street)) { value, field in
                TextField("Street", text: value)

                if let firstError = field.errors?.messages.first {
                    Text(firstError)
                        .foregroundStyle(.red)
                }
            }

            SAFormControllerView(formConfig: form, key: keyPath.appending(path: \.city)) { value, field in
                TextField("City", text: value)

                if let firstError = field.errors?.messages.first {
                    Text(firstError)
                        .foregroundStyle(.red)
                }
            }

            SAFormControllerView(formConfig: form, key: keyPath.appending(path: \.postalCode)) { value, field in
                TextField("Postal Code", text: value)

                if let firstError = field.errors?.messages.first {
                    Text(firstError)
                        .foregroundStyle(.red)
                }
            }
        }
    }
}
```

## Key Idea

Groups let a large form read like its domain model.
The UI still binds with typed key paths such as `\.shippingAddress.city`, and submit data keeps the same nested shape.
