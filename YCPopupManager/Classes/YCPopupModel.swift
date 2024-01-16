//
//  YCPopupModel.swift
//  YCPopupManager
//
//  Created by Xyy on 2023/11/24.
//

import UIKit

public class YCPopupModel: NSObject {
    
    /// 展示的视图
    public let popupView: UIView
    
    /// 配置对象
    public var config: YCPopupManager.Config
    
    /// 弹窗的容器视图
    public let containerView: UIView
    
    /// 原始Frame
    public private(set) var popupOriginalFrame: CGRect = .zero
    
    /// 遮罩视图
    public var maskView: UIView?
    
    /// 是否正在展示
    public private(set) var isDisplaying: Bool = false
    
    /// 用于自动隐藏使用
    private var delayWorkItem: DispatchWorkItem?
    
    /// 获取动画对象
    public var animator: YCPopupTransitioning { config.animationType.animator }
    
    /// 初始化方法
    public init(popupView: UIView,
                popupConfig: YCPopupManager.Config,
                popupContainerView: UIView) {
        self.popupView = popupView
        self.config = popupConfig
        self.containerView = popupContainerView
        super.init()
        /// 设置遮罩视图
        setupMaskView()
        /// 延迟消失
        hideAfterDelay()
        /// 添加手势
        addGestureRecognizer()
        /// 添加键盘监听
        addKeyboardMonitor()
        /// 记录原始popupView初始Frame
        popupOriginalFrame = popupView.frame
    }
    
    /// 视图销毁的方法
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 视图展示的方法
    /// - Parameters:
    ///   - completion: 完成的回调
    public func present(completion: YCPopupManager.Completion? = nil) {
        guard !isDisplaying else {
            return
        }
        
        DispatchQueue.main.async {
            self.isDisplaying = true
            self.config.popupViewWillAppearCallback?(self)
            /// 展示动画
            self.animator.present(self) { [weak self] in
                guard let `self` = self else { return }
                self.config.popupViewDidAppearCallback?(self)
                completion?()
            }
        }
    }

    /// 视图消失的方法
    /// - Parameters:
    ///   - completion: 完成的回调
    ///   - animation: 是否展示动画
    public func dismiss(animation: Bool = true, completion: YCPopupManager.Completion? = nil) {
        guard isDisplaying else {
            return
        }
        if !animation {
            config.animationTime = 0.0
        }
        DispatchQueue.main.async {
            self.isDisplaying = false
            self.config.popupViewWillDisappearCallback?(self)
            /// 消失动画
            self.animator.dismiss(self) { [weak self] in
                guard let `self` = self else { return }
                self.destoryPopup()
                self.config.popupViewDidDisappearCallback?(self)
                completion?()
            }
        }
    }
    
}

extension YCPopupModel {
    
    /// 初始化遮罩视图
    private func setupMaskView() {
        switch config.maskStyle {
        case .darkBlur:
            self.maskView = UIView(frame: containerView.bounds)
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            blurView.frame = containerView.bounds
            self.maskView?.insertSubview(blurView, at: 0)
        case .lightBlur:
            self.maskView = UIView(frame: containerView.bounds)
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            blurView.frame = containerView.bounds
            self.maskView?.insertSubview(blurView, at: 0)
        case .extraLightBlur:
            self.maskView = UIView(frame: containerView.bounds)
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            blurView.frame = containerView.bounds
            self.maskView?.insertSubview(blurView, at: 0)
        case .white:
            self.maskView = UIView(frame: containerView.bounds)
            self.maskView?.backgroundColor = .white
        case .black(let alpha):
            self.maskView = UIView(frame: containerView.bounds)
            self.maskView?.backgroundColor = UIColor.black.withAlphaComponent(alpha)
        case .color(let color):
            self.maskView = UIView(frame: containerView.bounds)
            self.maskView?.backgroundColor = color
        case .clear:
            self.maskView = UIView(frame: containerView.bounds)
            self.maskView?.backgroundColor = .clear
        case .none:
            self.maskView = nil
        }
    }
    
    /// 销毁Popup
    private func destoryPopup() {
        delayWorkItem?.cancel()
        if let maskView = maskView {
            maskView.removeFromSuperview()
        } else {
            popupView.removeFromSuperview()
        }
    }
    
