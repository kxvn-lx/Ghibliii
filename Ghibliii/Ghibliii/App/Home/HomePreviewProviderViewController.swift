//
//  HomePreviewProviderViewController.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 6/8/20.
//

import UIKit
import Backend
import Nuke

class HomePreviewProviderViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray6
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let film: Film
    
    init(film: Film) {
        self.film = film
        super.init(nibName: nil, bundle: nil)
        
        setupView()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let url = URL(string: film.image)!
        var request = ImageRequest(url: url)
        request.processors = [ImageProcessors.Resize(size: imageView.bounds.size)]

        loadImage(with: url, into: imageView)
    }
    
    private func setupView() {
        view.addSubview(imageView)
        preferredContentSize = imageView.frame.size
    }
    
    private func setupConstraint() {
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
