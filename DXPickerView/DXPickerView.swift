//
//  DXPickerView.swift
//  DXPickerViewDemo
//
//  Created by fashion on 2018/8/13.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class DXPickerView: UIView {

    // MARK: - Properties
    // MARK: Readwrite Properties
    /// Readwrite. Data source of picker view.
    public var dataSource: DXPickerViewDataSource?
    
    // 一般ViewController作为pickerView的代理,把pickerView所需要的数据传给pickerView
    
    /// Readwrite. Delegate of picker view.
    public weak var delegate: DXPickerViewDelegate? = nil {
        didSet(delegate) {
            self.intercepter.delegate = delegate
        }
    }
    
    /// Readwrite. A font which used in NOT selected cells.
    public lazy var font = UIFont.systemFont(ofSize: 20)
    
    /// Readwrite. A font which used in selected cells.
    public lazy var highlightedFont = UIFont.boldSystemFont(ofSize: 20)
    
    /// Readwrite. A color of the text on NOT selected cells.
    @IBInspectable public lazy var textColor: UIColor = UIColor.darkGray
    
    /// Readwrite. A color of the text on selected cells.
    @IBInspectable public lazy var highlightedTextColor: UIColor = UIColor.black
    
    /// Readwrite. A float value which indicates the spacing between cells.
    @IBInspectable public var interitemSpacing: CGFloat = 0.0
    
    /// Readwrite. The style of the picker view. See DXPickerViewStyle.
    public var pickerViewStyle = DXPickerViewStyle.wheel
    
    // perspective 观点
    /// Readwrite. A float value which determines the perspective representation which used when using DXPickerViewStyle.Wheel style.
    @IBInspectable public var viewDepth: CGFloat = 1000.0 {
        didSet {
            collectionView.layer.sublayerTransform = viewDepth > 0.0 ? {
                var transform = CATransform3DIdentity;
                transform.m34 = -1.0 / viewDepth;
                return transform;
                }() : CATransform3DIdentity;
        }
    }
    
    // 渐变图层用法示例
    /// Readwrite. A boolean value indicates whether the mask is disabled.
    @IBInspectable public var maskDisabled: Bool = false {
        didSet {
            collectionView.layer.mask = maskDisabled == true ? nil : {
                let maskLayer = CAGradientLayer()
                maskLayer.frame = collectionView.bounds
                maskLayer.colors = [
                    UIColor.clear.cgColor,
                    UIColor.black.cgColor,
                    UIColor.black.cgColor,
                    UIColor.clear.cgColor]
                maskLayer.locations = [0.0, 0.33, 0.66, 1.0]
                maskLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
                maskLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
                return maskLayer
                }()
        }
    }
    
    // MARK: Readonly Properties
    /// Readonly. Index of currently selected item.
    public private(set) var selectedItem: Int = 0
    
    /// Readonly. The point at which the origin of the content view is offset from the origin of the picker view.
    public var contentOffset: CGPoint {
        get {
            return collectionView.contentOffset
        }
    }
    
    // MARK: Private Properties
    /// Private. A UICollectionView which shows contents on cells.
    fileprivate var collectionView: UICollectionView!
    
    /// Private. An intercepter to hook UICollectionViewDelegate then throw it picker view and its delegate
    fileprivate var intercepter: DXPickerViewDelegateIntercepter!
    
    /// Private. A UICollectionViewFlowLayout used in picker view's collection view.
    fileprivate var collectionViewLayout: DXCollectionViewLayout {
        let layout = DXCollectionViewLayout()
        layout.delegate = self
        return layout
    }
    
    // MARK: - Functions
    // MARK: View Lifecycle
    /**
     Private. Initializes picker view's subviews and friends.
     */
    fileprivate func initialize() {
        
        collectionView?.removeFromSuperview()
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        // 快速减速 调整UIScrollView的滑动速度（适用于tableView、collectionView）
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        collectionView.dataSource = self
        collectionView.register(
            DXCollectionViewCell.self,
            forCellWithReuseIdentifier: NSStringFromClass(DXCollectionViewCell.self))
        addSubview(collectionView)
        
        intercepter = DXPickerViewDelegateIntercepter(pickerView: self, delegate: self.delegate)
        collectionView.delegate = intercepter
        
        //self.maskDisabled = self.maskDisabled == nil ? false : self.maskDisabled
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        self.initialize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    public required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    deinit {
        self.collectionView.delegate = nil
    }
    
    // MARK: Layout
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if dataSource != nil && dataSource!.numberOfItemsInPickerView(self) > 0 {
            collectionView.collectionViewLayout = collectionViewLayout
            scrollToItem(selectedItem, animated: false)
        }
        collectionView.layer.mask?.frame = collectionView.bounds
    }
    
    // 在AutoLayout中，它作为UIView的属性（不是语法上的属性），意思就是说我知道自己的大小，如果你没有为我指定大小，我就按照这个大小来
    // Intrinsic 固有的；内在的；本身的
    // 固有的大小
    open override var intrinsicContentSize : CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: max(self.font.lineHeight, self.highlightedFont.lineHeight))
    }
    
    // MARK: Calculation Functions
    
    /**
     Private. Used to calculate bounding size of given string with picker view's font and highlightedFont
     
     :param: string A NSString to calculate size
     :returns: A CGSize which contains given string just.
     */
    fileprivate func sizeForString(_ string: NSString) -> CGSize {
        let size = string.size(withAttributes: [NSAttributedStringKey.font: self.font])
        let highlightedSize = string.size(withAttributes: [NSAttributedStringKey.font: self.highlightedFont])
        // ceil(3.4) == 4
        // 如果参数是小数，则求最小的整数但不小于本身
        return CGSize(
            width: ceil(max(size.width, highlightedSize.width)),
            height: ceil(max(size.height, highlightedSize.height)))
    }
    
    /**
     Private. Used to calculate the x-coordinate of the content offset of specified item.
     
     :param: item An integer value which indicates the index of cell.
     :returns: An x-coordinate of the cell whose index is given one.
     */
    fileprivate func offsetForItem(_ item: Int) -> CGFloat {
        var offset: CGFloat = 0
        for i in 0 ..< item {
            let indexPath = IndexPath(item: i, section: 0)
            let cellSize = collectionView(
                collectionView,
                layout: collectionView.collectionViewLayout,
                sizeForItemAt: indexPath)
            offset += cellSize.width
        }
        
        let firstIndexPath = IndexPath(item: 0, section: 0)
        let firstSize = self.collectionView(
            collectionView,
            layout: collectionView.collectionViewLayout,
            sizeForItemAt: firstIndexPath)
        let selectedIndexPath = IndexPath(item: item, section: 0)
        let selectedSize = collectionView(
            collectionView,
            layout: collectionView.collectionViewLayout,
            sizeForItemAt: selectedIndexPath)
        offset -= (firstSize.width - selectedSize.width) / 2.0
        
        return offset
    }
    
    // MARK: View Controls
    /**
     Reload the picker view's contents and styles. Call this method always after any property is changed.
     */
    public func reloadData() {
        
        // 在需要改变这个值的时候调用：invalidateIntrinsicContentSize 方法，通知系统这个值改变了->就会调用 intrinsicContentSize : CGSize
        invalidateIntrinsicContentSize()
        
        /*
         当我们使用自己自定义的UICollectionView的时候，每当刷新数据调用reloadData()方法的时候：
         务必调用 collectionViewLayout.invalidateLayout()方法，不然可能会发生下面的错误
         UICollectionView received layout attributes for a cell with an index path that does not exist
         */
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        if dataSource != nil && dataSource!.numberOfItemsInPickerView(self) > 0 {
            selectItem(selectedItem, animated: false, notifySelection: false)
        }
    }
    
    /**
     Move to the cell whose index is given one without selection change.
     
     :param: item     An integer value which indicates the index of cell.
     :param: animated True if the scrolling should be animated, false if it should be immediate.
     */
    public func scrollToItem(_ item: Int, animated: Bool = false) {
        switch pickerViewStyle {
        case .flat:
            collectionView.scrollToItem(
                at: IndexPath(
                    item: item,
                    section: 0),
                at: .centeredHorizontally,
                animated: animated)
        case .wheel:
            collectionView.setContentOffset(
                CGPoint(
                    x: offsetForItem(item),
                    y: collectionView.contentOffset.y),
                animated: animated)
        }
    }
    
    /**
     Select a cell whose index is given one and move to it.
     
     :param: item     An integer value which indicates the index of cell.
     :param: animated True if the scrolling should be animated, false if it should be immediate.
     */
    public func selectItem(_ item: Int, animated: Bool = false) {
        selectItem(item, animated: animated, notifySelection: true)
    }
    
    /**
     Private. Select a cell whose index is given one and move to it, with specifying whether it calls delegate method.
     
     :param: item            An integer value which indicates the index of cell.
     :param: animated        True if the scrolling should be animated, false if it should be immediate.
     :param: notifySelection True if the delegate method should be called, false if not.
     */
    fileprivate func selectItem(_ item: Int, animated: Bool, notifySelection: Bool) {
        collectionView.selectItem(
            at: IndexPath(item: item, section: 0),
            animated: animated,
            scrollPosition: UICollectionViewScrollPosition())
        scrollToItem(item, animated: animated)
        selectedItem = item
        if notifySelection {
            delegate?.pickerView(self, didSelectItem: item)
        }
    }
    
    // MARK: Delegate Handling
    /**
     Private.
     */
    fileprivate func didEndScrolling() {
        switch pickerViewStyle {
        case .flat:
            let center = convert(collectionView.center, to: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: center) {
                selectItem(indexPath.item, animated: true, notifySelection: true)
            }
        case .wheel:
            guard let dataS = dataSource else { return }
            let numberOfItems = dataS.numberOfItemsInPickerView(self)
            for i in 0 ..< numberOfItems {
                let indexPath = IndexPath(item: i, section: 0)
                let cellSize = self.collectionView(
                   collectionView,
                    layout: collectionView.collectionViewLayout,
                    sizeForItemAt: indexPath)
                if offsetForItem(i) + cellSize.width / 2 > collectionView.contentOffset.x {
                    selectItem(i, animated: true, notifySelection: true)
                    break
                }
            }
 
        }
        
    }

}


