//
//  SettingsTableViewController.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 2/8/20.
//

import UIKit
import MessageUI
import SafariServices

class SettingsTableViewController: UITableViewController {
    
    private var viewModel: SettingsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTitle("Settings", backgroundColor: .systemGroupedBackground)
        setupView()
        
        viewModel = SettingsViewModel(delegate: self)
        
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
    }
    
    private func setupView() {
        // Setup close button
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeTapped))
        navigationItem.leftBarButtonItem = closeButton
        
        self.tableView.tableFooterView = SettingsFooterView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 150))
    }

    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Delegation methods
extension SettingsTableViewController: SettingsViewModelDelegate {
    func emailCellTapped() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["kevinlaminto.dev@gmail.com"])
            mail.setSubject("[Ghibliii] Hi there! ✉️")
            
            present(mail, animated: true)
        } else {
            AlertHelper.shared.presentOKAction(
                withTitle: "No mail account.",
                andMessage: "Please configure a mail account in order to send email. Or, manually email it to kevinlaminto.dev@gmail.com",
                to: self
            )
        }
    }
    
    func twitterCellTapped() {
        if let url = URL(string: "https://twitter.com/kevinlx_") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                let sfSafariVC = SFSafariViewController(url: url)
                present(sfSafariVC, animated: true)
            }
        }
    }
}

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
