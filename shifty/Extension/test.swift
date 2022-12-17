//
//  test.swift
//  shifty
//
//  Created by 黒田拓杜 on 2022/07/04.
//

//
//  Template.swift
//  sns
//
//  Created by 黒田拓杜 on 2022/07/04.
//

import Foundation
import UIKit
import Firebase

class VC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

class TVCell: UITableViewCell{

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}

class a:UIViewController{


    override func viewDidLoad() {
        viewDidLoad()
    }
}
    


class tempResponse:UIViewController{


    override func viewDidLoad() {
        super.viewDidLoad()
        print("load")
//        loadData()
    }

    @IBOutlet weak var tv1: UITableView!

    var textlist:[String] = []
    private func loadData(){

        Firestore.firestore().collection("test").getDocuments { snapshots, err in
            if err != nil{
                print(err!)
//                print("通信エラー====")
                return
            }
            snapshots?.documents.forEach { doc in
                let dic  = doc.data()
                let text = dic["test1"] as? String ?? "error"
                self.textlist.append(text)
            }
            print(self.textlist.count)
            self.tv1.delegate   = self
            self.tv1.dataSource = self
            self.tv1.reloadData()

        }
    }
}


extension tempResponse:UITableViewDelegate,UITableViewDataSource{
 
    
//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textlist.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv1.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResponseCell
        cell.textLabel1.text = textlist[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {


        return 100
    }
//
}



class ResponseCell:UITableViewCell{
    @IBOutlet weak var textLabel1: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }


}


