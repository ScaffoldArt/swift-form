import Testing
@testable import FormCraft

@MainActor
@FormCraft
private struct CollectionFormFields: FormCraftFields {
    struct UserFields: FormCraftCollectionItem {
        var title = FormCraftField(value: "") { value in
            .success(value: value)
        }

        var description = FormCraftField(value: "") { value in
            .success(value: value)
        }
    }

    var users = FormCraftCollection { UserFields() }
}

@MainActor
struct FormCraftCollectionTests {
    @Test("collection add(): creates item via factory")
    func collectionAddUsesFactory() {
        let users = FormCraftCollection<CollectionFormFields.UserFields> { .init() }

        #expect(users.count == 0)
        users.add()
        #expect(users.count == 1)
        #expect(users[0].title.value == "")
    }

    @Test("collection set by index: auto-creates missing items")
    func collectionSetAutoCreatesItems() {
        let users = FormCraftCollection<CollectionFormFields.UserFields> { .init() }

        users[2] = .init()

        #expect(users.count == 3)
        #expect(users[0].title.value == "")
        #expect(users[1].description.value == "")
    }

    @Test("setDefaultValue: applies value for dynamic index and expands collection")
    func setDefaultValueAppliesForDynamicIndex() {
        let form = FormCraft(fields: CollectionFormFields())

        #expect(form.fields.users.count == 0)

        form.setDefaultValue(
            key: \.users[2].title,
            value: "from-server"
        )

        #expect(form.fields.users.count == 3)
        #expect(form.fields.users[2].title.value == "from-server")
        #expect(form.fields.users[2].title.defaultValue == "from-server")
        #expect(form.fields.users[2].title.isDirty == false)
        #expect(form.fields.users[2].title.errors == nil)
    }

    @Test("setDefaultValues: delegates to setDefaultValue")
    func setDefaultValuesDelegates() {
        let form = FormCraft(fields: CollectionFormFields())

        form.setDefaultValues(
            (\.users[1].title, "A"),
            (\.users[1].description, "B")
        )

        #expect(form.fields.users.count == 2)
        #expect(form.fields.users[1].title.value == "A")
        #expect(form.fields.users[1].title.defaultValue == "A")
        #expect(form.fields.users[1].description.value == "B")
        #expect(form.fields.users[1].description.defaultValue == "B")
        #expect(form.fields.users[1].title.isDirty == false)
        #expect(form.fields.users[1].description.isDirty == false)
    }
}
