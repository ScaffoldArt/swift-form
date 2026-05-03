# SAFormCollection <Badge type="tip" text="Class" />

`SAFormCollection<Item>` is a dynamic list container for repeated form sections.
Use it when your form has a variable number of items (for example, phone numbers, addresses, passengers).

`Item` must conform to `SAFormCollectionItem`.

## Constructors

```swift
init(_ items: [Item] = [])
init(_ itemFactory: @escaping () -> Item)
init(_ items: [Item], itemFactory: @escaping () -> Item)
```

- `items` - initial list.
- `itemFactory` - factory used for auto-growing indexed access and `add()`.

## Properties

| Property | Type | Description |
|---|---|---|
| `count` | `Int` | Number of items. |
| `isEmpty` | `Bool` | Whether collection is empty. |
| `indices` | `Array<Item>.Indices` | Valid indices range. |
| `items` | `[Item]` | Full storage access (get/set). |

## Subscript

```swift
subscript(index: Int) -> Item
```

- If index is out of current bounds and `itemFactory` exists, collection auto-appends items up to this index.
- If `itemFactory` is missing for this case, runtime precondition fails.

## Methods

- `add()` - appends `itemFactory()` item (requires factory).
- `add(_ item: Item)` - appends provided item.
- `insert(_ item: Item, at index: Int)` - inserts item when index is in `0...count`.
- `remove(at index: Int) -> Item?` - removes item at index and returns it; returns `nil` for invalid index.
- `removeAll()` - clears collection.
