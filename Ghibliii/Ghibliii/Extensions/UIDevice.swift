//
//  UIDevice.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 30/7/20.
//

import UIKit

extension UIDevice {
    var hasNotch: Bool {
        if let keyWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            return keyWindow.safeAreaInsets.bottom > 0
        } else {
            return false
        }
    }
}
