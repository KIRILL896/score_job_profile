//
//  ScrollContryCode.swift
//  imscored
//
//  Created by отмеченные on 24.03.2021.
//  Copyright © 2021 Winfox. All rights reserved.
//

import UIKit
import RxSwift


struct CodeModel {
    var code:String
    var image:String
    var contry:String
}


class ScrollContryCode: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
  fileprivate var pickerData:[String] = []

    
    
  fileprivate let selected:BehaviorSubject<CodeModel> = BehaviorSubject(value: CodeModel(code:"+7", image:"tn_rs-flag", contry:"Russia"))
  
 
    
    
  var disposeBag = DisposeBag()

  static let middleVal: Float = 5.5
  static let middleIndex: Int = 9
    
    
  let models:[CodeModel] = [
    CodeModel(code:"+7", image:"tn_rs-flag", contry:"Russia"),
    CodeModel(code:"+1", image:"tn_us-flag", contry:"Usa"),
    CodeModel(code:"+2", image:"tn_ca-flag", contry:"Canada")
  ]
    
    var selectedValue: Observable<CodeModel>!
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
    
    
  func setup() {
    self.delegate = self
    self.dataSource = self
    selectedValue = selected.asObservable()
    //self.selectRow(5, inComponent: 0, animated: true)
  }

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return models.count
  }


  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.selected.onNext(self.models[row])
  }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width - 30, height: 90))
        let model = self.models[row]
        myView.layer.opacity = 0.8
        myView.layer.cornerRadius = 5.0
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 25))
        imageView.image = UIImage(named: model.image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        let text = UILabel()
        text.font = .systemFont(ofSize: 19, weight: .medium)
        text.text = model.code + " " + model.contry//"Россия +7"
        text.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [imageView, text])
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .fill
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
    
        myView.addSubview(stack)
        stack.centerYAnchor.constraint(equalTo: myView.centerYAnchor).isActive = true
        stack.centerXAnchor.constraint(equalTo: myView.centerXAnchor).isActive = true
        return myView
    }
    
    /*
  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    var string:String = ""
    var res:NSAttributedString
    let attrs_blue = [NSAttributedString.Key.foregroundColor: Colors.accentBlue, NSAttributedString.Key.font: UIFont(name: "Verdana", size: 17)]
    let attrs_black = [NSAttributedString.Key.foregroundColor: UIColor.black]
    if pickerData[row] == "Neutral" {
        string = "Neutral"
        res = NSAttributedString(string: string, attributes: attrs_blue)
    } else if pickerData[row] == "Choose value" {
        string = "Choose value"
        res = NSAttributedString(string: string, attributes: attrs_black)
    } else {
        string = Double(pickerData[row])!.string(fractionDigits: 1)
        res = NSAttributedString(string: string, attributes: attrs_black)
    }
    return res
  } */

 /* func select(value: Float) {
    let val = Double(value)
    if let index = pickerData.firstIndex(of: String(val)) {
      selectRow(index, inComponent: 0, animated: true)
    }
  }

  func selectMiddle() {
    selectRow(pickerData.count / 2, inComponent: 0, animated: true)
    selected.onNext(200)
  }*/
}

