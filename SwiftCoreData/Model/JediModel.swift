//
//  JediModel.swift
//  SwiftCoreData
//
//  Created by John Lima on 28/07/17.
//  Copyright © 2017 limadeveloper. All rights reserved.
//

import Foundation
import CoreData

private var dataManager = DataManager()

struct JediModel: Codable {
    var id: Int
    var name: String
    var trainedBy: String
    var rank: String
    var holocronBio: String
    var photo: String
    var species: [SpecieModel]
}

extension JediModel {
    
    init?(jedi: Jedi) {
        
        id = Int(jedi.id)
        name = jedi.name ?? ""
        trainedBy = jedi.trainedBy ?? ""
        rank = jedi.rank ?? ""
        holocronBio = jedi.holocronBio ?? ""
        photo = jedi.photo ?? ""
        
        guard let species = jedi.species?.allObjects as? [Specie] else { return nil }
        
        var items = [SpecieModel]()
        
        for specie in species {
            let specieModel = SpecieModel(specie: specie)
            items.append(specieModel)
        }
        
        self.species = items
    }
}

extension JediModel {
    struct Keys {
        static let id = "id"
        static let name = "name"
        static let trainedBy = "trainedBy"
        static let rank = "rank"
        static let holocronBio = "holocronBio"
        static let photo = "photo"
        static let species = "species"
    }
}

extension JediModel {
    
    func toJSON() -> JSON {
        
        var json = JSON()
        
        json[Keys.id] = self.id
        json[Keys.name] = self.name
        json[Keys.trainedBy] = self.trainedBy
        json[Keys.rank] = self.rank
        json[Keys.holocronBio] = self.holocronBio
        json[Keys.photo] = self.photo
        json[Keys.species] = self.species.count > 0 ? SpecieModel.toJSON(array: self.species) : []
        
        return json
    }
    
    static func toJSON(array: [JediModel]) -> [JSON] {
        
        var result = [JSON]()
        
        for item in array {
            let json = item.toJSON()
            result.append(json)
        }
        
        return result
    }
}

extension JediModel {
    
    private func save(completion: ((String?)->())? = nil) {
        
        let error = "No possible to save the Jedi: Error(01)"
        
        guard let entity = dataManager.getManagedObject(type: .jedi) as? Jedi else { completion?(error); return }
        
        entity.id = Int32(self.id)
        entity.name = self.name
        entity.trainedBy = self.trainedBy
        entity.rank = self.rank
        entity.holocronBio = self.holocronBio
        entity.photo = self.photo
        
        dataManager.save(with: entity.managedObjectContext) { (error) in
            print("save jedi: \(error == nil)")
            completion?(error?.localizedDescription)
        }
    }
    
    private func update(data: [Jedi]) {
        for item in data {
            
            item.name = self.name
            item.trainedBy = self.trainedBy
            item.rank = self.rank
            item.holocronBio = self.holocronBio
            item.photo = self.photo
            
            dataManager.save(with: item.managedObjectContext) { (error) in
                print("update jedi: \(error == nil)")
            }
        }
    }
    
    func saveJedi(completion: ((String?)->())? = nil) {
        
        let predicate = dataManager.predicate(id: self.id, key: Keys.id, type: .Equal)
        let data = dataManager.getSavedData(from: .jedi, predicate: predicate)
        
        func save() {
            self.save(completion: completion)
        }
        
        if data.data == nil {
            save()
        }else {
            if var data = data.data as? [Jedi] {
                if predicate == nil {data = data.filter({ $0.id == self.id })}
                if data.count > 0 {
                    self.update(data: data)
                    completion?(nil)
                }else {save()}
            }else {save()}
        }
    }
    
    static func getData(param1: (value: Int, key: String, type: DataManager.PredicateType)? = nil, param2: (value: String, key: String, type: DataManager.PredicateType)? = nil) -> (data: [JediModel]?, error: String?) {
        
        var result: (data: [JediModel]?, error: String?) = (nil, "Jedi no found")
        var resultItems = [JediModel]()
        var predicate: NSPredicate?
        
        if let param1 = param1 {
            predicate = dataManager.predicate(id: param1.value, key: param1.key, type: param1.type)
        }else if let param2 = param2 {
            predicate = dataManager.predicate(value: param2.value, key: param2.key, type: param2.type)
        }
        
        let data = dataManager.getSavedData(from: .jedi, predicate: predicate)
        
        if let data = data.data as? [Jedi], data.count > 0 {

            for entity in data {
                guard let item = JediModel(jedi: entity) else { continue }
                resultItems.append(item)
            }
            
            if resultItems.count > 0 {
                result = (resultItems, nil)
            }
        }
        
        return result
    }
    
    func delete() -> Error? {
        return dataManager.delete(entity: .jedi)
    }
}
