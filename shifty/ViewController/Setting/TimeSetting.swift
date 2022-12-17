//
//  TimeSetting.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/10/15.
//
//

import Foundation
import UIKit

class TimeSettingVC: UIViewController {

    @IBOutlet weak var defaulWorkingUnitL: UILabel!
    @IBOutlet weak var endTimeL: UILabel!
    @IBOutlet weak var presentStartTimePickerB: UIButton!
    @IBOutlet weak var presentEndTimePickerB: UIButton!
    @IBOutlet weak var startTimeL: UILabel!
    @IBOutlet weak var presentWorkingTimeUnitPickerB: UIButton!

    var startTimePickerView:UIPickerView!
    var endTimePickerView:UIPickerView!
    var unitPickerView:UIPickerView!

    
    private var selectedStartTimeOption = 0{
        didSet{

        }
    }
    private var selectedEndTimeOption = 0{
        didSet{

        }
    }
    private var selectedUnitOption = 0{
        didSet{
            
        }
    }
    var presentTimeOptions : [String] =
            [
                "00:00",
                "01:00",
                "02:00",
                "03:00",
                "04:00",
                "05:00",
                "06:00",
                "07:00",
                "08:00",
                "09:00",
                "10:00",
                "11:00",
                "12:00",
                "13:00",
                "14:00",
                "15:00",
                "16:00",
                "17:00",
                "18:00",
                "19:00",
                "20:00",
                "21:00",
                "22:00",
                "23:00",
                
            ]
    var presentUnitOptions : [String] =
            [
                "10",
                
                "15",
                "30",
                "60"
            ]
    private let screenWidth = UIScreen.main.bounds.width - 10
    private let screenHeight = UIScreen.main.bounds.height / 3
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentStartTimePickerB.addTarget(self, action: #selector(tappedStartTimePickerB), for: .touchUpInside)
        presentEndTimePickerB.addTarget(self, action: #selector(tappedEndTimePickerB), for: .touchUpInside)

        presentWorkingTimeUnitPickerB.addTarget(self, action: #selector(tappedWorkingTimeUnitpickerB), for: .touchUpInside)
        setUpView()

    }
    
    private func setUpView(){
        view.layer.backgroundColor = UIColor.rgb(red: 240, green: 234, blue: 210).cgColor

        guard let startTime = val.user?.defaultWorkingTime[0] else {return}
        guard let endTime = val.user?.defaultWorkingTime[1] else {return}
        guard let unit = val.user?.defaultWorkingUnit else {return}
        startTimeL.text = startTime
        endTimeL.text = endTime
        defaulWorkingUnitL.text = String(unit) + "分"

    }

    @objc func tappedStartTimePickerB(){
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        startTimePickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: Int(screenWidth), height:Int(screenHeight)))
        startTimePickerView.dataSource = self
        startTimePickerView.delegate = self
        
        startTimePickerView.selectRow(selectedStartTimeOption, inComponent: 0, animated: false)
        vc.view.addSubview(startTimePickerView)
        startTimePickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        startTimePickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "出勤時刻", message: "", preferredStyle: .actionSheet)
        
        alert.popoverPresentationController?.sourceView = presentStartTimePickerB
        alert.popoverPresentationController?.sourceRect = presentStartTimePickerB.bounds
        
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
        }))
        
        alert.addAction(UIAlertAction(title: "決定", style: .default, handler: { (UIAlertAction) in
            self.selectedStartTimeOption = self.startTimePickerView.selectedRow(inComponent: 0)
            let option = self.presentTimeOptions[self.selectedStartTimeOption]
            self.startTimeL.text = option
            val.user?.defaultWorkingTime[0] = option
            save().save(value: val.user!.defaultWorkingTime, Key: "defaultWorkingTime")
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    @objc func tappedEndTimePickerB(){
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        endTimePickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: Int(screenWidth), height:Int(screenHeight)))
        endTimePickerView.dataSource = self
        endTimePickerView.delegate = self
        
        endTimePickerView.selectRow(selectedEndTimeOption, inComponent: 0, animated: false)
        vc.view.addSubview(endTimePickerView)
        endTimePickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        endTimePickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "退勤時刻", message: "", preferredStyle: .actionSheet)
        
        alert.popoverPresentationController?.sourceView = presentStartTimePickerB
        alert.popoverPresentationController?.sourceRect = presentStartTimePickerB.bounds
        
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
        }))
        
        alert.addAction(UIAlertAction(title: "決定", style: .default, handler: { (UIAlertAction) in
            self.selectedEndTimeOption = self.endTimePickerView.selectedRow(inComponent: 0)
            let option = self.presentTimeOptions[self.selectedEndTimeOption]
            self.endTimeL.text = option
            val.user?.defaultWorkingTime[1] = option
            save().save(value: val.user!.defaultWorkingTime, Key: "defaultWorkingTime")
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc func tappedWorkingTimeUnitpickerB(){
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        unitPickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: Int(screenWidth), height:Int(screenHeight)))
        unitPickerView.dataSource = self
        unitPickerView.delegate = self
        
        unitPickerView.selectRow(selectedUnitOption, inComponent: 0, animated: false)
        vc.view.addSubview(unitPickerView)
        unitPickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        unitPickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "労働単位時間", message: "", preferredStyle: .actionSheet)
        
        alert.popoverPresentationController?.sourceView = presentStartTimePickerB
        alert.popoverPresentationController?.sourceRect = presentStartTimePickerB.bounds
        
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
        }))
        
        alert.addAction(UIAlertAction(title: "決定", style: .default, handler: { (UIAlertAction) in
            self.selectedUnitOption = self.unitPickerView.selectedRow(inComponent: 0)
            let option = self.presentUnitOptions[self.selectedUnitOption]
            self.defaulWorkingUnitL.text = option + "分"
            val.user?.defaultWorkingUnit = Int(option)!
            save().save(value: val.user!.defaultWorkingUnit, Key: "defaultWorkingUnit")
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}





extension TimeSettingVC:UIPickerViewDelegate,UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView{
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
        switch pickerView {
        case startTimePickerView:
            label.text = presentTimeOptions[row]
        case endTimePickerView:
            label.text = presentTimeOptions[row]
        case unitPickerView:
            label.text = presentUnitOptions[row] + "分"
        default:
            return label
        }
        
        
        label.sizeToFit()
        return label
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1 //return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView {
        case startTimePickerView:
            return presentTimeOptions.count
        case endTimePickerView:
            return presentTimeOptions.count
        case unitPickerView:
            return presentUnitOptions.count
        default:
            return presentTimeOptions.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 30
        
    }
    
    
}


