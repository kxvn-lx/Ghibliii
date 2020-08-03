//
//  HomeCollectionViewCell.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 26/7/20.
//

import UIKit
import Backend
import Nuke

class HomeCollectionViewCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "FilmCell"
    private let filmImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray6
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 5
        imageView.layer.cornerCurve = .continuous
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private let filmName: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    private let filmYear: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()
    private var textStackView: UIStackView!
    private let watchedLabel: UIButton = {
        let button = UIButton()
        button.setTitle("Watched", for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption2)
        button.isUserInteractionEnabled = false
        button.addBlurEffect(style: .regular)
       return button
    }()
    
    var film: Film! {
        didSet {
            let url = URL(string: film.image)!
            var request = ImageRequest(url: url)
            request.processors = [ImageProcessors.Resize(size: self.bounds.size)]
            
            loadImage(with: request, into: filmImageView)
            
            filmName.text = film.title
            filmName.accessibilityLabel = film.title
            
            filmYear.text = film.releaseDate
            filmYear.accessibilityValue = "\(film.releaseDate)"
            
            watchedLabel.isHidden = !film.hasWatched
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func layoutSubviews() {
        setupConstraint()
    }
    
    override func setNeedsLayout() {
        filmImageView.snp.remakeConstraints { (make) in
            make.width.equalTo(self.frame.width)
            make.height.equalTo(self.frame.width * 1.5)
            make.top.equalToSuperview()
        }

        textStackView.snp.remakeConstraints { (make) in
            make.width.equalToSuperview()
            make.top.equalTo(filmImageView.snp.bottom).offset(10)
        }
        
        watchedLabel.snp.remakeConstraints { (make) in
            make.left.top.equalToSuperview().inset(NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 0))
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.filmImageView.image = UIImage()
        self.watchedLabel.isHidden = true
    }
    
    private func setupView() {
        addSubview(filmImageView)
        textStackView = UIStackView(arrangedSubviews: [filmName, filmYear])

        addSubview(textStackView)

        textStackView.alignment = .leading
        textStackView.axis = .vertical
        textStackView.distribution = .fillProportionally
        
        addSubview(watchedLabel)
    }
    
    private func setupConstraint() {
        filmImageView.snp.makeConstraints { (make) in
            make.width.equalTo(self.frame.width)
            make.height.equalTo(self.frame.width * 1.5)
            make.top.equalToSuperview()
        }
        
        textStackView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.top.equalTo(filmImageView.snp.bottom).offset(10)
        }
        
        watchedLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().inset(NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 0))
        }
    }
}
