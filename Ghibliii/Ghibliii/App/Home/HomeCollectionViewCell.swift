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
    
    static let REUSE_IDENTIFIER = "FilmCell"
    let filmImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray6
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 5
        imageView.layer.cornerCurve = .continuous
        imageView.layer.masksToBounds = true
        return imageView
    }()
    let filmName: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    let filmYear: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()
    var textStackView: UIStackView!
    
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
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.filmImageView.image = UIImage()
    }
    
    private func setupView() {
        addSubview(filmImageView)
        textStackView = UIStackView(arrangedSubviews: [filmName, filmYear])

        addSubview(textStackView)

        textStackView.alignment = .leading
        textStackView.axis = .vertical
        textStackView.distribution = .fillProportionally
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
    }
}
