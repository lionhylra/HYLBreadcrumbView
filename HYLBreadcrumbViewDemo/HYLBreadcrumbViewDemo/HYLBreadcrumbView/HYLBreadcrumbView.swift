//
//  HYLBreadcrumbView.swift
//
//  Created by HeYilei on 15/02/2016.
//  Copyright © 2016 lionhylra.com. All rights reserved.
//

import UIKit

//let defaultRowHeight:CGFloat = 30.0
let defaultSeparatorWidth:CGFloat = 8.0


@objc public protocol HYLBreadcrumbViewDelegate:class, NSObjectProtocol {
//    optional func breadcrumbView(breadcrumbView:HYLBreadcrumbView, shouldSelectItemAtIndex index:Int) -> Bool
    optional func breadcrumbView(breadcrumbView:HYLBreadcrumbView, didSelectItemAtIndex index:Int)
    optional func minimumInterItemSpacingForBreadcrumbView(breadcrumbView: HYLBreadcrumbView) -> CGFloat
    optional func heightForRowInBreadcrumbView(breadcrumbView:HYLBreadcrumbView) -> CGFloat
    optional func widthForSeparatorViewInBreadcrumbView(breadcrumbView:HYLBreadcrumbView) -> CGFloat
}

@objc public protocol HYLBreadcrumbViewDataSource:class, NSObjectProtocol {
    func numberOfItemsInBreadcrumbView(breadcrumbView: HYLBreadcrumbView) -> Int
    func breadcrumbView(breadcrumbView:HYLBreadcrumbView, titleForItemAtIndex index:Int) -> String
    optional func breadcrumbView(breadcrumbView:HYLBreadcrumbView, separatorViewForItemAtIndex index:Int) -> UIView
}


