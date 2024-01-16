//
//  InputView.swift
//  PopupDemo
//
//  Created by Xyy on 2021/5/26.
//

import UIKit

class InputView: UIView {
    @IBOutlet var inputTextField: UITextField!

    @IBOutlet weak var sendButton: UIButton!
    
    class func instantiateFromNib() -> InputView {
        return Bundle.main.loadNibNamed("InputView", owner: nil, options: nil)?.first as! InputView
    }
}