    /// 延迟消失
    private func hideAfterDelay() {
        guard config.dismissDuration > 0 else {
            return
        }
        delayWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.hide()
        }
        self.delayWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + config.dismissDuration, execute: workItem)
    }
    
    /// 添加手势
    private func addGestureRecognizer() {
        /// 遮罩背景添加点击手势
        if config.isClickMaskBackgroundDismiss {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureAction(_:)))
            tapGesture.delegate = self
            maskView?.addGestureRecognizer(tapGesture)
        }
        
        /// 遮罩背景添加滑动手势
        if config.isPanGestureRecognizerEnabled {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureAction(_:)))
            panGesture.delegate = self
            popupView.addGestureRecognizer(panGesture)
        }
    }
    
    /// 添加手势
    private func addKeyboardMonitor() {
        guard config.isKeyboardMonitor else {
            return
        }
        
        /// 键盘将要显示
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        /// 键盘显示完毕
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(_:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        /// 键盘frame将要改变
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        /// 键盘frame改变完毕
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidChangeFrame(_:)),
                                               name: UIResponder.keyboardDidChangeFrameNotification,
                                               object: nil)
        /// 键盘将要收起
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
}

// MARK: - Public
extension YCPopupModel {
    
    /// 在视图的下面添加视图
    public func addSubview(below siblingSubview: UIView? = nil) {
        if let siblingSubview = siblingSubview {
            if let maskView = maskView {
                containerView.insertSubview(maskView, belowSubview: siblingSubview)
                containerView.insertSubview(popupView, aboveSubview: maskView)
            } else {
                containerView.insertSubview(popupView, aboveSubview: siblingSubview)
            }
        } else {
            if let maskView = maskView {
                containerView.addSubview(maskView)
                containerView.insertSubview(popupView, aboveSubview: maskView)
            } else {
                containerView.addSubview(popupView)
            }
        }
    }
    
    /// 获取位置动画的开始和结束点Point
    /// - Returns: (starPoint, endPoint)
    public func getStartEndPosition() -> (CGPoint, CGPoint) {
        let popViewSize = popupOriginalFrame.size
        let originPoint = popupOriginalFrame.origin
        switch config.animationType {
        case .position(let direction):
            switch direction {
            case .top:
                let endPosition = CGPoint(x: originPoint.x + (popViewSize.width / 2),
                                          y: originPoint.y + (popViewSize.height / 2))
                let startPosition = CGPoint(x: endPosition.x,
                                            y: -popViewSize.height/2)
                return (startPosition, endPosition)
            case .left:
                let endPosition = CGPoint(x: originPoint.x + (popViewSize.width / 2),
                                          y: originPoint.y + (popViewSize.height / 2))
                let startPosition = CGPoint(x: -(popViewSize.width / 2),
                                            y: endPosition.y)
                return (startPosition, endPosition)
            case .bottom:
                let endPosition = CGPoint(x: originPoint.x + (popViewSize.width / 2),
                                          y: originPoint.y + (popViewSize.height / 2))
                let startPosition = CGPoint(x: endPosition.x,
                                            y: containerView.bounds.height + (popViewSize.height / 2))
                return (startPosition, endPosition)
            case .right:
                let endPosition = CGPoint(x: originPoint.x + (popViewSize.width / 2),
                                          y: originPoint.y + (popViewSize.height / 2))
                let startPosition = CGPoint(x: containerView.bounds.width + (popViewSize.width / 2),
                                            y: endPosition.y)
                return (startPosition, endPosition)
            }
        default:
            return (CGPoint.zero, CGPoint.zero)
        }
    }
    
}

extension YCPopupModel {
    
    /// 隐藏的方法
    @objc public func hide() {
        popupView.endEditing(true)
        if let popupViewHideCallback = config.popupViewCustomHideCallback {
            popupViewHideCallback(self)
        } else {
            YCPopupManager.shared.hidePopup(popupModel: self)
        }
    }
    
    /// 处理点击手势
    @objc private func handleTapGestureAction(_ tap: UIGestureRecognizer) {
        hide()
    }
    
