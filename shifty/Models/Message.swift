//
//  Message.swift
//  practice
//
//  Created by 黒田拓杜 on 2021/05/14.
//

import Foundation
import Firebase

class Message {
    
    let message: String
    let countryUid: String
    let username: String
    let createdAt: Timestamp
    let profileImageUrl: String
    
//    var uid: String?
    
    init(dic: [String: Any]) {
        self.message = dic["message"]as? String ?? ""
        self.countryUid = dic["countryUid"]as? String ?? ""
        self.username = dic["username"]as? String ?? ""
        self.createdAt = dic["createdAt"]as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageUrl"]as? String ?? ""
        
    }
    
}
