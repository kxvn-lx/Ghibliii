//
//  SettingsViewModel.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 4/8/20.
//

import UIKit

struct SettingsSection {
    var title: String
    var cells: [SettingsItem]
}

struct SettingsItem {
    var createdCell: (SettingsItem) -> UITableViewCell
    var action: ((SettingsItem) -> Swift.Void)?
}

protocol SettingsViewModelDelegate: class {
    func emailCellTapped()
    func twitterCellTapped()
}

// MARK: - SettingsViewModel
class SettingsViewModel: NSObject {
    
    static let ReuseIdentifier = "SettingsCell"
    private var tableViewSections = [SettingsSection]()
    weak var delegate: SettingsViewModelDelegate?
    
    // MARK: - Init
    init(delegate: SettingsViewModelDelegate) {
        super.init()
        self.delegate = delegate
        configureDatasource()
    }
    
    private func configureDatasource() {
        let getInTouchSection = SettingsSection(
            title: "Get in touch",
            cells: [
                SettingsItem(
                    createdCell: {_ in
                        let cell = UITableViewCell(style: .value1, reuseIdentifier: Self.ReuseIdentifier)
                        cell.textLabel?.text = "Email"
                        cell.accessoryType = .disclosureIndicator
                        return cell
                    },
                    action: { [weak self] _ in self?.delegate?.emailCellTapped() }
                ),
                SettingsItem(
                    createdCell: {_ in
                        let cell = UITableViewCell(style: .value1, reuseIdentifier: Self.ReuseIdentifier)
                        cell.textLabel?.text = "Twitter"
                        cell.accessoryType = .disclosureIndicator
                        return cell
                    },
                    action: { [weak self] _ in self?.delegate?.twitterCellTapped() }
                )
            ] // Cells
        ) // Section
        
        tableViewSections = [getInTouchSection]
    }
}

// MARK: - TableView delegate and datasource
extension SettingsViewModel: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewSections[section].cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewSections[indexPath.section].cells[indexPath.row]
        return cell.createdCell(cell)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewSections.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableViewSections[indexPath.section].cells[indexPath.row]
        cell.action?(cell)
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewSections[section].title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.text = tableViewSections[section].title
            headerView.textLabel?.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .bold)
        }
    }
}
