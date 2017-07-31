//
//  CustomNavigationViewController.swift
//  CoreData
//
//  Created by John Lima on 27/07/17.
//  Copyright © 2017 limadeveloper. All rights reserved.
//

import UIKit

class CustomNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.tintColor = .purple
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.purple]
        
        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = true
            navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.purple]
        }
    }
}
