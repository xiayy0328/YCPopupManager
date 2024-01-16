//
//  ShareView.swift
//  PopupDemo
//
//  Created by Xyy on 2021/5/26.
//

import UIKit

class ShareView: UIView {
    
    @IBOutlet var cancelButton: UIButton!

    class func instantiateFromNib() -> ShareView {
        return Bundle.main.loadNibNamed("ShareView", owner: nil, options: nil)?.first as! ShareView
    }
}
