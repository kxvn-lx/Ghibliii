//
//  UIApplication.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 5/8/20.
//

import UIKit

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
