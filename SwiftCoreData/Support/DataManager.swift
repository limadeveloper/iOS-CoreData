//
//  DataManager.swift
//  SwiftCoreData
//
//  Created by John Lima on 27/07/17.
//  Copyright © 2017 limadeveloper. All rights reserved.
//

import Foundation
import CoreData

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
