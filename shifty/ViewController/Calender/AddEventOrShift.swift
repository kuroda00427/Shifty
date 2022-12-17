//
//  AddEventOrShift.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/10/25.
//

import Foundation
import UIKit
import PanModal


class AddEventOrShift :UIViewController{
    
    var shopOrWorkerTF = UITextView()
    var startTimeL = UILabel()
    var endTimeL = UILabel()

    var textL1 = UILabel()
    var textL2 = UILabel()
    let upImage = UIImage(systemName: "arrowtriangle.up.square")
    let downImage = UIImage(systemName: "arrowtriangle.down.square")

    let nextB = UIButton()
    let backB = UIButton()

    var startUpB = UIButton()
    var startDownB = UIButton()
    var endUpB = UIButton()
    var endDownB = UIButton()
    
    var addB = UIButton(type: .system)

    
    let height:CGFloat = 500
    let labelHeight:CGFloat = 48
    let width:CGFloat = UIScreen.main.bounds.size.width
    
    private var selectedShopIndex = val.user?.shopIDs.count ?? 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        startUpB.addTarget(self, action: #selector(tappedUpStartB), for: .touchUpInside)
        startDownB.addTarget(self, action: #selector(tappedDownStartB), for: .touchUpInside)
        endUpB.addTarget(self, action: #selector(tappedUpEndB), for: .touchUpInside)
        endDownB.addTarget(self, action: #selector(tappedDownEndB), for: .touchUpInside)
        addB.addTarget(self, action: #selector(tappedAddB), for: .touchUpInside)
        
        shopOrWorkerTF.delegate = self
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillShow(sender:)),
//            name: UIResponder.keyboardWillShowNotification,
//            object: nil)
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillHide(sender:)),
//            name: UIResponder.keyboardWillHideNotification,
//            object: nil)
        setDismissKeyboard()

    }
    
    
    @objc func tappedUpStartB() {
        var time = startTimeL.text
        time = upTimePar30minutes(time: time!)
        startTimeL.text = time
    }
    
    @objc func tappedDownStartB() {
        var time = startTimeL.text
        time = downTimePar30minutes(time: time!)
        startTimeL.text = time
    }
    @objc func tappedUpEndB( ) {
        var time = endTimeL.text
        time = upTimePar30minutes(time: time!)
        endTimeL.text = time
    }
    @objc func tappedDownEndB() {
        var time = endTimeL.text
        time = downTimePar30minutes(time: time!)
        endTimeL.text = time
    }
    @objc func tappedNextShopB(){
        backB.isEnabled = true
        backB.isHidden = false
        let shopCount = val.user?.shopIDs.count ?? 0
        selectedShopIndex += 1
        let shopID = val.user?.shopIDs[selectedShopIndex]
        let shopName = val.user?.shopNames[shopID!]
        shopOrWorkerTF.text = shopName
        if selectedShopIndex == shopCount - 1{
            nextB.isHidden = true
            nextB.isEnabled = false
        }
    }
    @objc func tappedBackShopB(){
        nextB.isEnabled = true
        nextB.isHidden = false
//        let shopCount = val.user?.shopIDs.count ?? 0
        selectedShopIndex -= 1
        let shopID = val.user?.shopIDs[selectedShopIndex]
        let shopName = val.user?.shopNames[shopID!]
        shopOrWorkerTF.text = shopName
        if selectedShopIndex == 0{
            backB.isHidden = true
            backB.isEnabled = false
        }
    }
    @objc func tappedAddB(){
        guard let selectedDate = CalenderVC.selectedDate else { return }
        let dayInt = makeIntArrayFromDate(selectedDate)
        let dayS = makeDaySForFirestoreFromIntArray(day: dayInt)
        let eventName = shopOrWorkerTF.text
        if eventName == "" || eventName == nil{
            failedAlert(sentence: "入力に不備があります")
            return
        }
        let startTime = startTimeL.text!
        let endTime = endTimeL.text!
        let dic = [
            "eventName":eventName!,
            "workingTime":[startTime,endTime]
        ] as [String : Any]
        var eventsAtDay = loadAny(Key: dayS) as? [[String:Any]]
        if eventsAtDay == nil{
            eventsAtDay = []
            print("nil")
        }
        print(dic)
        eventsAtDay!.append(dic)
        save().save(value: eventsAtDay!, Key: dayS)
        dismiss(animated: true, completion: nil)
    }
    
    private func upTimePar30minutes(time:String) -> String{
        let defaultWorkingUnit = val.user?.defaultWorkingUnit ?? 30
        var hour = Int(time.prefix(2))!
        var minute = Int(time.suffix(2))!
        minute += defaultWorkingUnit
        if minute >= 60{
            minute -= 60
            hour += 1
        }
        if hour >= 24{
            hour -= 24
        }
        return intToStringFormatter(time:hour) + ":" + intToStringFormatter(time:minute)
    }
    private func downTimePar30minutes(time:String) -> String{
        let defaultWorkingUnit = val.user?.defaultWorkingUnit ?? 30

        var hour = Int(time.prefix(2))!
        var minute = Int(time.suffix(2))!
        minute -= defaultWorkingUnit
        if minute < 0{
            minute += 60
            hour -= 1
        }
        if hour < 0{
            hour += 24
        }
        return intToStringFormatter(time:hour) + ":" + intToStringFormatter(time:minute)
    }
    private func intToStringFormatter(time:Int) -> String{
        if time < 10 {
            return "0" + String(time)
        }else{
            return String(time)
        }
    }
    

}
extension AddEventOrShift:UITextViewDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension AddEventOrShift:PanModalPresentable{
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    var panScrollable: UIScrollView? {
        nil
    }
    var longFormHeight: PanModalHeight{
        return .contentHeight(height)
    }
    var anchorModalToLongForm: Bool{
        return false
    }

}











extension AddEventOrShift{
    private func setUpView(){
        let defalutWorkingTime = val.user?.defaultWorkingTime ?? ["17:00" , "23:00"]
        let shopIDs = val.user!.shopIDs
        let IDcount = shopIDs.count
        var shopName = ""
        if IDcount != 0{
            shopName = (val.user!.shopNames[shopIDs[IDcount - 1]])!

        }
        
        
        view.backgroundColor = UIColor.backgroundColor1()
        guard let date = CalenderVC.selectedDate else { return }
        let day = makeIntArrayFromDate(date)
        let dayStr = makeDayForUserFromDayS(dayS: makeDaySForFirestoreFromIntArray(day: day))
        let titleL = UILabel()
        var titleText =  "予定を追加 " + "(" + dayStr  + ")"
        var alertLText = "注意：ここで追加した予定はシフトには反映されません"
        if val.user!.rank == 1{
            titleText =  "シフトを追加 " + "(" + dayStr  + ")"
            alertLText = "注意：ここで追加した予定は従業員には公開されません"

        }
        titleL.frame = CGRect(x: 0, y: 5, width: width, height: 30)
        titleL.text = titleText
        titleL.font = UIFont.boldSystemFont(ofSize: 15)
        titleL.textAlignment = .center
        view.addSubview(titleL)
        let alertL = UILabel()
        alertL.frame = CGRect(x: 0, y: 35, width: width, height: 20)
        alertL.text = alertLText
        alertL.font = UIFont.systemFont(ofSize: 10)
        alertL.textAlignment = .center
        view.addSubview(alertL)
        
        
        let backL1y:CGFloat = 75
        let backL1 = UILabel()
        
        backL1.frame = CGRect(x: 0, y: backL1y, width: width, height: labelHeight)
        backL1.backgroundColor = .white
        view.addSubview(backL1)
        let textL11 = UILabel()
        textL11.frame = CGRect(x: 0, y: backL1y, width: 60, height: labelHeight/2)
        textL11.backgroundColor = .clear
        var L11Text =  "イベント名"
        if val.user!.rank == 1{
            L11Text =  "従業員名"

        }
        textL11.text = L11Text
        textL11.textAlignment = .center
        textL11.font = UIFont.boldSystemFont(ofSize: 11)
        view.addSubview(textL11)
        shopOrWorkerTF.frame = CGRect(x: 68, y: backL1y + 6, width: width * 7/10 - 68, height: labelHeight)
        shopOrWorkerTF.text = shopName
        shopOrWorkerTF.backgroundColor = .clear
        shopOrWorkerTF.font = UIFont.systemFont(ofSize: 17)
        shopOrWorkerTF.textAlignment = .center

        shopOrWorkerTF.layer.borderColor = UIColor.clear.cgColor
        shopOrWorkerTF.layer.borderWidth = 1.0
        shopOrWorkerTF.layer.cornerRadius = 3
        view.addSubview(shopOrWorkerTF)
        nextB.setImage( upImage, for: .normal)
        backB.setImage(downImage, for: .normal)
        backB.frame = CGRect(x: width - 60, y: backL1y, width: 40, height: labelHeight)
        nextB.frame = CGRect(x: width - 100, y: backL1y, width: 40, height: labelHeight)
        view.addSubview(nextB)
        view.addSubview(backB)
        nextB.isHidden = true
        nextB.isEnabled = false
        if IDcount <= 1{
            backB.isHidden = true
            backB.isEnabled = false
        }
        
        let backL2y:CGFloat = backL1y + labelHeight + 15
        let backL2 = UILabel()
        backL2.frame = CGRect(x: 0, y: backL2y, width: width, height: labelHeight)
        backL2.backgroundColor = .white
        view.addSubview(backL2)
        let textL21 = UILabel()
        textL21.frame = CGRect(x: 0, y: backL2y, width: 60, height: labelHeight/2)
        textL21.backgroundColor = .clear
        textL21.text = "開始時刻"
        textL21.textAlignment = .center
        textL21.font = UIFont.boldSystemFont(ofSize: 11)
        view.addSubview(textL21)
        startTimeL.frame = CGRect(x: 68, y: backL2y, width: width * 7/10 - 68, height: labelHeight)
        startTimeL.text = defalutWorkingTime[0]
        startTimeL.font = UIFont.systemFont(ofSize: 18)
        startTimeL.textAlignment = .center
        startTimeL.layer.borderColor = UIColor.clear.cgColor
        view.addSubview(startTimeL)
      
        startUpB.setImage(upImage, for: .normal)
        startDownB.setImage(downImage, for: .normal)
        startUpB.frame = CGRect(x: width - 100, y: backL2y, width: 40, height: labelHeight)
        startDownB.frame = CGRect(x: width - 60, y: backL2y, width: 40, height: labelHeight)
        view.addSubview(startUpB)
        view.addSubview(startDownB)
        
        let backL3y:CGFloat = backL2y + labelHeight + 15
        let backL3 = UILabel()
        backL3.frame = CGRect(x: 0, y: backL3y, width: width, height: labelHeight)
        backL3.backgroundColor = .white
        view.addSubview(backL3)
        let textL31 = UILabel()
        textL31.frame = CGRect(x: 0, y: backL3y, width: 60, height: labelHeight/2)
        textL31.backgroundColor = .clear
        textL31.text = "終了時刻"
        textL31.textAlignment = .center
        textL31.font = UIFont.boldSystemFont(ofSize: 11)
        view.addSubview(textL31)
        endTimeL.frame = CGRect(x: 68, y: backL3y, width: width * 7/10 - 68, height: labelHeight)
        endTimeL.text = defalutWorkingTime[1]
        endTimeL.font = UIFont.systemFont(ofSize: 18)
        endTimeL.textAlignment = .center
        endTimeL.layer.borderColor = UIColor.clear.cgColor
        view.addSubview(endTimeL)
      
        endUpB.setImage(upImage, for: .normal)
        endDownB.setImage(downImage, for: .normal)
        endUpB.frame = CGRect(x: width - 100, y: backL3y, width: 40, height: labelHeight)
        endDownB.frame = CGRect(x: width - 60, y: backL3y, width: 40, height: labelHeight)
        view.addSubview(endUpB)
        view.addSubview(endDownB)
        
        let addBy = backL3y + labelHeight + 40
        let buttonWidth = width * 40/100
        addB.frame = CGRect(x: (width - buttonWidth)/2, y: addBy, width: buttonWidth, height: 40)
        addB.layer.backgroundColor = UIColor.white.cgColor
        addShadow(view: addB)
        addB.setTitle("＋予定を追加", for: .normal)
        view.addSubview(addB)

    }
}
