//
//  NextViewController.swift
//  YCPopupManager_Example
//
//  Created by Xyy on 2023/11/27.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import YCPopupManager

class NextViewController: UIViewController {

    lazy var testView: UILabel = {
        let testView = UILabel()
        testView.textColor = .white
        testView.textAlignment = .center
        testView.font = UIFont.systemFont(ofSize: 15)
        testView.backgroundColor = .purple.withAlphaComponent(0.85)
        testView.text = "我是一个简单的提示"
        testView.layer.cornerRadius = 6
        testView.layer.masksToBounds = true
        let bottomSpace = view.safeAreaInsets.bottom > 0 ? view.safeAreaInsets.bottom : 20
        testView.frame = CGRect(x: (view.bounds.width - 200)/2, y: view.bounds.height - 40 - bottomSpace, width: 200, height: 40)
        return testView
    }()
    
    let manager = YCPopupManager()
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    
    @IBAction func testAction(_ sender: UIButton) {
        var config = YCPopupManager.Config()
        config.animationType = .scale
        config.maskStyle = .color(UIColor.orange.withAlphaComponent(0.3))
        config.containerView = self.view
        config.isClickMaskBackgroundDismiss = true
        config.popupViewCustomHideCallback = { [weak self] popupModel in
            guard let `self` = self else { return }
            self.manager.hidePopup(popupModel: popupModel)
        }
        manager.showPopup(popupView: testView, config: config)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

}