public class HYLBreadcrumbView: UIView {
    // MARK: public properties
    @IBOutlet public weak var delegate:HYLBreadcrumbViewDelegate?
    @IBOutlet public weak var dataSource: HYLBreadcrumbViewDataSource?
    public var fontSize:CGFloat = UIFont.buttonFontSize()
    public var backgroundView:UIView? {
        get{
            return collectionView.backgroundView
        }
        set{
            collectionView.backgroundView = newValue
        }
    }
    public var separatorString:String? = "/"
    // MARK: private properties
    private lazy var collectionView: UICollectionView = {
        let layout = NHAlignmentFlowLayout()
        layout.scrollDirection = .Vertical
        layout.alignment = .TopLeftAligned
        layout.minimumInteritemSpacing = 0.0
        var collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    private var rowHeight:CGFloat {
        return delegate?.heightForRowInBreadcrumbView?(self) ?? UIFont.systemFontOfSize(fontSize).lineHeight
    }
    private var separatorWidth:CGFloat {
        if let width = delegate?.widthForSeparatorViewInBreadcrumbView?(self) {
            return width
        }else if let str = self.separatorString{
            return NSString(string: str).boundingRectWithSize(CGSize(width: CGFloat.max, height: CGFloat.max), options: [.UsesLineFragmentOrigin], attributes: [NSFontAttributeName:UIFont.systemFontOfSize(fontSize)], context: nil).size.width
        }
        return defaultSeparatorWidth
    }
    private var spaceBetweenTextAndSeparator:CGFloat {
        if let space = self.delegate?.minimumInterItemSpacingForBreadcrumbView?(self) {
            return space
        }else{
            return (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing
        }
    }
    
    // MARK: public methods
    override public func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = self.bounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        collectionView.registerClass(HYLBreadcrumbViewCell.self, forCellWithReuseIdentifier: "Cell")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(collectionView)
        collectionView.registerClass(HYLBreadcrumbViewCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    public func reloadData() {
        collectionView.reloadData()
    }
}

extension HYLBreadcrumbView:UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    // MARK: UICollectionViewDataSource
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfItemsInBreadcrumbView(self) ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! HYLBreadcrumbViewCell
        return cell
    }
        
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? HYLBreadcrumbViewCell, dataSource = self.dataSource else {
            return
        }
        
        /* configure button */
        let title = dataSource.breadcrumbView(self, titleForItemAtIndex: indexPath.item)
        cell.titleButton.setTitle(title, forState: .Normal)
        cell.titleButton.titleLabel?.font = UIFont.systemFontOfSize(fontSize)
        cell.titleButton.addTarget(self, action: "buttonItemTapped:", forControlEvents: .TouchUpInside)
        
        /* configure separator */
        if let label = cell.separatorView as? UILabel{
            label.font = UIFont.systemFontOfSize(fontSize)
            label.text = self.separatorString
        }
        if dataSource.respondsToSelector("breadcrumbView:seperatorViewForItenAtIndex:") {
            cell.separatorView = dataSource.breadcrumbView!(self, separatorViewForItemAtIndex: indexPath.item)
        }
        /* layout cell subviews */
        cell.titleButton.frame.origin = CGPoint(x: 0, y: 0)
        cell.titleButton.frame.size = (title as NSString).boundingRectWithSize(CGSize(width: 9999, height: rowHeight), options: [.UsesLineFragmentOrigin], attributes: [NSFontAttributeName:UIFont.systemFontOfSize(fontSize)], context: nil).size
        cell.titleButton.titleLabel?.frame = cell.titleButton.bounds
        cell.titleButton.frame.size.height = rowHeight
        if indexPath.item == collectionView.numberOfItemsInSection(indexPath.section) - 1 {
            cell.separatorView?.removeFromSuperview()
            cell.separatorView = nil
        }else if cell.separatorView != nil{
            cell.separatorView!.frame.origin = CGPoint(x: cell.titleButton.frame.width + spaceBetweenTextAndSeparator, y: 0)
            cell.separatorView!.frame.size = CGSize(width: separatorWidth, height: rowHeight)
        }
        
        cell.setNeedsLayout()
        cell.setNeedsDisplay()
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let dataSource = self.dataSource else {
            return CGSizeZero
        }

        /* calculate cell size dynamically */
        let height:CGFloat = rowHeight
        let separatorWidth:CGFloat = self.separatorWidth
        let title = dataSource.breadcrumbView(self, titleForItemAtIndex: indexPath.item)


        let textWidth = (title as NSString).boundingRectWithSize(CGSize(width: 9999, height: height), options: [.UsesLineFragmentOrigin], attributes: [NSFontAttributeName:UIFont.systemFontOfSize(fontSize)], context: nil).size.width
        if indexPath.item == collectionView.numberOfItemsInSection(indexPath.section) - 1 {
            return CGSize(width: textWidth, height: height)
        }else{
            return CGSize(width: textWidth + spaceBetweenTextAndSeparator + separatorWidth, height: height)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return delegate?.minimumInterItemSpacingForBreadcrumbView?(self) ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return delegate?.minimumInterItemSpacingForBreadcrumbView?(self) ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    // MARK: private method
    func buttonItemTapped(button:UIButton){
        guard let indexPath = button.indexPathInCollectionView(self.collectionView) else {
            return
        }
        self.delegate?.breadcrumbView?(self, didSelectItemAtIndex: indexPath.item)
    }
}

private class HYLBreadcrumbViewCell:UICollectionViewCell {
    let titleButton:UIButton
    var separatorView:UIView?
    override init(frame: CGRect) {
        titleButton = UIButton(type: .System)
        titleButton.titleLabel?.lineBreakMode = .ByClipping
        titleButton.titleLabel?.textAlignment = .Center
        let label = UILabel()
        label.text = "/"
        label.textAlignment = .Center
        label.lineBreakMode = .ByClipping
        separatorView = label
        super.init(frame: frame)
        self.contentView.addSubview(titleButton)
        self.contentView.addSubview(separatorView!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override private func prepareForReuse() {
        if self.separatorView == nil{
            let label = UILabel()
            label.text = "/"
            label.textAlignment = .Center
            label.lineBreakMode = .ByClipping
            separatorView = label
            self.contentView.addSubview(separatorView!)
        }
    }
}
