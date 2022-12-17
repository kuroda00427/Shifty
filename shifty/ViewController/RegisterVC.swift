//
//  SettingVC.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/08/19.
//

import Foundation
import UIKit
import Firebase

class RegisterVC: UIViewController {
    var db = Firestore.firestore()
    private var rank = 0
    private let enabledOrnerBColor = UIColor.rgb(red: 255, green: 191, blue: 10)
    private let disabledOrnerBColor = UIColor.rgb(red: 255, green: 240, blue: 200)
    private let disabledOrnerBCornerColor = UIColor.rgb(red: 255, green: 210, blue: 140)

    
    private let enabledPartBColor = UIColor.rgb(red: 240, green: 255, blue: 10)
    private let disabledPartBColor = UIColor.rgb(red: 240, green: 255, blue: 205)
    
    
    
    @IBOutlet weak var rankL: UILabel!
    @IBOutlet weak var OrnerB: UIButton!
    @IBOutlet weak var PartB: UIButton!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var IDL: UILabel!
    @IBOutlet weak var IDTF: UITextField!
    @IBOutlet weak var passwordL: UILabel!
    
    @IBOutlet weak var registerB: UIButton!

    @IBOutlet weak var passTF: UITextField!
    @IBAction func ornerB(_ sender: Any) {
        let valrank = val.user?.rank ?? 0
        if valrank != 0{
            return
        }

        OrnerB.backgroundColor = enabledOrnerBColor
        PartB.backgroundColor = disabledPartBColor
        nameL.text = "店舗名を入力してください"
        IDL.text = "ご希望の店舗IDを入力してください（半角）"
        passwordL.text = "ご希望のパスワードを入力してください（半角）"
        rankL.text = "店長（シフト管理人）として登録します"
        rank = 1
    }
    
