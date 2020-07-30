//
//  UIScrollView.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 30/7/20.
//

import UIKit

extension UIScrollView {
    func updateContentView() {
        if let height = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY {
            contentSize.height = height + 20
        } else {
            contentSize.height = contentSize.height
        }
    }
}
