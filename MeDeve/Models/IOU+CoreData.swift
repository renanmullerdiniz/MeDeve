import Foundation
import CoreData

// MARK: - NSManagedObject subclass

@objc(IOU)
public class IOU: NSManagedObject {}

// MARK: - Managed properties

extension IOU {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IOU> {
        return NSFetchRequest<IOU>(entityName: "IOU")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var personName: String?
    @NSManaged public var amount: Double
    @NSManaged public var note: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var isPaid: Bool
}

// MARK: - Computed helpers

extension IOU {

    var wrappedPersonName: String { personName ?? "Desconhecido" }
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

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle    = .currency
        formatter.locale         = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: amount)) ?? "R$ \(amount)"
    }
}

// MARK: - Embarrassment level

enum EmbarrassmentLevel {
    case recent   // verde  — menos de 7 dias
    case overdue  // amarelo — 7 a 29 dias
    case critical // vermelho — 30+ dias
}
