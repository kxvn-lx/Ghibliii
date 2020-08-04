//
//  SettingsFooterView.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 4/8/20.
//

import UIKit

class SettingsFooterView: UIView {
    
    private var mStackView: UIStackView!
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ghibliii"
        label.textColor = .label
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .bold)
        return label
    }()
    private let appVersionLabel: UILabel = {
        let label = UILabel()
        label.text = "1.1"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .medium)
        return label
    }()
    private let createdByLabel: UILabel = {
        let label = UILabel()
        label.text = "Made with ❤️ by Kevin Laminto\nin Melbourne, Australia 🇦🇺"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .medium)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        mStackView = UIStackView(arrangedSubviews: [titleLabel, appVersionLabel, createdByLabel])
        mStackView.isLayoutMarginsRelativeArrangement = true
        mStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        mStackView.axis = .vertical
        mStackView.alignment = .center
        
        mStackView.setCustomSpacing(10, after: appVersionLabel)
        
        addSubview(mStackView)
    }
    
    private func setupConstraint() {
        mStackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
}
