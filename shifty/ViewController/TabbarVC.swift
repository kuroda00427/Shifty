//
//  TabbarVC.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/08/18.
//

import Foundation
import UIKit

class TabbarVC:UITabBarController{
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    private func setUpView(){
        UITabBar.appearance().barTintColor = UIColor.rgb(red: 242, green: 250, blue: 224)
        

        viewControllers?.enumerated().forEach({ (index, viewController) in
            switch index {
            case 0:
                viewController.tabBarItem.selectedImage = UIImage(named:"calendar")?.resize(size: .init(width: 25, height: 25))
                viewController.tabBarItem.image = UIImage(named:"calendar")?.resize(size: .init(width: 25, height: 25))
                viewController.tabBarItem.title = "マイシフト"
            
            case 1:
                viewController.tabBarItem.selectedImage = UIImage(named:"group")?.resize(size: .init(width: 25, height: 25))
                viewController.tabBarItem.image = UIImage(named:"group")?.resize(size: .init(width: 25, height: 25))
                viewController.tabBarItem.title = "シフト"

            case 2:
                viewController.tabBarItem.selectedImage = UIImage(named:"register")?.resize(size: .init(width: 25, height: 25))
                viewController.tabBarItem.image = UIImage(named:"register")?.resize(size: .init(width: 25, height: 25))
                viewController.tabBarItem.title = "登録"
            case 3:
                viewController.tabBarItem.selectedImage = UIImage(named:"setting")?.resize(size: .init(width: 25, height: 25))
                viewController.tabBarItem.image = UIImage(named:"setting")?.resize(size: .init(width: 25, height: 25))
                viewController.tabBarItem.title = "その他"

            default:
                break
            }
        })
    }
}
