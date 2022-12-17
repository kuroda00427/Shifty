//
//  funcs.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/08/20.
//

import Foundation
import UIKit

extension UIViewController {
    func dateFormatterForDateLabel(date: Date,dateStyle: DateFormatter.Style,timeStyle:DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_jp")
        return formatter.string(from: date)
    }
    
    func loadStr(Key: String) -> String?{
        let value = UserDefaults.standard.object(forKey: Key)
        guard let Str = value as? String else { return nil }
        return Str
    }
    func loadInt(Key: String) -> Int?{
        let value = UserDefaults.standard.object(forKey: Key)
        guard let int = value as? Int else { return nil }
        return int
    }
    func loadIntArr(Key: String) -> [Any]?{
        if let value = UserDefaults.standard.array(forKey: Key){
            return value
        }else{
            return nil
        }
    }
    func loadStringArr (Key: String) -> [String]?{
        let value = UserDefaults.standard.object(forKey: Key)
        guard let St = value as? [String] else { return nil }
        return St
    }
    func loadAny(Key: String) -> Any?{
        let value = UserDefaults.standard.object(forKey: Key)
        //        guard let Str = value as? Any else { return nil }
        return value
    }
    // キーボードが表示された時
    @objc func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo else { return }
        let duration: Float = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
            let transform = CGAffineTransform(translationX: 0, y: -150)
            self.view.transform = transform
        })
        
    }

    // キーボードが閉じられた時
    @objc func keyboardWillHide(sender: NSNotification) {
        guard let userInfo = sender.userInfo else { return }
        let duration: Float = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
            self.view.transform = CGAffineTransform.identity
        })
    }
    
    func setDismissKeyboard() {
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
class save {
    func save(value:Any,Key:String){
        UserDefaults.standard.setValue(value, forKey: Key)
    }
}
//let alert = UIAlertController(title: "左の日程のシフトを募集します", message: "", preferredStyle: UIAlertController.Style.alert)
//alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
//alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
//})
//self.present(alert, animated: true, completion: nil)

extension UIViewController{
    func pushView(storyboard:String,ID:String) {
        let sb = UIStoryboard(name: storyboard, bundle: nil)
        let view = sb.instantiateViewController(withIdentifier: ID)
        navigationController?.pushViewController(view, animated: true)
    }
    func modalView(storyboard:String,ID:String) {
        let sb = UIStoryboard(name: storyboard, bundle: nil)
        let view = sb.instantiateViewController(withIdentifier: ID)
        present(view, animated: true, completion: nil)
    }
    func failedAlert(sentence:String){
        let alert = UIAlertController(title: sentence, message: "", preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
        })
        self.present(alert, animated: true, completion: nil)
    }
    func failedAlert(sentence:String,message:String){
        let alert = UIAlertController(title: sentence, message: message, preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ _ in
        })
        self.present(alert, animated: true, completion: nil)
    }
    func makeDayForUserFromDayS(dayS:String) -> String{
        let dayStr = dayS.suffix(2)

        let startIndex = dayS.index(dayS.startIndex, offsetBy: 4)

        let endIndex = dayS.index(dayS.endIndex,offsetBy: -3)
        let monthStr = dayS[startIndex...endIndex]
        let dayInt = Int(dayStr)!
        let monthInt = Int(monthStr)!
        return String(monthInt) + "月" + String(dayInt) + "日"
    }
    
    func makeIntArrayFromDate(_ date:Date) -> [Int]{
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return [year,month,day]
    }
    func addLabel(text:String,view:UIView, x:Int, y:Int,width: Int,height: Int, soroe: NSTextAlignment,size: CGFloat,font:Int)  {
        let label = UILabel()
        label.frame = CGRect(x: x, y: y, width: width, height: height)
        label.textAlignment = soroe
        label.text = text
        label.textColor = UIColor.black
        if font == 1{
            label.font = UIFont(name: "HirakakuProN-W6", size: size)

        }else{
            label.font = UIFont(name: "System", size: size)

        }
        label.adjustsFontSizeToFitWidth = true
        view.addSubview(label)
    }
    
    
    func changeEndTime(end:String) -> String{
        guard var endInt = Int(end.prefix(2)) else { return "error" }
        if endInt >= 24 {
            endInt -= 24
        }
        if endInt < 10{
            return "0" + String(endInt) + ":" + end.suffix(2)
        }else{
            return String(endInt) + ":" + end.suffix(2)

        }
    }
    func makeDayForUserFromIntArray(day:[Int]) -> String{
        var text = "未入力"
        if day.count >= 2{
            text = String(day[1]) + "月" + String(day[2]) + "日"

        }
        return text
    }
    func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    func getDayOfWeek(date:Date) -> String{
        let ID = getWeekIdx(date)
        switch ID {
        case 1:
            return "（日）"
        case 2:
            return "（月）"
        case 3:
            return "（火）"
        case 4:
            return "（水）"
        case 5:
            return "（木）"
        case 6:
            return "（金）"
        case 7:
            return "（土）"
        default:
            return ""
        }
    }
    func compareTwoDateStr_d1d2(d1:String,d2:String) -> Bool{
        if d1 == "" || d2 == "" {
            return false
        }
        let d1h = d1.prefix(2)
        let d1m = d1.suffix(2)
        let d2h = d2.prefix(2)
        let d2m = d2.suffix(2)
        let d1eva = Int(d1h)! * 100 + Int(d1m)!
        let d2eva = Int(d2h)! * 100 + Int(d2m)!
        return d1eva > d2eva
    }
    func makeDaySForFirestoreFromIntArray(day:[Int]) -> String{
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
    
}
extension UITableViewCell{
    func getDay(_ date:Date) -> [Int]{
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return [year,month,day]
    }
    func compareTwoDateStr_d1d2(d1:String,d2:String) -> Bool{
        if d1 == "" || d2 == "" {
            return false
        }
        let d1h = d1.prefix(2)
        let d1m = d1.suffix(2)
        let d2h = d2.prefix(2)
        let d2m = d2.suffix(2)
        let d1eva = Int(d1h)! * 100 + Int(d1m)!
        let d2eva = Int(d2h)! * 100 + Int(d2m)!
        return d1eva > d2eva
    }
    
    
    func add24Hour(time:String) -> String{
        let h = time.prefix(2)
        let m = time.suffix(2)
        let hint = Int(h)! + 24
        return String(hint) + ":" + m
    }
}


