//
//  ShiftSubVC.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/08/19.
//

import Foundation
import UIKit

class TimeSubVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var startTimeTF: UITextField!
    
    @IBOutlet weak var endTimeTF: UITextField!
    @IBOutlet weak var registerB: UIButton!
    @IBOutlet weak var dateOverL: UILabel!
    @IBAction func resetB(_ sender: Any) {
        guard let row = registerShiftVC.selectedRow else { return }

        registerShiftVC.days[row].startTime = nil
        registerShiftVC.days[row].endTime = nil

        startTimeTF.text = ""
        endTimeTF.text = ""
    }
    @IBAction func registerB(_ sender: Any) {
        guard let row = registerShiftVC.selectedRow else { return }

        if startTimeTF.text == "" {
            failedAlert(sentence: "出勤時刻を入力して下さい")
            return
        }
        if endTimeTF.text == ""{
            failedAlert(sentence: "退勤時刻を入力して下さい")
            return
        }
        let start = startTimeTF.text!
        var end = endTimeTF.text!
        
        if compareTwoDateStr_d1d2(d1: start, d2: end){
            let endh = end.prefix(2)
            let endhInt = Int(endh)! + 24
            end = String(endhInt) + ":" + end.suffix(2)
        }
        registerShiftVC.days[row].startTime = start
        registerShiftVC.days[row].endTime = end
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSubedTimes()
        startTimeTF.delegate = self
        endTimeTF.delegate = self

        startTimeTF.inputView = timePickerS
        endTimeTF.inputView = timePickerE
    }
    
    private func loadSubedTimes(){
        guard let row = registerShiftVC.selectedRow else { return }
        guard let start = registerShiftVC.days[row].startTime else {return}
        guard var end = registerShiftVC.days[row].endTime else { return }
        end = changeEndTime(end: end)
        
        startTimeTF.text = start
        endTimeTF.text = end
        subTimeDidChange()
    }
    
    
    //UIDatePickerをインスタンス化
    let timePickerS: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = UIDatePicker.Mode.time
        dp.timeZone = NSTimeZone.local
        //時間をJapanese(24時間表記)に変更
        dp.locale = Locale.init(identifier: "Japanese")
        dp.addTarget(self, action: #selector(dateChangeS), for: .valueChanged)
        //最小単位（分）を設定
        dp.minuteInterval = 10
        dp.preferredDatePickerStyle = .wheels
        return dp
    }()
    let timePickerE: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = UIDatePicker.Mode.time
        dp.timeZone = NSTimeZone.local
        //時間をJapanese(24時間表記)に変更
        dp.locale = Locale.init(identifier: "Japanese")
        dp.addTarget(self, action: #selector(dateChangeE), for: .valueChanged)
        //最小単位（分）を設定
        dp.minuteInterval = 10
        dp.preferredDatePickerStyle = .wheels
        return dp
    }()
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return false
    }
    @objc func dateChangeS(){
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        startTimeTF.text = "\(formatter.string(from: timePickerS.date))"
        subTimeDidChange()

    }
    @objc func dateChangeE(){
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        endTimeTF.text = "\(formatter.string(from: timePickerE.date))"
        subTimeDidChange()
    }
    func subTimeDidChange(){
        if compareTwoDateStr_d1d2(d1: startTimeTF.text ?? "", d2: endTimeTF.text ?? ""){
            dateOverL.text = "次の日の日付として認識しています"

        }else {
            dateOverL.text = ""
        }
    }
    
    
}

