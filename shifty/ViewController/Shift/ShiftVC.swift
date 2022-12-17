//
//  ShiftVC.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/08/19.
//

import Foundation
import UIKit
import Firebase

class ShiftVC: UIViewController {
    private let cellId = "cellId"
    private var shifts:[Shift] = []
    private var shopNamesOfShifts:[String] = []
    static var selectedShift:Shift?
    private let date = Date()
    
    @IBOutlet weak var messageL: UILabel!
    @IBOutlet weak var ShiftTV: UITableView!
    @IBOutlet weak var goToAddShiftB: UIButton!
    @IBAction func goToAddShiftB(_ sender: Any) {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        var nowVersion = "1.0"
        var shopSubscription = false
        var subscriptionMode = false
        let dis = DispatchGroup()
        dis.enter()
        guard let shopID = val.user?.shopIDs[0] else { return }
        Firestore.firestore().collection("shops").document(shopID).getDocument { doc, err in
            if err != nil{
                self.failedAlert(sentence: "通信エラー")
                return
            }
            guard let doc = doc ,let dic = doc.data() else { return}
            shopSubscription = dic["subscription"] as? Bool ?? false
            dis.leave()

        }
        dis.enter()
        Firestore.firestore().collection("subscriptionMode").document("subscriptionMode").getDocument { doc, err in
            if err != nil{
                self.failedAlert(sentence: "通信エラー")
                return
            }
            guard let doc = doc ,let dic = doc.data() else { return}
            subscriptionMode = dic["subscriptionMode"] as? Bool ?? false
            nowVersion = dic["version"] as? String ?? "1.0"
            dis.leave()
        }
        dis.notify(queue: .main){
            if subscriptionMode || shopSubscription{
                let sb = UIStoryboard(name: "AddShift", bundle: nil)
                let nextView = sb.instantiateViewController( identifier: "AddShiftVC") as! AddShiftVC
                nextView.presentationController?.delegate = self
                self.present(nextView, animated: true, completion: nil)
            }else{
                if version == nowVersion{
                    self.failedAlert(sentence: "有料プランへの加入をお願いします")

                }else{
                    self.failedAlert(sentence: "AppStoreからアプリをアップデートしてください")

                }
            }
            
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        AddShiftVC().shiftReloadDelegate = self

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadShifts()
        setUpView()
    }
    private func setUpView(){
        ShiftTV.separatorStyle = .none

        view.layer.backgroundColor = UIColor.backgroundColor0().cgColor
        ShiftTV.backgroundColor = .clear
        goToAddShiftB.cornerRadius = 15
        navigationController?.navigationBar.barTintColor = UIColor.navigationBarColor()
        
        
        
    }
    private func loadShifts(){
        guard let shopIDs = val.user?.shopIDs else { return }
        guard let shopNames = val.user?.shopNames else { return }
        guard let names = val.user?.names else { return }

        guard let registerUIDs = val.user?.registerUIDs else { return }
         let IDCount = shopIDs.count
        let nameCount = shopNames.count
        if IDCount == 0{

            return
        }

        if IDCount != nameCount{
            failedAlert(sentence: "深刻なエラーが発生しています。アプリを再起動してください。")
            return
        }
        shifts.removeAll()
        shopNamesOfShifts.removeAll()
        let db = Firestore.firestore()
        let dis = DispatchGroup()
        for i in 0...IDCount-1{
            dis.enter()

            db.collection("shops").document(shopIDs[i]).collection("shifts").getDocuments { docs, err in
                if let err = err{
                    print(err)
                    self.failedAlert(sentence: "シフトの読み込みに失敗しました")
                    return
                }
                
                
                docs?.documents.forEach({ doc in
                    let dic = doc.data()
                    let shift = Shift.init(dic: dic)
                    shift.uid = doc.documentID
                    shift.shopID = shopIDs[i]
                    shift.registeredName = names[shopIDs[i]]
                    shift.registerUid = registerUIDs[i]
                    if shift.endDate > self.date{
                        self.shifts.append(shift)
                        self.shopNamesOfShifts.append(shopNames[shopIDs[i]]!)
                    }
                    
                })
                dis.leave()

                
            }

        }
        dis.notify(queue: .main){
            self.ShiftTV.reloadData()

            if self.shifts.count == 0{
                self.messageL.text = "募集しているシフトはありません"
            }else {
//                self.messageL.text = "シフトを選択してください"
                let rank = val.user?.rank ?? 0
                if rank != 1{
                    self.goToAddShiftB.isHidden = true
                    self.goToAddShiftB.isEnabled = false
                    self.messageL.text = "シフトを選択してください"

                }
                if rank == 1{
                    self.goToAddShiftB.isHidden = false
                    self.goToAddShiftB.isEnabled = true
                    self.messageL.text = "シフトを選択してください"

                }
                if rank == 0{
                    self.messageL.text = "「登録」から店長または従業員として登録してください"
                    
                }
            }
            self.ShiftTV.delegate = self
            self.ShiftTV.dataSource = self
            
        }
        
        
    }

}

extension ShiftVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        140
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shifts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ShiftTV.dequeueReusableCell(withIdentifier: cellId,for: indexPath) as! ShiftTVCell
        cell.shopNameL.text = shopNamesOfShifts[indexPath.row]
        let startS = String( makeIntArrayFromDate(shifts[indexPath.row].startDate)[1]) + "月" + String( makeIntArrayFromDate(shifts[indexPath.row].startDate)[2]) + "日"
        let endS = String( makeIntArrayFromDate(shifts[indexPath.row].endDate)[1]) + "月" + String( makeIntArrayFromDate(shifts[indexPath.row].endDate)[2]) + "日"
        let deadS = String( makeIntArrayFromDate(shifts[indexPath.row].deadline)[1]) + "月" + String( makeIntArrayFromDate(shifts[indexPath.row].deadline)[2]) + "日"
        cell.dateL.text = "期間" + startS + "〜" + endS
        cell.deadlineL.text = "締め切り日：" + deadS

