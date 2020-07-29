//
//  DetailHeroView.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 28/7/20.
//

import UIKit
import Backend
import Nuke

class DetailHeroView: UIView {
    
    private let filmBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray6
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private let filmBackgroundBlurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        return blurredEffectView
    }()
    let filmImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray5
        imageView.contentMode = .scaleToFill
        
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize.zero
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowRadius = 10
        imageView.layer.masksToBounds =  false
        return imageView
    }()
    private var textStackView: UIStackView!
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2 ).pointSize, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()
    private let rtLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()
    var film: Film! {
        didSet {
            loadImage(with: URL(string: FILM_IMAGE[film.id]!)!, into: filmBackgroundImageView)
            loadImage(with: URL(string: FILM_IMAGE[film.id]!)!, into: filmImageView)
            
            titleLabel.text = film.title
            yearLabel.text = film.releaseDate
            rtLabel.text = "Rotten tomatoes: \(film.rtScore)%"
        }
    }
    
    // MARK: - View lifecycle
    required init(film: Film) {
        super.init(frame: .zero)
        defer {
            self.film = film
        }
        self.commonSetup()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonSetup()
    }
    
    private func commonSetup() {
        setupView()
        setupConstraint()
    }
    
    private func setupView() {
        addSubview(filmBackgroundImageView)
        filmBackgroundImageView.addSubview(filmBackgroundBlurView)
        
        addSubview(filmImageView)
        addSubview(titleLabel)
        
        textStackView = UIStackView(arrangedSubviews: [yearLabel, rtLabel])
        textStackView.alignment = .center
        textStackView.axis = .vertical
        
        addSubview(textStackView)
    }
    
    private func setupConstraint() {
        filmBackgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        filmBackgroundBlurView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        filmImageView.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(300)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20 + 44)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(filmImageView.snp.bottom).offset(20)
        }
        
        textStackView.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        

    }
}
