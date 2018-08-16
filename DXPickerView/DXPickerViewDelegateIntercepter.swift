//
//  DXPickerViewDelegateIntercepter.swift
//  DXPickerViewDemo
//
//  Created by fashion on 2018/8/13.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

// intercepter 拦截器
class DXPickerViewDelegateIntercepter: NSObject,UICollectionViewDelegate {
    
    weak var pickerView: DXPickerView?
    weak var delegate: UIScrollViewDelegate?
    
    init(pickerView: DXPickerView, delegate: UIScrollViewDelegate?) {
        self.pickerView = pickerView
        self.delegate = delegate
    }
    
    // 将这个SEL转给其他对象的机会
    internal override func forwardingTarget(for aSelector: Selector) -> Any? {
        if pickerView!.responds(to: aSelector) {
            return pickerView
        } else if delegate != nil && delegate!.responds(to: aSelector) {
            return delegate
        } else {
            return nil
        }
    }
    
    // 用来检查对象是否实现了某函数
    // 此函数通常是不需要重载的，但是在动态实现了查找过程后，需要重载此函数让对外接口查找动态实现函数的时候返回YES，保证对外接口的行为统一
    internal override func responds(to aSelector: Selector) -> Bool {
        if pickerView!.responds(to: aSelector) {
            return true
        } else if delegate != nil && delegate!.responds(to: aSelector) {
            return true
        } else {
            return super.responds(to: aSelector)
        }
    }
    
}
