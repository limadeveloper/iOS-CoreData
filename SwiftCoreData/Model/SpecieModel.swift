//
//  SpecieModel.swift
//  SwiftCoreData
//
//  Created by John Lima on 28/07/17.
//  Copyright © 2017 limadeveloper. All rights reserved.
//

import Foundation
import CoreData

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
