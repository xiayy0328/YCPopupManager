//
//  TopView.swift
//  PopupDemo
//
//  Created by Xyy on 2021/5/26.
//

import UIKit

class TopView: UIView {
    @IBOutlet var closeButton: UIButton!

    class func instantiateFromNib() -> TopView {
        return Bundle.main.loadNibNamed("TopView", owner: nil, options: nil)?.first as! TopView
    }
}
