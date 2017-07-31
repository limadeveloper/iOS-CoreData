//
//  Requests.swift
//  SwiftCoreData
//
//  Created by John Lima on 27/07/17.
//  Copyright © 2017 limadeveloper. All rights reserved.
//

import Foundation

struct Requests {
    
    func request(from url: URL, completion: ((Data?, Error?) -> ())?) {
        
        let session = URLSession.shared
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else { completion?(nil, error); return }
            completion?(data, error)
            
        }.resume()
    }
}

extension Requests {
    
    struct Parser {
        
        /// Use this function to get dictionary or array from data
        ///
        /// - Parameter data: data to convert
        /// - Returns: data converted
        static func parseJson(data: Data) -> Any? {
            do {
                return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            }catch let error {
                print(error.localizedDescription)
            }
            return nil
        }
    }
}


