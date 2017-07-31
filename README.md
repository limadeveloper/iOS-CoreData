# iOS CoreData Example
An example of CoreData in iOS
* Swift 4
* Xcode 9

## Xcode Data Model
 <p align="center">
    <img src="https://github.com/limadeveloper/iOS-CoreData/blob/master/docs/images/01.png" width="720">
</p><br>

<p align="center">
    <img src="https://github.com/limadeveloper/iOS-CoreData/blob/master/docs/images/02.png" width="720">
</p><br>

<p align="center">
    <img src="https://github.com/limadeveloper/iOS-CoreData/blob/master/docs/images/03.png" width="720">
</p><br>
 
## Data Manager
 ```
 struct DataManager {
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "SwiftCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    mutating func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            }catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension DataManager {
    
    enum Entity: String {
        case jedi = "Jedi"
        case specie = "Specie"
    }
    
    enum PredicateType: String {
        case Equal = "=="
        case Different = "<>"
        case AND = "AND"
    }
}

extension DataManager {
    
    mutating func getManagedObject(type: Entity) -> Any? {
        let context = persistentContainer.viewContext
        let entity = NSEntityDescription.insertNewObject(forEntityName: type.rawValue, into: context)
        return entity
    }
    
    func save(with context: NSManagedObjectContext?, completion: ((Error?)->())? = nil) {
        context?.performAndWait {
            do {
                try context?.save()
                completion?(nil)
            }catch {
                completion?(error)
            }
        }
    }
    
    mutating func getSavedData(from entity: Entity, predicate: NSPredicate? = nil) -> (data: [Any]?, error: String?) {
        
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        
        fetchRequest.predicate = predicate
        
        do {
            let results = try context.fetch(fetchRequest)
            return (results.count > 0 ? results : nil, nil)
        }catch {
            return (nil, error.localizedDescription)
        }
    }
    
    mutating func delete(entity: Entity, predicate: NSPredicate? = nil) -> Error? {
        
        let context = persistentContainer.viewContext
        let coordinator = persistentContainer.persistentStoreCoordinator
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        fetchRequest.predicate = predicate
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coordinator.execute(deleteRequest, with: context)
            return nil
        }catch {
            return error
        }
    }
    
    func predicate(id: Int?, key: String, type: PredicateType) -> NSPredicate? {
        guard let id = id else { return nil }
        return NSPredicate(format: "\(key) \(type.rawValue) %d", id)
    }
    
    func predicate(value: String?, key: String, type: PredicateType) -> NSPredicate? {
        guard let value = value, !value.isEmpty else { return NSPredicate(format: "\(key) \(type.rawValue) nil") }
        return NSPredicate(format: "\(key) \(type.rawValue) %@", value)
    }
}
 ```
 
## Model Example
```
private var dataManager = DataManager()

struct SpecieModel: Codable {
    var id: Int
    var name: String
}

extension SpecieModel {
    init(specie: Specie) {
        id = Int(specie.id)
        name = specie.name ?? ""
    }
}

extension SpecieModel {
    struct Keys {
        static let id = "id"
        static let name = "name"
        static let jedi = "jedi"
    }
}

extension SpecieModel {
    
    func toJSON() -> JSON {
        var json = JSON()
        json[Keys.id] = self.id
        json[Keys.name] = self.name
        return json
    }
    
    static func toJSON(array: [SpecieModel]) -> [JSON] {
        var result = [JSON]()
        for item in array {
            let json = item.toJSON()
            result.append(json)
        }
        return result
    }
}

extension SpecieModel {
    
    private func save(with jedi: Jedi, completion: ((String?)->())? = nil) {
        
        let error = "No possible to save the Specie: Error(01)"
        
        guard let entity = dataManager.getManagedObject(type: .specie) as? Specie else { completion?(error); return }
        entity.id = Int32(self.id)
        entity.name = self.name
        entity.jedi = jedi
        
        dataManager.save(with: entity.managedObjectContext) { (error) in
            print("save specie: \(error == nil)")
            completion?(error?.localizedDescription)
        }
    }
    
    private func update(data: [Specie]) {
        for item in data {
            
            item.id = Int32(self.id)
            item.name = self.name
            
            dataManager.save(with: item.managedObjectContext) { (error) in
                print("update specie: \(error == nil)")
            }
        }
    }
    
    func saveSpecie(with jediId: Int, completion: ((String?)->())? = nil) {
        
        let predicate = dataManager.predicate(id: self.id, key: Keys.id, type: .Equal)
        let data = dataManager.getSavedData(from: .specie, predicate: predicate)
        
        func save() {
            guard let jedi = (dataManager.getSavedData(from: .jedi).data as? [Jedi])?.filter({ $0.id == Int32(jediId) }).first else { return }
            self.save(with: jedi, completion: completion)
        }
        
        if data.data == nil {
            save()
        }else {
            if var data = data.data as? [Specie] {
                if predicate == nil {data = data.filter({ $0.id == self.id })}
                if data.count > 0 {
                    self.update(data: data)
                    completion?(nil)
                }else {save()}
            }else {save()}
        }
    }
    
    func getData(param1: (value: Int, key: String, type: DataManager.PredicateType)? = nil, param2: (value: String, key: String, type: DataManager.PredicateType)? = nil) -> (data: [SpecieModel]?, error: String?) {
        
        var result: (data: [SpecieModel]?, error: String?) = (nil, "Specie no found")
        var resultItems = [SpecieModel]()
        var predicate: NSPredicate?
        
        if let param1 = param1 {
            predicate = dataManager.predicate(id: param1.value, key: param1.key, type: param1.type)
        }else if let param2 = param2 {
            predicate = dataManager.predicate(value: param2.value, key: param2.key, type: param2.type)
        }
        
        let data = dataManager.getSavedData(from: .specie, predicate: predicate)
        
        if let data = data.data as? [Specie], data.count > 0 {
            
            for entity in data {
                let item = SpecieModel(specie: entity)
                resultItems.append(item)
            }
            
            if resultItems.count > 0 {
                result = (resultItems, nil)
            }
        }
        
        return result
    }
    
    func delete() -> Error? {
        return dataManager.delete(entity: .specie)
    }
    
    func deleteSpecie() {
        let _ = dataManager.delete(entity: .specie)
    }
}
```

## Demo
 <p align="center">
    <img src="https://github.com/limadeveloper/iOS-CoreData/blob/master/docs/images/04.png" width="375">
</p><br>

<p align="center">
    <img src="https://github.com/limadeveloper/iOS-CoreData/blob/master/docs/images/05.png" width="375">
</p><br>

## Dependencies
* AlamofireImage
* UltraVisualLayout