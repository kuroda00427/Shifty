//
//  ShiftVC.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/08/19.
//

import Foundation
import UIKit
import Firebase

class EditShiftVC: UIViewController {
    private let cellId = "cellId"
    private var shifts:[Shift] = []
    private var shopNamesOfShifts:[String] = []
//    static var selectedShift:Shift?
    private let date = Date()
    
    @IBOutlet weak var messageL: UILabel!
    @IBOutlet weak var EditShiftTV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EditShiftTV.delegate = self
        EditShiftTV.dataSource = self
        EditShiftTV.separatorStyle = .none
        EditShiftTV.backgroundColor = UIColor.rgb(red: 240, green: 234, blue: 210)
        setUpView()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadShifts()
    }
    private func setUpView(){
       
       
        view.layer.backgroundColor = UIColor.rgb(red: 240, green: 234, blue: 210).cgColor

//        view.layer.backgroundColor = UIColor.rgb(red: 238, green: 224, blue: 190).cgColor
        navigationController?.navigationBar.barTintColor = UIColor.rgb(red: 242, green: 250, blue: 224)
    }
    private func loadShifts(){
        guard let shopIDs = val.user?.shopIDs else { return }
        guard let shopNames = val.user?.shopNames else { return }
        guard let name = val.user?.names else { return }

        guard let registerUIDs = val.user?.registerUIDs else { return }


        let IDCount = shopIDs.count
        let nameCount = shopNames.count
        if IDCount == 0{

            return
        }
        if IDCount != nameCount{
            failedAlert(sentence: "深刻なエラーが発生しています。アプリを入れ直して下さい。")
            return
        }
        shifts.removeAll()
        shopNamesOfShifts.removeAll()
        let db = Firestore.firestore()

        for i in 0...IDCount-1{

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
                    shift.registeredName = name[shopIDs[i]]
                    shift.registerUid = registerUIDs[i]
                    if shift.endDate > self.date{
                        self.shifts.append(shift)
                        self.shopNamesOfShifts.append(shopNames[shopIDs[i]]!)
                    }
                    self.EditShiftTV.reloadData()
                    
                })
                if self.shifts.count == 0{
                    let screenWidth = Int(UIScreen.main.bounds.size.width)

                    self.addLabel(text:  "募集しているシフトはありません", view: self.view, x: 0, y: 120, width: screenWidth ,height:  50, soroe: .center, size: 17, font: 0)
                }
                
            }
        }
        
        
    }

}

extension EditShiftVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        235
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shifts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = EditShiftTV.dequeueReusableCell(withIdentifier: cellId,for: indexPath) as! EditShiftTVCell
        cell.shopNameL.text = shopNamesOfShifts[indexPath.row]
        cell.shift = shifts[indexPath.row]
        cell.deadlineDate = shifts[indexPath.row].deadline
        cell.delegate = self
        cell.viewReloadDelegate = self
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
        
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_jp")
        return formatter.string(from: date)
    }
}
extension EditShiftVC:failedAlertPresentDelegate,ViewReloadDelegate{
    func viewReload(uid:String) {
        shifts.removeAll { shift in
            shift.uid! == uid
        }
        loadView()
        viewDidLoad()
        
    }
    
    func present(view: UIViewController, animated: Bool) {
        present(view, animated: animated, completion: nil)

    }
    
    
}
protocol ViewReloadDelegate:AnyObject {
    func viewReload(uid:String)
}

class EditShiftTVCell:UITableViewCell{
    
    var shift:Shift!
    var deadlineDate:Date!
    var delegate:failedAlertPresentDelegate!
    var viewReloadDelegate:ViewReloadDelegate!
    @IBOutlet weak var shopNameL: UILabel!
    @IBOutlet weak var cellV: UIView!
    
