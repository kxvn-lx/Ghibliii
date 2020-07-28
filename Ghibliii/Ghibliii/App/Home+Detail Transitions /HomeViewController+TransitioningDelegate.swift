//
//  HomeViewController+TransitioningDelegate.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 28/7/20.
//

import UIKit

extension HomeViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}
