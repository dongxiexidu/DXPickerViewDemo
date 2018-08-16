//
//  DXCollectionViewLayout.swift
//  DXPickerViewDemo
//
//  Created by fashion on 2018/8/13.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class DXCollectionViewLayout: UICollectionViewFlowLayout {
    
    // pickerView作为它的代理
    var delegate: DXCollectionViewLayoutDelegate!
    var width: CGFloat!
    var midX: CGFloat!
    var maxAngle: CGFloat!
    
    func initialize() {
        sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        scrollDirection = .horizontal
        minimumLineSpacing = 0.0
    }
    
    override init() {
        super.init()
        initialize()
    }
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    internal override func prepare() {
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        midX = visibleRect.midX;
        width = visibleRect.width / 2;
        maxAngle = CGFloat.pi*2;
    }
    
    /*!
     *  多次调用 只要滑出范围就会 调用
     *  当CollectionView的显示范围发生改变的时候，是否重新发生布局
     *  一旦重新刷新 布局，就会重新调用
     *  1.layoutAttributesForElementsInRect：方法
     *  2.preparelayout方法
     */
    internal override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    internal override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes {
            
            switch delegate.pickerViewStyleForCollectionViewLayout(self) {
            case .flat:
                return attributes
                // 3d效果处理
            case .wheel:
                let distance = attributes.frame.midX - self.midX;
                let currentAngle = self.maxAngle * distance / self.width / CGFloat.pi*2
                var transform = CATransform3DIdentity;
                transform = CATransform3DTranslate(transform, -distance, 0, -self.width);
                transform = CATransform3DRotate(transform, currentAngle, 0, 1, 0);
                transform = CATransform3DTranslate(transform, 0, 0, self.width);
                attributes.transform3D = transform;
                attributes.alpha = fabs(currentAngle) < self.maxAngle ? 1.0 : 0.0;
                return attributes;
            }
        }
        
        return nil
    }
    
    /**
     *  这个方法的返回值是一个数组(数组里存放在rect范围内所有元素的布局属性)
     *  这个方法的返回值  决定了rect范围内所有元素的排布（frame）
     */
    private func layoutAttributesForElementsInRect(_ rect: CGRect) -> [AnyObject]? {
        switch self.delegate.pickerViewStyleForCollectionViewLayout(self) {
        case .flat:
            return super.layoutAttributesForElements(in: rect)
        case .wheel:
            var attributes = [AnyObject]()
            if collectionView!.numberOfSections > 0 {
                for i in 0 ..< collectionView!.numberOfItems(inSection: 0) {
                    let indexPath = IndexPath(item: i, section: 0)
                    attributes.append(self.layoutAttributesForItem(at: indexPath)!)
                }
            }
            return attributes
        }
    }

}
