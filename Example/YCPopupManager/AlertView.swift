//
//  AlertView.swift
//  PopupDemo
//
//  Created by Xyy on 2021/5/26.
//

import UIKit

class AlertView: UIView {
    @IBOutlet var cancelButton: UIButton!

    @IBOutlet var confirmButton: UIButton!

    class func instantiateFromNib() -> AlertView {
        return Bundle.main.loadNibNamed("AlertView", owner: nil, options: nil)?.first as! AlertView
    }
}
