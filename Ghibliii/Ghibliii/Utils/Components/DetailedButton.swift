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
    private let scaleDuration: Double = 0.125
    private let scale: CGFloat = 0.97
    
    required init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setupView()
        self.addTarget(self, action: #selector(scaleDownButton), for: .touchDown)
        self.addTarget(self, action: #selector(completeAnimation), for: .touchUpInside)
        self.addTarget(self, action: #selector(identityScaleButton), for: .touchUpOutside)
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
    
    override var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                self.backgroundColor = self.backgroundColor?.withAlphaComponent(1.0)
            } else {
                self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.5)
            }
        }
    }
    
    private func setupView() {
        self.titleLabel?.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .medium)
        
        layer.cornerRadius = 12.5
        layer.cornerCurve = .continuous
        setTitleColor(.white, for: .normal)
        setTitleColor(UIColor.white.withAlphaComponent(0.25), for: .disabled)
        tintColor = .white
        
        setTitleColor(UIColor.white.withAlphaComponent(highlightedAlphaValue), for: .highlighted)
        self.adjustsImageWhenHighlighted = false
    }
    
    @objc private func scaleDownButton() {
        UIView.animate(withDuration: scaleDuration) {
            self.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
        }
    }
    
    @objc private func identityScaleButton() {
        UIView.animate(withDuration: scaleDuration) {
            self.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
        } completion: { (_) in
            UIView.animate(withDuration: self.scaleDuration) {
                self.transform = .identity
            }
        }

    }
    
    @objc private func completeAnimation() {
        UIView.animate(withDuration: scaleDuration) {
            self.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
        } completion: { (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + self.scaleDuration) {
                UIView.animate(withDuration: self.scaleDuration) {
                    self.transform = .identity
                }
            }

        }
    }
}
