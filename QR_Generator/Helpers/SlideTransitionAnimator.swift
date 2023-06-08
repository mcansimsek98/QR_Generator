//
//  SlideTransitionAnimator.swift
//  QR_Generator
//
//  Created by Mehmet Can Şimşek on 7.06.2023.
//

import UIKit

class SlideTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3 // Geçiş süresini istediğiniz değere ayarlayın
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toViewController.view)
        
        let screenWidth = UIScreen.main.bounds.width
        
        toViewController.view.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: containerView.frame.height)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromViewController.view.frame = CGRect(x: -screenWidth, y: 0, width: screenWidth, height: containerView.frame.height)
            toViewController.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: containerView.frame.height)
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
