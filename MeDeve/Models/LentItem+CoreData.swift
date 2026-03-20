import Foundation
import CoreData

// MARK: - NSManagedObject subclass

@objc(LentItem)
public class LentItem: NSManagedObject {}

// MARK: - Managed properties

extension LentItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LentItem> {
        return NSFetchRequest<LentItem>(entityName: "LentItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var personName: String?
    @NSManaged public var itemName: String?
    @NSManaged public var note: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var isReturned: Bool
}

// MARK: - Computed helpers

extension LentItem {

    var wrappedPersonName: String { personName ?? "Desconhecido" }
    var wrappedItemName: String   { itemName ?? "" }
    var wrappedNote: String       { note ?? "" }
    var wrappedCreatedAt: Date    { createdAt ?? Date() }

    var daysSinceCreation: Int {
        Calendar.current.dateComponents([.day], from: wrappedCreatedAt, to: Date()).day ?? 0
    }

    var embarrassmentLevel: EmbarrassmentLevel {
        switch daysSinceCreation {
        case 0..<7:  return .recent
        case 7..<30: return .overdue
        default:     return .critical
        }
    }
}
