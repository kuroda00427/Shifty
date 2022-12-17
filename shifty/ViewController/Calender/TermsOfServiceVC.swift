//
//  TermsOfServiceVC.swift
//  shifty
//
//  Created by 黒田拓杜 on 2021/11/05.
//

import Foundation
import UIKit


class TermsOfServiceVC:UIViewController{
    @IBOutlet weak var termsOfServiceTV: UITableView!
    private var text = "この利用規約（以下，「本規約」といいます。）は，このアプリShiftyの運営（以下，「運営」といいます。）がこのアプリ上で提供するサービス（以下，「本サービス」といいます。）の利用条件を定めるものです。登録ユーザーの皆さま（以下，「ユーザー」といいます。）には，本規約に従って，本サービスをご利用いただきます。"
    private let termsOfServicesTitle =
        [
        "(適用)"
        ,"（ユーザーIDおよびパスワードの管理）"
        ,"（利用料金および支払方法）"
        ,"（禁止事項）"
        ,"（本サービスの提供の停止等）"
        ,"（利用制限および登録抹消）"
        ,"（退会）"
        ,"（保証の否認および免責事項）"
        ,"（サービス内容の変更等）"
        ,"（利用規約の変更）"
        ,"（個人情報の取扱い）"
        ,"（準拠法・裁判管轄）"
    
    ]
    private let termsOfServices =
        [
            //1"(適用)"
            "1.本規約は，ユーザーと運営との間の本サービスの利用に関わる一切の関係に適用されるものとします。当社は本サービスに関し，本規約のほか，ご利用にあたってのルール等，各種の定め（以下，「個別規定」といいます。）をすることがあります。\n2.これら個別規定はその名称のいかんに関わらず，本規約の一部を構成するものとします。\n3.本規約の規定が前条の個別規定の規定と矛盾する場合には，個別規定において特段の定めなき限り，個別規定の規定が優先されるものとします。"
            //2（ユーザーIDおよびパスワードの管理）
            ,"1.ユーザーは，自己の責任において，本サービスのユーザーIDおよびパスワードを適切に管理するものとします。\n2.ユーザーは，いかなる場合にも，ユーザーIDおよびパスワードを第三者に譲渡または貸与し，もしくは第三者と共用することはできません。当社は，ユーザーIDとパスワードの組み合わせが登録情報と一致してログインされた場合には，そのユーザーIDを登録しているユーザー自身による利用とみなします。\n3.ユーザーID及びパスワードが第三者によって使用されたことによって生じた損害は，当社に故意又は重大な過失がある場合を除き，当社は一切の責任を負わないものとします。"
            //3（利用料金および支払方法）
            ,"1.ユーザーは，本サービスの有料部分の対価として，当社が別途定め，本ウェブサイトに表示する利用料金を，当社が指定する方法により支払うものとします。\n2.ユーザーが利用料金の支払を遅滞した場合には，ユーザーは年14．6％の割合による遅延損害金を支払うものとします。"
            //4（禁止事項）
            ,"ユーザーは，本サービスの利用にあたり，以下の行為をしてはなりません。\n法令または公序良俗に違反する行為犯罪行為に関連する行為\n本サービスの内容等，本サービスに含まれる著作権，商標権ほか知的財産権を侵害する行為\n当社，ほかのユーザー，またはその他第三者のサーバーまたはネットワークの機能を破壊したり，妨害したりする行為\n本サービスによって得られた情報を商業的に利用する行為\n当社のサービスの運営を妨害するおそれのある行為\n不正アクセスをし，またはこれを試みる行為\n他のユーザーに関する個人情報等を収集または蓄積する行為\n不正な目的を持って本サービスを利用する行為\n本サービスの他のユーザーまたはその他の第三者に不利益，損害，不快感を与える行為\n他のユーザーに成りすます行為\n当社が許諾しない本サービス上での宣伝，広告，勧誘，または営業行為\n面識のない異性との出会いを目的とした行為\n当社のサービスに関連して，反社会的勢力に対して直接または間接に利益を供与する行為\nその他，当社が不適切と判断する行為"
            //5（本サービスの提供の停止等）
            ,"当社は，以下のいずれかの事由があると判断した場合，ユーザーに事前に通知することなく本サービスの全部または一部の提供を停止または中断することができるものとします。\n本サービスにかかるコンピュータシステムの保守点検または更新を行う場合\n地震，落雷，火災，停電または天災などの不可抗力により，本サービスの提供が困難となった場合\nコンピュータまたは通信回線等が事故により停止した場合\nその他，当社が本サービスの提供が困難と判断した場合\n当社は，本サービスの提供の停止または中断により，ユーザーまたは第三者が被ったいかなる不利益または損害についても，一切の責任を負わないものとします。"
            //6（利用制限および登録抹消）
            ,"当社は，ユーザーが以下のいずれかに該当する場合には，事前の通知なく，ユーザーに対して，本サービスの全部もしくは一部の利用を制限し，またはユーザーとしての登録を抹消することができるものとします。\n本規約のいずれかの条項に違反した場合\n登録事項に虚偽の事実があることが判明した場合\n料金等の支払債務の不履行があった場合\n当社からの連絡に対し，一定期間返答がない場合\n本サービスについて，最終の利用から一定期間利用がない場合\nその他，当社が本サービスの利用を適当でないと判断した場合\n当社は，本条に基づき当社が行った行為によりユーザーに生じた損害について，一切の責任を負いません。"
            //7（退会）
            ,"ユーザーは，当社の定める退会手続により，本サービスから退会できるものとします"
          
            //8（保証の否認および免責事項）
            ,"当社は，本サービスに事実上または法律上の瑕疵（安全性，信頼性，正確性，完全性，有効性，特定の目的への適合性，セキュリティなどに関する欠陥，エラーやバグ，権利侵害などを含みます。）がないことを明示的にも黙示的にも保証しておりません。\n当社は，本サービスに起因してユーザーに生じたあらゆる損害について一切の責任を負いません。ただし，本サービスに関する当社とユーザーとの間の契約（本規約を含みます。）が消費者契約法に定める消費者契約となる場合，この免責規定は適用されません。"
            
            //            前項ただし書に定める場合であっても，当社は，当社の過失（重過失を除きます。）による債務不履行または不法行為によりユーザーに生じた損害のうち特別な事情から生じた損害（当社またはユーザーが損害発生につき予見し，または予見し得た場合を含みます。）について一切の責任を負いません。また，当社の過失（重過失を除きます。）による債務不履行または不法行為によりユーザーに生じた損害の賠償は，ユーザーから当該損害が発生した月に受領した利用料の額を上限とします。
            //            当社は，本サービスに関して，ユーザーと他のユーザーまたは第三者との間において生じた取引，連絡または紛争等について一切責任を負いません。
              
            //9（サービス内容の変更等）
            ,"当社は，ユーザーに通知することなく，本サービスの内容を変更しまたは本サービスの提供を中止することができるものとし，これによってユーザーに生じた損害について一切の責任を負いません。"
            //10（利用規約の変更）
            ,"当社は，必要と判断した場合には，ユーザーに通知することなくいつでも本規約を変更することができるものとします。なお，本規約の変更後，本サービスの利用を開始した場合には，当該ユーザーは変更後の規約に同意したものとみなします。"
            //11（個人情報の取扱い）
            ,"当社は，本サービスの利用によって取得する個人情報については，当社「プライバシーポリシー」に従い適切に取り扱うものとしま"
            //12（準拠法・裁判管轄）
            ,"本規約の解釈にあたっては，日本法を準拠法とします。\n本サービスに関して紛争が生じた場合には，当社の本店所在地を管轄する裁判所を専属的合意管轄とします。"
        ]
    
    @IBAction func startB(_ sender: Any) {
        dismiss(animated: true) {
        }
    }
    
    @IBOutlet weak var startB: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setText()
        termsOfServiceTV.delegate = self
        termsOfServiceTV.dataSource = self
        termsOfServiceTV.separatorStyle = .none
        
    }
    private func setText(){
        let changeRow = "\n"

        let change2Row = "\n\n\n"
        text += change2Row
        let len = termsOfServicesTitle.count
        for i in 0...len-1{
            text += "第" + String(i+1)  + "条"
            text += termsOfServicesTitle[i]
            text += changeRow
            text += termsOfServices[i]
            text += change2Row
        }
    }
    private func setUpView(){
        startB.borderWidth = 4
        startB.borderColor = .green
        startB.cornerRadius = 10
        termsOfServiceTV.isScrollEnabled = true
    }
}
extension TermsOfServiceVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        2000
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = termsOfServiceTV.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! cell
        cell.textView.font = UIFont(name: "System", size: 14)
        cell.textView.text = text
        return cell
    }
    
    
    
}

class cell:UITableViewCell{
    
    
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
