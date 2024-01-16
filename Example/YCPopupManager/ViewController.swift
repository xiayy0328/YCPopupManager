//
//  ViewController.swift
//  YCPopupManager
//
//  Created by Loveying on 07/12/2021.
//  Copyright (c) 2021 Loveying. All rights reserved.
//

import UIKit
import YCPopupManager

/// 测试对象
struct Demo {
    let name: String
    let selecter: Selector
}

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!

    private let demos = [
        Demo(name: "从中间弹出自定义View", selecter: #selector(demo1)),
        Demo(name: "从顶部弹出自定义View", selecter: #selector(demo2)),
        Demo(name: "从底部弹出自定义View", selecter: #selector(demo3)),
        Demo(name: "从左边弹出自定义View", selecter: #selector(demo4)),
        Demo(name: "从右边弹出自定义View", selecter: #selector(demo5)),
        Demo(name: "展示多个优先级的自定义View", selecter: #selector(demo6)),
        Demo(name: "从底部展示Toast，2s自动消失", selecter: #selector(demo7)),
        Demo(name: "底部输入框自动适配键盘", selecter: #selector(demo8)),
        Demo(name: "自定义PopupManager", selecter: #selector(demo9)),
        Demo(name: "UIView快速使用", selecter: #selector(demo10)),
    ]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "PopupDemo"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func closeAction() {
        YCPopupManager.shared.hidePopup()
    }
    
    @objc func closeWindowAction() {
        YCPopupManager.shared.hidePopup()
    }
    
    @objc func sendAction(_ sender: UIButton) {
        let testView = sender.superview as? InputView
        testView?.inputTextField.endEditing(true)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = demos[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let demo = demos[indexPath.row]
        perform(demo.selecter)
    }
    
}

extension ViewController {
    
    @objc func demo1() {
        let testView = AlertView.instantiateFromNib()
        testView.layer.cornerRadius = 12
        testView.layer.masksToBounds = true
        testView.frame = CGRect(x: (view.bounds.width - 260)/2, y: (view.bounds.height - 160)/2, width: 260, height: 160)
        testView.cancelButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        testView.confirmButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        var config = YCPopupManager.Config()
        config.animationType = .scale
        config.containerView = self.view
        
        YCPopupManager.shared.showPopup(popupView: testView, config: config)
    }
    
    @objc func demo2() {
        let testView = TopView.instantiateFromNib()
        testView.frame = CGRect(x: 16, y: view.safeAreaInsets.top + 16, width: view.bounds.width - 32, height: 50)
        testView.layer.cornerRadius = 8
        testView.layer.masksToBounds = true
        testView.closeButton.addTarget(self, action: #selector(closeWindowAction), for: .touchUpInside)
        
        var config = YCPopupManager.Config()
        config.animationType = .position(.top)
        config.maskStyle = .clear
        config.containerView = self.view
    
        YCPopupManager.shared.showPopup(popupView: testView, config: config)
    }
    
    @objc func demo3() {
        let testView = ShareView.instantiateFromNib()
        testView.frame = CGRect(x: 0, y: view.bounds.height - 320, width: view.bounds.width, height: 320)
        testView.cancelButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        
        var config = YCPopupManager.Config()
        config.containerView = self.view
        config.animationType = .position(.bottom)
        config.isPanGestureRecognizerEnabled = true
        
        YCPopupManager.shared.showPopup(popupView: testView, config: config)
    }
    
    @objc func demo4() {
        let testView = UIView(frame: CGRect(x: 0, y: 0, width: 260, height: UIScreen.main.bounds.height))
        testView.backgroundColor = .red
        
        var config = YCPopupManager.Config()
        config.animationType = .position(.left)
        config.isPanGestureRecognizerEnabled = true
        
        YCPopupManager.shared.showPopup(popupView: testView, config: config)
    }
    
    @objc func demo5() {
        let testView = UIView(frame: CGRect(x: view.bounds.width - 260, y: 0, width: 260, height: UIScreen.main.bounds.height))
        testView.backgroundColor = .green
        
        var config = YCPopupManager.Config()
        config.animationType = .position(.right)
        config.isPanGestureRecognizerEnabled = true
        
        YCPopupManager.shared.showPopup(popupView: testView, config: config)
    }
    
    @objc func demo6() {
        let view1 = UIView(frame: CGRect(x: (view.bounds.width - 300)/2, y: 50, width: 300, height: 200))
        view1.backgroundColor = .red
        var config1 = YCPopupManager.Config()
        config1.containerView = self.view
        config1.priority = .veryHigh
        config1.animationType = .position(.top)
        config1.isClickMaskBackgroundDismiss = true

        let view2 = UIView(frame: CGRect(x: (view.bounds.width - 270)/2, y: view.bounds.height - 200 - 80, width: 270, height: 200))
        view2.backgroundColor = .blue
        var config2 = YCPopupManager.Config()
        config2.containerView = self.view
        config2.priority = .veryLow
        config2.animationType = .position(.bottom)
        config2.isClickMaskBackgroundDismiss = true

        let view3 = UIView(frame: CGRect(x: view.bounds.width - 270 - 30, y: (view.bounds.height - 80)/2 - 40, width: 270, height: 80))
        view3.backgroundColor = .green
        var config3 = YCPopupManager.Config()
        config3.containerView = self.view
        config3.priority = .normal
        config3.animationType = .position(.right)
        config3.isClickMaskBackgroundDismiss = true
        
        let view4 = UIView(frame: CGRect(x: 30, y: (view.bounds.height - 80)/2 + 50, width: 270, height: 80))
        view4.backgroundColor = .orange
        var config4 = YCPopupManager.Config()
        config4.containerView = self.view
        config4.priority = .normal
        config4.animationType = .position(.left)
        config4.isClickMaskBackgroundDismiss = true
        
        
        YCPopupManager.shared.showPopup(popupView: view1, config: config1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: DispatchWorkItem(block: {
            YCPopupManager.shared.showPopup(popupView: view2, config: config2)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: DispatchWorkItem(block: {
                YCPopupManager.shared.showPopup(popupView: view3, config: config3)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: DispatchWorkItem(block: {
                    YCPopupManager.shared.showPopup(popupView: view4, config: config4)
                }))
            }))
        }))
        
    }
    
    @objc func demo7() {
        let testView = UILabel()
        testView.textColor = .white
        testView.textAlignment = .center
        testView.font = UIFont.systemFont(ofSize: 15)
        testView.frame = CGRect(x: (UIScreen.main.bounds.width - 200)/2, y: UIScreen.main.bounds.height - UIApplication.safeInsets.bottom - 40, width: 200, height: 40)
        testView.backgroundColor = .purple.withAlphaComponent(0.85)
        testView.text = "我是一个简单的提示"
        testView.layer.cornerRadius = 6
        testView.layer.masksToBounds = true
        var config = YCPopupManager.Config()
        config.animationType = .fade
        config.maskStyle = .none
        config.dismissDuration = 2
        
        YCPopupManager.shared.showPopup(popupView: testView, config: config)
    }
    
    @objc func demo8() {
        let testView = InputView.instantiateFromNib()
        testView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - UIApplication.safeInsets.bottom - 50, width: UIScreen.main.bounds.width, height: 50)
        testView.sendButton.addTarget(self, action: #selector(sendAction(_:)), for: .touchUpInside)
        var config = YCPopupManager.Config()
        config.animationType = .position(.bottom)
        config.isKeyboardMonitor = true
        config.isClickMaskBackgroundDismiss = true
        YCPopupManager.shared.showPopup(popupView: testView, config: config)
    }
    
    @objc func demo9() {
        navigationController?.pushViewController(NextViewController(), animated: true)
    }
    
    @objc func demo10() {
        var config = YCPopupManager.Config()
        config.animationType = .scale
        config.isClickMaskBackgroundDismiss = true
        let testView = UIView(frame: CGRect(x: (view.bounds.width - 200)/2, y: (view.bounds.height - 200)/2, width: 200, height: 200))
        testView.backgroundColor = .purple
        testView.yc_showPopup(config: config)
    }
}

extension UIApplication {
    /// 获取应用程序的主窗口
    static var appWindow: UIWindow? {
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            return window
        }

        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first
        } else {
            return UIApplication.shared.keyWindow
        }
    }

    /// 获取当前屏幕的安全区域
    static var safeInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIApplication.appWindow?.safeAreaInsets ?? UIEdgeInsets.zero
        } else {
            return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }
    }
}

