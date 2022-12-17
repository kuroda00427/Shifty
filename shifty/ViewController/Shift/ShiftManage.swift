
import UIKit
import Firebase

class ShiftManageVC: UIViewController ,UIPickerViewDelegate, UIPickerViewDataSource{
    
    static var selectedRow:Int?

    private var dayS:String = ""
    private var presentWorkerIndex:[Int] = []

    private var selectedOption = 0{
        didSet{
            presentWorkerIndex.removeAll()
            guard let workers = registerShiftVC.workers[dayS] else { return }
            for (i ,worker) in workers.enumerated(){
                if presentWorkerCondition(worker: worker, presentOption: selectedOption){
                    presentWorkerIndex.append(i)
                    
                }
            }
        }
    }
    private var changeTimeButtonIsHidden = false
    private let screenWidth = UIScreen.main.bounds.width - 10
    private let screenHeight = UIScreen.main.bounds.height / 8
    var presentOptions : [String] =
            [
                "提出者全員" ,
                "出勤者全員"
            ]

    @IBOutlet weak var presentOptionL: UILabel!
    @IBOutlet weak var changeSizeB: UIButton!
    @IBAction func changeSizeB(_ sender: Any) {
        if changeTimeButtonIsHidden{
            changeTimeButtonIsHidden = false
            changeSizeB.setTitle("入力ON", for: .normal)

        }else {
            changeTimeButtonIsHidden = true
            changeSizeB.setTitle("入力OFF", for: .normal)

        }
        shiftManageTV.reloadData()
    }
    @IBOutlet weak var presentPickerViewB: UIButton!
    @IBAction func presentPickerViewB(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: Int(screenWidth), height:Int(screenHeight)))
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView.selectRow(selectedOption, inComponent: 0, animated: false)
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
            self.presentOptionL.text = option
            self.shiftManageTV.reloadData()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBOutlet weak var shiftManageTV: UITableView!
    private let cellId = "cellId"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dayS = registerShiftVC.days[registerShiftVC.selectedRow!].dayStr
        setUpView()
        shiftManageTV.delegate = self
        shiftManageTV.dataSource = self

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.shiftManageTV.reloadData()
        
    }
    private func setUpView()  {
        changeSizeB.setTitle("入力ON", for: .normal)

        let day = registerShiftVC.days[registerShiftVC.selectedRow!]
        let title = String(day.dayInt[1]) + "月" + String(day.dayInt[2]) + "日" + getDayOfWeek(date: day.date!)

        self.navigationItem.title = title
        view.layer.backgroundColor = UIColor.backgroundColor0().cgColor
        shiftManageTV.backgroundColor = UIColor.backgroundColor0()
        shiftManageTV.separatorStyle = .none
        presentWorkerIndex.removeAll()
        guard let workers = registerShiftVC.workers[dayS] else { return }
        for (i ,worker) in workers.enumerated(){
            if presentWorkerCondition(worker: worker, presentOption: selectedOption){
                presentWorkerIndex.append(i)
                
            }
        }
    }
}
extension ShiftManageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if changeTimeButtonIsHidden {
            return 60
        }else{
            return 112
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentWorkerIndex.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = shiftManageTV.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ShiftManageVCTableViewCell
        
        let index = presentWorkerIndex[indexPath.row]
        cell.index = index
        cell.subedTime = registerShiftVC.workers[dayS]?[index].subedTime
        guard let workers = registerShiftVC.workers[dayS] else {return cell}

        let worker = workers[index]
        cell.nameL.text = worker.name
        let sub = "勤務可能：" + worker.subedTime[0] + "〜" + worker.subedTime[1]
        cell.subedTimeL.text = sub

        if worker.workingTime != []{
            let working = "勤務時間：" + worker.workingTime[0] + "〜" + worker.workingTime[1]
            cell.workingTimeL.text = working
        }else{
            cell.workingTimeL.text = "勤務時間：未決定"
            cell.resetB.isEnabled = false
          
            
        }
        
        let name =  worker.name
        let count = registerShiftVC.workingDayCount[name!] ?? 0
        cell.workingDayCountL.text = "出勤日数:" + String(count) + "日"
        if changeTimeButtonIsHidden{
            cell.upStartTimeB.isHidden = true
            cell.downStartTimeB.isHidden = true
            cell.upEndTime.isHidden = true
            cell.downEndTime.isHidden = true
            cell.workingTimeL.isHidden = false
        }else {
            cell.upStartTimeB.isHidden = false
            cell.downStartTimeB.isHidden = false
            cell.upEndTime.isHidden = false
            cell.downEndTime.isHidden = false
            cell.workingTimeL.isHidden = false
        }
        let subedTime = worker.subedTime
        let workingTime = worker.workingTime
        if workingTime.count == 2{
            if !cell.isAdjustedSubedStartTime(submitedTime: subedTime, workingStartTime: workingTime[0]) || !cell.isAdjustedSubedEndTime(submitedTime: subedTime, workingEndTime: workingTime[1]) || !cell.workingTimeIsOK(submitedTime: subedTime, workingTime: workingTime){
                cell.workingTimeL.textColor = .red

            }
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
    private func presentWorkerCondition(worker:Worker,presentOption:Int) -> Bool{
        switch presentOption {
        case 0:
            return true
        case 1:
            if worker.workingTime.count == 2{
                return true
            }else{
                return false
            }
        default:
            return true
        }
    }
}

class ShiftManageVCTableViewCell: UITableViewCell {
    
//    private let defaltWorkingTime = ["17:00","23:00"]
    var index:Int!
    var subedTime:[String]!

    
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var resetB: UIButton!
    
    @IBAction func resetB(_ sender: Any) {
//        let row = index.row
        registerShiftVC.workers[dayS]![index].workingTime = []
        workingTimeL.text = "勤務時間：未決定"
        let name =  registerShiftVC.workers[dayS]![index].name
        var count = registerShiftVC.workingDayCount[name!] ?? 0
        let row = registerShiftVC.selectedRow!

        var workingCount = registerShiftVC.days[row].workingCount
        if count == 0{
            return
        }
        count -= 1
        workingCount -= 1
        registerShiftVC.workingDayCount[name!] = count
        registerShiftVC.days[row].workingCount = workingCount
        print(registerShiftVC.days[row].workingCount)

        workingDayCountL.text = "出勤日数:" + String(count) + "日"
        resetB.isEnabled = false

    }
//    @IBOutlet weak var resetB: UIStackView!
    @IBOutlet weak var cellV: UIView!
    @IBOutlet weak var subedTimeL: UILabel!
    @IBOutlet weak var workingDayCountL: UILabel!
    @IBOutlet weak var workingTimeL: UILabel!
    @IBOutlet weak var upStartTimeB: UIButton!
    @IBOutlet weak var downStartTimeB: UIButton!
    @IBOutlet weak var upEndTime: UIButton!
    @IBOutlet weak var downEndTime: UIButton!
    private var dayS:String = ""

    
    
    @IBAction func upStartB(_ sender: Any) {
        let workingTime = registerShiftVC.workers[dayS]![index].workingTime
        if workingTime == []{
            setDefaultWorkingTime()

        }else{
            var time = workingTime[0]
            time = upTimePar30minutes(time: time)
            registerShiftVC.workers[dayS]?[index].workingTime[0] = time
        }
        self.downStartTimeB.isEnabled = true

        reloadWorkingTime()
    }
    
    @IBAction func downStartB(_ sender: Any) {
        let workingTime = registerShiftVC.workers[dayS]![index].workingTime
        if workingTime == []{
            setDefaultWorkingTime()

        }else{

            var time = workingTime[0]
            time = downTimePar30minutes(time: time)
            
            if isAdjustedSubedStartTime(submitedTime: self.subedTime, workingStartTime: time){
                registerShiftVC.workers[dayS]?[index].workingTime[0] = time
                self.downStartTimeB.isEnabled = true
            }else{
                registerShiftVC.workers[dayS]?[index].workingTime[0] = subedTime[0]
                self.downStartTimeB.isEnabled = false
                
            }
        }
        reloadWorkingTime()

    }
    @IBAction func upEndB(_ sender: Any) {
        let workingTime = registerShiftVC.workers[dayS]![index].workingTime
        if workingTime == []{
            setDefaultWorkingTime()

        }else{
            var time = workingTime[1]
            time = upTimePar30minutes(time: time)
            if isAdjustedSubedEndTime(submitedTime: self.subedTime, workingEndTime: time){
                registerShiftVC.workers[dayS]?[index].workingTime[1] = time
                self.upEndTime.isEnabled = true
            }else{
                registerShiftVC.workers[dayS]?[index].workingTime[1] = subedTime[1]

                self.upEndTime.isEnabled = false
            }
        }
        reloadWorkingTime()

    }
    @IBAction func downEndB(_ sender: Any) {
        let workingTime = registerShiftVC.workers[dayS]![index].workingTime
        if workingTime == []{
            setDefaultWorkingTime()

        }else{
            var time = workingTime[1]
            time = downTimePar30minutes(time: time)
            registerShiftVC.workers[dayS]?[index].workingTime[1] = time
        }
        self.upEndTime.isEnabled = true
        reloadWorkingTime()

    }
    
    
    @IBOutlet weak var workingTimeL2: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dayS = registerShiftVC.days[registerShiftVC.selectedRow!].dayStr
        cellV.layer.backgroundColor = UIColor.cellColor().cgColor
        cellV.layer.cornerRadius = 0
        cellV.layer.borderColor = UIColor.white.cgColor
        cellV.layer.borderWidth = 1

        

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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

        registerShiftVC.workers[dayS]?[index].workingTime = subedTime
        let name =  registerShiftVC.workers[dayS]![index].name
        var count = registerShiftVC.workingDayCount[name!] ?? 0
        let row = registerShiftVC.selectedRow!

        count += 1
        var workingCount =  registerShiftVC.days[row].workingCount
        workingCount += 1
        registerShiftVC.days[row].workingCount = workingCount
        print(registerShiftVC.days[row].workingCount)

        

        registerShiftVC.workingDayCount[name!] = count
        
        workingDayCountL.text = "出勤日数:" + String(count) + "日"
        downStartTimeB.isEnabled = false
        upEndTime.isEnabled = false
        resetB.isEnabled = true

        
        
    }
    func intToStringFormatter(time:Int) -> String{
        if time < 10 {
            return "0" + String(time)
        }else{
            return String(time)
        }
    }
    func isAdjustedSubedStartTime(submitedTime:[String],workingStartTime:String) -> Bool{
        let dayChanged = compareTwoDateStr_d1d2(d1: submitedTime[0], d2: submitedTime[1])
        let startOK = !compareTwoDateStr_d1d2(d1: submitedTime[0] , d2:workingStartTime)
        if !dayChanged{
            return startOK
        }else{
            return (startOK || compareTwoDateStr_d1d2(d1: submitedTime[1], d2: workingStartTime))
        }
    }
    func isAdjustedSubedEndTime(submitedTime:[String],workingEndTime:String) -> Bool{
        let dayChanged = compareTwoDateStr_d1d2(d1: submitedTime[0], d2: submitedTime[1])
        let endOK = !compareTwoDateStr_d1d2(d1:workingEndTime , d2:  submitedTime[1])
        if !dayChanged{

            return endOK
        }else{

            return (endOK || compareTwoDateStr_d1d2(d1: workingEndTime, d2:submitedTime[0] ))
        }
    }
    private func reloadWorkingTime(){
        guard let workingTime = registerShiftVC.workers[dayS]?[index].workingTime else {return}
        let working = "勤務時間：" + workingTime[0] + "〜" + workingTime[1]
        if !workingTimeIsOK(submitedTime: self.subedTime, workingTime: workingTime){
            workingTimeL.textColor = .red
            
        }else{
            workingTimeL.textColor = .black

        }
        if !isAdjustedSubedStartTime(submitedTime: self.subedTime, workingStartTime: workingTime[0]) || !isAdjustedSubedEndTime(submitedTime: self.subedTime, workingEndTime: workingTime[1]){
            workingTimeL.textColor = .red

        }
        workingTimeL.text = working
    }
    func workingTimeIsOK (submitedTime:[String],workingTime:[String]) -> Bool{
        let dayChanged = compareTwoDateStr_d1d2(d1: submitedTime[0], d2: submitedTime[1])
        if workingTime.count < 2{
            return true
        }
        if !dayChanged{
            return compareTwoDateStr_d1d2(d1: workingTime[1], d2: workingTime[0])
            
        }else{
            if compareTwoDateStr_d1d2(d1: workingTime[1], d2: workingTime[0]){
                let ok1 = compareTwoDateStr_d1d2(d1: workingTime[0], d2: submitedTime[0]) && !compareTwoDateStr_d1d2(d1: submitedTime[0], d2: workingTime[1])
                let ok2 = compareTwoDateStr_d1d2(d1: submitedTime[1], d2: workingTime[0]) && !compareTwoDateStr_d1d2(d1:workingTime[1] , d2: submitedTime[1])

                return ok1 || ok2
            }else{

                return !compareTwoDateStr_d1d2(d1:submitedTime[0] , d2: workingTime[0]) && !compareTwoDateStr_d1d2(d1:  workingTime[1], d2:submitedTime[1])
            }
        }

    }
}





