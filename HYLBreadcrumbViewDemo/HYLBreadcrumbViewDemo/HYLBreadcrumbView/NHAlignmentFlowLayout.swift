//
//  NHAlignmentFlowLayout.swift
//
//  Created by HeYilei on 16/02/2016.
//  Copyright © 2016 lionhylra.com. All rights reserved.
//

import UIKit

@objc public enum NHAlignment:Int{
    case Justified, TopLeftAligned,BottomRightAligned
}

public class NHAlignmentFlowLayout: UICollectionViewFlowLayout {
    public var alignment:NHAlignment = .Justified
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?{
        guard let array = super.layoutAttributesForElementsInRect(rect) else{
            return nil
        }
        return array.map{
            attributes in
            var attributes = attributes
            if attributes.representedElementKind == nil {
                let indexPath = attributes.indexPath
                attributes = layoutAttributesForItemAtIndexPath(indexPath) ?? attributes
            }
            return attributes
        }
    }
    
    override public func layoutAttributesForItemAtIndexPath(indexPath:NSIndexPath) -> UICollectionViewLayoutAttributes?{
        let attributes:UICollectionViewLayoutAttributes?
        switch self.alignment {
        case .TopLeftAligned:
            if self.scrollDirection == .Vertical {
                attributes = layoutAttributesForLeftAlignmentForItemAtIndexPath(indexPath)
            }else{
                attributes = layoutAttributesForTopAlignmentForItemAtIndexPath(indexPath)
            }
        case .BottomRightAligned:
            if self.scrollDirection == .Vertical{
                attributes = layoutAttributesForRightAlignmentForItemAtIndexPath(indexPath)
            }else{
                attributes = layoutAttributesForBottomAlignmentForItemAtIndexPath(indexPath)
            }
        default:
            attributes = super.layoutAttributesForItemAtIndexPath(indexPath)?.copy() as! UICollectionViewLayoutAttributes?
        }
        return attributes
    }
    
    func layoutAttributesForLeftAlignmentForItemAtIndexPath(indexPath:NSIndexPath)->UICollectionViewLayoutAttributes?{
        guard let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)?.copy() as! UICollectionViewLayoutAttributes? else{
            return nil
        }
        
        if attributes.frame.origin.x <= self.sectionInset.left {
            return attributes
        }
        
        if indexPath.item == 0 {
            attributes.frame.origin.x = self.sectionInset.left
        }else{
            let previousIndexPath = NSIndexPath(forItem: indexPath.item - 1 , inSection: indexPath.section)
            let previousAttributs = layoutAttributesForLeftAlignmentForItemAtIndexPath(previousIndexPath)!
            if attributes.frame.origin.y > previousAttributs.frame.origin.y{
                attributes.frame.origin.x = self.sectionInset.left
            }else{
                attributes.frame.origin.x = CGRectGetMaxX(previousAttributs.frame) + self.minimumInteritemSpacingForSection(indexPath.section)
            }
        }
        return attributes
    }
    
    func layoutAttributesForTopAlignmentForItemAtIndexPath(indexPath:NSIndexPath)->UICollectionViewLayoutAttributes?{
        guard let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)?.copy() as! UICollectionViewLayoutAttributes? else{
            return nil
        }
        if attributes.frame.origin.y <= self.sectionInset.top {
            return attributes
        }
        
        if indexPath.item == 0 {
            attributes.frame.origin.y = self.sectionInset.top
        }else{
            let previousIndexPath = NSIndexPath(forItem: indexPath.item - 1 , inSection: indexPath.section)
            let previousAttributs = layoutAttributesForTopAlignmentForItemAtIndexPath(previousIndexPath)!
            if attributes.frame.origin.x > previousAttributs.frame.origin.x{
                attributes.frame.origin.y = self.sectionInset.top
            }else{
                attributes.frame.origin.y = CGRectGetMaxY(previousAttributs.frame) + self.minimumInteritemSpacingForSection(indexPath.section)
            }
        }
        return attributes
    }
    
    func layoutAttributesForRightAlignmentForItemAtIndexPath(indexPath:NSIndexPath)->UICollectionViewLayoutAttributes?{
        guard let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)?.copy() as! UICollectionViewLayoutAttributes? else{
            return nil
        }
        if CGRectGetMaxX(attributes.frame) >= self.collectionViewContentSize().width - self.sectionInset.right {
            return attributes
        }
        
        if indexPath.item == self.collectionView!.numberOfItemsInSection(indexPath.section) - 1 {
            attributes.frame.origin.x = self.collectionViewContentSize().width - self.sectionInset.right - attributes.frame.size.width
        }else{
            let nextIndexPath = NSIndexPath(forItem: indexPath.item + 1, inSection: indexPath.section)
            let nextAttributes = layoutAttributesForRightAlignmentForItemAtIndexPath(nextIndexPath)!
            
            if attributes.frame.origin.y < nextAttributes.frame.origin.y{
                attributes.frame.origin.x = self.collectionViewContentSize().width - self.sectionInset.right - attributes.frame.size.width
            }else{
                attributes.frame.origin.x = nextAttributes.frame.origin.x - self.minimumInteritemSpacingForSection(indexPath.section) - attributes.frame.size.width
            }
        }
        return attributes
    }
    
    func layoutAttributesForBottomAlignmentForItemAtIndexPath(indexPath:NSIndexPath)->UICollectionViewLayoutAttributes?{
        guard let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)?.copy() as! UICollectionViewLayoutAttributes? else{
            return nil
        }
        if CGRectGetMaxY(attributes.frame) >= self.collectionViewContentSize().height - self.sectionInset.left {
            return attributes
        }
        
        if indexPath.item == self.collectionView!.numberOfItemsInSection(indexPath.section) - 1 {
            attributes.frame.origin.y = self.collectionViewContentSize().height - self.sectionInset.bottom - attributes.frame.size.height
        }else{
            let nextIndexPath = NSIndexPath(forItem: indexPath.item + 1, inSection: indexPath.section)
            let nextAttributes = layoutAttributesForBottomAlignmentForItemAtIndexPath(nextIndexPath)!
            
            if attributes.frame.origin.x < nextAttributes.frame.origin.x{
                attributes.frame.origin.y = self.collectionViewContentSize().height - self.sectionInset.bottom - attributes.frame.size.height
            }else{
                attributes.frame.origin.y = nextAttributes.frame.origin.y - self.minimumInteritemSpacingForSection(indexPath.section) - attributes.frame.size.height
            }
        }
        return attributes
    }
    
    private func minimumInteritemSpacingForSection(section:Int)->CGFloat{
        if let spacing = (self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAtIndex: section){
            return spacing
        }else{
            return self.minimumInteritemSpacing
        }
    }
}