    @IBOutlet weak var dateL: UILabel!
    @IBOutlet weak var deadlineL: UILabel!
    @IBOutlet weak var statusL: UILabel!
    @IBAction func updateDeadlineB(_ sender: Any) {
        let shopId = shift.shopID!
        let uid = shift.uid!
        
        
        Firestore.firestore().collection("shops").document(shopId).collection("shifts").document(uid).updateData(["deadline":deadlineDate!]){(err) in
            if err != nil{
                self.delegate.failedAlert(sentence: "通信エラー")
                return
            }
            self.delegate.failedAlert(sentence: "締め切り日を変更しました")
        }
    }
    
    
    
    @IBAction func deadlineUpB(_ sender: Any) {
        deadlineDate = Calendar.current.date(byAdding: .day, value: 1, to: deadlineDate)
        let deadS = String( getDay(deadlineDate!)[1]) + "月" + String( getDay(deadlineDate!)[2]) + "日"
        deadlineL.text = "締め切り日：" + deadS
        
    }
    @IBAction func deadlineDownB(_ sender: Any) {
        deadlineDate = Calendar.current.date(byAdding: .day, value: -1, to: deadlineDate)
        let deadS = String( getDay(deadlineDate!)[1]) + "月" + String( getDay(deadlineDate!)[2]) + "日"
        deadlineL.text = "締め切り日：" + deadS
    }
    @IBAction func deleteShiftB(_ sender: Any) {
        let shopId = shift.shopID!
        let shiftUid = shift.uid!
        
        let alert = UIAlertController(title: "このシフトを完全に削除します。よろしいですか？", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
            
            self.deleteShift(shopID: shopId, shiftUid: shiftUid)
            
            
            
        })
        self.delegate.present(view:alert, animated: true)
        
    }
    func deleteShift (shopID:String,shiftUid:String){
        var dateInShift:[String] = []
        Firestore.firestore().collection("shops").document(shopID).collection("shifts").document(shiftUid).collection("date").getDocuments { docs, err in
            if err != nil{
                self.delegate.failedAlert(sentence: "通信エラー")

                return
            }
            docs?.documents.forEach({ doc in
                let dayS = doc.documentID
                dateInShift.append(dayS)
            })
            self.deleteShiftAtDay(shopID: shopID, shiftUid: shiftUid, dateinShift: dateInShift)
            self.deleteDateAtShift(shopID: shopID, shiftUid: shiftUid)
            
            Firestore.firestore().collection("shops").document(shopID).collection("shifts").document(shiftUid).delete(){ err in
                if err != nil{
                    self.delegate.failedAlert(sentence: "通信エラー")
                    return
                }
                self.delegate.failedAlert(sentence: "削除しました")
                self.viewReloadDelegate.viewReload(uid: shiftUid)
            }
            
        }
    }
    func deleteCollection(collection: CollectionReference, batchSize: Int = 100) {
        collection.limit(to: batchSize).getDocuments { (docset, error) in
          //An error occurred.
          let docset = docset
          let batch = collection.firestore.batch()
          docset?.documents.forEach { batch.deleteDocument($0.reference) }
          batch.commit {_ in
            self.deleteCollection(collection: collection, batchSize: batchSize)
          }
        }
      }
    private func deleteShiftAtDay(shopID:String,shiftUid:String,dateinShift:[String]){
        dateinShift.forEach({dayS  in
            let collectionPath =  Firestore.firestore().collection("shops").document(shopID).collection("shifts").document(shiftUid).collection("date").document(dayS).collection("shift")
            self.deleteCollection(collection: collectionPath)
           
        })
       
    }
    private func deleteDateAtShift(shopID:String,shiftUid:String){
        let collectionPath =  Firestore.firestore().collection("shops").document(shopID).collection("shifts").document(shiftUid).collection("date")
        deleteCollection(collection: collectionPath)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        cellV.layer.cornerRadius = 35
        self.backgroundColor = UIColor.rgb(red: 240, green: 234, blue: 210)

        self.selectedBackgroundView?.layer.backgroundColor = UIColor.white.cgColor
        
        cellV.layer.borderColor = UIColor.white.cgColor
        cellV.layer.borderWidth = 5
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
