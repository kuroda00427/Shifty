//
//  AddShiftCVCell.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/10/12.
//

import Foundation

import UIKit
import FSCalendar
import CalculateCalendarLogic

import Firebase





class AddShiftCVCell2: UICollectionViewCell,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance{
    
    var selectedDays:[[Int]] = []
    
    
    var calendar:FSCalendar = FSCalendar()
    var textLabel : UILabel?
    var selectedDayL : UILabel?

    
    weak var delegate: CollectionViewReloadDataDelegate!

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)        
        setUpView()
    }
    
    
    
    private func setUpView(){
        let screenWidth = Int(UIScreen.main.bounds.size.width)
        let screenHeight = Int(UIScreen.main.bounds.size.height)
        
        self.backgroundColor = UIColor.rgb(red: 240, green: 238, blue: 210)


        calendar.frame = CGRect(x:screenWidth * 2/100, y:screenHeight * 20/100,width:screenWidth * 96/100, height:screenHeight * 52/100)
        calendar.appearance.headerDateFormat = "YYYY年MM月"
        calendar.appearance.selectionColor = .clear
        calendar.appearance.titleSelectionColor = .black
        calendar.calendarWeekdayView.weekdayLabels[0].text = "日"
        self.calendar.calendarWeekdayView.weekdayLabels[1].text = "月"
        self.calendar.calendarWeekdayView.weekdayLabels[2].text = "火"
        self.calendar.calendarWeekdayView.weekdayLabels[3].text = "水"
        self.calendar.calendarWeekdayView.weekdayLabels[4].text = "木"
        self.calendar.calendarWeekdayView.weekdayLabels[5].text = "金"
        self.calendar.calendarWeekdayView.weekdayLabels[6].text = "土"


        
        
        calendar.backgroundColor = .white
        addShadow(view: calendar)
        self.contentView.addSubview(calendar)

        self.calendar.dataSource = self
        self.calendar.delegate = self
        
        textLabel = UILabel(frame: CGRect(x:0, y: 50 , width:screenWidth, height:screenHeight * 8/100))
        textLabel?.text = "nil"
        textLabel?.textAlignment = NSTextAlignment.center
        self.contentView.addSubview(textLabel!)
        selectedDayL = UILabel(frame: CGRect(x:0, y: 90 , width:screenWidth, height:screenHeight * 8/100))
        selectedDayL?.text = "未入力"
        selectedDayL?.textAlignment = NSTextAlignment.center
        self.contentView.addSubview(selectedDayL!)
        let goNextL = UILabel(frame: CGRect(x:0, y: 0 , width:screenWidth  , height:screenHeight * 8/100))
        goNextL.text = "右にスワイプで次へ・・・"
        goNextL.textColor = .rgb(red: 40, green: 128, blue: 255)
        goNextL.textAlignment = NSTextAlignment.right
        self.contentView.addSubview(goNextL)

        
    }
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
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
    
    // 土日や祝日の日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
//
        
        //祝日判定をする（祝日は赤色で表示する）
        if self.judgeHoliday(date){
            return UIColor.red
        }
//        if selectedDay == getDay(date){
//            return UIColor.black
//        }
        //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekday = getWeekIdx(date)
        if weekday == 1 {   //日曜日
            return UIColor.red
        }
        else if weekday == 7 {  //土曜日
            return UIColor.blue
        }
        
        return nil
    }
    
    
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        
        let selectedDay = getDay(date)
        if selectedDays.contains(selectedDay){
            selectedDays.removeAll(where: {$0 == selectedDay})
        }else{
            selectedDays.append(selectedDay)
        }
        selectedDays.sort { m1, m2 in
            return m1[0]*1000 + m1[1]*100 + m1[2] < m2[0]*1000 + m2[1]*100 + m2[2]
        }
        AddShiftVC.holiday = selectedDays

        var text = "休業日："
        selectedDays.forEach { day in
            text += String(day[1]) + "/" + String(day[2]) + " "
        }
        AddShiftVC.holidayText = text
 
        self.delegate?.reloadData()
        calendar.reloadData()

        
    }
    func calendar(calendar: FSCalendar!, hasEventForDate date: NSDate!) -> Bool {
        return true
    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let day = getDay(date)
        
        
        if selectedDays.contains(day){
            
            return 1
            
        }else{
            return 0
            
        }
        
        
    }
    
    
//    private func recruit(shopId:Int){
//
//        Firestore.firestore().collection("shops").document(String(shopId)).collection("shifts").addDocument(data: ["days":selectedDays])
//    }
}



