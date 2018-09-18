//
//  StickyCollectionViewLayout.swift
//  Sticky
//
//  Created by Anca Julean on 12/07/2018.
//  Copyright © 2018 alarm.com. All rights reserved.
//

import UIKit

class StickyCollectionViewLayout: UICollectionViewLayout {
    public var numberOfColumns = 1
    public var shouldPinFirstColumn = true
    public var shouldPinFirstRow = true
    
    private var itemAttributes = [[UICollectionViewLayoutAttributes]]()
    private var itemsSize = [CGSize]()
    private var contentSize: CGSize = .zero
    
    override func prepare() {
        guard let collectionView = collectionView, collectionView.numberOfSections > 0 else { return }
        
        if itemAttributes.count != collectionView.numberOfSections {
            generateItemAttributes(collectionView: collectionView)
            return
        }
        
        for section in 0 ..< collectionView.numberOfSections {
            for item in 0 ..< collectionView.numberOfItems(inSection: section) {
                guard section != 0, item != 0 else { continue }
                
                if let attributes = layoutAttributesForItem(at: IndexPath(item: item, section: section)) {
                    if section == 0 {
                        var frame = attributes.frame
                        frame.origin.y = collectionView.contentOffset.y
                        attributes.frame = frame
                    }
                    
                    if item == 0 {
                        var frame = attributes.frame
                        frame.origin.x = collectionView.contentOffset.x
                        attributes.frame = frame
                    }
                }
            }
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributes[indexPath.section][indexPath.row]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        
        for section in 0 ..< (collectionView?.numberOfSections)! {
            for item in 0 ..< (collectionView?.numberOfItems(inSection: section))! {
                let layout = layoutAttributesForItem(at: IndexPath.init(item: item, section: section))
                if (section == 0 || item == 0) {
                    let col = collectionView
                    let contentOffset = col?.contentOffset
                    var origin = layout?.frame.origin
                    
                    if (item == 0) {
                        origin?.x = (contentOffset?.x)!
                        layout?.zIndex = 1022
                    }
                    
                    if section == 0 {
                        origin?.y = (contentOffset?.y)!
                        layout?.zIndex = 1023
                        if (item == 0) {
                            layout?.zIndex = 1024
                        }
                    }
                    layout?.frame = CGRect(origin: origin!, size: (layout?.frame.size)!)
                }
                attributes.append(layout!)
            }
        }
        
        return attributes
    }
    
    
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
}

extension StickyCollectionViewLayout {
    private func generateItemAttributes(collectionView: UICollectionView) {
        if itemsSize.count != numberOfColumns {
            calculateItemSizes()
        }
        
        var column = 0
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        var contentWidth: CGFloat = 0
        
        itemAttributes = []
        
        for section in 0 ..< collectionView.numberOfSections {
            var sectionAttributes: [UICollectionViewLayoutAttributes] = []
            
            for index in 0 ..< numberOfColumns {
                let itemSize = itemsSize[index]
                let indexPath = IndexPath(item: index, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height).integral
                
                //                // WE CHANGE THE zIndex VALUES HERE SO THAT THE CELLS COME ON TOP
                //                if section == 0 && index == 0 {
                //                    // First cell should be on top
                //                    attributes.zIndex = 1024
                //                } else if section == 0 || index == 0 {
                //                    // First row/column should be above other cells
                //                    attributes.zIndex = 1023
                //                }
                //
                //                if section == 0 {
                //                    var frame = attributes.frame
                //                    frame.origin.y = collectionView.contentOffset.y
                //                    attributes.frame = frame
                //                }
                //                if index == 0 {
                //                    var frame = attributes.frame
                //                    frame.origin.x = collectionView.contentOffset.x
                //                    attributes.frame = frame
                //                }
                
                sectionAttributes.append(attributes)
                xOffset += itemSize.width
                column += 1
                
                if column == numberOfColumns {
                    if xOffset > contentWidth {
                        contentWidth = xOffset
                    }
                    
                    column = 0
                    xOffset = 0
                    yOffset += itemSize.height
                }
            }
            
            itemAttributes.append(sectionAttributes)
        }
        
        if let attributes = itemAttributes.last?.last {
            contentSize = CGSize(width: contentWidth, height: attributes.frame.maxY)
        }
    }
    
    private func calculateItemSizes() {
        itemsSize = []
        
        for index in 0 ..< numberOfColumns {
            itemsSize.append(sizeForItemWithColumnIndex(index))
        }
    }
    
    private func sizeForItemWithColumnIndex(_ columnIndex: Int) -> CGSize {
        var text: NSString
        
        switch columnIndex {
        case 0:
            text = "MMM-99-YYYY"
            
        default:
            text = "1234"
        }
        
        let size: CGSize = text.size(withAttributes: [.font: UIFont.systemFont(ofSize: 14.0)])
        let width: CGFloat = size.width + 16
        return CGSize(width: width, height: 30)
    }
}

