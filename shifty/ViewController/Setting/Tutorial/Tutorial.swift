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

class TutorialVC:UIViewController, dismissDelegate{
    var collectionView: UICollectionView!
    var layout: UICollectionViewFlowLayout!
    var goToNextB:UIButton!
//    var goToBackB:UIButton!
    let screenWidth = Int(UIScreen.main.bounds.size.width)
    let screenHeight = Int(UIScreen.main.bounds.size.height)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.backgroundColor = UIColor.rgb(red: 238, green: 224, blue: 190).cgColor
        
        let viewWidth = view.frame.size.width
        let viewHeight = view.frame.size.height

        let collectionViewFrame = CGRect (x: 0, y:-50, width: viewWidth, height: viewHeight )
        
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
        collectionView.backgroundColor = UIColor.white

        // Cellに使われるクラスを登録
        collectionView.register(TutorialCell0.self, forCellWithReuseIdentifier: "CustomCell0")
        collectionView.register(TutorialCell1.self, forCellWithReuseIdentifier: "CustomCell1")
        collectionView.register(TutorialCell2.self, forCellWithReuseIdentifier: "CustomCell2")
        collectionView.register(TutorialCell3.self, forCellWithReuseIdentifier: "CustomCell3")
        collectionView.register(TutorialCell4.self, forCellWithReuseIdentifier: "CustomCell4")

        
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
    
//    override func viewDidAppear(_ animated: Bool) {
//        // ViewDidLoadではSafeAreaが取得できないのでここでリサイズ
//        let safeArea = self.view.safeAreaInsets
//        let viewWidth = self.view.frame.width
//        let viewHeight = self.view.frame.height
//        let collectionViewFrame = CGRect (x: safeArea.left, y: safeArea.top + CGFloat(offSet), width: viewWidth - safeArea.left, height: viewHeight - safeArea.top - safeArea.bottom - CGFloat(offSet))
//
//        layout.itemSize = CGSize(width: viewWidth - safeArea.left, height: viewHeight - safeArea.top - safeArea.bottom)
//
//        collectionView.frame = collectionViewFrame
//
//        loadView()
//        viewDidLoad()
//    }
    
    
    private func setUpButton(){
        goToNextB = UIButton(type: UIButton.ButtonType.system)
//        goToBackB = UIButton(type: UIButton.ButtonType.system)

        goToNextB.frame = CGRect(x: screenWidth * 84/100, y: -30, width: 100, height: 30)
//        goToBackB.frame = CGRect(x: 5 ,y:100, width: 60, height: 40)
        goToNextB.setTitle("次へ", for: .normal)
//        goToBackB.setTitle("前へ", for: .normal)
        goToNextB.addTarget(self, action: #selector(btnRightArrowAction(_:)), for: .touchUpInside)
//        goToBackB.addTarget(self, action: #selector(btnLeftArrowAction(_:)), for: .touchUpInside)

        goToNextB.borderColor = .white
//        goToBackB.borderColor = .white
//        goToBackB.borderWidth = 1
        goToNextB.borderWidth = 1
        view.addSubview(goToNextB)
//        view.addSubview(goToBackB)



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

extension TutorialVC: UICollectionViewDataSource{
    
    
    // Cellの数を設定
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    // Cellに値を設定する
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            let cell : TutorialCell0 = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell0", for: indexPath as IndexPath) as! TutorialCell0
            
         
            return cell

        case 1:
            let cell : TutorialCell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell1", for: indexPath as IndexPath) as! TutorialCell1
            
            return cell
        case 2:
            let cell : TutorialCell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell2", for: indexPath as IndexPath) as! TutorialCell2
            
            return cell

        case 3:
            let cell : TutorialCell3 = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell3", for: indexPath as IndexPath) as! TutorialCell3
            return cell
        case 4:
            let cell : TutorialCell4 = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell4", for: indexPath as IndexPath) as! TutorialCell4
            cell.dismissDelegate = self
            return cell

       

        default:
            let cell : AddShiftCVCell0 = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell0", for: indexPath as IndexPath) as! AddShiftCVCell0
            cell.delegate = self
            return cell
        }
//        return collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell0", for: indexPath as IndexPath) as! AddShiftCVCell0
    }
    
}

extension TutorialVC:CollectionViewReloadDataDelegate{
    func reloadData() {
        collectionView.reloadData()
    }
}
extension TutorialVC:failedAlertPresentDelegate{
    func present(view: UIViewController, animated: Bool){
        present(view, animated: animated, completion: nil)
    }

    
}


