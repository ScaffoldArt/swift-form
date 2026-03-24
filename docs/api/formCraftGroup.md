# FormCraftGroup <Badge type="tip" text="Protocol" />

::: warning
`FormCraftGroup` must be declared inside a struct annotated with `@FormCraft`.
:::

Use it when you want to split a large form into logical nested sections while keeping typed access.

Example:

```swift
@FormCraft
private struct CheckoutFields: FormCraftFields {
    struct Customer: FormCraftGroup {
        var firstName = FormCraftField(value: "") { value in
            await FormCraftValidationRules()
                .string()
                .notEmpty()
                .min(min: 2)
                .validate(value: value)
        }

        var email = FormCraftField(value: "") { value in
            await FormCraftValidationRules()
                .string()
                .notEmpty()
                .email()
                .validate(value: value)
        }
    }

    struct Delivery: FormCraftGroup {
        var city = FormCraftField(value: "") { value in
            await FormCraftValidationRules()
                .string()
                .notEmpty()
                .validate(value: value)
        }

        var street = FormCraftField(value: "") { value in
            await FormCraftValidationRules()
                .string()
                .notEmpty()
                .min(min: 5)
                .validate(value: value)
        }

        var zipCode = FormCraftField(value: "") { value in
            await FormCraftValidationRules()
                .string()
                .notEmpty()
                .regex(pattern: #/^\d{5}$/#)
                .validate(value: value)
        }
    }

    struct Payment: FormCraftGroup {
        var cardHolder = FormCraftField(value: "") { value in
            await FormCraftValidationRules()
                .string()
                .notEmpty()
                .validate(value: value)
        }

        var cardLast4 = FormCraftField(value: "") { value in
            await FormCraftValidationRules()
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
In `FormCraftControllerView`, `key` points to nested fields the same way:

```swift
import SwiftUI

struct CheckoutView: View {
    @State private var form = FormCraft(fields: CheckoutFields())

    var body: some View {
        VStack(spacing: 12) {
            FormCraftView(formConfig: form) {
                // Customer group
                FormCraftControllerView(formConfig: form, key: \.customer.firstName) { value, field in
                    TextField("First Name", text: value)
                    if let firstError = field.errors?.messages.first {
                        Text(firstError).foregroundStyle(.red)
                    }
                }

                FormCraftControllerView(formConfig: form, key: \.customer.email) { value, field in
                    TextField("Email", text: value)
                    if let firstError = field.errors?.messages.first {
                        Text(firstError).foregroundStyle(.red)
                    }
                }

                // Delivery group
                FormCraftControllerView(formConfig: form, key: \.delivery.city) { value, _ in
                    TextField("City", text: value)
                }

                FormCraftControllerView(formConfig: form, key: \.delivery.street) { value, _ in
                    TextField("Street", text: value)
                }

                FormCraftControllerView(formConfig: form, key: \.delivery.zipCode) { value, _ in
                    TextField("ZIP Code", text: value)
                }

                // Payment group
                FormCraftControllerView(formConfig: form, key: \.payment.cardHolder) { value, _ in
                    TextField("Card Holder", text: value)
                }

                FormCraftControllerView(formConfig: form, key: \.payment.cardLast4) { value, _ in
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
