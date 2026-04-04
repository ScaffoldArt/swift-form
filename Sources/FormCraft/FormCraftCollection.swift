import SwiftUI

@MainActor
public protocol FormCraftCollectionItem {}

@MainActor
@Observable
public final class FormCraftCollection<Item: FormCraftCollectionItem> {
    private var storage: [Item]
    private let itemFactory: (() -> Item)?

    public init(
        _ items: [Item] = []
    ) {
        self.storage = items
        self.itemFactory = nil
    }

    public init(
        _ itemFactory: @escaping () -> Item
    ) {
        self.storage = []
        self.itemFactory = itemFactory
    }

    public init(
        _ items: [Item],
        itemFactory: @escaping () -> Item
    ) {
        self.storage = items
        self.itemFactory = itemFactory
    }

    public var count: Int {
        storage.count
    }

    public var isEmpty: Bool {
        storage.isEmpty
    }

    public var indices: Array<Item>.Indices {
        storage.indices
    }

    public var items: [Item] {
        get { storage }
        set { storage = newValue }
    }

    public subscript(index: Int) -> Item {
        get {
            ensureIndexExists(index)
            return storage[index]
        }
        _modify {
            ensureIndexExists(index)
            yield &storage[index]
        }
        set {
            ensureIndexExists(index)
            storage[index] = newValue
        }
    }

    public func add() {
        storage.append(makeItem())
    }

    public func add(_ item: Item) {
        storage.append(item)
    }

    public func insert(_ item: Item, at index: Int) {
        guard index >= 0, index <= storage.count else {
            return
        }

        storage.insert(item, at: index)
    }

    @discardableResult
    public func remove(at index: Int) -> Item? {
        guard storage.indices.contains(index) else {
            return nil
        }

        return storage.remove(at: index)
    }

    public func removeAll() {
        storage.removeAll()
    }

    private func makeItem() -> Item {
        guard let itemFactory else {
            preconditionFailure(
                "FormCraftCollection: itemFactory is not configured. Use init(_ itemFactory:) or add(_ item:)."
            )
        }

        return itemFactory()
    }

    private func ensureIndexExists(_ index: Int) {
        precondition(index >= 0, "FormCraftCollection: index must be greater than or equal to 0.")

        while storage.count <= index {
            storage.append(makeItem())
        }
    }
}
