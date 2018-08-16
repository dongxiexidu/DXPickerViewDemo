//
//  DXPickerViewProtocal.swift
//  AKPickerView
//
//  Created by fashion on 2018/8/13.
//  Copyright © 2018年 Akio Yasui. All rights reserved.
//

import UIKit

/**
 Styles of AKPickerView.
 
 - Wheel: Style with 3D appearance like UIPickerView.
 - Flat:  Flat style.
 */
public enum DXPickerViewStyle {
    case wheel
    case flat
}

// MARK: - Protocols
// MARK: AKPickerViewDataSource
/**
 Protocols to specify the number and type of contents.
 */
@objc protocol DXPickerViewDataSource {
    func numberOfItemsInPickerView(_ pickerView: DXPickerView) -> Int
    @objc optional func pickerView(_ pickerView: DXPickerView, imageForItem item: Int) -> UIImage?
    @objc optional func pickerView(_ pickerView: DXPickerView, titleForItem item: Int) -> String?
}

// optional 这里不可以用分类实现可选,因为DXPickerViewDelegateIntercepter拦截器会对事件处理
//extension DXPickerViewDataSource{
//
//    func pickerView(_ pickerView: DXPickerView, titleForItem item: Int) -> String?{
//        return nil
//    }

//    func pickerView(_ pickerView: DXPickerView, imageForItem item: Int) -> UIImage?{
//        return nil
//    }
//}

// MARK: AKPickerViewDelegate
/**
 Protocols to specify the attitude when user selected an item,
 and customize the appearance of labels.
 */
@objc protocol DXPickerViewDelegate: UIScrollViewDelegate {
    @objc func pickerView(_ pickerView: DXPickerView, didSelectItem item: Int)
    @objc optional func pickerView(_ pickerView: DXPickerView, marginForItem item: Int) -> CGSize
    @objc optional func pickerView(_ pickerView: DXPickerView, configureLabel label: UILabel, forItem item: Int)
}
// optional
//extension DXPickerViewDelegate{
//    func pickerView(_ pickerView: DXPickerView, marginForItem item: Int) -> CGSize?{
//        return nil
//    }
//    func pickerView(_ pickerView: DXPickerView, configureLabel label: UILabel, forItem item: Int){
//
//    }
//}

// MARK: - Private Classes and Protocols
// MARK: AKCollectionViewLayoutDelegate
/**
 Private. Used to deliver the style of the picker.
 */
protocol DXCollectionViewLayoutDelegate {
    func pickerViewStyleForCollectionViewLayout(_ layout: DXCollectionViewLayout) -> DXPickerViewStyle
}
