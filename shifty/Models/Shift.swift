//
//  dates.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/08/22.
//

import Foundation
import Firebase

class Shift {
    let startDate:Date
    let endDate:Date
    var deadline:Date
    let holiday:[String]
    var shopID:String?
    var uid:String?
    var registeredName:String?
    var registerUid:String?
    
    init(dic:[String:Any]) {
        let startTime = dic["startDate"] as? Timestamp ?? Timestamp()
        
        self.startDate = startTime.dateValue()
        self.endDate = (dic["endDate"] as? Timestamp ?? Timestamp()).dateValue()
        self.deadline = (dic["deadline"] as? Timestamp ?? Timestamp()).dateValue()
        self.holiday = dic["holiday"] as? [String] ?? []
        

    }
    
}
class infoOfDay{
    var startTime:String?
    var endTime:String?
    var date:Date?
    var dayInt:[Int] = []
    var dayStr:String = ""
    var submittedCount:Int = 0
    var workingCount:Int = 0
    var isHoliday:Bool = false
    init() {
    }
    
}
