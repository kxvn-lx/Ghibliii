//
//  UIStackView.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 29/7/20.
//

import UIKit

extension UIStackView {
    
    /// Add a background with a color to a stackview
    /// - Parameters:
    ///   - color: the color
    ///   - cornerRadius: the corner radius if any
    func addBackgroundColor(_ color: UIColor, withCornerRadius cornerRadius: CGFloat = 0) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.layer.cornerRadius = cornerRadius
        subView.layer.cornerCurve = .continuous
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
