import UIKit

import PanModal
import SnapKit
import Then

final class MyPageBottomAlertViewController: BaseViewController {
  
  // MARK: - Properties
  
  let myPageBottomAlertVCType: MyPageBottomAlertVCType
  
  // MARK: - LifeCycle
  
  init(_ myPageBottomAlertVCType: MyPageBottomAlertVCType) {
    self.myPageBottomAlertVCType = myPageBottomAlertVCType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
}

// MARK: - PanModal Setup

extension MyPageBottomAlertViewController: PanModalPresentable {
  var panScrollable: UIScrollView? { return nil }
  
  var shortFormHeight: PanModalHeight {
    return PanModalHeight.contentHeight(CGFloat(myPageBottomAlertVCType.height))
  }
  
  var longFormHeight: PanModalHeight {
    return PanModalHeight.contentHeight(CGFloat(myPageBottomAlertVCType.height))
  }
}
