//
//  MatchingViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/23.
//

import SnapKit
import UIKit

class MatchingViewController: UIViewController {
  // MARK: - Properties
  let myInfo = MyInfo(dormNumber: "3 기숙사", period: "16 주", gender: true, age: "21", snore: true, grinding: false, smoke: true, allowedFood: false, earphone: true, wakeupTime: "8시", cleanUpStatus: "33", showerTime: "33", mbti: "ISFJ", wishText: "하고싶은 말입니다.", chakLink: nil)
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    
    let infoView = MyInfoView()
    infoView.configureUI(myinfo: myInfo)

    view.addSubview(infoView)
    
    infoView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(view.safeAreaLayoutGuide).inset(40)
    }
  }
}
