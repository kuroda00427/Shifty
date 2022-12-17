//
//  StartVC.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/08/13.
//

import UIKit
import Firebase
import FSCalendar
import CalculateCalendarLogic

class AddShiftVC:UIViewController{
//    weak var shiftReloadDelegate:shiftReloadDelegate!
    var collectionView: UICollectionView!
    var layout: UICollectionViewFlowLayout!
    var goToNextB:UIButton!
    var goToBackB:UIButton!
    let screenWidth = Int(UIScreen.main.bounds.size.width)
    let screenHeight = Int(UIScreen.main.bounds.size.height)
    let offSet = 60
    
    static var startDate:Date?
    static var endDate:Date?
    static var holiday:[[Int]]?
    static var deadline:Date?
    static var startDayText = "開始日：未入力"
    static var endDayText = "最終日：未入力"
    static var holidayText = "休業日：なし"
    static var deadlineText = "締め切り：未入力"
    

    
    var labelTexts = ["募集する期間の開始日を選択してください","募集する期間の最終日を選択してください","休業日を選択してください（任意）","シフト提出締め切り日を選択してください（任意）",""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.backgroundColor = UIColor.rgb(red: 238, green: 224, blue: 190).cgColor

        let viewWidth = screenWidth
        let viewHeight = screenHeight

        let collectionViewFrame = CGRect (x: 0, y: 0, width: viewWidth, height: viewHeight )
        
        // CollectionViewのレイアウトを生成
        layout = UICollectionViewFlowLayout()
        
        // Cell一つ一つの大きさを設定
        layout.itemSize = CGSize(width: viewWidth, height: viewHeight )
        
        // Cellの行間隔を設定
        layout.minimumLineSpacing = 0
        
        // Cellの列間隔を設定
        layout.minimumInteritemSpacing = 0
        
        // CollectionViewのスクロールの方向を横にする
        layout.scrollDirection = .horizontal
        
        // CollectionViewを生成
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.rgb(red: 240, green: 238, blue: 210)

        // Cellに使われるクラスを登録
        collectionView.register(AddShiftCVCell0.self, forCellWithReuseIdentifier: "CustomCell0")
        collectionView.register(AddShiftCVCell1.self, forCellWithReuseIdentifier: "CustomCell1")
        collectionView.register(AddShiftCVCell2.self, forCellWithReuseIdentifier: "CustomCell2")
        collectionView.register(AddShiftCVCell3.self, forCellWithReuseIdentifier: "CustomCell3")
        collectionView.register(AddShiftCVCell4.self, forCellWithReuseIdentifier: "CustomCell4")

        
        // dataSourceを自身に設定
        collectionView.dataSource = self
        
        // ページングさせる
        collectionView.isPagingEnabled = true
        
        // ScrollIndicatorを非表示にする
        collectionView.showsHorizontalScrollIndicator = false
        
        // CollectionViewをViewに追加する
        self.view.addSubview(collectionView)
        
//        setUpButton()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        AddShiftVC.startDate = nil
        AddShiftVC.endDate = nil
        AddShiftVC.holiday = nil
        AddShiftVC.deadline = nil
        AddShiftVC.startDayText = "開始日：未入力"
        AddShiftVC.endDayText = "最終日：未入力"
        AddShiftVC.holidayText = "休業日：なし"
        AddShiftVC.deadlineText = "締め切り：未入力"
        
    }
    
    private func setUpButton(){
        goToNextB = UIButton(type: UIButton.ButtonType.system)
        goToBackB = UIButton(type: UIButton.ButtonType.system)

        goToNextB.frame = CGRect(x: screenWidth * 84/100, y: 100, width: 60, height: 40)
        goToBackB.frame = CGRect(x: 5 ,y:100, width: 60, height: 40)
        goToNextB.setTitle("次へ", for: .normal)
        goToBackB.setTitle("前へ", for: .normal)
        goToNextB.addTarget(self, action: #selector(btnRightArrowAction(_:)), for: .touchUpInside)
        goToBackB.addTarget(self, action: #selector(btnLeftArrowAction(_:)), for: .touchUpInside)

        goToNextB.borderColor = .white
        goToBackB.borderColor = .white
        goToBackB.borderWidth = 1
        goToNextB.borderWidth = 1
        view.addSubview(goToNextB)
        view.addSubview(goToBackB)



    }
    @IBAction func btnLeftArrowAction(_ sender: Any) {
        let collectionBounds = self.collectionView.bounds
        let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x - collectionBounds.size.width))
        self.moveCollectionToFrame(contentOffset: contentOffset)
        
    }
    
