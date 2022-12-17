//
//  AddShiftCVCell.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/10/12.
//

import Foundation

import UIKit
//import FSCalendar
//import CalculateCalendarLogic

import Firebase





class AddShiftCVCell4: UICollectionViewCell{
    
 
    var confirmStartDayL:UILabel?
    var confirmEndDayL:UILabel?
    var confirmDeadlineL:UILabel?
    var confirmHolidayL:UILabel?
    
    
    weak var delegate: CollectionViewReloadDataDelegate!

    weak var alertDelegate:failedAlertPresentDelegate!
    weak var dismissDelegate:dismissDelegate!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        setUpButton()
    }
    
    
    
    private func setUpView(){
        let screenWidth = Int(UIScreen.main.bounds.size.width)
        let screenHeight = Int(UIScreen.main.bounds.size.height)

        self.backgroundColor = UIColor.rgb(red: 240, green: 238, blue: 210)
        let stack:UIStackView = UIStackView()
        stack.layer.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255).cgColor
        stack.axis = .vertical
        stack.layer.borderColor = UIColor.black.cgColor
        stack.layer.borderWidth = 1
        stack.layer.cornerRadius = 15
        contentView.addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -230).isActive = true
        stack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7).isActive = true
        stack.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.18).isActive = true
        stack.distribution = .fillEqually

        let goNextL = UILabel(frame: CGRect(x:0, y: 0 , width:screenWidth  , height:screenHeight * 8/100))
        goNextL.text = "    左にスワイプで戻る"
        goNextL.textColor = .rgb(red: 40, green: 128, blue: 255)
        goNextL.textAlignment = NSTextAlignment.left
        self.contentView.addSubview(goNextL)
        
        addLabel(text:  "この内容でシフトを募集します", view: contentView, x: 0, y: 60, width: screenWidth, height: screenHeight * 10/100, soroe: .center, size: 17, font: 0)
        
        confirmStartDayL = UILabel()
        confirmEndDayL = UILabel()
        confirmHolidayL = UILabel()
        confirmDeadlineL = UILabel()
        confirmStartDayL?.textAlignment = NSTextAlignment.center
        confirmEndDayL?.textAlignment = NSTextAlignment.center
        confirmHolidayL?.textAlignment = NSTextAlignment.center
        confirmDeadlineL?.textAlignment = NSTextAlignment.center
        
        confirmStartDayL?.text = "開始日：未入力"
        confirmEndDayL?.text = "最終日：未入力"
        confirmHolidayL?.text = "休業日：なし"
        confirmDeadlineL?.text = "締め切り：未入力"
        stack.addArrangedSubview(confirmStartDayL!)
        stack.addArrangedSubview(confirmEndDayL!)
        stack.addArrangedSubview(confirmHolidayL!)
        stack.addArrangedSubview(confirmDeadlineL!)
   
        
    }
    private func setUpButton(){
//        let screenWidth = Int(UIScreen.main.bounds.size.width)
//        let screenHeight = Int(UIScreen.main.bounds.size.height)

//        let addShiftB = UIButton(type: UIButton.ButtonType.system)
////        addShiftB = UIButton()
//        addShiftB.frame(forAlignmentRect: CGRect(x:screenWidth/4, y:screenHeight/2,
//                                                  width:screenWidth/2, height:50))
//        addShiftB.setTitle("募集開始", for: .normal)
//        addShiftB.titleLabel?.font =  UIFont.systemFont(ofSize: 36)
//        addShiftB.setTitleColor(UIColor.black, for: .normal)
////        addShiftB.text = text
//
//        self.addSubview(addShiftB)
        let button = UIButton()
        //表示されるテキスト
        button.setTitle("募集開始", for: .normal)
        //テキストの色
        button.setTitleColor(UIColor.blue, for: .normal)
        //タップした状態のテキスト
//        button.setTitle("Tapped!", for: .highlighted)
        //タップした状態の色
        button.setTitleColor(UIColor.red, for: .highlighted)
        //サイズ
        button.frame = CGRect(x: 0,y: 0,width: 300,height: 50)
        //タグ番号
        button.tag = 1
        //配置場所
        button.layer.position = CGPoint(x: self.frame.width / 2, y: self.bounds.height / 2)
        //背景色
        button.backgroundColor = UIColor.yellow
        //角丸
        button.layer.cornerRadius = 10
        //ボーダー幅
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        //ボタンをタップした時に実行するメソッドを指定
        button.addTarget(self, action: #selector(self.addShiftButtonTapped), for:.touchUpInside)
        self.addSubview(button)
    }
 
    @objc func addShiftButtonTapped(){
        guard let startDate = AddShiftVC.startDate else {
            alertDelegate.failedAlert(sentence: "開始日を入力してください")

            return
        }
        guard let endDate = AddShiftVC.endDate else {
            alertDelegate.failedAlert(sentence: "最終日を入力してください")
            return
        }
        let holidayInt = AddShiftVC.holiday ?? []
        let holiday = holidayInt.map { delegate.makeDaySForFirestoreFromIntArray(day: $0) }
        let deadline = AddShiftVC.deadline ?? endDate
        if startDate > endDate {
            alertDelegate.failedAlert(sentence: "開始日と終了日の前後関係が正しくありません")
            return
        }
        let startDateTmp = Calendar.current.date(byAdding: .day, value: 31, to: startDate)
        if startDateTmp! < endDate {
            alertDelegate.failedAlert(sentence: "一度に募集できる期間は31日までです")
            return
        }
        let start = getDay(startDate)
        let end = getDay(endDate)
        guard let shopId = val.user?.shopIDs[0] else { return }
        guard let shopName = val.user?.shopNames[shopId] else {return}
        let alert = UIAlertController(title: "以下の日程で\(shopName)でのシフトを募集します", message: "\(start[1])/\(start[2])〜\(end[1])/\(end[2])", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
            Firestore.firestore().collection("shops").document(shopId).collection("shifts").addDocument(data: ["startDate":startDate,"endDate":endDate,"deadline":deadline,"holiday":holiday]){(err) in
                if let err = err {
                    print(err)
                    self.alertDelegate.failedAlert(sentence:"サーバへの保存に失敗しました")
                    return
                }

                let alert2 = UIAlertController(title: "募集しました", message: "", preferredStyle: UIAlertController.Style.alert)

                alert2.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
                    self.dismissDelegate.dismiss(animated: true, completion: nil)
                })
                self.alertDelegate.present(view:alert2, animated: true)

                
            }
            
        })
        self.alertDelegate.present(view:alert, animated: true)
        
        
    }
 
}


protocol failedAlertPresentDelegate:AnyObject {
    func failedAlert(sentence:String)
    func present(view: UIViewController, animated: Bool)
    

}
protocol dismissDelegate:AnyObject {
    func dismiss(animated:Bool,completion: (() -> Void)?)
}
