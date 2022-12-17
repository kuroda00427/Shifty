//
//  User.swift
//  FirstApp
//
//  Created by 黒田拓杜 on 2021/05/02.
//

import Foundation
import Firebase

class User {
    var rank: Int
    var names: [String:String]
    var shopIDs: [String]
    var shopNames: [String:String]
    var registerUIDs: [String]
    var defaultWorkingTime:[String]
    var defaultWorkingUnit:Int
    
    init(dic: [String: Any]) {
        self.rank = dic["rank"]as? Int ?? 0
        self.names = dic["names"]as? [String:String] ?? [:]
        self.shopIDs = dic["shopIDs"]as? [String] ?? []
        self.shopNames = dic["shopNames"]as? [String:String] ?? [:]
        self.registerUIDs = dic["registerUIDs"] as? [String] ?? []
        self.defaultWorkingTime = dic["defaultWorkingTime"] as? [String] ?? ["17:00","23:00"]
        self.defaultWorkingUnit = dic["defaultWorkingUnit"] as? Int ?? 30
    }
    
}

class val{
    static var user:User?
    
    static var events:[String:[Event]] = [:]
    static var workers:[String:[Worker]] = [:]
    
}