        if date < shifts[indexPath.row].deadline{
            
            cell.cellV.layer.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 190).cgColor
            cell.statusL.text = "募集中"
            
        }else {
            switch val.user?.rank {
            case 1:
                cell.cellV.layer.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 120).cgColor
                cell.statusL.text = "募集終了　シフトを決定してください"
                cell.statusL.textColor = .green
                
            case 2:
                cell.cellV.layer.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 190).cgColor
                cell.statusL.text = "募集締め切り"
                cell.statusL.textColor = .red
            default:
                break
            }
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ShiftVC.selectedShift = shifts[indexPath.row]

        if val.user?.rank == 1{
            
            pushView(storyboard: "registerShift", ID: "registerShiftVC")
            
        }else if val.user?.rank == 2{
            pushView(storyboard: "SubmissionShift", ID: "SubmissionShiftVC")
        }
        
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_jp")
        return formatter.string(from: date)
    }
}
//extension ShiftVC:shiftReloadDelegate{
//    func reloadShift() {
//        loadView()
//        viewDidLoad()
//        viewWillAppear(false)
//    }
//
//
//}

extension ShiftVC:UIAdaptivePresentationControllerDelegate{
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        loadView()
        viewWillAppear(false)
        
    }
    
}

class ShiftTVCell:UITableViewCell{
    
    @IBOutlet weak var shopNameL: UILabel!
    @IBOutlet weak var cellV: UIView!
    
    @IBOutlet weak var dateL: UILabel!
    @IBOutlet weak var deadlineL: UILabel!
    @IBOutlet weak var statusL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        cellV.layer.cornerRadius = 35
        self.backgroundColor = .clear

        self.selectedBackgroundView?.layer.backgroundColor = UIColor.white.cgColor
        
        cellV.layer.borderColor = UIColor.white.cgColor
        cellV.layer.borderWidth = 5
        self.selectionStyle = .none

        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        buttonPushAnimation(view: self)
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        buttonPullAnimation(view: self)
    }
}
