//
//  CommunityAlertViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/21.
//

import PanModal
import UIKit
import SnapKit

class CommunityAlertViewController: UIViewController {
  // MARK: - Properties
  let communityAlertType: CommunityAlertType
  
  let deleteCommentButton = CommunityUtilities.getBasicButton(title: "댓글 삭제", imageName: "trash")
  let reportButton = CommunityUtilities.getReportButton()
  let shareButton = CommunityUtilities.getBasicButton(title: "공유하기", imageName: "share")
  let deletePostButton = CommunityUtilities.getBasicButton(title: "게시글 삭제", imageName: "trash")
  let modifyPostButton = CommunityUtilities.getBasicButton(title: "게시글 수정", imageName: "write")
  let dorm1Button = CommunityUtilities.getDormNumberButton(title: "인천대 1기숙사")
  let dorm2Button = CommunityUtilities.getDormNumberButton(title: "인천대 2기숙사")
  let dorm3Button = CommunityUtilities.getDormNumberButton(title: "인천대 3기숙사")

  lazy var xmarkButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "Xmark_Black"), for: .normal)
    button.addTarget(self, action: #selector(didTapXmarkButton), for: .touchUpInside)
    
    return button
  }()
  
  // MARK: - LifeCycle
  init(communityAlertType: CommunityAlertType) {
    self.communityAlertType = communityAlertType
    super.init(nibName: nil, bundle: nil)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    reportButton.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
    deletePostButton.addTarget(self, action: #selector(didTapDeletePostButton), for: .touchUpInside)
  }
  
  // MARK: - Selectors
  @objc private func didTapTrashButton() {
    
  }
  
  @objc private func didTapXmarkButton() {
    dismiss(animated: true)
  }
  
  @objc private func didTapReportButton() {
    let communityPopupVC = CommunityPopupViewController(contents: "게시글을 신고하고 싶으신가요?")
    communityPopupVC.modalPresentationStyle = .overFullScreen
    present(communityPopupVC, animated: false)
  }
  
  @objc private func didTapDeletePostButton() {
    let communityPopupVC = CommunityPopupViewController(contents: "게시글을 삭제하고 싶으신가요?")
    communityPopupVC.modalPresentationStyle = .overFullScreen
    present(communityPopupVC, animated: false)
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    
    [ xmarkButton, deleteCommentButton, reportButton, shareButton, deletePostButton, modifyPostButton, dorm1Button, dorm2Button, dorm3Button ]
      .forEach { view.addSubview($0) }
    
    [ xmarkButton, deleteCommentButton, reportButton, shareButton, deletePostButton, modifyPostButton, dorm1Button, dorm2Button, dorm3Button ]
      .forEach { $0.isHidden = true }

    xmarkButton.isHidden = false
    
    xmarkButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(10)
      make.trailing.equalToSuperview().inset(18)
    }
    
    switch communityAlertType {
    case .myComment:
      deleteCommentButton.isHidden = false
      deleteCommentButton.snp.makeConstraints { make in
        make.top.equalTo(xmarkButton.snp.bottom).offset(8)
        make.leading.trailing.equalToSuperview().inset(24)
      }
      
      reportButton.isHidden = false
      reportButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(deleteCommentButton.snp.bottom)
      }
    case .someoneComment:
      reportButton.isHidden = false
      reportButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(xmarkButton.snp.bottom).offset(8)
      }
    case .myPost:
      shareButton.isHidden = false
      shareButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(xmarkButton.snp.bottom).offset(8)
      }
      
      deletePostButton.isHidden = false
      deletePostButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(shareButton.snp.bottom)
      }
      
      modifyPostButton.isHidden = false
      modifyPostButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(deletePostButton.snp.bottom)
      }
      
      reportButton.isHidden = false
      reportButton.snp.makeConstraints { make in
        make.top.equalTo(modifyPostButton.snp.bottom)
        make.leading.trailing.equalToSuperview().inset(24)
      }
    case .someonePost:
      shareButton.isHidden = false
      shareButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(xmarkButton.snp.bottom).offset(8)
      }
      
      reportButton.isHidden = false
      reportButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(shareButton.snp.bottom)
      }
    case .selectDorm:
      dorm1Button.isHidden = false
      dorm1Button.snp.makeConstraints { make in
        make.top.equalTo(xmarkButton.snp.bottom).offset(8)
        make.leading.trailing.equalToSuperview().inset(24)
      }
      
      dorm2Button.isHidden = false
      dorm2Button.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(dorm1Button.snp.bottom)
      }
      
      dorm3Button.isHidden = false
      dorm3Button.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(dorm2Button.snp.bottom)
      }
    }
  }
}

extension CommunityAlertViewController: PanModalPresentable {
  var panScrollable: UIScrollView? {
    return nil
  }
  
  var cornerRadius: CGFloat {
    return 24.0
  }
  
  var shortFormHeight: PanModalHeight {
    let height = communityAlertType.rawValue
    return .contentHeight(CGFloat(height))
  }
  
  var longFormHeight: PanModalHeight {
    let height = communityAlertType.rawValue
    return .contentHeight(CGFloat(height))
  }
}
