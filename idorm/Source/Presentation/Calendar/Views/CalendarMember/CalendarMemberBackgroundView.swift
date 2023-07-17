//
//  CalendarMemberBackgroundView.swift
//  idorm
//
//  Created by 김응철 on 7/15/23.
//

import UIKit

/// `CalendarMemberBackgroundView`에 배경화면 뷰입니다.
final class CalendarMemberBackgroundView: UICollectionReusableView {
   
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = .iDormColor(.iDormGray100)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
