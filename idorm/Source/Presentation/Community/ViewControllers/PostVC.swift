//
//  PostVC.swift
//  idorm
//
//  Created by 김응철 on 2023/01/10.
//

import UIKit

import SnapKit
import RSKPlaceholderTextView

final class PostViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let completeBtn: UIButton = {
    let button = UIButton()
    var config = UIButton.Configuration.plain()
    var container = AttributeContainer()
    container.font = .init(name: MyFonts.bold.rawValue, size: 16)
    container.strokeColor = .idorm_gray_300
    config.attributedTitle = AttributedString("완료", attributes: container)
    button.configuration = config
    
    return button
  }()
  
  private let titleTf: UITextField = {
    let tf = UITextField()
    tf.attributedPlaceholder = NSAttributedString(
      string: "제목",
      attributes: [
        .strokeColor: UIColor.idorm_gray_200,
        .font: UIFont.init(name: MyFonts.bold.rawValue, size: 20)!
      ]
    )
    tf.font = .init(name: MyFonts.bold.rawValue, size: 20)
    tf.textColor = .black
    
    return tf
  }()
  
  private let contentsTv: RSKPlaceholderTextView = {
    let tv = RSKPlaceholderTextView()
    tv.attributedPlaceholder = NSAttributedString(
      string: """
              기숙사에 있는 학우들에게 질문하거나
              함께 이야기를 나누어보세요.
              """,
      attributes: [
        .strokeColor: UIColor.idorm_gray_200,
        .font: UIFont(name: MyFonts.medium.rawValue, size: 16)!
      ]
    )
    tv.font = .init(name: MyFonts.medium.rawValue, size: 16)
    tv.textColor = .black
    
    return tv
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    navigationItem.title = "글쓰기"
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: completeBtn)
  }
  
  override func setupLayouts() {
    [
      titleTf
    ].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    titleTf.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalToSuperview().inset(30)
    }
  }
  
  // MARK: - Bind
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct PostVC_PreView: PreviewProvider {
  static var previews: some View {
    PostViewController().toPreview()
  }
}
#endif
