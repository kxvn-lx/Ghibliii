//
//  UIDevice.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 30/7/20.
//

import UIKit

extension UIDevice {
    static var isIphoneX: Bool {
        var modelIdentifier = ""
        if isSimulator {
            modelIdentifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
        } else {
            var size = 0
            sysctlbyname("hw.machine", nil, &size, nil, 0)
            var machine = [CChar](repeating: 0, count: size)
            sysctlbyname("hw.machine", &machine, &size, nil, 0)
            modelIdentifier = String(cString: machine)
        }

        return modelIdentifier == "iPhone10,3" || modelIdentifier == "iPhone10,6"
    }

    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}
