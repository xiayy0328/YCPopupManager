//
//  YCPopupManager.swift
//  PopupDemo
//
//  Created by Xyy on 2021/5/24.
//

import UIKit

public class YCPopupManager {
    
    /// 内容视图(默认加载在window上)
    private var popupContainerView: UIView!
    
    /// 弹窗队列
    public private(set) var popupQueue: [YCPopupModel] = []
    
    /// 单例对象
    public static let shared = YCPopupManager()

    /// 初始化方法
    public init() { }
    
    /// 显示Popup
    /// - Parameters:
    ///   - popupView: 弹窗视图
    ///   - config: 弹窗配置
    public func showPopup(popupView: UIView, config: YCPopupManager.Config) {
        /// 弹窗的容器视图
        popupContainerView = config.containerView ?? UIApplication.shared.windows.filter { $0.isKeyWindow }.first!
        
        /// 弹窗数据对象
        let popupModel = YCPopupModel(popupView: popupView, popupConfig: config, popupContainerView: popupContainerView)
        
        /// 是否只展示一个, 隐藏所有Popup
        if popupModel.config.isAloneMode {
            hidePopup(option: .all)
        }
        
        /// 按照优先级添加弹窗
        let sortedPopupQueue = popupQueue.sorted(by: { $0.config.priority.rawValue < $1.config.priority.rawValue })
        if sortedPopupQueue.isEmpty {
            popupModel.addSubview()
        } else {
            if let last = sortedPopupQueue.last, popupModel.config.priority.rawValue >= last.config.priority.rawValue {
                popupModel.addSubview()
            } else {
                /// 遍历试图添加
                for element in sortedPopupQueue {
                    if popupModel.config.priority.rawValue < element.config.priority.rawValue {
                        if let maskView = element.maskView {
                            popupModel.addSubview(below: maskView)
                        } else {
                            popupModel.addSubview(below: element.popupView)
                        }
                        break
                    }
                }
            }
        }
        
        /// 添加弹窗对象
        popupQueue.append(popupModel)
        
        /// 展示动画
        popupModel.present()
                
    }
    
    /// 隐藏Popup
    /// - Parameter animation: 是否展示动画
    /// - Parameter popupModel: YCPopupModel对象
    public func hidePopup(animation: Bool = true, popupModel: YCPopupModel) {
        popupModel.dismiss {  [weak self] in
            guard let `self` = self else { return }
            /// 移除队列的弹窗
            self.popupQueue.removeAll(where: { $0 == popupModel })
        }
    }
    
    /// 隐藏Popup
    /// - Parameter popupView: 弹出视图对象
    public func hidePopup(popupView: UIView) {
        let popupViewModels = popupQueue.filter({ $0.popupView == popupView })
        guard !popupViewModels.isEmpty else {
            return
        }
        popupViewModels.forEach({ hidePopup(popupModel: $0) })
    }
    
    ///  隐藏Popup
    /// - Parameters:
    ///   - option: 消失的选项
    ///   - completion: 完成的回调
    public func hidePopup(option: YCPopupManager.DissmissOption = .last) {
        switch option {
        case .first:
            guard let firstPopupModel = popupQueue.first else { return }
            hidePopup(popupModel: firstPopupModel)
        case .last:
            guard let lastPopupModel = popupQueue.last else { return }
            hidePopup(popupModel: lastPopupModel)
        default:
            popupQueue.forEach({ hidePopup(animation: false, popupModel: $0) })
        }
    }
    
}
