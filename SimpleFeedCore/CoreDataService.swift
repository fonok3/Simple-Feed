//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData

public final class CoreDataService: NSObject {
    public static let shared = CoreDataService(modelUrl: App.Persistence.modelUrl,
                                               kind: .sqLite(App.Persistence.storeUrl))

    private let modelUrl: URL
    private let kind: Kinds

    // MARK: - Creating a Container
    init(modelUrl: URL, kind: Kinds) {
        self.modelUrl = modelUrl
        self.kind = kind
    }

    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let model = NSManagedObjectModel(contentsOf: modelUrl) else {
            fatalError("Failed to load managed object model at '\(modelUrl)'.")
        }
        return model
    }()

    private lazy var persistentContainer: NSPersistentContainer = {
        try? migrateStoreIfNeeded()

        let container = NSPersistentContainer(name: App.Persistence.modelName, managedObjectModel: managedObjectModel)
        container.persistentStoreDescriptions = [kind.storeDescription]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
            }

            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
        return container
    }()

    // MARK: - Migrating the Persistent Store

    private let applicationDocumentsStoreUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent("SingleViewCoreData.sqlite")

    private func migrateStoreIfNeeded() throws {
        let hasApplicationGroupStore = FileManager.default.fileExists(atPath: App.Persistence.storeUrl.path)
        guard !hasApplicationGroupStore else { return }

        if hasStore(at: applicationDocumentsStoreUrl) {
            try migrateStore(from: applicationDocumentsStoreUrl, to: App.Persistence.storeUrl)
        }
    }

    private func hasStore(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }

    private func migrateStore(from sourceUrl: URL, to destinationUrl: URL) throws {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let store = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sourceUrl, options: [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true,
        ])
        try coordinator.migratePersistentStore(store, to: destinationUrl, options: nil, withType: NSSQLiteStoreType)
    }

    // MARK: - Access context

    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    public func performBackgroundTask(task: @escaping (NSManagedObjectContext) -> Void) {
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        taskContext.automaticallyMergesChangesFromParent = true
        taskContext.performAndWait {
            task(taskContext)
            do {
                try taskContext.saveAndWaitWhenChanged()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    public func fetchData<T: NSManagedObject>(predicate: NSPredicate? = nil,
                                              sortDescriptors: [NSSortDescriptor]? = nil,
                                              limit: Int? = nil,
                                              curContext: NSManagedObjectContext? = nil) -> [T] {
        let context = curContext ?? viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: T.self))

        if limit != nil {
            request.fetchLimit = limit!
        }

        if predicate != nil {
            request.predicate = predicate
        }
        if sortDescriptors != nil {
            request.sortDescriptors = sortDescriptors
        }
        var items = [T]()
        do {
            items = try context.fetch(request) as? [T] ?? [T]()
        } catch {}

        return items
    }
}

public extension NSManagedObjectContext {
    func saveAndWaitWhenChanged() throws {
        guard hasChanges else { return }

        do {
            try save()
        } catch {
            let error = error as NSError
            print(error.code)
            print(error.localizedDescription)
            print(error.userInfo)
            throw error
        }
    }

    func performTask(task: @escaping (NSManagedObjectContext) -> Void) {
        performAndWait {
            task(self)
            do {
                try self.saveAndWaitWhenChanged()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension CoreDataService {
    enum Kinds {
        case inMemory
        case sqLite(URL)

        var storeDescription: NSPersistentStoreDescription {
            switch self {
            case .inMemory:
                let description = NSPersistentStoreDescription()
                description.type = NSInMemoryStoreType
                return description
            case let .sqLite(url):
                let description = NSPersistentStoreDescription(url: url)
                description.type = NSSQLiteStoreType
                return description
            }
        }
    }
}
