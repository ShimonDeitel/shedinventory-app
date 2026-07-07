import XCTest
@testable import ShedInventory

@MainActor
final class StoreTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
        store.items = []
        store.isPro = false
    }

    func testAddItem() {
        let item = ShedInventoryItem(itemName: "A", shelfLocation: "B", notes: "C")
        let added = store.add(item)
        XCTAssertTrue(added)
        XCTAssertEqual(store.items.count, 1)
    }

    func testFreeLimitBlocksAdd() {
        for i in 0..<Store.freeLimit {
            store.add(ShedInventoryItem(itemName: "\(i)", shelfLocation: "B", notes: "C"))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit)
        let blocked = store.add(ShedInventoryItem(itemName: "over", shelfLocation: "B", notes: "C"))
        XCTAssertFalse(blocked)
        XCTAssertEqual(store.items.count, Store.freeLimit)
    }

    func testProBypassesLimit() {
        store.isPro = true
        for i in 0..<(Store.freeLimit + 5) {
            store.add(ShedInventoryItem(itemName: "\(i)", shelfLocation: "B", notes: "C"))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit + 5)
    }

    func testDeleteItem() {
        let item = ShedInventoryItem(itemName: "A", shelfLocation: "B", notes: "C")
        store.add(item)
        store.delete(item)
        XCTAssertTrue(store.items.isEmpty)
    }

    func testUpdateItem() {
        var item = ShedInventoryItem(itemName: "A", shelfLocation: "B", notes: "C")
        store.add(item)
        item.itemName = "Updated"
        store.update(item)
        XCTAssertEqual(store.items.first?.itemName, "Updated")
    }

    func testCanAddMoreTrueInitially() {
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteAtOffsets() {
        store.add(ShedInventoryItem(itemName: "A", shelfLocation: "B", notes: "C"))
        store.add(ShedInventoryItem(itemName: "D", shelfLocation: "E", notes: "F"))
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.items.count, 1)
    }

    func testPersistenceRoundTrip() {
        store.add(ShedInventoryItem(itemName: "Persist", shelfLocation: "B", notes: "C"))
        let reloaded = Store()
        XCTAssertTrue(reloaded.items.contains(where: { $0.itemName == "Persist" }))
    }
}
