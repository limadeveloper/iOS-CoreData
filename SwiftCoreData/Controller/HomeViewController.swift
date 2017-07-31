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
    private var objects = [JediModel]()
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    // MARK: - Actions
    private func loadData() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        requests.request(from: Constants.Services.URLs.jedis!) { (data, error) in
            
            func finish() {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.updateUI()
                }
            }
            
            self.objects = Model.getData() ?? []
            
            guard let data = data, let model = Model.toObject(from: data) else { finish(); return }
            
            self.objects = model.jedis
            
            model.save()
            
            finish()
        }
    }
    
    private func updateUI() {
        navigationItem.title = "Home"
        print("objects: \(objects.count)")
    }
}
