//
//  BackGround.swift
//  practice
//
//  Created by 黒田拓杜 on 2021/06/10.
//

import Foundation
import UIKit

extension UIViewController {
    func gradiationAndShadow(view:UIView,red:CGFloat,green:CGFloat,blue:CGFloat){
        if view.layer.sublayers?[0] as? CAGradientLayer != nil{
            view.layer.sublayers?.remove(at: 0)
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame =   view.bounds
        gradientLayer.colors = [UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor,
                                UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint.init(x: 1, y: 1)
        gradientLayer.endPoint = CGPoint.init(x: 0, y:1)
        gradientLayer.cornerRadius = 5
        view.layer.insertSublayer(gradientLayer,at:0)
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.6
        view.layer.shadowRadius = 4
        
    }
    func gradiation(view:UIView,red:CGFloat,green:CGFloat,blue:CGFloat){
        if view.layer.sublayers?[0] as? CAGradientLayer != nil{
            view.layer.sublayers?.remove(at: 0)
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame =   view.bounds
        gradientLayer.colors = [UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor,
                                UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint.init(x: 1, y: 1)
        gradientLayer.endPoint = CGPoint.init(x: 0, y:1)
        gradientLayer.cornerRadius = 5
        view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    func grad2(view:UIView,reds:CGFloat,greens:CGFloat,blues:CGFloat,rede:CGFloat,greene:CGFloat,bluee:CGFloat){
        if view.layer.sublayers?[0] as? CAGradientLayer != nil{
            view.layer.sublayers?.remove(at: 0)
        }

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame =   view.bounds
        gradientLayer.colors = [UIColor(red: reds / 255, green: greens / 255, blue: blues / 255, alpha: 1).cgColor,
                                UIColor(red: rede / 255, green: greene / 255, blue: bluee / 255, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint.init(x: 1, y:1)
        gradientLayer.cornerRadius = 5
        view.layer.insertSublayer(gradientLayer, at: 0)
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.6
        view.layer.shadowRadius = 4
    }
    
    
    func buttonPushAnimation(view:UIView){
        UIView.animate(withDuration: 0.01) {
            view.layer.shadowColor = UIColor.clear.cgColor
            view.transform = view.transform.translatedBy(x: 0, y: 4)
        }
    }
    func buttonPullAnimation(view:UIView){
        UIView.animate(withDuration: 0.01) {
            
            view.layer.shadowColor = UIColor.black.cgColor
            view.transform = CGAffineTransform.identity
        }
    }
    func addShadow(view:UIView){
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 4
        
    }
}
extension UITableViewCell{
    func buttonPushAnimation(view:UIView){
        UIView.animate(withDuration: 0.01) {
            view.layer.shadowColor = UIColor.clear.cgColor
            view.transform = view.transform.translatedBy(x: 0, y: 4)
        }
    }
    func buttonPullAnimation(view:UIView){
        UIView.animate(withDuration: 0.01) {
            
            view.layer.shadowColor = UIColor.black.cgColor
            view.transform = CGAffineTransform.identity
        }
    }
}
extension UICollectionViewCell{
    func addShadow(view:UIView){
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.6
        view.layer.shadowRadius = 4
        
    }
    
}
