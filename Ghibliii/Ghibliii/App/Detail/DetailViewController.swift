//
//  DetailViewController.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 28/7/20.
//

import UIKit
import Backend

class DetailViewController: UIViewController {
    
    var film: Film! {
        didSet {
            titleLabel.text = film.title
            descriptionLabel.text = film.filmDescription
            directorLabel.text = "Director: \(film.director)"
            producerLabel.text = "Producer: \(film.producer)"
        }
    }
    private var detailHeroView: DetailHeroView!
    private let mScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        return label
    }()
    private let directorLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        return label
    }()
    private let producerLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        return label
    }()
    private let showMoreLessButton: UIButton = {
        let button = UIButton()
        button.setTitle("Show more", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .callout)
        return button
    }()
    
    private var mStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarTitle("")
        view.backgroundColor = .systemBackground
        self.navigationController?.isNavigationBarHidden = true
        
        setupView()
        setupConstraint()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mScrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
    }
    
    private func setupView() {
        view.addSubview(mScrollView)
        
        detailHeroView = DetailHeroView(film: film)
        mScrollView.addSubview(detailHeroView)
        
        // Setup close button
        let closeButton = UIButton(type: .close)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().inset(NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 0))
        }
        
        // Link button with action
        showMoreLessButton.addTarget(self, action: #selector(showMoreLessButtonTapped), for: .touchUpInside)
        
        // Setup views
        mStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, showMoreLessButton, directorLabel, producerLabel])
        mStackView.axis = .vertical
        
        mScrollView.addSubview(mStackView)
        
        mStackView.setCustomSpacing(20, after: showMoreLessButton)
    }
    
    private func setupConstraint() {
        mScrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        detailHeroView.snp.makeConstraints { (make) in
            make.width.top.equalToSuperview()
            make.height.equalTo(400)
        }
        
        mStackView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.95)
            make.top.equalTo(detailHeroView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc private func showMoreLessButtonTapped(_ sender: UIButton) {
        sender.setTitle(descriptionLabel.numberOfLines == 0 ? "Show more" : "Show less", for: .normal)
        descriptionLabel.numberOfLines = descriptionLabel.numberOfLines == 0 ? 2 : 0
        UIView.animate(withDuration: 0.0625) {
            self.descriptionLabel.superview?.layoutIfNeeded()
        }
    }
    
    
}
