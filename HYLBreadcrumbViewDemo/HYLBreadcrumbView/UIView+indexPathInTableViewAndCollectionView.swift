//
//  UIView.swift
//
//  Created by HeYilei on 16/02/2016.
//  Copyright © 2016 lionhylra. All rights reserved.
//

import UIKit

extension UIView {
    func indexPathInTableView(tableView:UITableView) -> NSIndexPath? {
        let point = self.convertPoint(CGPointZero, toView:tableView)
        return tableView.indexPathForRowAtPoint(point)
    }
    
    func indexPathInCollectionView(collectionView:UICollectionView) -> NSIndexPath? {
        let point = self.convertPoint(CGPointZero, toView: collectionView)
        return collectionView.indexPathForItemAtPoint(point)
    }

}
