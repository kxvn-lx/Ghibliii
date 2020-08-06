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

protocol DetailViewDelegate: class {
    func displayNeedsRefresh(withNewRecord record: CKRecord?)
}

class DetailViewController: UIViewController {
    var film: Film! {
        didSet {
            descriptionLabel.text = film.filmDescription
            directorLabel.text = "Director: \(film.director)"
            producerLabel.text = "Producer: \(film.producer)"
            filmRecord = film.record
        }
    }
    
    private var hasWatched: Bool = false {
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
    private let addToWatchedButton: DetailedButton = {
        let button = DetailedButton(title: "Add to watched bucket")
        button.backgroundColor = .systemBlue
        return button
    }()
    private let removeFromWatchedButton: DetailedButton = {
        let button = DetailedButton(title: "Remove from watched bucket")
        button.isHidden = true
        button.backgroundColor = .systemRed
        return button
    }()
    private let disclosureLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .tertiaryLabel

        return label
    }()
    
    private var infoStackView: UIStackView!
    private var mStackView: UIStackView!
    
    weak var delegate: DetailViewDelegate?
    
    // MARK: - View lifecycle
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
        checkConnectivity()
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
            let inset = NSDirectionalEdgeInsets(top: UIDevice.current.hasNotch ? 20 + 44 : 20 + 10, leading: 20, bottom: 0, trailing: 0)
            make.left.top.equalToSuperview().inset(inset)
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
        
        mStackView = UIStackView(arrangedSubviews: [addToWatchedButton, removeFromWatchedButton, disclosureLabel, infoStackView])
        mStackView.axis = .vertical
        mStackView.spacing = 20
        
        mScrollView.addSubview(mStackView)
    }
    
    private func checkConnectivity() {
        if !ReachabilityHelper.shared.isConnectedToNetwork() {
            disclosureLabel.text =
                """
                Yikes! This feature requires internet connectivity to function.
                Please make sure your device is connected to one.
                """
            // Internet
            UIView.animate(withDuration: 0.25) {
                self.addToWatchedButton.isEnabled = ReachabilityHelper.shared.isConnectedToNetwork()
                self.removeFromWatchedButton.isEnabled = ReachabilityHelper.shared.isConnectedToNetwork()
                self.disclosureLabel.isHidden = ReachabilityHelper.shared.isConnectedToNetwork()
            }
            
        } else if FileManager.default.ubiquityIdentityToken == nil {
            disclosureLabel.text =
                """
                Oops! This is one of the iCloud based feature.
                Please log into your iCloud on your device to use it.
                """
            UIView.animate(withDuration: 0.25) {
                self.addToWatchedButton.isEnabled = FileManager.default.ubiquityIdentityToken != nil
                self.removeFromWatchedButton.isEnabled = FileManager.default.ubiquityIdentityToken != nil
                self.disclosureLabel.isHidden = FileManager.default.ubiquityIdentityToken != nil
            }
        }
        
        if !disclosureLabel.isHidden {
            mStackView.setCustomSpacing(10, after: addToWatchedButton)
            mStackView.setCustomSpacing(10, after: removeFromWatchedButton)
        }
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
            let sfSafariVC = SFSafariViewController(url: url)
            present(sfSafariVC, animated: true)
        }
    }
    
    @objc private func addToWatchedButtonTapped(_ sender: UIButton) {
        // Display loading indicator
        let loadingVC = LoadingViewController()
        add(loadingVC)
        loadingVC.view.frame = self.view.frame
        
        CloudKitEngine.shared.save(film: film) { [weak self] (result) in
            switch result {
            case .success(let record):
                DispatchQueue.main.async {
                    loadingVC.remove()
                    self?.animateButtonOut(sender)
                }
                TapticHelper.shared.successTaptic()
                self?.delegate?.displayNeedsRefresh(withNewRecord: record)
                
            case .failure(let error):
                DispatchQueue.main.async {
                    AlertHelper.shared.presentOKAction(andMessage: error.rawValue, to: self)
                    loadingVC.remove()
                }
                TapticHelper.shared.errorTaptic()
            }
        }
    }
    
    @objc private func removeFromWatchedButtonTapped(_ sender: UIButton) {
        let loadingVC = LoadingViewController()
        add(loadingVC)
        loadingVC.view.frame = self.view.frame
        
        CloudKitEngine.shared.remove(filmWithRecord: filmRecord) { [weak self] (result) in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    loadingVC.remove()
                    self?.animateButtonOut(sender)
                }
                TapticHelper.shared.lightTaptic()
                self?.delegate?.displayNeedsRefresh(withNewRecord: nil)
                
            case .failure(let error):
                DispatchQueue.main.async {
                    AlertHelper.shared.presentOKAction(andMessage: error.rawValue, to: self)
                    loadingVC.remove()
                }
                TapticHelper.shared.errorTaptic()
            }
        }
    }
    
    private func expandScrollView(_ isExpanded: Bool) {
        let margin: CGFloat = 40
        originalScrollViewHeight = mStackView.frame.maxY + margin
        if self.view.frame.height > originalScrollViewHeight {
            originalScrollViewHeight = self.view.frame.height
        }
        
        mScrollView.layoutIfNeeded()
        if isExpanded && self.view.frame.height > mStackView.frame.maxY {
            mScrollView.contentSize.height = originalScrollViewHeight
            return
        }
        
        mScrollView.contentSize.height = isExpanded ? mStackView.frame.maxY + margin : originalScrollViewHeight
    }
    
    private func animateButtonOut(_ sender: UIButton) {
        sender.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.animate(withDuration: 0.25) {
                sender.isHidden = true
                sender.alpha = 0
            }
        }
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
