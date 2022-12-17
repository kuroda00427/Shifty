
import Foundation
import UIKit


class HelpAndTutorialVC: UIViewController, UITextFieldDelegate {
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    
    var button: UIButton!
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "ヘルプ"
        button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.backgroundColor = UIColor.white.cgColor
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.systemBlue.cgColor
        
        button.setTitle("チュートリアルを見る", for: .normal)
        button.frame = CGRect(x: screenWidth * 0.2, y: 200, width: screenWidth * 0.6, height: 60)
        button.addTarget(self, action: #selector(onTappedPush), for: .touchUpInside)
        self.view.addSubview(button)
        addLabel(text: "Shiftyをご利用頂きありがとうございます。", view: view, x: 0, y: 300, width: Int(screenWidth), height: 30, soroe: .center, size: 17, font: 0)
        addLabel(text: "ご質問、ご要望がありましたら、以下のメール", view: view, x: 0, y: 340, width: Int(screenWidth), height: 30, soroe: .center, size: 17, font: 0)
        addLabel(text: "アドレスにご連絡お願い致します。", view: view, x: 0, y: 360, width: Int(screenWidth), height: 30, soroe: .center, size: 17, font: 0)
//        addLabel(text: "shifty.management2021@gmail.com", view: view, x: 0, y: 420, width: Int(screenWidth), height: 30, soroe: .center, size: 17, font: 0)
        let emailTF = UITextField()
        emailTF.frame = CGRect(x: 0, y: 420, width: Int(screenWidth), height: 30)
        emailTF.textAlignment = .center
       
        emailTF.text = "shifty.management2021@gmail.com"
        emailTF.delegate = self
        view.addSubview(emailTF)
        setDismissKeyboard()
        
        addLabel(text: "多くの同質問を頂きましたら、ここに掲載致します。", view: view, x: 0, y: 480, width: Int(screenWidth), height: 30, soroe: .center, size: 17, font: 0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func onTappedPush() {
        modalView(storyboard: "Tutorial", ID: "TutorialVC")

//        print(sender)
//        let vc = SecondViewController(titleName: "second")
//        navigationController?.pushViewController(vc, animated: true)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}
