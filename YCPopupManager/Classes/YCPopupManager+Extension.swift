//
//  YCPopupManager+Extension.swift
//  YCPopupManager
//
//  Created by Xyy on 2023/11/24.
//

import UIKit

/// 弹窗管理者
public extension YCPopupManager {
    
    /// 定义完成的回调
    typealias Completion = () -> Void
    
    /// 生命周期的回调
    typealias LifeCycleCallback = (YCPopupModel) -> Void
    
    /// 定义键盘改变的回调
    typealias KeyBoardChange = (_ beginFrame: CGRect, _ endFrame: CGRect, _ duration: CGFloat) -> Void
    
    /// 定义遮罩样式
    enum MaskStyle {
        case none
        case white
        case clear
        case darkBlur
        case lightBlur
        case extraLightBlur
        case color(_ color: UIColor)
        case black(_ alpha: CGFloat)
    }

    /// 定义位置动画的方向
    enum PositionDirection {
        case top
        case left
        case bottom
        case right
    }
    
    /// 定义动画类型
    enum AnimationType {
        case fade
        case scale
        case custom(_ animator: YCPopupTransitioning)
        case position(_ direction: YCPopupManager.PositionDirection)
    }

    /// 视图优先级
    enum Priority: Int {
        case veryLow = 0
        case low
        case normal
        case high
        case veryHigh
    }

    /// 视图消失的选项
    enum DissmissOption {
        case first
        case last
        case all
    }
    
    /// 样式配置
    struct Config {
        
        /// 内容视图(默认加载在window上)
        public var containerView: UIView?
        
        /// 遮罩样式
        public var maskStyle: YCPopupManager.MaskStyle = .black(0.25)
        
        /// 设置视图展示的优先级，默认normal。只有当内容视图在同一个才有效
        public var priority: YCPopupManager.Priority = .normal
        
        /// 动画类型
        public var animationType: YCPopupManager.AnimationType = .fade
        
        /// 动画执行时间
        public var animationTime: TimeInterval = 0.3
        
        /// 自动消失的时间=0不自动消失
        public var dismissDuration: TimeInterval = 0
        
        /// 点击遮罩背景是否消失
        public var isClickMaskBackgroundDismiss = false
        
        /// 滑动手势是否可用
        public var isPanGestureRecognizerEnabled = false
        
        /// 滑动手势消失的百分比
        public var panGestureDismissPercent: CGFloat = 0.5
        
        /// 是否监听键盘
        public var isKeyboardMonitor = false
        
        /// 键盘和弹窗之间的垂直间距,默认为0
        public var keyboardVerticalSpace = CGFloat(0)
        
        /// 是否单独展示（设置true展示前会将之前展示的全部清除掉）
        public var isAloneMode = false
        
        /// Popup生命周期回调
        public var popupViewWillAppearCallback: YCPopupManager.LifeCycleCallback?
        public var popupViewDidAppearCallback: YCPopupManager.LifeCycleCallback?
        public var popupViewWillDisappearCallback: YCPopupManager.LifeCycleCallback?
        public var popupViewDidDisappearCallback: YCPopupManager.LifeCycleCallback?
        
        /// PopupModel自定义隐藏方法的回调(默认实现单例的hidePopup)
        public var popupViewCustomHideCallback: YCPopupManager.LifeCycleCallback?
        
        /// Popup键盘方法回调
        public var keyboardWillShowCallback: YCPopupManager.Completion?
        public var keyboardDidShowCallback: YCPopupManager.Completion?
        public var keyboardFrameWillChange: YCPopupManager.KeyBoardChange?
        public var keyboardFrameDidChange: YCPopupManager.KeyBoardChange?
        public var keyboardWillHideCallback: YCPopupManager.Completion?
        public var keyboardDidHideCallback: YCPopupManager.Completion?
        
        /// 初始化方法
        public init() { }
        
    }
    
}

public extension YCPopupManager.AnimationType {
    
    /// 获取动画对象
    var animator: YCPopupTransitioning {
        switch self {
        case .fade:
            return YCPopupFadeAnimator()
        case .scale:
            return YCPopupScaleAnimator()
        case .position(_):
            return YCPopupPositionAnimator()
        case .custom(let customAnimator):
            return customAnimator
        }
    }
    
}

// MARK: - YCPopupManager + UIView
public extension UIView {

    /// 快速展示
    /// - Parameter config: 配置
    func yc_showPopup(config: YCPopupManager.Config) {
        YCPopupManager.shared.showPopup(popupView: self, config: config)
    }
    
    /// 快速消失
    func yc_hidePopup() {
        YCPopupManager.shared.hidePopup(popupView: self)
    }
    
}
