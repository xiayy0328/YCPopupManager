//
//  YCPopupTransitioning.swift
//  YCPopupManager
//
//  Created by Xyy on 2023/11/24.
//

import UIKit

/// 定义Popuper动画协议
public protocol YCPopupTransitioning {
    /// 展示动画
    func present(_ model: YCPopupModel, completion: @escaping YCPopupManager.Completion)
    /// 消失动画
    func dismiss(_ model: YCPopupModel, completion: @escaping YCPopupManager.Completion)
}

// MARK: - Animators
public struct YCPopupFadeAnimator: YCPopupTransitioning {
    
    public func present(_ model: YCPopupModel, completion: @escaping YCPopupManager.Completion) {
        model.popupView.alpha = 0
        UIView.animate(withDuration: model.config.animationTime, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseOut]) {
            model.popupView.alpha = 1
        } completion: { _ in
            completion()
        }
    }
    
    public func dismiss(_ model: YCPopupModel, completion: @escaping YCPopupManager.Completion) {
        UIView.animate(withDuration: model.config.animationTime, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseIn]) {
            model.popupView.alpha = 0
        } completion: { _ in
            completion()
        }
    }
    
}

public struct YCPopupScaleAnimator: YCPopupTransitioning {
    
    public func present(_ model: YCPopupModel, completion: @escaping YCPopupManager.Completion) {
        model.maskView?.alpha = 0
        model.popupView.alpha = 0
        model.popupView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: model.config.animationTime, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.curveEaseOut]) {
            model.maskView?.alpha = 1
            model.popupView.alpha = 1
            model.popupView.transform = .identity
        } completion: { _ in
            completion()
        }
    }
    
    public func dismiss(_ model: YCPopupModel, completion: @escaping YCPopupManager.Completion) {
        UIView.animate(withDuration: model.config.animationTime, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseIn]) {
            model.maskView?.alpha = 0
            model.popupView.alpha = 0
            model.popupView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        } completion: { _ in
            completion()
        }
    }
    
}

public struct YCPopupPositionAnimator: YCPopupTransitioning {
    
    public func present(_ model: YCPopupModel, completion: @escaping YCPopupManager.Completion) {
        /// 获取起始和结束的中心点坐标
        let (startPosition, endPosition) = model.getStartEndPosition()
        model.maskView?.alpha = 0
        model.popupView.layer.position = startPosition
        
        UIView.animate(withDuration: model.config.animationTime,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut) {
            model.maskView?.alpha = 1
            model.popupView.layer.position = endPosition
        } completion: { _ in
            completion()
        }
    }
    
    public func dismiss(_ model: YCPopupModel, completion: @escaping YCPopupManager.Completion) {
        /// 获取起始的中心点坐标
        let startPosition = model.getStartEndPosition().0
        
        UIView.animate(withDuration: model.config.animationTime,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: .curveEaseIn) {
            model.maskView?.alpha = 0
            model.popupView.layer.position = startPosition
        } completion: { _ in
            completion()
        }
    }
    
}
