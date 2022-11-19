import UIKit

import RxSwift
import RxCocoa
import PanModal
import SnapKit
import Then

final class MyPageBottomAlertViewController: BaseViewController {
  
  // MARK: - Properties
  
  var deleteButton: UIButton!
  var reportButton: UIButton!
  var chatButton: UIButton!
  private var xMarkButton: UIButton!
  private let indicator = UIActivityIndicatorView()
  
  private let vcType: MyPageVCTypes.MyPageBottomAlertVCType
  
  // MARK: - LifeCycle
  
  init(_ vcType: MyPageVCTypes.MyPageBottomAlertVCType) {
    self.vcType = vcType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    setupButtons()
    super.viewDidLoad()
  }
  
  // MARK: - Setup
  
  private func setupButtons() {
    let deleteButton: UIButton
    switch vcType {
    case .dislike:
      deleteButton = BottomAlertUtilities.getBasicButton(title: "싫어요한 룸메에서 삭제", image: UIImage(named: "trash"))
    case .like:
      deleteButton = BottomAlertUtilities.getBasicButton(title: "좋아요한 룸메에서 삭제", image: UIImage(named: "trash"))
    }
    self.deleteButton = deleteButton
    self.chatButton = BottomAlertUtilities.getBasicButton(title: "룸메이트와 채팅하기", image: UIImage(named: "speechBubble"))
    self.reportButton = BottomAlertUtilities.getReportButton()
    
    let xmarkButton = UIButton()
    xmarkButton.setImage(#imageLiteral(resourceName: "Xmark_Black"), for: .normal)
    self.xMarkButton = xmarkButton
  }
  
  override func setupStyles() {
    view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [xMarkButton, deleteButton, reportButton, chatButton, indicator]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    xMarkButton.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview().inset(16)
    }
    
    chatButton.snp.makeConstraints { make in
      make.top.equalTo(xMarkButton.snp.bottom).offset(4)
      make.leading.trailing.equalToSuperview().inset(22)
    }
    
    deleteButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(22)
      make.top.equalTo(chatButton.snp.bottom).offset(4)
    }
    
    reportButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(22)
      make.top.equalTo(deleteButton.snp.bottom).offset(4)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Bind
}

// MARK: - PanModal Setup

extension MyPageBottomAlertViewController: PanModalPresentable {
  var panScrollable: UIScrollView? { return nil }
  
  var shortFormHeight: PanModalHeight {
    return PanModalHeight.contentHeight(CGFloat(vcType.height))
  }
  
  var longFormHeight: PanModalHeight {
    return PanModalHeight.contentHeight(CGFloat(vcType.height))
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct MyPageBottomAlertVC_PreView: PreviewProvider {
  static var previews: some View {
    MyPageBottomAlertViewController(.dislike).toPreview()
  }
}
#endif
