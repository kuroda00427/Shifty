
import UIKit
import Firebase

class UserInfoVC: UIViewController {
 
    
    @IBOutlet weak var userInfoTV: UITableView!
    @IBOutlet weak var checkRegisterL: UILabel!
    private var password:String?
    
    private let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        loadShopPassword()
        setUpView()
        userInfoTV.delegate = self
        userInfoTV.dataSource = self
        
    }
    private func setUpView(){
        checkRegisterL.isHidden = true
        view.backgroundColor = UIColor.backgroundColor1()
        userInfoTV.backgroundColor = UIColor.backgroundColor1()
        


        guard let rank = val.user?.rank else { return }
        if rank == 0{
            checkRegisterL.isHidden = false
        }
    }
    private func loadShopPassword(){
        let shopIDs = val.user!.shopIDs
        if shopIDs.count == 0{
            return
        }
        Firestore.firestore().collection("shops").document(shopIDs[0]).getDocument { doc, err in
            if err != nil{
                self.failedAlert(sentence: "パスワードの取得に失敗しました")
                return
            }else{
                let doc = doc!.data()!
                self.password = doc["password"] as? String
                self.userInfoTV.reloadData()
            }
        }
    }
}

extension UserInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        220
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return val.user?.registerUIDs.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userInfoTV.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserInfoTVCell
        
        let shopNames = val.user?.shopNames
        let shopIDs = val.user?.shopIDs
        let names = val.user?.names
        let UIDs = val.user?.registerUIDs
        if val.user?.rank == Optional(1) || val.user?.rank == 1 {
            cell.shopIndexL.text = "登録店舗"
            cell.nameOrPasswordL.text = "パスワード"
            cell.registeredNameL.text = password
        }else{
            cell.shopIndexL.text = "登録店舗 " + String(indexPath.row + 1)
            cell.registeredNameL.text = names![shopIDs![indexPath.row]]

        }
        cell.shopNameL.text = shopNames![shopIDs![indexPath.row]]
        cell.shopIDL.text = shopIDs![indexPath.row]
        cell.UIDL.text = UIDs![indexPath.row]
        
        return cell
    }
    
    
}

class UserInfoTVCell: UITableViewCell {
    
    @IBOutlet weak var nameOrPasswordL: UILabel!
    @IBOutlet weak var shopIndexL: UILabel!
    @IBOutlet weak var shopNameL: UILabel!
    @IBOutlet weak var shopIDL: UILabel!
    @IBOutlet weak var registeredNameL: UILabel!
    @IBOutlet weak var UIDL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.backgroundColor1()

        self.selectionStyle = .none
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}





