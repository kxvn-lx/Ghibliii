//
//  UIStackView.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 29/7/20.
//

import UIKit

extension UIStackView {
    
    /// Add a background with a color to a stackview
    func addBackgroundColor(_ color: UIColor, withCornerRadius cornerRadius: CGFloat = 10) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.layer.cornerRadius = cornerRadius
        subView.layer.cornerCurve = .continuous
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
    
    /// Add a background blur to a stackview
    func addbackgroundBlur(_ effect: UIBlurEffect.Style, withCornerRadius cornerRadius: CGFloat = 10) {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.clipsToBounds = true
        blurEffectView.layer.cornerRadius = cornerRadius
        blurEffectView.layer.cornerCurve = .continuous
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(blurEffectView, at: 0)
    }
}
