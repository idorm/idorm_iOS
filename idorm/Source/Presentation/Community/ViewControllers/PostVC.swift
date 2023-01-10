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
  
  private lazy var pictsCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.showsHorizontalScrollIndicator = false
    cv.register(PostCell.self, forCellWithReuseIdentifier: PostCell.identifier)
    cv.dataSource = self
    cv.delegate = self
    
    return cv
  }()
  
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
  
  private let separatorLine: UIView = {
    let view = UIView()
    view.backgroundColor = .idorm_gray_200
    
    return view
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    navigationItem.title = "글쓰기"
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: completeBtn)
  }
  
  override func setupLayouts() {
    [
      titleTf,
      separatorLine,
      pictsCollectionView
    ].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    titleTf.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalToSuperview().inset(30)
    }
    
    separatorLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(0.3)
      make.top.equalTo(titleTf.snp.bottom).offset(12)
    }
    
    pictsCollectionView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(separatorLine.snp.bottom).offset(22)
      make.height.equalTo(85)
    }
  }
  
  // MARK: - Bind
}

// MARK: - CollectionView Setup

extension PostViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return 5
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: PostCell.identifier,
      for: indexPath
    ) as? PostCell else {
      return UICollectionViewCell()
    }
    
    return cell
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    return .init(top: 0, left: 24, bottom: 0, right: 24)
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    return .init(width: 83, height: 83)
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct PostVC_PreView: PreviewProvider {
  static var previews: some View {
    PostViewController().toPreview()
  }
}
#endif