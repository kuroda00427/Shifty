//
//  AddShiftCVCell.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/10/12.
//

import Foundation

import UIKit






class TutorialCell1: UICollectionViewCell{
    
    
    let image = UIImageView()
    var textLabel:UILabel?
    var pageLabel:UILabel?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // スクリーンサイズの取得
//        let screenWidth = UIScreen.main.bounds.size.width
//        let screenHeight = UIScreen.main.bounds.size.height
        let screenW:CGFloat = contentView.frame.size.width
        let screenH:CGFloat = contentView.frame.size.height
        
        // 画像を読み込んで、準備しておいたimageSampleに設定
        image.image = UIImage(named: "tutorial1")
        // 画像のフレームを設定
        image.frame = CGRect(x:0, y:50, width:screenW * 84/100, height: screenH * 80/100)
        
        // 画像を中央に設定
        image.center = CGPoint(x:screenW/2, y:screenH/2 + 20)
        contentView.backgroundColor = UIColor.rgb(red: 254, green: 248, blue: 240)

        image.layer.shadowOffset = CGSize(width: 2, height: 2)
        image.layer.shadowColor = UIColor.black.cgColor
        image.layer.shadowOpacity = 0.6
        image.layer.shadowRadius = 4
        // 設定した画像をスクリーンに表示する
        self.contentView.addSubview(image)
        textLabel = UILabel(frame: CGRect(x:0, y: 40 , width:screenW  , height:screenH * 8/100))
        textLabel?.text = "右にスワイプで次へ・・・"
        textLabel?.textColor = .rgb(red: 40, green: 128, blue: 255)
        textLabel?.textAlignment = NSTextAlignment.right
        self.contentView.addSubview(textLabel!)
        
        pageLabel = UILabel(frame: CGRect(x:screenW * 0.05, y: 40 , width:screenW * 0.9  , height:screenH * 8/100))
        pageLabel?.text = "2"
        pageLabel?.font = UIFont(name: "system", size: 30.0)
        pageLabel?.textAlignment = NSTextAlignment.left
        self.contentView.addSubview(pageLabel!)
//        addLabel(text: "右にスワイプで次へ", view: contentView, x: 0 , y: 30, width: Int(screenH), height: 30, soroe: .right, size: 16, font: 0)
        
    }
    
    
    
    
    
}



