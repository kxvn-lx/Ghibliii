//
//  SettingsTableViewController.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 2/8/20.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    private struct CellPath {

    }
    private var isPhone: Bool {
        return UIScreen.main.traitCollection.userInterfaceIdiom == .phone
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTitle("Settings")
        setupView()
    }
    
    private func setupView() {
        // Setup close button
        let closeButton = UIButton(type: .close)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
    }

    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsTableViewController {
    
}

extension SettingsTableViewController {
    
}
