//
//  StartVC.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/08/13.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import Firebase

class CalenderVC: UIViewController,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance{

    @IBOutlet weak var yoteiL: UILabel!
    
    @IBOutlet weak var startTV: UITableView!
    @IBOutlet var startView: UIView!
    var shadowView = UIView()

    @IBOutlet weak var calendar: FSCalendar!
    private var totalWorkingTimeL:UILabel!
    private var totalWorkingTime:Double = 0
    
    private var events:[String:[Event]] = [:]
    private var workers:[String:[Worker]] = [:]
    private var eventTexts:[String] = []
    static var selectedDate:Date?
    private var selectedMonth = 0{
        didSet{
            showTotalWorkingTime(date: CalenderVC.selectedDate!)
        }
    }
    
    @IBOutlet weak var addEventOrShiftB: UIButton!
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    override func viewDidLoad() {
        super.viewDidLoad()
        showTermsOfService()

        self.calendar.dataSource = self
        self.calendar.delegate = self
        startTV.delegate = self
        startTV.dataSource = self
        addEventOrShiftB.addTarget(self, action: #selector(tappedAddEventOrShiftB), for: .touchUpInside)
        setUpView()

        showTutorial()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserInfo()
        guard let date = CalenderVC.selectedDate else{return}
        reloadEventText(date: date)
        startTV.reloadData()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shadowView.frame = startTV.frame
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    private func setUpView(){
        calendar.sizeToFit()
        startTV.separatorStyle = .none
        addEventOrShiftB.setTitle("＋シフト・予定を追加", for: .normal)
        addEventOrShiftB.isHidden = true
        addEventOrShiftB.isEnabled = false

        navigationController?.navigationBar.barTintColor = UIColor.rgb(red: 242, green: 250, blue: 224)
        view.layer.backgroundColor = UIColor.backgroundColor0().cgColor
        self.calendar.appearance.headerDateFormat = "YYYY年MM月"
        self.calendar.calendarWeekdayView.weekdayLabels[0].text = "日"
        self.calendar.calendarWeekdayView.weekdayLabels[1].text = "月"
        self.calendar.calendarWeekdayView.weekdayLabels[2].text = "火"
        self.calendar.calendarWeekdayView.weekdayLabels[3].text = "水"
        self.calendar.calendarWeekdayView.weekdayLabels[4].text = "木"
        self.calendar.calendarWeekdayView.weekdayLabels[5].text = "金"
        self.calendar.calendarWeekdayView.weekdayLabels[6].text = "土"
        yoteiL.text = ""

        gradiationAndShadow(view: calendar, red: 255, green: 255, blue: 255)
        startTV.backgroundColor = UIColor.clear
//        gradiationAndShadow(view: startTV, red: 255, green: 255, blue: 255)
        navigationController?.navigationItem.title = "マイシフト"
        totalWorkingTimeL = UILabel(frame: CGRect(x: 0, y: 100, width: screenWidth, height: 30))
        totalWorkingTimeL.textAlignment = .center
        totalWorkingTimeL.adjustsFontSizeToFitWidth = true
        totalWorkingTimeL.layer.backgroundColor = UIColor.clear.cgColor
        
        view.addSubview(totalWorkingTimeL)
        startTV.borderColor = .white
        startTV.borderWidth = 1
        
        
    }
    // 祝日判定を行い結果を返すメソッド(True:祝日)
    func judgeHoliday(_ date : Date) -> Bool {
        //祝日判定用のカレンダークラスのインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)

        // 祝日判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)

        // CalculateCalendarLogic()：祝日判定のインスタンスの生成
        let holiday = CalculateCalendarLogic()

        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    //点マークをつける関数
    func calendar(calendar: FSCalendar!, hasEventForDate date: NSDate!) -> Bool {
        return true
    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let day = makeIntArrayFromDate(date)
        let dayS = changeDayStr(day: day)

        if events[dayS] == nil || events[dayS]?[0].workingTime == Optional([]){
            
            return 0
        }else{
            return 1
        }
    }

    // 土日や祝日の日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        //祝日判定をする（祝日は赤色で表示する）
        if self.judgeHoliday(date){
            return UIColor.red
        }

        //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekday = self.getWeekIdx(date)
        if weekday == 1 {   //日曜日
            return UIColor.red
        }
        else if weekday == 7 {  //土曜日
            return UIColor.blue
        }

        return nil
    }
    
    //選択された時の処理
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        reloadEventText(date: date)
        addEventOrShiftB.isHidden = false
        addEventOrShiftB.isEnabled = true

        startTV.reloadData()
        setSelectedMonth(date: date)

    }
    private func reloadEventText(date:Date){
        let day = makeIntArrayFromDate(date)
        let dayS = changeDayStr(day: day)
        let addtionalEvent = loadAny(Key: dayS) as? [[String:Any]]
        eventTexts.removeAll()
        yoteiL.text = String(day[1]) + "月" + String(day[2]) + "日" + "のシフト"

        if val.user?.rank == 2{
            if let event = events[dayS]{
                event.forEach { eve in
                    if eve.workingTime.count == 2{
                        let text = eve.shopName! + "    " + eve.workingTime[0] + "〜" + eve.workingTime[1]
                        self.eventTexts.append(text)
                    }
                }
                
            }
            if let event = addtionalEvent{
                event.forEach { eve in
                    print(eve)
                    let workingTime = eve["workingTime"] as! [String]
                    let eventName = eve["eventName"] as! String
                    let startTime = workingTime[0]
                    let endTime = workingTime[1]
                    let text = eventName + "    " + startTime + "〜" + endTime
                    self.eventTexts.append(text)
                }
            }
        }else if val.user?.rank == 1{
            if let worker = workers[dayS]{

                worker.forEach { work in

                    if work.workingTime.count == 2{
                        let text = work.name! + "    " + work.workingTime[0] + "〜" + work.workingTime[1]
                        self.eventTexts.append(text)
                    }
                }
            }
        }
    }
    private func loadUserInfo() {

        let my = DispatchGroup()
//        let load = UIViewController()

        let shopIDs = loadStringArr(Key: "shopIDs") ?? []
        let registerUIDs = loadStringArr(Key: "registerUIDs") ?? []
        let defaultWorkingTime = loadStringArr(Key: "defaultWorkingTime")
        let defaultWorkingUnit = loadInt(Key: "defaultWorkingUnit")
        var names:[String:String] = [:]
        var shopNames:[String:String] = [:]
        let rank = loadInt(Key: "rank")

        if rank != nil{

            for (i,shopID) in shopIDs.enumerated(){
                my.enter()

                Firestore.firestore().collection("shops").document(shopID).getDocument { doc, err in
                    if err != nil{

                        self.failedAlert(sentence: "通信エラー", message: "通信状況を確認してください")
                        return
                    }
                    
                    guard let doc = doc ,let dic = doc.data() else { return}
                    let shopName =  dic["shopName"]
                    shopNames[shopID] = shopName as? String

                }
                if rank == 1{
                    Firestore.firestore().collection("shops").document(shopID).updateData(["lastLogin":Date()])
                }
                
                
                Firestore.firestore().collection("shops").document(shopIDs[i]).collection("members").document(registerUIDs[i]).getDocument { doc, err in
                    if err != nil{
                        self.failedAlert(sentence: "通信エラー", message: "通信状況を確認してください")
                        return
                    }
                    
                    guard let doc = doc ,let dic = doc.data() else { return}
                    let name =  dic["name"]
                    self.setLastLogin(shopID: shopID, registerUID: registerUIDs[i])
                    if rank == 1{
                        names[shopID] = "店長"
                    }else{
                        names[shopID] = name as? String

                    }
                   

                    my.leave()

                }


            }

            my.notify(queue: .main){
                let dic = ["names":names,
                       "shopIDs":shopIDs,
                       "rank":rank ?? 0,
                       "registerUIDs":registerUIDs,
                       "shopNames":shopNames,
                       "defaultWorkingTime":defaultWorkingTime as Any,
                       "defaultWorkingUnit":defaultWorkingUnit ?? 30] as [String : Any]
                let user = User.init(dic:dic)
                val.user = user
                
                print(dic)
                if val.user!.rank == 1{
                    self.loadAllShift()
                }else if val.user!.rank == 2{
                    self.loadEvents()
                }

            }

        }else{
            let dic = ["names":names,
                   "shopIDs":shopIDs,
                   "rank":rank ?? 0,
                   "registerUIDs":registerUIDs,
                   "shopNames":shopNames,
                   "defaultWorkingTime":defaultWorkingTime as Any,
                   "defaultWorkingUnit":defaultWorkingUnit ?? 30] as [String : Any]
            let user = User.init(dic:dic)
            val.user = user
            print(dic)

        }
    }
    private func setLastLogin(shopID:String,registerUID:String){
        Firestore.firestore().collection("shops").document(shopID).collection("members").document(registerUID).updateData(["lastLogin":Timestamp()])
         
    }
    
    
    
    private func removeUserDefaults() {
        let appDomain = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
        print("removed User default")
    }
    
    private func loadEvents(){
        let my = DispatchGroup()
        events.removeAll()
        guard let shopIDs = val.user?.shopIDs else { return}
        guard let shopNames = val.user?.shopNames else { return }
        guard let myUids = val.user?.registerUIDs else { return }
        if shopIDs.count == 0{
            return
        }


        for i in 0...shopIDs.count - 1{
            my.enter()
            Firestore.firestore().collection("shops").document(shopIDs[i]).collection("members").document(myUids[i]).collection("date").getDocuments { docs, err in
                if  err != nil {
                    self.failedAlert(sentence: "通信エラー", message: "通信状況を確認してください")
                    return
                    
                    
                }
                docs?.documents.forEach({ doc in
                    let dic = doc.data()
                    let event = Event.init(dic: dic)
                    event.shopName = shopNames[shopIDs[i]]
                    let dayS = doc.documentID
                    if self.events[dayS] == nil{
                        self.events[dayS] = []
                    }
                    var eventList = self.events[dayS]!
                    eventList.append(event)
                    self.events[dayS] = eventList
                })
                my.leave()
            }
        }
        my.notify(queue: .main){
            self.calendar.reloadData()

        }

    }
    private func loadAllShift(){
        workers.removeAll()

        guard let shopIDs = val.user?.shopIDs else { return}
        Firestore.firestore().collection("shops").document(shopIDs[0]).collection("shifts").getDocuments { docs, err in
            if err != nil{
                self.failedAlert(sentence: "通信エラー", message: "通信状況を確認してください")
                return
            }
            docs?.documents.forEach({ doc in
                let shiftUid = doc.documentID
                self.loadShift(shopID: shopIDs[0], shiftUid: shiftUid)
            })
            
        }
    }
    private func loadShift(shopID:String, shiftUid:String){

        Firestore.firestore().collection("shops").document(shopID).collection("shifts").document(shiftUid).collection("date").getDocuments { docs, err in
            if err != nil{

                return
            }
            docs?.documents.forEach({ doc in
                let dateStr = doc.documentID
                self.loadWorkerAtDay(shopID: shopID, shiftUid: shiftUid, dateStr: dateStr)
            })
        }
    }
    private func loadWorkerAtDay(shopID:String,shiftUid:String,dateStr:String){

        Firestore.firestore().collection("shops").document(shopID).collection("shifts").document(shiftUid).collection("date").document(dateStr).collection("shift").getDocuments { docs, err in
            if err != nil{
                return
            }
            docs?.documents.forEach({ doc in
                let dic = doc.data()
                let worker = Worker.init(dic: dic)
                if self.workers[dateStr] == nil{
                    self.workers[dateStr] = []
                }
                self.workers[dateStr]?.append(worker)
            })
        }
        
        
    }
    @objc func tappedAddEventOrShiftB(){
        let view = AddEventOrShift()
//        view.presentationController?.delegate = self
        presentPanModal(view)
    }
    
    private func changeDayStr(day:[Int]) -> String{
        var month = String(day[1])
        var d = String(day[2])
        let year = String(day[0])
        if day[1] < 10 {
            month = "0" + month
        }
        if day[2] < 10 {
            d = "0" + d
        }
        return year + month + d
    }
    private func showTutorial(){
        let first = loadInt(Key: "first")
        if first == nil{
            Auth.auth().signInAnonymously{ authResult, error in
                if error != nil{
                    self.failedAlert(sentence: "認証に失敗しました。アプリを再度ダウンロードしてください")
                }else{
                    print("認証しました")
                }
            }
            modalView(storyboard: "Tutorial", ID: "TutorialVC")
            save().save(value: 1, Key: "first")
        }
        
    }
    private func showTermsOfService(){
        
            modalView(storyboard: "termsOfService", ID: "TermsOfServiceVC")
            save().save(value: 1, Key: "first")
            
    }
    
    private func setSelectedMonth(date:Date){
        CalenderVC.selectedDate = date
        let year = makeIntArrayFromDate(date)[0]
        let month = makeIntArrayFromDate(date)[1]
        selectedMonth = year * 100 + month
    }
    private func showTotalWorkingTime(date:Date){
        totalWorkingTime = 0
        let year = makeIntArrayFromDate(date)[0]
        let month = makeIntArrayFromDate(date)[1]
        guard let rank = val.user?.rank else {return}
        if rank == 2{
            for (dayS,value) in events{
                let yearS = dayS.prefix(4)
    
                let startIndex = dayS.index(dayS.startIndex, offsetBy: 4)

                let endIndex = dayS.index(dayS.endIndex,offsetBy: -3)
                let monthS = dayS[startIndex...endIndex]// -> "3456"
                if yearS == String(year) && monthS == String(month){
                    value.forEach { event in
                        let workingTime = self.calculateWorkingTime(workingTime: event.workingTime)
                        totalWorkingTime += workingTime
                    }
                    
                }
            }
        }else{
            for (dayS , workers) in workers{
                let yearS = dayS.prefix(4)
                let startIndex = dayS.index(dayS.startIndex, offsetBy: 4)
                let endIndex = dayS.index(dayS.endIndex,offsetBy: -3)
                let monthS = dayS[startIndex...endIndex]// -> "3456"
                if yearS == String(year) && monthS == String(month){
                    workers.forEach { worker in
                        let workingTime = self.calculateWorkingTime(workingTime: worker.workingTime)
                        totalWorkingTime += workingTime

                    }
                }
            }
            
        }
        setWorkingTimeL(monthS: String(month))
       
    }
    private func calculateWorkingTime(workingTime:[String]) -> Double{
        if workingTime.count < 2{
            return 0
        }
        let dayChanged = workingTime[1] < workingTime[0]
        let startH = Int(workingTime[0].prefix(2))!
        let startM = Int(workingTime[0].suffix(2))!
        let endH = Int(workingTime[1].prefix(2))!
        let endM = Int(workingTime[1].suffix(2))!
        let hd = Double(endH - startH)
        let md = Double(endM - startM) / 60
        if !dayChanged{
            
            return hd + md
        }else{
            return 24 + hd + md
        }
    }
    private func setWorkingTimeL(monthS:String){
        let time = floor(totalWorkingTime * 10) / 10
        let rank = val.user!.rank
        if rank == 1{
            totalWorkingTimeL.text = monthS + "月の従業員の合計労働時間は " + String(time) + " 時間です"
            totalWorkingTimeL.adjustsFontSizeToFitWidth = true

        }else{
            totalWorkingTimeL.text = monthS + "月の労働時間は " + String(time) + " 時間です"

        }
    }
    
}
class Event {
    let workingTime:[String]
    var shopName:String?
    init(dic:[String:Any]) {
        self.workingTime = dic["workingTime"] as? [String] ?? []

    }
}

extension CalenderVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rank = val.user?.rank else { return 30 }
        if rank == 1{
            return 30
        }else{
            return 40
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventTexts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = startTV.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! startCell
        cell.eventL.text = eventTexts[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let date = CalenderVC.selectedDate else { return nil }
        let day = makeIntArrayFromDate(date)
        let dayS = changeDayStr(day: day)
        var addtionalEvent = loadAny(Key: dayS) as? [[String:Any]]
        let addtionalCount = addtionalEvent?.count ?? 0
        let textCount = self.eventTexts.count
        let shiftCount = textCount - addtionalCount
        // 削除のアクションを設定する
        if indexPath.row < shiftCount{
            return nil
        }
        let deleteAction = UIContextualAction(style: .destructive, title:"delete") {
            (ctxAction, view, completionHandler) in
            self.eventTexts.remove(at: indexPath.row)
            addtionalEvent?.remove(at: indexPath.row - shiftCount)
            self.startTV.deleteRows(at: [indexPath], with: .automatic)
            if addtionalEvent?.count == 0{
                UserDefaults.standard.removeObject(forKey: dayS)
            }else{
                save().save(value: addtionalEvent!, Key: dayS)

            }
            completionHandler(true)
        }
        // 削除ボタンのデザインを設定する
        let trashImage = UIImage(systemName: "trash.fill")?.withTintColor(UIColor.white , renderingMode: .alwaysTemplate)
        deleteAction.image = trashImage
        deleteAction.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
        
        // スワイプでの削除を無効化して設定する
        let swipeAction = UISwipeActionsConfiguration(actions:[deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        
        return swipeAction
        
    }
    
    
}
//extension CalenderVC:UIAdaptivePresentationControllerDelegate{
//    
//}

class startCell:UITableViewCell {
    
    @IBOutlet weak var eventL: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear

        self.cornerRadius = 0
        self.borderWidth = 1
        self.borderColor = UIColor.white
        self.selectionStyle = .none
        
    }
}