// MARK: DXCollectionViewLayoutDelegate
extension DXPickerView : DXCollectionViewLayoutDelegate{
    func pickerViewStyleForCollectionViewLayout(_ layout: DXCollectionViewLayout) -> DXPickerViewStyle {
        return pickerViewStyle
    }
}

// MARK: UICollectionViewDataSource
extension DXPickerView : UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource != nil && dataSource!.numberOfItemsInPickerView(self) > 0 ? 1 : 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource != nil ? dataSource!.numberOfItemsInPickerView(self) : 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(DXCollectionViewCell.self), for: indexPath) as! DXCollectionViewCell
        
        guard let dataS = dataSource else { return cell }
  
        if let title = dataS.pickerView?(self, titleForItem: indexPath.item) {
            cell.label.text = title
            cell.label.textColor = self.textColor
            cell.label.highlightedTextColor = self.highlightedTextColor
            cell.label.font = self.font
            cell.font = self.font
            cell.highlightedFont = self.highlightedFont
            cell.label.bounds = CGRect(origin: CGPoint.zero, size: self.sizeForString(title as NSString))
            if let delegate = self.delegate {
                delegate.pickerView?(self, configureLabel: cell.label, forItem: indexPath.item)
                if let margin = delegate.pickerView?(self, marginForItem: indexPath.item) {
                    cell.label.frame = cell.label.frame.insetBy(dx: -margin.width, dy: -margin.height)
                }
            }
        } else if let image = dataS.pickerView?(self, imageForItem: indexPath.item) {
            cell.imageView.image = image
        }
        cell._selected = (indexPath.item == selectedItem)
        return cell
    }
}

 // MARK: UICollectionViewDelegate