extension UICollectionViewCell{

    
    func getDay(_ date:Date) -> [Int]{
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return [year,month,day]
    }
    func addLabel(text:String,view:UIView, x:Int, y:Int,width: Int,height: Int, soroe: NSTextAlignment,size: CGFloat,font:Int)  {
        let label = UILabel()
        label.frame = CGRect(x: x, y: y, width: width, height: height)
        label.textAlignment = soroe
        label.text = text
        label.textColor = UIColor.black
        if font == 1{
            label.font = UIFont(name: "HirakakuProN-W6", size: size)

        }else{
            label.font = UIFont(name: "System", size: size)

        }
        view.addSubview(label)
    }
    func changeDayToLabel(day:[Int]) -> String{
        let text = String(day[1]) + "月" + String(day[2]) + "日"
        return text
    }
    
    func changeEndTime(end:String) -> String{
        guard var endInt = Int(end.prefix(2)) else { return "error" }
        if endInt >= 24 {
            endInt -= 24
        }
        if endInt < 10{
            return "0" + String(endInt) + ":" + end.suffix(2)
        }else{
            return String(endInt) + ":" + end.suffix(2)

        }
    }
    func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    func getDayOfWeek(date:Date) -> String{
        let ID = getWeekIdx(date)
        switch ID {
        case 1:
            return "（日）"
        case 2:
            return "（月）"
        case 3:
            return "（火）"
        case 4:
            return "（水）"
        case 5:
            return "（木）"
        case 6:
            return "（金）"
        case 7:
            return "（土）"
        default:
            return ""
        }
    }
    func compareTwoDateStr_d1d2(d1:String,d2:String) -> Bool{
        if d1 == "" || d2 == "" {
            return false
        }
        let d1h = d1.prefix(2)
        let d1m = d1.suffix(2)
        let d2h = d2.prefix(2)
        let d2m = d2.suffix(2)
        let d1eva = Int(d1h)! * 100 + Int(d1m)!
        let d2eva = Int(d2h)! * 100 + Int(d2m)!
        return d1eva > d2eva
    }
    

    
}
