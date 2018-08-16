//
//  ViewController.swift
//  DXPickerViewDemo
//
//  Created by fashion on 2018/8/13.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let titles = ["Tokyo", "Kanagawa", "Osaka", "Aichi", "Saitama", "Chiba", "Hyogo", "Hokkaido", "Fukuoka", "Shizuoka"]
   // let titles = [#imageLiteral(resourceName: "Aichi"), #imageLiteral(resourceName: "Chiba"), #imageLiteral(resourceName: "Fukuoka"), #imageLiteral(resourceName: "Hokkaido"), #imageLiteral(resourceName: "Hyogo"), #imageLiteral(resourceName: "Kanagawa"), #imageLiteral(resourceName: "Osaka"), #imageLiteral(resourceName: "Saitama"), #imageLiteral(resourceName: "Shizuoka"), #imageLiteral(resourceName: "Tokyo")]
    @IBOutlet weak var pickerView: DXPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerView.font = UIFont(name: "HelveticaNeue-Light", size: 20)!
        pickerView.highlightedFont = UIFont(name: "HelveticaNeue", size: 20)!
        pickerView.pickerViewStyle = .wheel
        pickerView.maskDisabled = false
        pickerView.reloadData()
    }
}

extension ViewController : DXPickerViewDataSource {
    func numberOfItemsInPickerView(_ pickerView: DXPickerView) -> Int {
        return self.titles.count
    }

//    func pickerView(_ pickerView: DXPickerView, imageForItem item: Int) -> UIImage? {
//        return titles[item]
//    }
    
    func pickerView(_ pickerView: DXPickerView, titleForItem item: Int) -> String? {
        return self.titles[item]
    }
}
extension ViewController : DXPickerViewDelegate{
    func pickerView(_ pickerView: DXPickerView, didSelectItem item: Int) {
        print("Your favorite city is \(self.titles[item])")
    }
}
