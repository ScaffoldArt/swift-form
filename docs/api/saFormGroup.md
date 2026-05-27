---
pageClass: api-reference-page
---

# SAFormGroup <Badge type="tip" text="Protocol" />

Use `SAFormGroup` to define nested sections inside an `SAFormFields` type.
Groups are useful when a form has fields that naturally belong together, such as a shipping address, billing details, or profile section.
They keep large forms easier to read while preserving typed nested key paths for UI bindings, validation, errors, and submitted data.

::: warning
`SAFormGroup` must be declared inside a type annotated with `@SAForm`.
If you declare the group somewhere else and then use it inside the `@SAForm` type, the generated form accessors will not work.
:::

## Example

Create a complete checkout form with a nested shipping address section.

```swift{5}
import SwiftUI

@SAForm
private struct CheckoutFields: SAFormFields {
    struct ShippingAddress: SAFormGroup {
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

    var shippingAddress = ShippingAddress()
}

struct CheckoutView: View {
    @State private var form = SAForm(fields: CheckoutFields())

    var body: some View {
        SAFormView(formConfig: form) {
            VStack(spacing: 12) {
                SAFormControllerView(formConfig: form, key: \.shippingAddress.street) { value, field in
                    TextField("Street Address", text: value)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError)
                            .foregroundStyle(.red)
                    }
                }

                SAFormControllerView(formConfig: form, key: \.shippingAddress.city) { value, field in
                    TextField("City", text: value)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError)
                            .foregroundStyle(.red)
                    }
                }

                SAFormControllerView(formConfig: form, key: \.shippingAddress.postalCode) { value, field in
                    TextField("Postal Code", text: value)

                    if let firstError = field.errors?.messages.first {
                        Text(firstError)
                            .foregroundStyle(.red)
                    }
                }

                Button("Save Shipping Address", action: form.handleSubmit { data in
                    let street: String = data.shippingAddress.street
                    let city: String = data.shippingAddress.city
                    let postalCode: String = data.shippingAddress.postalCode

                    await saveShippingAddress(
                        street: street,
                        city: city,
                        postalCode: postalCode
                    )
                })
                .disabled(form.formState.isSubmitting)
            }
        }
    }
}
```
