//
//  MyLikeRoommateCollectionVIewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/30.
//

import SnapKit
import UIKit

class MyLikeRoommateCollectionViewCell: UICollectionViewCell {
  // MARK: - Properties
  let myinfo = MatchingInfo(dormNumber: .no1, period: .period_16, gender: .female, age: "22", snoring: true, grinding: true, smoke: true, allowedFood: true, earphone: true, wakeupTime: "dddfsdf", cleanUpStatus: "sdfsdf", showerTime: "sdfsdf")
  
  lazy var infoView = MatchingCard(myInfo: myinfo)
  
  static let identifier = "MyLikeRoommateCollectionViewCell"
  
  // MARK: - Helpers
  func configureUI() {
    contentView.addSubview(infoView)
    contentView.backgroundColor = .white
    
    infoView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(24)
      make.centerX.equalToSuperview()
    }
  }
}