    @IBAction func btnRightArrowAction(_ sender: Any) {
        
        let collectionBounds = self.collectionView.bounds
        let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x + collectionBounds.size.width))
        self.moveCollectionToFrame(contentOffset: contentOffset)
        
    }
    
    func moveCollectionToFrame(contentOffset : CGFloat) {
        
//        self.collectionView.contentOffset.y = 0

        let frame: CGRect = CGRect(x : contentOffset ,y : self.collectionView.contentOffset.y ,width : self.collectionView.frame.width,height : self.collectionView.frame.height)
        self.collectionView.scrollRectToVisible(frame, animated: true)
    }
    
    
}

extension AddShiftVC: UICollectionViewDataSource{
    
    
    // Cellの数を設定
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    // Cellに値を設定する
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            let cell : AddShiftCVCell0 = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell0", for: indexPath as IndexPath) as! AddShiftCVCell0
            
            cell.delegate = self
            cell.textLabel?.text = labelTexts[indexPath.row]
            cell.selectedDayL?.text = AddShiftVC.startDayText

            return cell

        case 1:
            let cell : AddShiftCVCell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell1", for: indexPath as IndexPath) as! AddShiftCVCell1
            cell.delegate = self
            cell.textLabel?.text = labelTexts[indexPath.row]

            cell.selectedDayL?.text = AddShiftVC.endDayText
            return cell
        case 2:
            let cell : AddShiftCVCell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell2", for: indexPath as IndexPath) as! AddShiftCVCell2
            cell.delegate = self
            cell.textLabel?.text = labelTexts[indexPath.row]

            cell.selectedDayL?.text = AddShiftVC.holidayText

            return cell

        case 3:
            let cell : AddShiftCVCell3 = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell3", for: indexPath as IndexPath) as! AddShiftCVCell3
            cell.delegate = self
            cell.textLabel?.text = labelTexts[indexPath.row]

            cell.selectedDayL?.text = AddShiftVC.deadlineText

            return cell

        case 4:
            let cell : AddShiftCVCell4 = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell4", for: indexPath as IndexPath) as! AddShiftCVCell4
            cell.delegate = self
            cell.alertDelegate = self
            cell.dismissDelegate = self
            cell.confirmStartDayL?.text = AddShiftVC.startDayText
            cell.confirmEndDayL?.text = AddShiftVC.endDayText
            cell.confirmHolidayL?.text = AddShiftVC.holidayText
            cell.confirmDeadlineL?.text = AddShiftVC.deadlineText

            return cell

        default:
            let cell : AddShiftCVCell0 = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell0", for: indexPath as IndexPath) as! AddShiftCVCell0
            cell.delegate = self
            return cell
        }
//        return collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell0", for: indexPath as IndexPath) as! AddShiftCVCell0
    }
    
}

extension AddShiftVC:CollectionViewReloadDataDelegate{
    func reloadData() {
        collectionView.reloadData()
    }
}
extension AddShiftVC:failedAlertPresentDelegate{
    func present(view: UIViewController, animated: Bool){
        present(view, animated: animated, completion: nil)
    }

    
}

extension AddShiftVC:dismissDelegate{
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else {
            return
        }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
//    func dismiss(){
//        dismiss(animated: true) {
//            self.shiftReloadDelegate.reloadShift()
//        }
//    }
}
//protocol shiftReloadDelegate:AnyObject {
//    func reloadShift()
//}

protocol CollectionViewReloadDataDelegate:AnyObject {
    func reloadData()
    func makeDaySForFirestoreFromIntArray(day:[Int]) -> String
}
