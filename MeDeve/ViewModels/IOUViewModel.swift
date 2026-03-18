import Foundation
import CoreData
import Combine

final class IOUViewModel: ObservableObject {

    @Published var ious: [IOU] = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchIOUs()
    }

    // MARK: - Fetch

    func fetchIOUs() {
        let request: NSFetchRequest<IOU> = IOU.fetchRequest()
        request.predicate      = NSPredicate(format: "isPaid == NO")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \IOU.createdAt, ascending: false)]

        do {
            ious = try context.fetch(request)
        } catch {
            print("MeDeve — erro ao buscar IOUs: \(error)")
        }
    }

    // MARK: - Add

    func addIOU(personName: String, amount: Double, note: String) {
        let iou        = IOU(context: context)
        iou.id         = UUID()
        iou.personName = personName
        iou.amount     = amount
        iou.note       = note.trimmingCharacters(in: .whitespaces).isEmpty ? nil : note
        iou.createdAt  = Date()
        iou.isPaid     = false

        saveContext()
        HapticHelper.success()
    }

    // MARK: - Mark as paid

    func markAsPaid(_ iou: IOU) {
        iou.isPaid = true
        saveContext()
        HapticHelper.success()
    }

    // MARK: - Delete

    func delete(_ iou: IOU) {
        context.delete(iou)
        saveContext()
        HapticHelper.warning()
    }

    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            context.delete(ious[index])
        }
        saveContext()
        HapticHelper.warning()
    }

    // MARK: - Private

    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
            fetchIOUs()
        } catch {
            print("MeDeve — erro ao salvar: \(error)")
        }
    }
}