extension DXPickerView : UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectItem(indexPath.item, animated: true)
    }
}
// MARK: UICollectionViewDelegateFlowLayout
extension DXPickerView : UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: self.interitemSpacing, height: collectionView.bounds.size.height)
        guard let dataS = dataSource else { return size }
        
        if let title = dataS.pickerView?(self, titleForItem: indexPath.item) {
            size.width += sizeForString(title as NSString).width
            if let margin = delegate?.pickerView?(self, marginForItem: indexPath.item) {
                size.width += margin.width * 2
            }
        } else if let image = dataS.pickerView?(self, imageForItem: indexPath.item) {
            size.width += image.size.width
        }
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let number = self.collectionView(collectionView, numberOfItemsInSection: section)
        let firstIndexPath = IndexPath(item: 0, section: section)
        let firstSize = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: firstIndexPath)
        let lastIndexPath = IndexPath(item: number - 1, section: section)
        let lastSize = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: lastIndexPath)
        return UIEdgeInsetsMake(
            0, (collectionView.bounds.size.width - firstSize.width) / 2,
            0, (collectionView.bounds.size.width - lastSize.width) / 2
        )
    }
}

// MARK: UIScrollViewDelegate
extension DXPickerView : UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewDidEndDecelerating?(scrollView)
        self.didEndScrolling()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        if !decelerate {
            self.didEndScrolling()
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewDidScroll?(scrollView)
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.collectionView.layer.mask?.frame = self.collectionView.bounds
        CATransaction.commit()
    }
}
