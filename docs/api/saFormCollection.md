---
pageClass: api-reference-page
---

# SAFormCollection <Badge type="tip" text="Class" />

Use `SAFormCollection` to store a dynamic list of repeated form sections.
Collections are useful when users can add, remove, or edit multiple items with the same fields, such as emergency contacts, dependents, invoice rows, or delivery stops.
Each item keeps typed access to its nested fields while the collection manages the dynamic list.

::: warning
`SAFormCollectionItem` must be declared inside a type annotated with `@SAForm`.
If you declare the item somewhere else and then use it inside the `@SAForm` type, the generated form accessors will not work.
:::

```swift
init(_ items: [Item] = [])
init(_ itemFactory: @escaping () -> Item)
init(_ items: [Item], itemFactory: @escaping () -> Item)
```

#### Parameters

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `items` | Initial collection items. | `[Item]` | `[]` |
| `itemFactory` | Factory used by `add()` and indexed access beyond the current count. | `() -> Item` | None |

## Properties

Properties available on the `SAFormCollection` instance.

| Name | Description | Type |
| --- | --- | --- |
| `count` | Number of items. | `Int` |
| `isEmpty` | `true` when the collection has no items. | `Bool` |
| `indices` | Valid item indices. | `Array<Item>.Indices` |
| `items` | Current item storage. | `[Item]` |

## Subscript

### subscript

Accesses an item by index.

```swift
subscript(index: Int) -> Item
```

#### Parameters

| Name | Description | Type |
| --- | --- | --- |
| `index` | Item index. | `Int` |

#### Example

```swift
let firstPhone = form.fields.emergencyContacts[0].phone.value
```

## Methods

Use these methods to update collection items.

### add

Appends an item created by the configured factory.

```swift
func add()
```

#### Example

```swift
form.fields.emergencyContacts.add()
```

### add

Appends the provided item.

```swift
func add(_ item: Item)
```

#### Parameters

| Name | Description | Type |
| --- | --- | --- |
| `item` | Item to append. | `Item` |

### insert

Inserts an item at an index.

```swift
func insert(_ item: Item, at index: Int)
```

#### Parameters

| Name | Description | Type |
| --- | --- | --- |
| `item` | Item to insert. | `Item` |
| `index` | Insert index. | `Int` |

### remove

Removes an item at an index.

```swift
func remove(at index: Int) -> Item?
```

#### Parameters

| Name | Description | Type |
| --- | --- | --- |
| `index` | Item index. | `Int` |

#### Returns

| Description | Type |
| --- | --- |
| Removed item, or `nil` when the index is invalid. | `Item?` |

### removeAll

Removes all items.

```swift
func removeAll()
```

## Example

Create a profile form where the user can add several emergency contacts.

```swift{21}
import SwiftUI

@SAForm
private struct ProfileFields: SAFormFields {
    struct EmergencyContact: SAFormCollectionItem {
        var name = SAFormField(value: "") { value in
            await SAFormValidationRules()
                .string()
                .notEmpty()
                .validate(value: value)
        }

        var phone = SAFormField(value: "") { value in
            await SAFormValidationRules()
                .string()
                .notEmpty()
                .validate(value: value)
        }
    }

    var emergencyContacts = SAFormCollection { EmergencyContact() }
}

struct ProfileView: View {
    @State private var form = SAForm(fields: ProfileFields())

    var body: some View {
        SAFormView(formConfig: form) {
            VStack(spacing: 12) {
                ForEach(form.fields.emergencyContacts.indices, id: \.self) { index in
                    VStack(spacing: 8) {
                        SAFormControllerView(formConfig: form, key: \.emergencyContacts[index].name) { value, field in
                            TextField("Contact Name", text: value)

                            if let firstError = field.errors?.messages.first {
                                Text(firstError)
                                    .foregroundStyle(.red)
                            }
                        }

                        SAFormControllerView(formConfig: form, key: \.emergencyContacts[index].phone) { value, field in
                            TextField("Phone", text: value)

                            if let firstError = field.errors?.messages.first {
                                Text(firstError)
                                    .foregroundStyle(.red)
                            }
                        }

                        Button("Remove Contact") {
                            form.fields.emergencyContacts.remove(at: index)
                        }
                    }
                }

                Button("Add Contact") {
                    form.fields.emergencyContacts.add()
                }

                Button("Save Profile", action: form.handleSubmit { data in
                    let contacts = data.emergencyContacts

                    await saveProfile(emergencyContacts: contacts)
                })
                .disabled(form.formState.isSubmitting)
            }
        }
    }
}
```
