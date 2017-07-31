//
//  HomeCollectionViewCell.swift
//  SwiftCoreData
//
//  Created by John Lima on 31/07/17.
//  Copyright © 2017 limadeveloper. All rights reserved.
//

import UIKit
import AlamofireImage

class HomeCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var imageCoverView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var imageViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet private weak var titleLabelConstraintHeight: NSLayoutConstraint!
    
    private let requests = Requests()
    
    var jedi: JediModel? {
        didSet {
            
            guard let jedi = jedi else { return }
            
            titleLabel.text = jedi.name.uppercased()
            subtitleLabel.text = jedi.rank.uppercased()
            
            if let photoURL = URL(string: jedi.photo) {
                imageView.af_setImage(withURL: photoURL, placeholderImage: #imageLiteral(resourceName: "StarWarsPlaceholder"))
            }
            
            if let text = titleLabel.text {
                let titleHeight = CGFloat.heightWithConstrainedWidth(string: text, width: titleLabel.frame.size.width, font: titleLabel.font)
                titleLabelConstraintHeight.constant = titleHeight + 12
            }
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let featuredHeight = UltraVisualLayoutConstants.Cell.featuredHeight
        let standardHeight = UltraVisualLayoutConstants.Cell.standardHeight
        
        let delta = 1 - ((featuredHeight - frame.height) / (featuredHeight - standardHeight))
        
        let minAlpha: CGFloat = 0.3
        let maxAlpha: CGFloat = 0.75
        
        imageCoverView.alpha = maxAlpha - (delta * (maxAlpha - minAlpha))
        
        let scale = max(delta, 0.5)
        titleLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        subtitleLabel.alpha = delta
        
        imageViewConstraintHeight.constant = featuredHeight
    }
}
