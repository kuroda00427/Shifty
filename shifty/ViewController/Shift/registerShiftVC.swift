//
//  registerShiftVC.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/08/22.
//

import Foundation
import UIKit
import Firebase

class registerShiftVC: UIViewController {
    
    
    static var selectedRow:Int?
    static var days:[infoOfDay] = []
    static var workers:[String:[Worker]] = [:]
    static var workingDayCount:[String:Int] = [:]
//    static var workingMemberCount:[String:Int] = [:]
    
    @IBAction func saveB(_ sender: Any) {
        let alert = UIAlertController(title: "保存します。よろしいですか？", message: "アプリを終了しても保存されます", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
            
            self.saveShift()
        })
        self.present(alert, animated: true, completion: nil)
    }
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var subShiftB: UIButton!
    @IBOutlet weak var registerShiftTV: UITableView!
    @IBAction func ReleaseShiftB(_ sender: Any) {
        guard let shift = ShiftVC.selectedShift else { return }
        let date = Date()
        if date < shift.deadline && shift.deadline != shift.endDate && shift.deadline < shift.startDate{
            self.failedAlert(sentence: "このシフトはまだ募集中です")
            return
        }
        let alert = UIAlertController(title: "この内容でシフトを決定します。よろしいですか？", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
            self.releaseShift()
        })
        self.present(alert, animated: true, completion: nil)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        self.registerShiftTV.delegate = self
        self.registerShiftTV.dataSource = self
        
        makeDays()
        getSubedShiftAsEmployer()

        subShiftB.setTitle("シフト決定", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerShiftTV.reloadData()
        
    }
    private func setUpView(){
        addLabel(text: "日にちを選択してください", view: view, x: 66, y: 120, width: 300, height: 40, soroe: .center,size: 12, font: 0)
        
        view.layer.backgroundColor = UIColor.rgb(red: 238, green: 224, blue: 190).cgColor
        registerShiftTV.backgroundColor = UIColor.rgb(red: 238, green: 224, blue: 190)
        saveB.layer.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255).cgColor
        saveB.layer.borderColor = UIColor.white.cgColor
        saveB.layer.borderWidth = 3
        subShiftB.layer.backgroundColor = UIColor.yellow.cgColor
        subShiftB.layer.borderWidth = 3
        subShiftB.layer.borderColor = UIColor.white.cgColor
        registerShiftTV.separatorStyle = .none
        
    }
    private func makeDays(){
        registerShiftVC.days.removeAll()
        guard let startDate = ShiftVC.selectedShift?.startDate else {return}
        guard let endDate = ShiftVC.selectedShift?.endDate else {return}
        guard let holiday = ShiftVC.selectedShift?.holiday else { return }

        var start = startDate
        
        while start <= endDate {
            let strDay = makeDaySForFirestoreFromIntArray(day: makeIntArrayFromDate(start))
            let day = infoOfDay.init()
            day.dayStr = strDay
            print(day.dayStr)
            day.dayInt = makeIntArrayFromDate(start)
            day.date = start
            day.submittedCount = 0
            if holiday.contains(strDay){

                day.isHoliday = true
            }
            registerShiftVC.days.append(day)
            registerShiftVC.workers[strDay] = []
            guard let a = Calendar.current.date(byAdding: .day, value: 1, to: start) else {return}
            start = a
        }
    }
    
    
    
    
    private func getSubedShiftAsEmployer(){
        registerShiftVC.workingDayCount = [:]
//        registerShiftVC.workers = [:]
//        registerShiftVC.workingMemberCount = [:]


        let my = DispatchGroup()
        guard let shopID = ShiftVC.selectedShift?.shopID else {return}
        guard let shiftUid = ShiftVC.selectedShift?.uid else { return}
        let count = registerShiftVC.days.count
        for i in 0...count-1{
            my.enter()
            let day = registerShiftVC.days[i]
            let dayS = day.dayStr
            
            Firestore.firestore().collection("shops").document(shopID).collection("shifts").document(shiftUid).collection("date").document(dayS).collection("shift").getDocuments { docs, err in
                if let err = err{
                    print("読み込み失敗\(err)")
                    return
                }
                
                var submittedCount = 0
                var workingCount = 0
                docs?.documents.forEach({ doc in
                    let dic = doc.data()
//                    let subed = dic["subedTime"] as? [String] ?? []
//                    if subed != []{
//
//                    }
        
                    let worker = Worker.init(dic: dic)
                    worker.uid = doc.documentID

                    let name = worker.name!
                    var workingDayCount = registerShiftVC.workingDayCount[name] ?? 0
                    if worker.workingTime.count == 2{
                        workingDayCount += 1
                        workingCount += 1
                    }
                    registerShiftVC.workingDayCount[name] = workingDayCount
                    
                    if worker.subedTime.count == 2{
                        submittedCount += 1

                        registerShiftVC.workers[dayS]!.append(worker)
                    }
                })
                
                registerShiftVC.days[i].submittedCount = submittedCount
                registerShiftVC.days[i].workingCount = workingCount

                my.leave()
                
            }
            
        }
        
        my.notify(queue: .main){
            self.registerShiftTV.reloadData()
        }
        
    }
    
    private func saveShift(){
        guard let shopID = ShiftVC.selectedShift?.shopID else {return}
        guard let uid = ShiftVC.selectedShift?.uid else { return}
        
        let count = registerShiftVC.days.count
        for i in 0...count-1{
            let day = registerShiftVC.days[i]
            let dayS = day.dayStr
            guard let workersAtDay = registerShiftVC.workers[dayS] else { return}
            workersAtDay.forEach { worker in
                guard let workerUid = worker.uid else { return}
                let workingTime = worker.workingTime
                
                Firestore.firestore().collection("shops").document(shopID).collection("shifts").document(uid).collection("date").document(dayS).collection("shift").document(workerUid).updateData(["workingTime":workingTime]){ err in
                    if err != nil {
                        self.failedAlert(sentence: "シフトの保存に失敗しました")
                    }else{
                        self.failedAlert(sentence: "シフトを保存しました")
                        
                    }
                }
            }
        }
    }
    
    
    private func releaseShift(){
        guard let shopID = ShiftVC.selectedShift?.shopID else {return}
        guard let shiftUid = ShiftVC.selectedShift?.uid else { return }
        var times:[String:[String:Any]] = [:]
        let workers = registerShiftVC.workers
        let cell = ShiftManageVCTableViewCell()
        workers.forEach { dayS,worker in
            worker.forEach { w in
                let subedTime = w.subedTime
                let workingTime = w.workingTime
                if workingTime.count == 2{
                    if subedTime.count == 0{
                        let day = self.makeDayForUserFromDayS(dayS: dayS)
                        self.failedAlert(sentence: "シフトが適切ではありません", message: day + "のシフトを確認してください")
                        return
                    }else if !cell.isAdjustedSubedStartTime(submitedTime: subedTime, workingStartTime: workingTime[0]) || !cell.isAdjustedSubedEndTime(submitedTime: subedTime, workingEndTime: workingTime[1]) || !cell.workingTimeIsOK(submitedTime: subedTime, workingTime: workingTime) {
                        let day = self.makeDayForUserFromDayS(dayS: dayS)
                        self.failedAlert(sentence: "シフトが適切ではありません", message: day + "のシフトを確認してください")
                        return
                    }
                }
                
                let uid = w.uid ?? "error"
                let working = w.workingTime
                if times[uid] == nil{
                    times[uid] = [:]
                }
                times[uid]![dayS] = working
            }
        }
        if times.count == 0{
            failedAlert(sentence: "勤務時間を入力してください")
        }
        times.forEach { uid, value in
            value.forEach { day, workingTime in
                Firestore.firestore().collection("shops").document(shopID).collection("members").document(uid).collection("date").document(day).setData(["shiftUid":shiftUid,"workingTime":workingTime]) { err in
                    if let err = err{
                        print(err)
                        self.failedAlert(sentence: "error")
                        return
                    }
                    
                }
            }
        }
        saveShift()
    }
    
}
extension registerShiftVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registerShiftVC.days.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = registerShiftTV.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! registerTVCell
        let day = registerShiftVC.days[indexPath.row]
        cell.dayL.text = String(day.dayInt[1]) + "月" + String(day.dayInt[2]) + "日" + getDayOfWeek(date: day.date!)
        
        
        let submittedCount = day.submittedCount
        let workingCount = day.workingCount
        cell.timeL.text = "提出人数：" + String(submittedCount) + "人" + "    " + "出勤人数" + String(workingCount)  + "人"
        cell.timeL.adjustsFontSizeToFitWidth = true
        
        addShadow(view: cell.cellV)
        cell.selectionStyle = .default
        if day.isHoliday{
            cell.selectionStyle = .none
            cell.timeL.text = "休業日"
            cell.cellV.backgroundColor = .white
        }else{
            cell.cellV.backgroundColor = UIColor.cellColor()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let day = registerShiftVC.days[row]

        if day.isHoliday{
            return
        }
        
        registerShiftVC.selectedRow = row
        pushView(storyboard: "ShiftManage", ID: "ShiftManageVC")
        return
        
    }
    
}

class registerTVCell:UITableViewCell{
    @IBOutlet weak var dayL: UILabel!
    @IBOutlet weak var timeL: UILabel!
    @IBOutlet weak var cellV: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        cellV.layer.backgroundColor = UIColor.rgb(red: 240, green: 238, blue: 210).cgColor
        cellV.layer.cornerRadius = 0
        self.backgroundColor = UIColor.rgb(red: 238, green: 224, blue: 190)
        
//        self.selectedBackgroundView?.layer.backgroundColor = UIColor.white.cgColor
        
        cellV.layer.borderColor = UIColor.white.cgColor
        cellV.layer.borderWidth = 1
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        buttonPushAnimation(view: self)
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesEnded(touches, with: event)
//        buttonPullAnimation(view: self)
//    }
}
