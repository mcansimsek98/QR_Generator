//
//  UIView+Extension.swift
//  QR_Generator
//
//  Created by Mehmet Can Şimşek on 5.06.2023.
//

import UIKit

extension UIView {
    @IBInspectable
     var cornerRadius: CGFloat {
         get {
             return layer.cornerRadius
         }
         set {
             layer.cornerRadius = newValue
         }
     }
}


extension UIView {
    func setVerticalGradientBackground(startColor: UIColor, endColor: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        guard let backgroundGradientImage = gradientLayer.createGradientImage() else { return }
        backgroundColor = UIColor(patternImage: backgroundGradientImage)
    }
}

extension CAGradientLayer {
    func createGradientImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        render(in: context)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return gradientImage
    }
}
