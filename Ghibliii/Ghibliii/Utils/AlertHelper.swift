//
//  AlertHelper.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 4/8/20.
//

import UIKit

struct AlertHelper {
    
    static let shared = AlertHelper()
    private init() { }
    
    /// Present a default alert view with an OK button.
    func presentOKAction(withTitle title: String? = nil, andMessage message: String? = nil, to viewController: UIViewController?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        viewController?.present(alert, animated: true, completion: nil)
    }
}
