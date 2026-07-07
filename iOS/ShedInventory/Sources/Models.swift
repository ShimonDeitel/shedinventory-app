import Foundation

struct ShedInventoryItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var itemName: String
    var shelfLocation: String
    var notes: String
    var createdAt: Date = Date()
}
