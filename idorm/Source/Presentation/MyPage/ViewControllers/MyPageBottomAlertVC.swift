import UIKit

import RxSwift
import RxCocoa
import PanModal
import SnapKit
import Then

final class MyPageBottomAlertViewController: BaseViewController {
  
  // MARK: - Properties
  
  private var deleteButton: UIButton!
  private var reportButton: UIButton!
  private var xMarkButton: UIButton!
  
  private let myPageBottomAlertVCType: MyPageBottomAlertVCType
  private let viewModel = MyPageBottomAlertViewModel()
  
  // MARK: - LifeCycle
  
  init(_ myPageBottomAlertVCType: MyPageBottomAlertVCType) {
    self.myPageBottomAlertVCType = myPageBottomAlertVCType
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
    switch myPageBottomAlertVCType {
    case .dislike:
      deleteButton = BottomAlertUtilities.getBasicButton(title: "싫어요한 룸메에서 삭제", imageName: "trash")
    case .like:
      deleteButton = BottomAlertUtilities.getBasicButton(title: "좋아요한 룸메에서 삭제", imageName: "trash")
    }
    self.deleteButton = deleteButton
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
    
    [xMarkButton, deleteButton, reportButton]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    xMarkButton.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview().inset(16)
    }
    
    deleteButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(xMarkButton.snp.bottom).offset(4)
    }
    
    reportButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(deleteButton.snp.bottom).offset(4)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 취소 버튼 클릭 이벤트
    xMarkButton.rx.tap
      .bind(to: viewModel.input.xmarkButtonTapped)
      .disposed(by: disposeBag)
    
    // 삭제 버튼 클릭 이벤트
    deleteButton.rx.tap
      .bind(to: viewModel.input.deleteButtonTapped)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // 화면 종료
    viewModel.output.dismissVC
      .bind(onNext: { [weak self] in
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
  }
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

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct MyPageBottomAlertVC_PreView: PreviewProvider {
  static var previews: some View {
    MyPageBottomAlertViewController(.dislike).toPreview()
  }
}
#endif
