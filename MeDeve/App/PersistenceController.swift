import CoreData

struct PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MeDeve")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("CoreData falhou ao carregar: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Preview helper

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        let samples: [(String, Double, String, Int)] = [
            ("João Silva",  150.00, "Churrasco de sábado",   2),
            ("Ana Costa",    80.50, "Vaquinha do presente",  10),
            ("Pedro Matos",  35.00, "",                      40),
        ]

        for (name, amount, note, daysAgo) in samples {
            let iou = IOU(context: context)
            iou.id          = UUID()
            iou.personName  = name
            iou.amount      = amount
            iou.note        = note.isEmpty ? nil : note
            iou.createdAt   = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())
            iou.isPaid      = false
        }

        try? context.save()
        return controller
    }()
}
