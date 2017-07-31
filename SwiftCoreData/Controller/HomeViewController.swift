//
//  HomeController.swift
//  CoreData
//
//  Created by John Lima on 27/07/17.
//  Copyright © 2017 limadeveloper. All rights reserved.
//

import UIKit

class HomeController: UICollectionViewController {

    // MARK: - Properties
    private let requests = Requests()
    private var objects = [JediModel]()
    private let cellName = "cell"
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        loadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        
        navigationItem.title = "Jedis"
        
        view.backgroundColor = Constants.Color.dark
        
        collectionView?.backgroundColor = .clear
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView?.reloadData()
    }
}

// MARK: - ColletionView DataSource and Delegate
extension HomeController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as! HomeCollectionViewCell
        cell.jedi = objects[indexPath.row]
        return cell
    }
}
