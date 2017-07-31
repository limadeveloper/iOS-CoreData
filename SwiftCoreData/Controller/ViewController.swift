//
//  ViewController.swift
//  CoreData
//
//  Created by John Lima on 27/07/17.
//  Copyright © 2017 limadeveloper. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: - Properties
    private let requests = Requests()
    private var dataModel = [Model]()
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        updateUI()
    }
    
    // MARK: - Actions
    private func loadData() {
        
        requests.request(from: Constants.Services.URLs.jedis!) { (data, error) in
            guard let data = data else { return }
            guard let jedi = Model.toObject(from: data) else { return }
            
        }
    }
    
    private func updateUI() {
        navigationItem.title = "Home"
    }
}
