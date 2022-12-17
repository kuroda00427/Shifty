//
//  SettingVC.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/09/20.
//

import Foundation


import UIKit

class SettingVC: UIViewController {
    
    private var cellNames:[String] = ["登録情報","各種設定","ヘルプ・使い方","機種変更（開発中）","運営より（開発中）"]
    private let ornerCellNames:[String] = ["従業員情報","シフト削除・締め切り延長","店舗パスワード変更（開発中）","自動シフト生成（開発中）"]

    @IBOutlet weak var heightOfSettingTV: NSLayoutConstraint!
    @IBOutlet weak var settingTV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "その他・設定等"
        navigationController?.navigationBar.barTintColor = UIColor.rgb(red: 242, green: 250, blue: 224)

        if val.user?.rank == Optional(1) {
            cellNames.append("")
            cellNames += ornerCellNames
        }
        heightOfSettingTV.constant = CGFloat(cellNames.count * 60)
        settingTV.tag = 1
        settingTV.delegate = self
        settingTV.dataSource = self
        

    }


}

extension SettingVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellNames.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingTV.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SettingTVCell
        cell.label.text = cellNames[indexPath.row]
        if cell.label.text == ""{
            cell.selectionStyle = .none
        }
        return cell
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            pushView(storyboard: "UserInfo", ID: "UserInfoVC")
        case 1:
            pushView(storyboard: "TimeSetting", ID: "TimeSettingVC")
        case 2:
//            modalView(storyboard: "Tutorial", ID: "TutorialVC")
            pushView(storyboard: "HelpAndTutorial", ID: "HelpAndTutorialVC")
                    
        case 6:
            pushView(storyboard: "EmployeeInfo", ID: "EmployeeInfoVC")
        case 7:
            pushView(storyboard: "EditShift", ID: "EditShiftVC")
        default:
            break
        }
    }
}


class SettingTVCell:UITableViewCell{
    
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


//class OrnerSettingCell: UITableViewCell {
//
//    @IBOutlet weak var label: UILabel!
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//}
