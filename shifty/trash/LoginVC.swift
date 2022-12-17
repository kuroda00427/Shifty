//
//  LoginVC.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/08/13.
//

import Foundation
import UIKit
import Firebase

class A: UIViewController {
    
    let tf1:UITextField? = nil
    
    func a(){
        let text = tf1?.text
        Firestore.firestore().collection("text").addDocument(data: ["writtenText":text ?? "nil"])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

