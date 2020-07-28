//
//  DetailViewController.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 28/7/20.
//

import UIKit
import Backend

class DetailViewController: UIViewController {
    
    var film: Film!
    private var detailHeroView: DetailHeroView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBarTitle("")
        view.backgroundColor = .systemBackground
        self.navigationController?.isNavigationBarHidden = true
        
        setupView()
        setupConstraint()
    }

    private func setupView() {
        detailHeroView = DetailHeroView(film: film)
        view.addSubview(detailHeroView)
        
        // Setup close button
        let closeButton = UIButton(type: .close)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().inset(NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 0))
        }
    }
    
    private func setupConstraint() {
        detailHeroView.snp.makeConstraints { (make) in
            make.width.top.equalToSuperview()
            make.height.equalTo(400)
        }
    }
    
    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }


}
