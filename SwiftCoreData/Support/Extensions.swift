//
//  Extensions.swift
//  SwiftCoreData
//
//  Created by John Lima on 31/07/17.
//  Copyright © 2017 limadeveloper. All rights reserved.
//

import UIKit
import Foundation

extension CGFloat {
    static func heightWithConstrainedWidth(string: String, width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = string.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.height
    }
}
