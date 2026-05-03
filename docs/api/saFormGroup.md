# SAFormGroup <Badge type="tip" text="Protocol" />

::: warning
`SAFormGroup` must be declared inside a struct annotated with `@SAForm`.
:::

Use it when you want to split a large form into logical nested sections while keeping typed access.

Example:

```swift
@SAForm
private struct CheckoutFields: SAFormFields {
    struct Customer: SAFormGroup {
        var firstName = SAFormField(value: "") { value in
            await SAFormValidationRules()
                .string()
                .notEmpty()
                .min(min: 2)
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

    struct Delivery: SAFormGroup {
        var city = SAFormField(value: "") { value in
            await SAFormValidationRules()
                .string()
                .notEmpty()
                .validate(value: value)
        }

        var street = SAFormField(value: "") { value in
            await SAFormValidationRules()
                .string()
                .notEmpty()
                .min(min: 5)
                .validate(value: value)
        }

        var zipCode = SAFormField(value: "") { value in
            await SAFormValidationRules()
                .string()
                .notEmpty()
                .regex(pattern: #/^\d{5}$/#)
                .validate(value: value)
        }
    }

    struct Payment: SAFormGroup {
        var cardHolder = SAFormField(value: "") { value in
            await SAFormValidationRules()
                .string()
                .notEmpty()
                .validate(value: value)
        }

        var cardLast4 = SAFormField(value: "") { value in
            await SAFormValidationRules()
                .string()
                .regex(pattern: #/^\d{4}$/#)
                .validate(value: value)
        }
    }

    var customer = Customer()
    var delivery = Delivery()
    var payment = Payment()
}
```

With validated submit data you can access nested values:

```swift
form.handleSubmit { data in
    print("Customer:", data.customer.firstName, data.customer.email)
    print("Delivery:", data.delivery.city, data.delivery.street, data.delivery.zipCode)
    print("Payment:", data.payment.cardHolder, data.payment.cardLast4)
}
```

UI binding also uses nested key paths.
In `SAFormControllerView`, `key` points to nested fields the same way:

```swift
import SwiftUI

struct CheckoutView: View {
    @State private var form = SAForm(fields: CheckoutFields())

    var body: some View {
        VStack(spacing: 12) {
            SAFormView(formConfig: form) {
                // Customer group
                SAFormControllerView(formConfig: form, key: \.customer.firstName) { value, field in
                    TextField("First Name", text: value)
                    if let firstError = field.errors?.messages.first {
                        Text(firstError).foregroundStyle(.red)
                    }
                }

                SAFormControllerView(formConfig: form, key: \.customer.email) { value, field in
                    TextField("Email", text: value)
                    if let firstError = field.errors?.messages.first {
                        Text(firstError).foregroundStyle(.red)
                    }
                }

                // Delivery group
                SAFormControllerView(formConfig: form, key: \.delivery.city) { value, _ in
                    TextField("City", text: value)
                }

                SAFormControllerView(formConfig: form, key: \.delivery.street) { value, _ in
                    TextField("Street", text: value)
                }

                SAFormControllerView(formConfig: form, key: \.delivery.zipCode) { value, _ in
                    TextField("ZIP Code", text: value)
                }

                // Payment group
                SAFormControllerView(formConfig: form, key: \.payment.cardHolder) { value, _ in
                    TextField("Card Holder", text: value)
                }

                SAFormControllerView(formConfig: form, key: \.payment.cardLast4) { value, _ in
                    TextField("Card Last 4", text: value)
                }
            }

            Button(
                "Submit",
                action: form.handleSubmit { data in
                    print("Customer:", data.customer.firstName, data.customer.email)
                    print("Delivery:", data.delivery.city, data.delivery.street, data.delivery.zipCode)
                    print("Payment:", data.payment.cardHolder, data.payment.cardLast4)
                }
            )
        }
        .padding()
    }
}
```
