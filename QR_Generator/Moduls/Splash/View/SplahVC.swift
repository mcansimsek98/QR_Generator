//
//  SplahVC.swift
//  QR_Generator
//
//  Created by Mehmet Can Şimşek on 5.06.2023.
//

import UIKit

class SplahVC: UIViewController {
    @IBOutlet weak var splashImageView: UIImageView!
    var images: [UIImage] = []
    var frameAnimator: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGIFImages()
        startGIF()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let destinationVC = MainVC()
            let navigationController = UINavigationController(rootViewController: destinationVC)
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.transitioningDelegate = self
            self.present(navigationController, animated: true, completion: nil)
            self.stopGIF()
        }
    }
    
    func loadGIFImages() {
        guard let gifURL = Bundle.main.url(forResource: "qrGift", withExtension: "gif"),
              let source = CGImageSourceCreateWithURL(gifURL as CFURL, nil) else {
            return
        }
        
        let totalCount = CGImageSourceGetCount(source)
        
        for i in 0..<totalCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let uiImage = UIImage(cgImage: cgImage)
                images.append(uiImage)
            }
        }
    }
    
    
    func startGIF() {
        var currentIndex = 0
        frameAnimator = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.splashImageView.image = self.images[currentIndex]
            currentIndex = (currentIndex + 1) % self.images.count
        }
        frameAnimator?.fire()
    }
    
    func stopGIF() {
        frameAnimator?.invalidate()
        frameAnimator = nil
    }
}

extension SplahVC: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransitionAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransitionAnimator()
    }
    
}
