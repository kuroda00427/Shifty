//
//  AddShift2VC.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/08/22.
//

import Foundation
import UIKit
import Firebase

class AddShift2VC: UIViewController {

    @IBOutlet weak var shiftStart: UIDatePicker!
    @IBOutlet weak var shiftLast: UIDatePicker!
    @IBOutlet weak var shiftDueDay: UIDatePicker!
    @IBOutlet weak var shiftL: UILabel!
    @IBOutlet weak var shiftRecruitB: UIButton!
    
    @IBAction func shiftRecuitB(_ sender: Any) {
        let startDate = shiftStart.date
        let endDate = shiftLast.date
        let deadDate = shiftDueDay.date
        if startDate > endDate {
            self.failedAlert(sentence: "開始日と終了日の前後関係が正しくありません")
            return
        }
        let start = makeIntArrayFromDate(startDate)
        let end = makeIntArrayFromDate(endDate)
        guard let shopId = val.user?.shopIDs[0] else { return }

        guard let shopName = val.user?.shopNames[shopId] else {return}
        let alert = UIAlertController(title: "以下の日程で\(shopName)でのシフトを募集します", message: "\(start[1])/\(start[2])〜\(end[1])/\(end[2])", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
            Firestore.firestore().collection("shops").document(shopId).collection("shifts").addDocument(data: ["startDate":startDate,"endDate":endDate,"deadline":deadDate]){(err) in
                if let err = err {
                    print(err)
                    self.failedAlert(sentence:"サーバへの保存に失敗しました")
                    return
                }
                self.failedAlert(sentence: "募集しました")
            }
            
        })
        self.present(alert, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        shiftStart.addTarget(self, action: #selector(didChangeStartDate), for: .valueChanged)
    }
   
    private func setUpView()  {
        let title = "シフト募集"
        
        self.navigationItem.title = title
        view.layer.backgroundColor = UIColor.rgb(red: 238, green: 224, blue: 190).cgColor

        
    }
    @objc func didChangeStartDate(_ sender: UIDatePicker) {
        print("s")
    }

//    private func dateFormatterForDateLabel(date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        formatter.timeStyle = .none
//        formatter.locale = Locale(identifier: "ja_jp")
//        return formatter.string(from: date)
//    }
//    private func getDay(_ date:Date) -> [Int]{
//        let tmpCalendar = Calendar(identifier: .gregorian)
//        let year = tmpCalendar.component(.year, from: date)
//        let month = tmpCalendar.component(.month, from: date)
//        let day = tmpCalendar.component(.day, from: date)
//        return [year,month,day]
//    }
//    private func failedAlert(sentence:String){
//        let alert = UIAlertController(title: sentence, message: "", preferredStyle: UIAlertController.Style.alert)
//        //alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
//
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
//        })
//        self.present(alert, animated: true, completion: nil)
//    }
}

