//
//  UIImageExtension.swift
//  practice
//
//  Created by 黒田拓杜 on 2021/05/17.
//

import UIKit

extension UIImage {
    func resize(size _size: CGSize) -> UIImage? {
            let widthRatio = _size.width / size.width
            let heightRatio = _size.height / size.height
            let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
            
            let resizeSize = CGSize(width: size.width * ratio, height: size.height * ratio)
            
            UIGraphicsBeginImageContextWithOptions(resizeSize, false, 0.0)
            draw(in: CGRect(origin: .zero, size: resizeSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return resizedImage
        }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
}