    @IBAction func partB(_ sender: Any) {
        let valrank = val.user?.rank ?? 0
        if valrank != 0{
            return
        }
        PartB.backgroundColor = enabledPartBColor
        OrnerB.backgroundColor = disabledOrnerBColor
        OrnerB.borderColor = disabledOrnerBCornerColor

        nameL.text = "登録名を入力してください"
        IDL.text = "店舗IDを入力してください"
        passwordL.text = "パスワードを入力してください"
        rankL.text = "従業員として登録します"
        rank = 2
    }
    @IBAction func registerB(_ sender: Any) {
        let valrank = val.user?.rank ?? 0
        let TFIsNotNil = TFnilCheck()
        if !TFIsNotNil{
            return
        }
        let name = nameTF.text!
        let shopID = IDTF.text!
        let password = passTF.text!
        if valrank == 1{
            if (val.user?.shopIDs ?? [""])[0] != shopID{
                failedAlert(sentence: "店舗IDを確認してください")
                return
            }

            changeShopName(name: name, shopID: shopID, password: password)
            return
        }
        if valrank == 2{
            if let index = (val.user?.shopIDs ?? []).firstIndex(of: shopID){
                self.changeName(name: name, shopID: shopID, password: password, index: index)
            }else {
                self.registerAsWorker(name: name, shopID: shopID, password: password)
            }
            return
        }
        switch rank {
        case 1:
            registerShop(shopName: name, shopID: shopID, password: password)
            

        case 2:
            registerAsWorker(name: name, shopID: shopID, password: password)

        default:
            break
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setDismissKeyboard()
        setUpViews()
        nameTF.delegate = self
        IDTF.delegate = self
        passTF.delegate = self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(sender:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(sender:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    private func setUpViews(){
//        view.backgroundColor = UIColor.backgroundColor0()
//        nameTF.backgroundColor = UIColor.backgroundColor1()
//        IDTF.backgroundColor = UIColor.backgroundColor1()
//        passTF.backgroundColor = UIColor.backgroundColor1()
        navigationController?.navigationBar.barTintColor = UIColor.navigationBarColor()

        nameL.text = ""
        IDL.text = ""
        passwordL.text = ""
        nameL.adjustsFontSizeToFitWidth = true
        IDL.adjustsFontSizeToFitWidth = true
        passwordL.adjustsFontSizeToFitWidth = true
        rankL.adjustsFontSizeToFitWidth = true

        OrnerB.backgroundColor = disabledOrnerBColor
        PartB.backgroundColor = disabledPartBColor
        OrnerB.cornerRadius = 15
        OrnerB.borderWidth = 3
        OrnerB.borderColor = enabledOrnerBColor
        PartB.cornerRadius = 15
        PartB.borderWidth = 3
        PartB.borderColor = enabledPartBColor
        registerB.cornerRadius = 10
        addShadow(view: registerB)
        guard let user = val.user else { return }
        switch user.rank {
        case 1:
            rank = 1
            OrnerB.backgroundColor = enabledOrnerBColor
            PartB.backgroundColor = disabledPartBColor
            PartB.isEnabled = false
//            OrnerB.isEnabled = false

            rankL.text = "店舗名を変更します"
            nameL.text = "新しい店舗名を入力してください"
            IDL.text = "店舗IDを入力してください"
            passwordL.text = "パスワードを入力してください"
            
            nameTF.text = user.shopNames[user.shopIDs.last!]
            IDTF.text = user.shopIDs.last!
            passTF.text = ""
            registerB.setTitle("店舗名変更", for: .normal)
            

        case 2:
            rank = 2
            PartB.backgroundColor = enabledPartBColor
            OrnerB.backgroundColor = disabledOrnerBColor
            OrnerB.isEnabled = false
            OrnerB.borderColor = disabledOrnerBCornerColor
//            PartB.isEnabled = false

            nameL.text = "登録名を入力してください"
            rankL.text = "登録名変更または新しい店舗を追加します"
            IDL.text = "店舗IDを入力してください"
            passwordL.text = "パスワードを入力してください"

            
            nameTF.text = user.names[user.shopIDs.last!]
            IDTF.text = user.shopIDs.last!
            passTF.text = ""
            registerB.setTitle("登録名変更または店舗追加", for: .normal)

        default:
            break
        
            
        }
    }
    
    private func registerShop(shopName:String,shopID:String,password:String) {
        db.collection("shops").whereField("ID", isEqualTo: shopID).getDocuments { (snapshots, err) in
            if err != nil {
                self.failedAlert(sentence: "通信エラー", message: "通信状況を確認してください")
                return
            }
            if snapshots?.documents == []{
                let alert = UIAlertController(title: "\(shopName)の店長として登録します。", message: "店舗ID:\(shopID),パスワード:\(password)", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
                    self.db.collection("shops").document(shopID).setData(["shopName":shopName,"ID":shopID,"password":password,"lastLogin":Timestamp(),"createdAt":Timestamp()]){ [self] err in
                        if err != nil{
                            self.failedAlert(sentence: "通信エラー", message: "通信状況を確認してください")
                            return
                        }
                        self.successAlert(messageType: 0)
                        
                        val.user?.rank = 1
                        
                        save().save(value: 1, Key: "rank")
                        
                        val.user?.shopIDs.append(shopID)
                        val.user?.shopNames[shopID] = shopName
                        val.user?.names[shopID] = "店長"
                        save().save(value: val.user?.shopIDs ?? [shopID], Key: "shopIDs")
                        self.addMember(shopID: password, name: "店長")
                        print("registerShop")
                        self.rankL.text = "店長として登録されています"
                        self.registerB.setTitle("店舗名変更", for: .normal)
                    }
                })
                self.present(alert, animated: true, completion: nil)
                
            }else{
                self.failedAlert(sentence: "そのIDは既に使用されています")
            }
        }
    }
    private func registerAsWorker(name:String,shopID:String,password:String){
        db.collection("shops").whereField("ID", isEqualTo: shopID).getDocuments { (snapshots, err) in
            if err != nil {
                self.failedAlert(sentence: "通信エラー", message: "通信状況を確認してください")
                return
            }
            if snapshots?.documents != []{
                self.db.collection("shops").document(shopID).getDocument { doc, err in
                    if err != nil{
                        self.failedAlert(sentence: "通信エラー", message: "通信状況を確認してください")
                        return
                    }
                    guard let doc = doc, let dic = doc.data() else {return}
                    guard let shopName = dic["shopName"] else {return}
                    guard let pass = dic["password"] else {return}
                    if pass as? String ?? "" != password{
                        self.failedAlert(sentence: "パスワードが違います")
                        return
                    }
                    
                    self.db.collection("shops").document(shopID).collection("members").whereField("name", isEqualTo: name).getDocuments { (snapshots, err) in
                        if err != nil {
                            self.failedAlert(sentence: "通信エラー", message: "通信状況を確認してください")
                            return
                        }
                        if snapshots?.documents == []{
                            let alert = UIAlertController(title: "\(shopName)の従業員として登録します。よろしいですか？", message: "", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ [self] _ in
                                self.addMember(shopID: password, name: name)
                                
                                val.user?.rank = 2
                                save().save(value: 2, Key: "rank")
                               
                                val.user?.names[shopID] = name
                                val.user?.shopIDs.append(shopID)
                                val.user?.shopNames[shopID] = shopName as? String ?? "error"
                                save().save(value: val.user?.shopIDs ?? [], Key: "shopIDs")
                                save().save(value: val.user?.names ?? [], Key: "names")
                                print("registerEmployee")
                                self.rankL.text = "従業員として登録されています"
                                self.registerB.setTitle("登録名変更または店舗追加", for: .normal)

                            })
                            self.present(alert, animated: true, completion: nil)
                            
                        }else{
                            self.failedAlert(sentence: "同じ氏名が使われています")
                        }
                    }
                }
            }else{
                self.failedAlert(sentence: "そのIDは存在しません")
            }
        }
    }
    private func addMember(shopID:String,name:String){
        let randam = String( Int.random(in: 0...999999999))
        self.db.collection("shops").document(shopID).collection("members").document(randam).setData(["name":name,"createdAt":Timestamp(),"lastLogin":Timestamp()]){ err in
            if err != nil{
                self.failedAlert(sentence: "通信エラー", message: "通信状況を確認してください")
                return
            }
            self.successAlert(messageType: 0)
            
            var registerUIDs = val.user?.registerUIDs ?? []
            registerUIDs.append(randam)
            val.user?.registerUIDs = registerUIDs
            save().save(value: registerUIDs , Key: "registerUIDs")
            
        }
        
    }
    private func changeShopName(name:String,shopID:String,password:String){
        db.collection("shops").document(shopID).getDocument { doc, err in
            if let err = err{
                print(err)
                self.failedAlert(sentence: "通信エラー", message: "通信状況を確認してください")
                return
            }
            guard let doc = doc, let dic = doc.data() else{return}
            guard let shopName = dic["shopName"] else {return}
            guard let pass = dic["password"] else {return}
            if pass as? String ?? "" != password{
                self.failedAlert(sentence: "パスワードが違います")
                return
            }
            let alert = UIAlertController(title: "\(shopName)での登録名を変更しますか？", message: "\(shopName)→\(name)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
                self.db.collection("shops").document(shopID).collection("members").whereField("name", isEqualTo: name).getDocuments { (snapshots, err) in
                    if let err = err {
                        print("failed \(err)")
                        return
                    }
                    if snapshots?.documents == []{
                        self.db.collection("shops").document(shopID).updateData(["shopName":name]){err in
                            if err != nil{
                                self.failedAlert(sentence: "通信エラー", message: "通信状況を確認してください")
                                return
                            }
                            val.user?.shopNames[shopID] = name
                            self.successAlert(messageType: 1)
                        }
                        
                    }else{
                        self.failedAlert(sentence: "同じ氏名が使われています")
                    }
                }
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    private func changeName(name:String,shopID:String,password:String,index:Int){
        db.collection("shops").document(shopID).getDocument { doc, err in
            if let err = err{
                print(err)
                self.failedAlert(sentence: "通信エラー", message: "通信状況を確認してください")

                return
            }

            guard let doc = doc, let dic = doc.data() else{return}
            print("s")

            guard let shopName = dic["shopName"] else {return}
            guard let pass = dic["password"] as? String else {return}
            print(pass)
            if pass != password{
                self.failedAlert(sentence: "パスワードが違います")
                return
            }
            let alert = UIAlertController(title: "\(shopName)での登録名を変更しますか？", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
                self.db.collection("shops").document(shopID).collection("members").whereField("name", isEqualTo: name).getDocuments { (snapshots, err) in
                    if let err = err {
                        print("failed \(err)")
                        return
                    }
                    if snapshots?.documents == []{
                        self.db.collection("shops").document(shopID).collection("members").document(val.user!.registerUIDs[index]).updateData(["name":name]){err in
                            if err != nil{
                                self.failedAlert(sentence: "通信エラー", message: "通信状況を確認してください")
                                return
                            }
                            val.user?.names[shopID] = name
                            self.successAlert(messageType: 1)
//                            save().save(value: val.user?.names ?? [], Key: "names")
                        }
                        
                    }else{
                        self.failedAlert(sentence: "同じ氏名が使われています")
                    }
                }
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    

    
    private func successAlert(messageType:Int){
        if messageType == 0{
            let alert = UIAlertController(title: "登録されました", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
            })
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "更新されました", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func TFnilCheck() -> Bool{
        switch rank {
        case 1:
            if nameTF.text == ""{
                self.failedAlert(sentence: "店舗名を入力して下さい")
                return false
            }
            if IDTF.text == "" {
                self.failedAlert(sentence: "店舗IDを入力して下さい")
                return false
            }
            if passTF.text == ""{
                self.failedAlert(sentence: "パスワードを入力して下さい")
                return false
            }
            return true
        case 2:
            if nameTF.text == "" {
                self.failedAlert(sentence: "氏名を入力して下さい")
                return false
            }
            if IDTF.text == "" {
                self.failedAlert(sentence: "店舗IDを入力して下さい")
                return false
            }
            if passTF.text == ""{
                self.failedAlert(sentence: "パスワードを入力して下さい")
                return false
            }
            return true
        default:
            self.failedAlert(sentence: "店長または従業員を設定して下さい")
            return false
        }
    }
    private func impossibleAlert(){
        let alert = UIAlertController(title: "店長⇄従業員を変更するにはAppを初期化する必要があります", message: "その他から初期化して下さい", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
}


extension RegisterVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
