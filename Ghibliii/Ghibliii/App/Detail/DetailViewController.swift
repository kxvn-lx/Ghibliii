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
    private var originalHeight: CGFloat = 425
    
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
        mScrollView.delegate = self
        
        // Setup close button
        let closeButton = UIButton(type: .close)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().inset(NSDirectionalEdgeInsets(top: 20 + 44, leading: 20, bottom: 0, trailing: 0))
        }
        
        // Link Description label with action
        let tap = UITapGestureRecognizer(target: self, action: #selector(showMoreLessButtonTapped))
        descriptionLabel.isUserInteractionEnabled = true
        descriptionLabel.addGestureRecognizer(tap)
        
        // Setup views
        mStackView = UIStackView(arrangedSubviews: [descriptionLabel, directorLabel, producerLabel])
        mStackView.axis = .vertical
        
        mScrollView.addSubview(mStackView)
    }
    
    private func setupConstraint() {
        mScrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        detailHeroView.snp.makeConstraints { (make) in
            make.width.top.equalToSuperview()
            make.height.equalTo(originalHeight)
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
    
    @objc private func showMoreLessButtonTapped() {
        descriptionLabel.numberOfLines = descriptionLabel.numberOfLines == 0 ? 2 : 0
        UIView.animate(withDuration: 0.0625) {
            self.descriptionLabel.superview?.layoutIfNeeded()
        }
    }
    
}

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let defaultTop: CGFloat = 0
        
        var currentTop = defaultTop
        if offset < 0 {
            currentTop = offset
            detailHeroView.snp.updateConstraints { (make) in
                make.height.equalTo(originalHeight - offset)
            }
            detailHeroView.filmImageView.snp.updateConstraints { (make) in
                make.top.equalToSuperview().offset(20 - offset)
            }
        }
        else {
            detailHeroView.snp.updateConstraints { (make) in
                make.height.equalTo(originalHeight)
            }
        }
        
        detailHeroView.snp.updateConstraints { (make) in
            make.top.equalTo(currentTop)
        }
    }
}
