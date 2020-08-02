//
//  DetailedButton.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 2/8/20.
//

import UIKit

class DetailedButton: UIButton {
    
    private var highlightedBackgroundColor: UIColor?
    private var temporaryBackgroundColor: UIColor?
    private let highlightedAlphaValue: CGFloat = 0.9
    
    required init(title: String, image: UIImage) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setupView()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                if temporaryBackgroundColor == nil {
                    if backgroundColor != nil {
                        if let highlightedColor = highlightedBackgroundColor {
                            temporaryBackgroundColor = backgroundColor
                            backgroundColor = highlightedColor
                        } else {
                            temporaryBackgroundColor = backgroundColor
                            backgroundColor = temporaryBackgroundColor?.withAlphaComponent(highlightedAlphaValue)
                        }
                    }
                }
            } else {
                if let temporaryColor = temporaryBackgroundColor {
                    backgroundColor = temporaryColor
                    temporaryBackgroundColor = nil
                }
            }
        }
    }
    
    private func setupView() {
        self.titleLabel?.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .medium)
        
        layer.cornerRadius = 12.5
        layer.cornerCurve = .continuous
        setTitleColor(.white, for: .normal)
        tintColor = .white
        
        setTitleColor(UIColor.white.withAlphaComponent(highlightedAlphaValue), for: .highlighted)
        self.adjustsImageWhenHighlighted = false
    }
    
}
