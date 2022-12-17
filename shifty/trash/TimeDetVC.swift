//
//  ShiftSubVC.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/08/19.
//

import Foundation
import UIKit

class TimeDetVC: UIViewController, UITextFieldDelegate {
    private let dayS = registerShiftVC.days[registerShiftVC.selectedRow!].dayStr

    
    @IBOutlet weak var startTimeTF: UITextField!
    
    @IBOutlet weak var endTimeTF: UITextField!
    @IBOutlet weak var registerB: UIButton!
    @IBAction func resetB(_ sender: Any) {
        guard let row = ShiftManageVC.selectedRow else { return }

        registerShiftVC.workers[dayS]![row].workingTime = []
//        registerShiftVC.days[row].endTime = nil

        startTimeTF.text = ""
        endTimeTF.text = ""
    }
    @IBAction func registerB(_ sender: Any) {

        guard let row = ShiftManageVC.selectedRow else { return }

//        registerShiftVC.days[row].startTime
        if startTimeTF.text == "" {
            failedAlert(sentence: "出勤時刻を入力して下さい")
            return
        }
        if endTimeTF.text == ""{
            failedAlert(sentence: "退勤時刻を入力して下さい")
            return
        }
        let start = startTimeTF.text!
        let end = endTimeTF.text!
        registerShiftVC.workers[dayS]?[row].workingTime = [start,end]
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTimeTF.delegate = self
        endTimeTF.delegate = self
        startTimeTF.inputView = timePickerS
        endTimeTF.inputView = timePickerE
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSubedTimes()

    }
    
    private func loadSubedTimes(){
        guard let row = ShiftManageVC.selectedRow else { return }
        guard let worker =  registerShiftVC.workers[dayS]?[row] else { return }
        if worker.workingTime == []{
            return
        }
        let start = worker.workingTime[0]
        let end = worker.workingTime[1]
 

        
        startTimeTF.text = start
        endTimeTF.text = end
        
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
    }
    @objc func dateChangeE(){
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        endTimeTF.text = "\(formatter.string(from: timePickerE.date))"
    }
}

