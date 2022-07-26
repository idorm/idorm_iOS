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
  let myInfo = MyInfo(dormNumber: .no1, period: .period_16, gender: .female, age: "21", snoring: true, grinding: false, smoke: true, allowedFood: false, earphone: true, wakeupTime: "8시", cleanUpStatus: "33", showerTime: "33", mbti: "ISFJ", wishText: "하고싶은 말입니다.", chatLink: nil)
  
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
