//
//  PeopleCollectionViewCell.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 8/8/20.
//

import UIKit
import Backend

class PeopleCollectionViewCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "PeopleCell"
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray5
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 5
        imageView.layer.cornerCurve = .continuous
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    private var mStackView: UIStackView!
    
    var people: People! {
        didSet {
            nameLabel.text = people.name
            nameLabel.accessibilityLabel = people.name
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        mStackView = UIStackView(arrangedSubviews: [imageView, nameLabel])
        mStackView.axis = .vertical
        mStackView.spacing = 20
        
        self.addSubview(mStackView)
    }
    
    private func setupConstraint() {
        mStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
