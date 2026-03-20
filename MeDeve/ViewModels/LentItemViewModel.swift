import Foundation
import CoreData
import Combine

final class LentItemViewModel: ObservableObject {

    @Published var lentItems: [LentItem] = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchLentItems()
    }

    // MARK: - Fetch

    func fetchLentItems() {
        let request: NSFetchRequest<LentItem> = LentItem.fetchRequest()
        request.predicate       = NSPredicate(format: "isReturned == NO")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LentItem.createdAt, ascending: false)]

        do {
            lentItems = try context.fetch(request)
        } catch {
            print("MeDeve — erro ao buscar itens emprestados: \(error)")
        }
    }

    // MARK: - Add

    func addLentItem(personName: String, itemName: String, note: String) {
        let item        = LentItem(context: context)
        item.id         = UUID()
        item.personName = personName
        item.itemName   = itemName
        item.note       = note.trimmingCharacters(in: .whitespaces).isEmpty ? nil : note
        item.createdAt  = Date()
        item.isReturned = false

        saveContext()
        HapticHelper.success()
    }

    // MARK: - Mark as returned

    func markAsReturned(_ item: LentItem) {
        item.isReturned = true
        saveContext()
        HapticHelper.success()
    }

    // MARK: - Delete

    func delete(_ item: LentItem) {
        context.delete(item)
        saveContext()
        HapticHelper.warning()
    }

    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            context.delete(lentItems[index])
        }
        saveContext()
        HapticHelper.warning()
    }

    // MARK: - Private

    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
            fetchLentItems()
        } catch {
            print("MeDeve — erro ao salvar: \(error)")
        }
    }
}
