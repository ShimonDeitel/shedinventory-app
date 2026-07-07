import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [ShedInventoryItem] = []
    @Published var isPro: Bool = false

    /// Free tier limit is intentionally well above seed data count so a fresh
    /// install never trips the paywall immediately.
    static let freeLimit = 15

    private let fileURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        fileURL = support.appendingPathComponent("shedinventory_items.json")
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([ShedInventoryItem].self, from: data) else {
            items = [
        ShedInventoryItem(itemName: "Cordless Drill", shelfLocation: "Shelf A1", notes: "18V, spare battery in drawer"),
        ShedInventoryItem(itemName: "Fertilizer Bags", shelfLocation: "Floor B2", notes: "3 bags left, buy more in spring"),
        ShedInventoryItem(itemName: "Garden Hose 50ft", shelfLocation: "Hook C1", notes: "Green, no leaks")
            ]
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    @discardableResult
    func add(_ item: ShedInventoryItem) -> Bool {
        guard canAddMore else { return false }
        items.insert(item, at: 0)
        save()
        return true
    }

    func update(_ item: ShedInventoryItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: ShedInventoryItem) {
        items.removeAll(where: { $0.id == item.id })
        save()
    }
}
