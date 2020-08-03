//
//  MenuController.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 4/8/20.
//

import UIKit

class MenuController {
    
    // Property list keys to access UICommand/UIKeyCommand values.
    struct CommandPListKeys {
        static let CommandIdentifierKey = "command"
    }
    
    enum Commands: String, CaseIterable {
        case refresh = "Refresh"
        
        func localizedString() -> String {
            return NSLocalizedString("\(self.rawValue)", comment: "")
        }
        
        func keyCommands() -> UIKeyCommand {
            switch self {
            case .refresh: return UIKeyCommand(title: self.localizedString(), action: #selector(AppDelegate.refreshHomeVC), input: "R", modifierFlags: .command)
            }
        }
    }
    
    init(with builder: UIMenuBuilder) {
        builder.remove(menu: .edit)
        builder.remove(menu: .format)
        builder.remove(menu: .services)
        
        builder.insertChild(MenuController.navigationMenu(), atStartOfMenu: .view)
    }
    
    class func navigationMenu() -> UIMenu {
        let keyChildrenCommands = Commands.allCases.map({ $0.keyCommands() })
        return UIMenu(
            title: "",
            image: nil,
            identifier: UIMenu.Identifier("com.kevinlaminto.com.ghibliii.commandsMenu"),
            options: .displayInline,
            children: keyChildrenCommands)
    }
}
