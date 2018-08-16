//
//  DXCollectionViewCell.swift
//  DXPickerViewDemo
//
//  Created by fashion on 2018/8/13.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class DXCollectionViewCell: UICollectionViewCell {
    
    var label: UILabel!
    var imageView: UIImageView!
    var font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    var highlightedFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    var _selected: Bool = false {
        didSet(selected) {
            let animation = CATransition()
            animation.type = kCATransitionFade
            animation.duration = 0.15
            label.layer.add(animation, forKey: "")
            label.font = isSelected ? highlightedFont : font
        }
    }
/*
 UIViewAutoresizingFlexibleLeftMargin 自动调整与superView左边的距离，保证与superView右边的距离不变。
 UIViewAutoresizingFlexibleRightMargin 自动调整与superView的右边距离，保证与superView左边的距离不变。
 UIViewAutoresizingFlexibleTopMargin 自动调整与superView顶部的距离，保证与superView底部的距离不变。
 UIViewAutoresizingFlexibleBottomMargin 自动调整与superView底部的距离，也就是说，与superView顶部的距离不变。
     
 UIViewAutoresizingFlexibleWidth 自动调整自己的宽度，保证与superView左边和右边的距离不变。
 UIViewAutoresizingFlexibleHeight 自动调整自己的高度，保证与superView顶部和底部的距离不变。
 */
    
    func initialize() {
        
        // 当场景中不需要展示背面内容时，这个机制有可能让GPU绘制了无意义的内容，造成资源浪费。
        // CALayer的isDoubleSided属性来控制图层的背面是否要被绘制。
        // 默认为true，如果设置为false，将会取消背面的绘制工作。
        layer.isDoubleSided = false
        // 光栅化
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        label = UILabel(frame: contentView.bounds)
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.textColor = UIColor.gray
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.highlightedTextColor = UIColor.black
        label.font = font
        label.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
        contentView.addSubview(label)
        
        imageView = UIImageView(frame: contentView.bounds)
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .center
        
        // 自动调整自己的宽度，保证与superView左边和右边的距离不变
        // 自动调整自己的高度，保证与superView顶部和底部的距离不变
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(imageView)
    }
    
    init() {
        super.init(frame: CGRect.zero)
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
}
