//
//  UltraVisualLayout.swift
//  RWDevCon
//
//  Created by Mic Pringle on 27/02/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//
// https://www.raywenderlich.com/99087/swift-expanding-cells-ios-collection-views

import UIKit

/// The heights are declared as constants outside of the class so they can be easily referenced elsewhere
struct UltraVisualLayoutConstants {
    
    /**
     * standardHeight: The height of the non-featured cell
     * featuredHeight: The height of the first visible cell
     */
    struct Cell {
        static let standardHeight: CGFloat = 100
        static let featuredHeight: CGFloat = UIApplication.shared.keyWindow!.frame.size.height * 85 / 100
    }
}

class UltraVisualLayout: UICollectionViewLayout {
    
    // MARK: - Properties and Variables
    /// The amount the user needs to scroll before the featured cell changes
    let dragOffset: CGFloat = 180.0
    
    var cache = [UICollectionViewLayoutAttributes]()
    
    /// Returns the item index of the currently featured cell
    var featuredItemIndex: Int {
        get {
            guard let collectionView = collectionView else { return 0 }
            return max(0, Int(collectionView.contentOffset.y / dragOffset)) // Use max to make sure the featureItemIndex is never < 0
        }
    }
    
    /// Returns a value between 0 and 1 that represents how close the next cell is to becoming the featured cell
    var nextItemPercentageOffset: CGFloat {
        get {
            guard let collectionView = collectionView else { return 0 }
            return (collectionView.contentOffset.y / dragOffset) - CGFloat(featuredItemIndex)
        }
    }
    
    /// Returns the width of the collection view
    var width: CGFloat {
        get {
            guard let collectionView = collectionView else { return 0 }
            return collectionView.bounds.width
        }
    }
    
    /// Returns the height of the collection view
    var height: CGFloat {
        get {
            guard let collectionView = collectionView else { return 0 }
            return collectionView.bounds.height
        }
    }
    
    /// Returns the number of items in the collection view
    var numberOfItems: Int {
        get {
            guard let collectionView = collectionView else { return 0 }
            return collectionView.numberOfItems(inSection: 0)
        }
    }
    
    // MARK: - UICollectionViewLayout
    /// Return the size of all the content in the collection view
    override var collectionViewContentSize: CGSize {
        let contentHeight = (CGFloat(numberOfItems) * dragOffset) + (height - dragOffset)
        return CGSize(width: width, height: contentHeight)
    }
    
    override func prepare() {
        
        cache.removeAll(keepingCapacity: false)
        
        let standardHeight = UltraVisualLayoutConstants.Cell.standardHeight
        let featuredHeight = UltraVisualLayoutConstants.Cell.featuredHeight
        
        var frame = CGRect.zero
        var y: CGFloat = 0
        
        if #available(iOS 10.0, *) {
            collectionView?.isPrefetchingEnabled = false
        }
        
        for item in 0 ..< numberOfItems {
            
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            // Important because each cell has to slide over the top of the previous one
            attributes.zIndex = item
            
            /// Initially set the height of the cell to the standard height
            var height = standardHeight
            
            if indexPath.item == featuredItemIndex {
                
                guard let collectionView = collectionView else { continue }
                
                // The featured cell
                let yOffset = standardHeight * nextItemPercentageOffset
                y = collectionView.contentOffset.y - yOffset
                height = featuredHeight
                
            }else if indexPath.item == (featuredItemIndex + 1) && indexPath.item != numberOfItems {
                
                // The cell directly below the featured cell, which grows as the user scrolls
                let maxY = y + standardHeight
                
                height = standardHeight + max((featuredHeight - standardHeight) * nextItemPercentageOffset, 0)
                y = maxY - height
                
            }
            
            frame = CGRect(x: 0, y: y, width: width, height: height)
            attributes.frame = frame
            
            cache.append(attributes)
            
            y = frame.maxY
        }
    }
    
    
    /// Return all attributes in the cache whose frame intersects with the rect passed to the method
    ///
    /// - Parameter rect: CGRect
    /// - Returns: [UICollectionViewLayoutAttributes]?
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    
    /// Return the content offset of the nearest cell which achieves the nice snapping effect, similar to a paged UIScrollView
    ///
    /// - Parameters:
    ///   - proposedContentOffset: CGPoint
    ///   - velocity: CGPoint
    /// - Returns: CGPoint
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let itemIndex = round(proposedContentOffset.y / dragOffset)
        let yOffset = itemIndex * dragOffset
        return CGPoint(x: 0, y: yOffset)
    }
    
    
    /// Return true so that the layout is continuously invalidated as the user scrolls
    ///
    /// - Parameter newBounds: CGRect
    /// - Returns: Bool
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
