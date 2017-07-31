//
//  Model.swift
//  SwiftCoreData
//
//  Created by John Lima on 27/07/17.
//  Copyright © 2017 limadeveloper. All rights reserved.
//

import Foundation
import CoreData

private var dataManager: DataManager!

struct Model: Codable {
    var jedis: [JediModel]
}

extension Model {
    struct Keys {
        static let jedis = "jedis"
    }
}

extension Model {
    
    func toJSON() -> JSON {
        var json = JSON()
        json[Keys.jedis] = self.jedis.count > 0 ? JediModel.toJSON(array: self.jedis) : []
        return json
    }
    
    static func toObject(from: Data) -> Model? {
        let decoder = JSONDecoder()
        let object = try? decoder.decode(Model.self, from: from)
        return object
    }
    
    static func toObject(from: JSON) -> Model? {
        guard let data = try? JSONSerialization.data(withJSONObject: from, options: .prettyPrinted) else { return nil }
        guard let object = toObject(from: data) else { return  nil }
        return object
    }
}

extension Model {
    
    static func getData() -> [JediModel]? {
        return JediModel.getData().data
    }
    
    func save() {
        guard self.jedis.count > 0 else { return }
        for jedi in self.jedis {
            jedi.saveJedi { (error) in
                guard error == nil, jedi.species.count > 0 else { return }
                for specie in jedi.species {
                    specie.saveSpecie(with: jedi.id)
                }
            }
        }
    }
    
    func delete() {
        guard self.jedis.count > 0 else { return }
        for jedi in self.jedis {
            let error = jedi.delete()
            if let error = error {
                print("Delete the jedi error: \(error)")
            }else {
                if jedi.species.count > 0 {
                    for specie in jedi.species {
                        specie.deleteSpecie()
                    }
                }
            }
        }
    }
}
