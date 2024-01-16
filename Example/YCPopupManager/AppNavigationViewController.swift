//
//  AppNavigationViewController.swift
//  ElegantPopuper_Example
//
//  Created by Xyy on 2023/10/25.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class AppNavigationViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigation()
    }
    
    //MARK: 重写跳转
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        /// 重新定义push之后的Controller
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        let item = UIBarButtonItem(title: " ", style: .plain, target: self, action: nil)
        viewController.navigationItem.backBarButtonItem = item
        super.pushViewController(viewController, animated: animated)
    }
}

extension AppNavigationViewController {
    
    func setNavigation() {
        UINavigationBar.appearance().isTranslucent = false // 导航栏设置为不透明
        navigationBar.tintColor = .white // 导航栏文字 颜色
        navigationBar.barTintColor = .systemBlue // 导航栏背景设置为白色
        /// 标题颜色/字号
        let titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.white]
        if #available(iOS 13.0, *) {
            let _appearance = navigationBar.standardAppearance // UINavigationBarAppearance()
            _appearance.configureWithOpaqueBackground() // 重置背景和阴影颜色
            _appearance.backgroundEffect = nil // 去掉半透明效果
            _appearance.backgroundColor = .systemBlue //设置背景颜色
            _appearance.titleTextAttributes = titleTextAttributes
            _appearance.shadowColor = .clear // 设置导航栏下边界分割线透明
            navigationBar.standardAppearance = _appearance //普通样式
            navigationBar.scrollEdgeAppearance = _appearance //滚动样式
        } else {
            navigationBar.titleTextAttributes = titleTextAttributes // 导航栏文字样式
            // 设置导航栏下边界分割线透明
            navigationBar.subviews.first?.alpha = 0;
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
        }
    }
}
