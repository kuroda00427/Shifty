
//import UIKit
//import Firebase
//
//class cell: UIViewController {
//
//
//
//    private var cities = [Int].self
//    private let cellId = "cellId"
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//
//    }
//
//}
//    private func loadCity(){
//        guard let countryUid = HomeVC.loginUser?.countryUid else { return }
//        Firestore.firestore().collection("countries").document(countryUid).collection("cities").getDocuments { snapshots, err in
//            if let err = err{
//                print(err)
//                return
//            }
//            snapshots?.documents.forEach({ snapshot in
//                let dic = snapshot.data()
//                let city = City.init(dic: dic)
//                city.uid = snapshot.documentID
//                self.cities.append(city)
//                self.myCountryTableView.reloadData()
//            })
//            self.myCountryTableView.delegate = self
//            self.myCountryTableView.dataSource = self
//
//        }
//    }

//extension cell: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = myCountryTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! clTableViewCell
//
//        return
//    }
//
//
//}

//class clTableViewCell: UITableViewCell {
//
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//    }
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
//}
//




