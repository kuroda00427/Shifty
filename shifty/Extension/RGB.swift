//
//  RGB.swift
//  practice
//
//  Created by 黒田拓杜 on 2021/05/12.
//

import Foundation
import UIKit

extension UIColor{
    static func rgb(red: CGFloat, green:CGFloat, blue: CGFloat) -> UIColor{
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
        
    }
    static func backgroundColor0() -> UIColor {
        return  UIColor.rgb(red: 238, green: 224, blue: 190)

    }
    static func backgroundColor1() -> UIColor {
        return  UIColor.rgb(red: 240, green: 234, blue: 210)

    }
    static func backgroundColor2() -> UIColor {
        return  UIColor.rgb(red: 242, green: 250, blue: 224)

    }
    static func cellColor() -> UIColor{
        return  UIColor.rgb(red: 240, green: 238, blue: 210)

    }
    
    static func cellYellowColor() -> UIColor{
        return  UIColor.rgb(red: 255, green: 255, blue: 210)

    }
    static func navigationBarColor() -> UIColor {
        return  UIColor.rgb(red: 242, green: 250, blue: 224)

    }

}

