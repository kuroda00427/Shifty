//
//  registerShiftVC.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/08/22.
//

import Foundation
import UIKit
import Firebase

class SubmissionShiftVC: UIViewController {
    
    
    
    static var selectedRow:Int?
    static var days:[infoOfDay] = []
    @IBOutlet weak var presentConditionL: UILabel!
    @IBOutlet weak var presentPickerViewB: UIButton!
    private var presentDayIndex:[Int] = []

    private var selectedOption = 0{
        didSet{
            presentDayIndex.removeAll()
            for (i ,day) in SubmissionShiftVC.days.enumerated(){
                if presentDayCondition(day: day, presentOption: selectedOption){
                    presentDayIndex.append(i)
                    
                }
            }
            print(presentDayIndex)
        }
    }
    var presentOptions : [String] =
            [
                "すべての日程" ,
                "提出する日程のみ"
            ]
    @IBOutlet weak var changeSizeB: UIButton!
    @IBOutlet weak var submissionShiftTV: UITableView!
    @IBOutlet weak var subShiftB: UIButton!
    
    
    private var changeTimeButtonIsHidden = false
    private let screenWidth = UIScreen.main.bounds.width - 10
    private let screenHeight = UIScreen.main.bounds.height / 8
    
    @objc func tappedChangeSizeB(){
        if changeTimeButtonIsHidden{
            changeTimeButtonIsHidden = false
            changeSizeB.setTitle("入力ON", for: .normal)

        }else {
            changeTimeButtonIsHidden = true
            changeSizeB.setTitle("入力OFF", for: .normal)

        }
        submissionShiftTV.reloadData()
    }
    @IBAction func presentPickerViewB(_ sender: Any) {
    
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: Int(screenWidth), height:Int(screenHeight)))
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView.selectRow(selectedOption, inComponent: 0, animated: false)
        //pickerView.selectRow(selectedRowTextColor, inComponent: 1, animated: false)
        
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "表示オプション", message: "", preferredStyle: .actionSheet)
        
        alert.popoverPresentationController?.sourceView = presentPickerViewB
        alert.popoverPresentationController?.sourceRect = presentPickerViewB.bounds
        
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
        }))
        
        alert.addAction(UIAlertAction(title: "決定", style: .default, handler: { (UIAlertAction) in
            self.selectedOption = pickerView.selectedRow(inComponent: 0)
            let option = self.presentOptions[self.selectedOption]
            print(option)
            self.presentConditionL.text = option
            self.submissionShiftTV.reloadData()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func subShiftB(_ sender: Any) {
        let alert = UIAlertController(title: "この内容で提出します。よろしいですか？", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
            self.updateOrSubmitShift()
        })
        self.present(alert, animated: true, completion: nil)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        changeSizeB.addTarget(self, action: #selector(tappedChangeSizeB), for: .touchUpInside)
        
        self.submissionShiftTV.delegate = self
        self.submissionShiftTV.dataSource = self
        
        makeDays()
    
        getSubedShiftAsWorker()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        submissionShiftTV.reloadData()
    }
    private func setUpView(){
        subShiftB.setTitle("シフト提出・更新", for: .normal)
        presentConditionL.text = "すべての日程"
        changeSizeB.setTitle("入力ON", for: .normal)

        view.layer.backgroundColor = UIColor.rgb(red: 238, green: 224, blue: 190).cgColor
        submissionShiftTV.backgroundColor = UIColor.rgb(red: 238, green: 224, blue: 190)
        subShiftB.layer.backgroundColor = UIColor.yellow.cgColor
        subShiftB.layer.borderWidth = 3
        subShiftB.layer.borderColor = UIColor.white.cgColor
        submissionShiftTV.separatorStyle = .none
        
        let deadline = ShiftVC.selectedShift!.deadline
        let now = Date()
        if deadline < now{
            subShiftB.isEnabled = false
            subShiftB.setTitle("締め切り超過", for: .normal)

        }

    }
    private func makeDays(){
        SubmissionShiftVC.days.removeAll()
        guard let startDate = ShiftVC.selectedShift?.startDate else {return}
        guard let endDate = ShiftVC.selectedShift?.endDate else {return}
        guard let holiday = ShiftVC.selectedShift?.holiday else { return }
        var start = startDate
        
        while start <= endDate {
            let strDay = makeDaySForFirestoreFromIntArray(day: makeIntArrayFromDate(start))
            let day = infoOfDay.init()
            day.dayStr = strDay
            day.dayInt = makeIntArrayFromDate(start)
            day.date = start
            day.submittedCount = 0
            if holiday.contains(strDay){
                day.isHoliday = true
            }
            SubmissionShiftVC.days.append(day)
            guard let a = Calendar.current.date(byAdding: .day, value: 1, to: start) else {return}
            start = a
        }
        presentDayIndex.removeAll()

        for (i ,day) in SubmissionShiftVC.days.enumerated(){
            if presentDayCondition(day: day, presentOption: selectedOption){
                presentDayIndex.append(i)
                
            }
        }
        submissionShiftTV.reloadData()
        print(presentDayIndex)
    }
    
    
    private func getSubedShiftAsWorker(){
        
        let my = DispatchGroup()
        guard let shopID = ShiftVC.selectedShift?.shopID else {return}
        guard let shiftUid = ShiftVC.selectedShift?.uid else { return}
        guard let myUid = ShiftVC.selectedShift?.registerUid else { return}

        let count = SubmissionShiftVC.days.count

        for i in 0...count-1{
            my.enter()

            let day = SubmissionShiftVC.days[i]
            let dayS = day.dayStr
            if dayS == ""{
                continue
            }

            Firestore.firestore().collection("shops").document(shopID).collection("shifts").document(shiftUid).collection("date").document(dayS).collection("shift").document(myUid).getDocument { doc, err in
                if let err = err{
                    print("読み込み失敗\(err)")
                    return
                }
                guard let doc = doc,let dic = doc.data() else{return}
                let times = dic["subedTime"] as? [String] ?? []
                if times.count == 2{
                    SubmissionShiftVC.days[i].startTime = times[0]
                    SubmissionShiftVC.days[i].endTime = times[1]

                }

                my.leave()

            }

        }
        
        my.notify(queue: .main){

           
            self.submissionShiftTV.reloadData()
            print("提出されたシフトを取得")
        }
        
    }

    
    private func updateOrSubmitShift(){
        guard let shopID = ShiftVC.selectedShift?.shopID else {return}
        guard let uid = ShiftVC.selectedShift?.uid else { return}
        guard let workerUid = ShiftVC.selectedShift?.registerUid else { return}
        guard let registeredName = ShiftVC.selectedShift?.registeredName else { return }
        let count = SubmissionShiftVC.days.count
        for i in 0...count-1{
            let day = SubmissionShiftVC.days[i]
            let dayS = day.dayStr
            Firestore.firestore().collection("shops").document(shopID).collection("shifts").document(uid).collection("date").document(dayS).setData(["uid":uid])
            
            Firestore.firestore().collection("shops").document(shopID).collection("shifts").document(uid).collection("date").document(dayS).collection("shift").document(workerUid).updateData(["name":registeredName, "subedTime":[day.startTime,day.endTime]]){ err in
                if err != nil {
                    self.submitShift(shopID: shopID, uid: uid, dayS: dayS, workerUid: workerUid, name: registeredName, subedTime: [day.startTime,day.endTime])
                }else{
                    self.failedAlert(sentence: "シフトを更新しました")

                }

            }
        }
        
    }
    private func submitShift(shopID:String,uid:String,dayS:String,workerUid:String, name:String,subedTime:[String?]){
        Firestore.firestore().collection("shops").document(shopID).collection("shifts").document(uid).collection("date").document(dayS).collection("shift").document(workerUid).setData(["name":name, "subedTime":subedTime]){  err in
            if err != nil{
                self.failedAlert(sentence: "シフトの提出に失敗しました")
                return

            }else{
                self.failedAlert(sentence: "シフトを提出しました")

            }

        }
    }
}
    
       

extension SubmissionShiftVC: UITableViewDelegate,UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if changeTimeButtonIsHidden {
            return 64
        }else{
            return 112
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentDayIndex.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = submissionShiftTV.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SubmissionShiftTVCell
        let index = presentDayIndex[indexPath.row]
        let day = SubmissionShiftVC.days[index]
        cell.index = index
        cell.dayL.text = String(day.dayInt[1]) + "月" + String(day.dayInt[2]) + "日" + getDayOfWeek(date: day.date!)
        if let start = day.startTime, var end = day.endTime{
            end = changeEndTime(end: end)
            cell.subTimeL.text = "勤務時間：" + start + "〜" + end
            cell.cellV.backgroundColor = UIColor.cellYellowColor()
//            gradiation(view: cell.cellV, red: 255, green: 255, blue: 80)
        }else{
            cell.subTimeL.text = "勤務時間：" + "未入力"
            cell.cellV.backgroundColor = UIColor.white
            
//            gradiation(view: cell.cellV, red: 255, green: 255, blue: 210)
            
            addShadow(view: cell.cellV)
        }
        
        if changeTimeButtonIsHidden{
            cell.resetB.isHidden = true
            cell.upStartB.isHidden = true
            cell.downStartB.isHidden = true
            cell.upEndB.isHidden = true
            cell.downEndB.isHidden = true
        }else {
            cell.resetB.isHidden = false

            cell.upStartB.isHidden = false
            cell.downStartB.isHidden = false
            cell.upEndB.isHidden = false
            cell.downEndB.isHidden = false
        }
        if day.isHoliday{
            cell.selectionStyle = .none
            cell.resetB.isHidden = true
            cell.upStartB.isHidden = true
            cell.downStartB.isHidden = true
            cell.upEndB.isHidden = true
            cell.downEndB.isHidden = true
            cell.subTimeL.text = "休業日"
            cell.cellV.backgroundColor = .white
        }
        return cell
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
        {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
            label.text = presentOptions[row]
            label.sizeToFit()
            return label
        }
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1 //return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        presentOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 30
        
    }
    private func presentDayCondition(day:infoOfDay,presentOption:Int) -> Bool{
        switch presentOption {
        case 0:
            return true
        case 1:
            if day.startTime != nil {
                return true
            }else{
                return false
            }
        default:
            return true
        }
    }
}

class SubmissionShiftTVCell:UITableViewCell{

    @IBOutlet weak var dayL: UILabel!
    @IBOutlet weak var subTimeL: UILabel!
    @IBOutlet weak var resetB: UIButton!
    @IBOutlet weak var upStartB: UIButton!
    @IBOutlet weak var downStartB: UIButton!
    @IBOutlet weak var upEndB: UIButton!
    @IBOutlet weak var downEndB: UIButton!
    @IBOutlet weak var cellV: UIView!
    var isHoliday = false
    
    var index:Int!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        resetB.backgroundColor = UIColor.white
        resetB.contentVerticalAlignment = .fill
        self.selectionStyle = .none
        self.backgroundColor = UIColor.backgroundColor0()
        self.borderWidth = 1
        self.borderColor = UIColor.backgroundColor0()
        
        cellV.layer.borderColor = UIColor.white.cgColor
        cellV.layer.borderWidth = 3
        cellV.layer.cornerRadius = 15
        
        resetB.addTarget(self, action: #selector(tappedResetB), for: .touchUpInside)
        upStartB.addTarget(self, action: #selector(tappedUpStartB), for: .touchUpInside)
        downStartB.addTarget(self, action: #selector(tappedDownStartB), for: .touchUpInside)
        upEndB.addTarget(self, action: #selector(tappedUpEndB), for: .touchUpInside)
        downEndB.addTarget(self, action: #selector(tappedDownEndB), for: .touchUpInside)
        
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    @objc func tappedResetB(){
        SubmissionShiftVC.days[index].startTime = nil
        SubmissionShiftVC.days[index].endTime = nil

        subTimeL.text = "勤務時間：未入力"
        cellV.backgroundColor = UIColor.white
//        UIViewController().gradiation(view: self.cellV, red: 255, green: 255, blue: 210)
        
    }
    
    @objc func tappedUpStartB() {
        setDefaultWorkingTime()
        var time = SubmissionShiftVC.days[index].startTime
        time = upTimePar30minutes(time: time!)
        SubmissionShiftVC.days[index].startTime = time
        reloadWorkingTime()
    }
    
    @objc func tappedDownStartB() {
        setDefaultWorkingTime()

        var time = SubmissionShiftVC.days[index].startTime
        time = downTimePar30minutes(time: time!)
        SubmissionShiftVC.days[index].startTime = time
        reloadWorkingTime()

    }
    @objc func tappedUpEndB( ) {
        setDefaultWorkingTime()

        var time = SubmissionShiftVC.days[index].endTime
        time = upTimePar30minutes(time: time!)
        SubmissionShiftVC.days[index].endTime = time
        reloadWorkingTime()

    }
    @objc func tappedDownEndB() {
        setDefaultWorkingTime()

        var time = SubmissionShiftVC.days[index].endTime
        time = downTimePar30minutes(time: time!)
        SubmissionShiftVC.days[index].endTime = time
        
        reloadWorkingTime()

    }
    private func reloadWorkingTime(){
        let day = SubmissionShiftVC.days[index]
        let text = "勤務時間：" + day.startTime! + "〜" + day.endTime!
        subTimeL.text = text
        cellV.backgroundColor = UIColor.cellYellowColor()
//        UIViewController().gradiation(view: self.cellV, red: 255, green: 255, blue: 80)
        
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


    private func setDefaultWorkingTime(){
        if SubmissionShiftVC.days[index].startTime == nil{
            let defaltWorkingTime = val.user?.defaultWorkingTime ?? ["17:00","23:00"]
            SubmissionShiftVC.days[index].startTime = defaltWorkingTime[0]
            SubmissionShiftVC.days[index].endTime = defaltWorkingTime[1]
        }
    }
    private func intToStringFormatter(time:Int) -> String{
        if time < 10 {
            return "0" + String(time)
        }else{
            return String(time)
        }
    }
    
}