    /// 处理滑动手势
    @objc private func handlePanGestureAction(_ pan: UIPanGestureRecognizer) {
        /// 获取手指的偏移量
        let transPoint = pan.translation(in: popupView)
        
        if pan.state == .changed {
            switch config.animationType {
            case .position(let direction):
                switch direction {
                case .top:
                    if transPoint.y < 0 {
                        let offY = (popupOriginalFrame.origin.y + (popupOriginalFrame.size.height / 2)) - abs(transPoint.y)
                        popupView.layer.position = CGPoint(x: popupView.layer.position.x, y: offY)
                    } else {
                        popupView.frame = popupOriginalFrame
                    }
                case .bottom:
                    if transPoint.y > 0 {
                        let offY = (popupOriginalFrame.origin.y + (popupOriginalFrame.size.height / 2)) + abs(transPoint.y)
                        popupView.layer.position = CGPoint(x: popupView.layer.position.x, y: offY)
                    } else {
                        popupView.frame = popupOriginalFrame
                    }
                case .left:
                    if transPoint.x < 0 {
                        let offX = (popupOriginalFrame.origin.x + (popupOriginalFrame.size.width / 2)) - abs(transPoint.x)
                        popupView.layer.position = CGPoint(x: offX, y: popupView.layer.position.y)
                    } else {
                        popupView.frame = popupOriginalFrame
                    }
                case .right:
                    if transPoint.x > 0 {
                        let offX = (popupOriginalFrame.origin.x + (popupOriginalFrame.size.width / 2)) + abs(transPoint.x)
                        popupView.layer.position = CGPoint(x: offX, y: popupView.layer.position.y)
                    } else {
                        popupView.frame = popupOriginalFrame
                    }
                }
            default:
                break
            }
            
        } else if pan.state == .ended {
            switch config.animationType {
            case .position(let direction):
                switch direction {
                case .top, .bottom:
                    if abs(transPoint.y) >= popupOriginalFrame.size.height * config.panGestureDismissPercent {
                        // 向上/下滑动了至少内容的一半高度，触发关闭弹窗
                        hide()
                    } else {
                        popupView.frame = popupOriginalFrame
                    }
                case .left, .right:
                    if abs(transPoint.x) >= popupOriginalFrame.size.width * config.panGestureDismissPercent {
                        // 向左/右滑动了至少内容的一半宽度，触发关闭弹窗
                        hide()
                    } else {
                        popupView.frame = popupOriginalFrame
                    }
                }
            default:
                break
            }
            
        }
    }
    
    /// 键盘将要展示
    @objc private func keyboardWillShow(_ notification: Notification) {
        config.keyboardWillShowCallback?()
        guard let userInfo = notification.userInfo else {
            return
        }
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        let keyboardEedFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardMaxY = keyboardEedFrame?.origin.y ?? 0
        let popViewPoint = popupView.layer.position
        let currMaxY = popViewPoint.y + popupView.frame.size.height / 2
        let offY = currMaxY - keyboardMaxY + config.keyboardVerticalSpace
        if keyboardMaxY < currMaxY { // 键盘被遮挡
            // 执行动画
            let originPoint = popupView.layer.position
            UIView.animate(withDuration: duration) { [weak self] in
                guard let `self` = self else { return }
                self.popupView.layer.position = CGPoint(x: originPoint.x, y: originPoint.y - offY)
            }
        }
    }
    
    /// 键盘已经展示
    @objc private func keyboardDidShow(_ notification: Notification) {
        config.keyboardDidShowCallback?()
    }
    
    /// 键盘将要改变布局
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        let keyboardBeginFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect ?? .zero
        let keyboardEndFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        config.keyboardFrameWillChange?(keyboardBeginFrame, keyboardEndFrame, duration)
    }
    
    /// 键盘已经改变布局
    @objc private func keyboardDidChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        let keyboardBeginFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect ?? .zero
        let keyboardEndFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        config.keyboardFrameDidChange?(keyboardBeginFrame, keyboardEndFrame, duration)
    }
    
    /// 键盘将要隐藏
    @objc private func keyboardWillHide(_ notification: Notification) {
        config.keyboardWillHideCallback?()
        guard let userInfo = notification.userInfo else {
            return
        }
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        UIView.animate(withDuration: duration) { [weak self] in
            guard let `self` = self else { return }
            self.popupView.frame = self.popupOriginalFrame
        }
    }
    
    /// 键盘已经隐藏
    @objc private func keyboardDidHide(_ notification: Notification) {
        config.keyboardDidHideCallback?()
    }
    
}


// MARK: - UIGestureRecognizerDelegate
extension YCPopupModel: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            return !touch.view!.isDescendant(of: popupView)
        }
        return true
    }
}
