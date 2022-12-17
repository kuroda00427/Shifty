
import UIKit
import Firebase

class EmployeeInfoVC: UIViewController {
 
    
    @IBOutlet weak var tableView: UITableView!
    private let cellId = "cellId"
    private var employees:[Employee] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        tableView.delegate = self
        tableView.dataSource = self
        loadEmployee()

        
    }
    private func setUpView(){
        tableView.backgroundColor = UIColor.rgb(red: 240, green: 234, blue: 210)

        view.backgroundColor = UIColor.rgb(red: 240, green: 234, blue: 210)

    }
    private func loadEmployee(){
        let shopID = val.user!.shopIDs[0]
        Firestore.firestore().collection("shops").document(shopID).collection("members").getDocuments { docs, err in
            if err != nil{
                self.failedAlert(sentence: "通信エラー")
                return
            }
            docs?.documents.forEach({ doc in
                let dic = doc.data()
                let employee = Employee.init(dic: dic)
                employee.uid = doc.documentID
                self.employees.append(employee)
            })
            self.employees.sort { e1, e2 in
                return e1.createdAt.dateValue() < e2.createdAt.dateValue()
            }
            self.tableView.reloadData()
        }
    }
}

extension EmployeeInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        140
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EmployeeInfoTVCell
        let employee = employees[indexPath.row]
        cell.nameL.text = employee.name
        cell.IDL.text = employee.uid
        let day = makeIntArrayFromDate(employee.createdAt.dateValue())
        cell.registerDateL.text = String(day[0]) + "年" + String(day[1]) + "月" + String(day[2]) + "日"
        return cell
    }
    
    
}

class EmployeeInfoTVCell: UITableViewCell {
    @IBOutlet weak var nameL: UILabel!
    
    @IBOutlet weak var IDL: UILabel!
    
    @IBOutlet weak var registerDateL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.rgb(red: 240, green: 234, blue: 210)
        self.selectionStyle = .none
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
class Employee{
    let name:String
    var uid:String?
    let createdAt:Timestamp
    init(dic:[String:Any]) {
        self.name = dic["name"] as? String ?? "error"
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}




