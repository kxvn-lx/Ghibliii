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
    private var filmPeople = [People]()
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
    private var originalHeight: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: return 450
        default: return 500
        }
    }
    
    private var mStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarTitle("")
        view.backgroundColor = .systemBackground
        self.navigationController?.isNavigationBarHidden = true
        
        setupView()
        setupConstraint()
        fetchFilmPeople()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mScrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
            make.left.top.equalToSuperview().inset(NSDirectionalEdgeInsets(top: UIDevice.current.hasNotch ? 20 + 44 : 20 + 10, leading: 20, bottom: 0, trailing: 0))
        }
        
        // Link Description label with action
        let tap = UITapGestureRecognizer(target: self, action: #selector(showMoreLessButtonTapped))
        descriptionLabel.isUserInteractionEnabled = true
        descriptionLabel.addGestureRecognizer(tap)
        
        // Setup views
        mStackView = UIStackView(arrangedSubviews: [descriptionLabel, directorLabel, producerLabel])
        mStackView.addBackgroundColor(.secondarySystemBackground, withCornerRadius: 10)
        mStackView.isLayoutMarginsRelativeArrangement = true
        mStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        mStackView.axis = .vertical
        mStackView.setCustomSpacing(20, after: descriptionLabel)
        
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
    }
    
    private func fetchFilmPeople() {
        API.shared.getData(type: People.self, fromEndpoint: .people(id: nil)) { [weak self] (peoples) in
            guard let peoples = peoples else { return }
            var selectedPeoples = [People]()
            
            for people in peoples {
                let peopleFilmID = people.films
                for id in peopleFilmID {
                    let parsedID = id.replacingOccurrences(of: "https://ghibliapi.herokuapp.com/films/", with: "")
                    if parsedID == self?.film.id {
                        if !selectedPeoples.contains(people) {
                            selectedPeoples.append(people)
                        }
                    }
                }
            }
            self?.filmPeople = selectedPeoples
            
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
            viewDidLayoutSubviews()
            mScrollView.updateContentView()
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
            
            if offset < -300 {
                closeTapped()
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
