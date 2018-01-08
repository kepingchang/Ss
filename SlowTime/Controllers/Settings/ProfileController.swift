//
//  ProfileController.swift
//  SlowTime
//
//  Created by KKING on 2018/1/2.
//  Copyright © 2018年 KKING. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import PKHUD

class ProfileController: BaseViewController {
    
    
    @IBOutlet weak var nickName: UITextField! {
        didSet {
            nickName.text = UserDefaults.standard.string(forKey: "nickname_key")
        }
    }

    @IBOutlet weak var profileTextView: UITextView! {
        didSet {
            profileTextView.layer.borderColor = UIColor.black.cgColor
            profileTextView.layer.borderWidth = 1
            profileTextView.layer.masksToBounds = true
            profileTextView.text = UserDefaults.standard.string(forKey: "profile_key")
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.title = "修改资料"
        navBar.wr_setRightButton(title: "修改", titleColor: .black)
        navBar.onClickRightButton = { [weak self] in
            self?.changeProfileRequest()
        }
        
        
        view.rx.sentMessage(#selector(touchesBegan(_:with:)))
            .bind { [unowned self] (_) in
                _ = self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    
    }
    
    private func changeProfileRequest() {
        let provider = MoyaProvider<Request>()
        provider.rx.request(.profile(nickName: nickName.text!, profile: profileTextView.text!))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode({ (_, mess) in
                HUD.flash(.label(mess), delay: 1.0)
            })
            .filterObject(to: User.self)
            .subscribe { [weak self] (event) in
                if case .next(let user) = event {
                    
                    UserDefaults.standard.set(user.accessToken!, forKey: "accessToken_key")
                    UserDefaults.standard.set(user.userHash!, forKey: "userHash_key")
                    UserDefaults.standard.set(user.nickname!, forKey: "nickname_key")
                    UserDefaults.standard.set(user.profile!, forKey: "profile_key")
                    self?.popAction()
                    
                }else if case .error = event {
                    HUD.flash(.label("请求失败！"), delay: 1.0)
                }
            }
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
