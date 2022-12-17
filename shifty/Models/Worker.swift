//
//  Worker.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/09/04.
//

import Foundation
class Worker {
    var subedTime:[String]
    var workingTime:[String]
    var name:String?
    var uid:String?
    init(dic:[String:Any]) {
        self.name = dic["name"] as? String ?? "error"
        self.subedTime = dic["subedTime"] as? [String] ?? []
        self.workingTime = dic["workingTime"] as? [String] ?? []

        

    }
    
}
