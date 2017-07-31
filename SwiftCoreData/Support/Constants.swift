//
//  Constants.swift
//  SwiftCoreData
//
//  Created by John Lima on 27/07/17.
//  Copyright © 2017 limadeveloper. All rights reserved.
//

import UIKit
import Foundation

typealias JSON = [String: Any]

struct Constants {
    
    struct Services {
        struct URLs {
            static let jedis = URL(string: "http://jlimadeveloper.com/files/json/jedi.json")
        }
    }
    
    struct Color {
        static let dark = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
}
