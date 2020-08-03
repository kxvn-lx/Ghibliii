//
//  DetailViewController.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 28/7/20.
//

import UIKit
import Backend
import SafariServices
import CloudKit
import SPAlert

class DetailViewController: UIViewController {
    
    var film: Film! {
        didSet {
            descriptionLabel.text = film.filmDescription
            directorLabel.text = "Director: \(film.director)"
            producerLabel.text = "Producer: \(film.producer)"
            filmRecord = film.record
        }
    }
    var hasWatched: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.addToWatchedButton.isHidden = self.hasWatched
                self.removeFromWatchedButton.isHidden = !self.hasWatched
            }
            
        }
    }
    private var filmRecord: CKRecord? {
        didSet {
            if filmRecord != nil {
                hasWatched = true
            }
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
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        return label
    }()
    private let directorLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        return label
    }()
    private let producerLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        return label
    }()
    private let imdbLinkButton: UIButton = {
        let button = UIButton()
        button.setTitle("see on IMDB", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(UIColor.systemBlue.withAlphaComponent(0.9), for: .highlighted)
        button.titleLabel?.font = .preferredFont(forTextStyle: .callout)
        return button
    }()
    private var originalHeight: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: return 450
        default: return 500
        }
    }
    private var originalScrollViewHeight: CGFloat!
    private var addToWatchedButton: DetailedButton = {
        let button = DetailedButton(title: "Add to watched bucket!")
        button.backgroundColor = .systemBlue
        return button
    }()
    private var removeFromWatchedButton: DetailedButton = {
        let button = DetailedButton(title: "Remove from watched bucket")
        button.isHidden = true
        button.backgroundColor = .systemRed
        return button
    }()
    
    private var infoStackView: UIStackView!
    private var mStackView: UIStackView!
    
    //MARK: - View lifecycle
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
        originalScrollViewHeight = mStackView.frame.maxY + 40
        expandScrollView(false)
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
            make.left.top.equalToSuperview().inset(NSDirectionalEdgeInsets(top: UIDevice.current.hasNotch ? 20 + 44 : 20 + 10, leading: 20, bottom: 0, trailing: 0))
        }
        
        // Link Description label with action
        let tap = UITapGestureRecognizer(target: self, action: #selector(showMoreLessButtonTapped))
        descriptionLabel.isUserInteractionEnabled = true
        descriptionLabel.addGestureRecognizer(tap)
        
        // Setup button
        imdbLinkButton.addTarget(self, action: #selector(imdbButtonTapped), for: .touchUpInside)
        addToWatchedButton.addTarget(self, action: #selector(addToWatchedButtonTapped), for: .touchUpInside)
        removeFromWatchedButton.addTarget(self, action: #selector(removeFromWatchedButtonTapped), for: .touchUpInside)
        
        // Setup views
        infoStackView = UIStackView(arrangedSubviews: [descriptionLabel, directorLabel, producerLabel, imdbLinkButton])
        infoStackView.addBackgroundColor(.secondarySystemBackground)
        infoStackView.isLayoutMarginsRelativeArrangement = true
        infoStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        infoStackView.axis = .vertical
        infoStackView.setCustomSpacing(20, after: descriptionLabel)
        
        mStackView = UIStackView(arrangedSubviews: [addToWatchedButton, removeFromWatchedButton, infoStackView])
        mStackView.axis = .vertical
        mStackView.spacing = 20
        
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
            switch UIDevice.current.userInterfaceIdiom {
            case .phone: make.width.equalToSuperview().multipliedBy(0.95)
            case .pad: make.width.equalToSuperview().multipliedBy(0.7)
            default: break
            }
            make.top.equalTo(detailHeroView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        addToWatchedButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
        }
        
        removeFromWatchedButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
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
        } completion: { [self] (_) in
            expandScrollView(descriptionLabel.numberOfLines == 0)
        }
    }
    
    @objc private func imdbButtonTapped() {
        if let url = URL(string: film.imdbLink) {
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }
    }
    
    @objc private func addToWatchedButtonTapped(_ sender: UIButton) {
        CloudKitEngine.shared.save(film: film) { [weak self] (result) in
            switch result {
            case .success(let record):
                self?.hasWatched = true
                self?.filmRecord = record
                DispatchQueue.main.async {
                    SPAlert.present(message: "Added to your watched bucket")
                }
                TapticHelper.shared.successTaptic()
                
            case .failure(let error):
                DispatchQueue.main.async {
                    SPAlert.present(message: error.localizedDescription)
                }
                TapticHelper.shared.errorTaptic()
            }
        }
    }
    
    @objc private func removeFromWatchedButtonTapped(_ sender: UIButton) {
        CloudKitEngine.shared.remove(filmWithRecord: filmRecord) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.hasWatched = false
                self?.filmRecord = nil
                DispatchQueue.main.async {
                    SPAlert.present(message: "Removed from your watched bucket")
                }
                TapticHelper.shared.lightTaptic()
            case .failure(let error):
                DispatchQueue.main.async {
                    SPAlert.present(message: error.localizedDescription)
                }
                TapticHelper.shared.errorTaptic()
            }
        }
    }
    
    private func expandScrollView(_ isExpanded: Bool) {
        let margin: CGFloat = 40
        mScrollView.contentSize.height = isExpanded ? mStackView.frame.maxY + margin : originalScrollViewHeight
    }
    
}

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // only implement the animation on phone
        if UIDevice.current.userInterfaceIdiom == .phone {
            let offset = scrollView.contentOffset.y
            let defaultTop: CGFloat = 0
            
            var currentTop = defaultTop
            if offset < 0 {
                currentTop = offset
                detailHeroView.snp.updateConstraints { (make) in
                    make.height.equalTo(originalHeight - offset * 1.5)
                }
                detailHeroView.filmImageView.snp.updateConstraints { (make) in
                    make.top.equalToSuperview().offset(20 - offset)
                    make.width.equalTo(200 - offset / 3)
                    make.height.equalTo(300 - offset / 3)
                }
                
                if offset < -230 {
                    closeTapped()
                }
            }
            
            detailHeroView.snp.updateConstraints { (make) in
                make.top.equalTo(currentTop)
            }
        }
    }
}
