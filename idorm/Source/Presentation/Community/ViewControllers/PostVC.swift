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
    cv.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
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
  
  private let bottomContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.shadowOpacity = 1
    view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
    view.layer.shadowRadius = 15
    view.layer.shadowOffset = .init(width: 0, height: 3)
    
    return view
  }()
  
  private let currentPictsCountLb: UILabel = {
    let lb = UILabel()
    lb.text = "0"
    lb.font = .init(name: MyFonts.medium.rawValue, size: 12)
    lb.textColor = .black
    
    return lb
  }()
  
  private let pictsCountLb: UILabel = {
    let lb = UILabel()
    lb.text = "/10"
    lb.textColor = .black
    lb.font = .init(name: MyFonts.medium.rawValue, size: 12)
    
    return lb
  }()
  
  private let anonymousLabel: UILabel = {
    let lb = UILabel()
    lb.text = "익명"
    lb.font = .init(name: MyFonts.medium.rawValue, size: 12)
    
    return lb
  }()
  
  private let anonymousBtn: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "circle_blue"), for: .selected)
    btn.setImage(UIImage(named: "circle"), for: .normal)
    btn.isSelected = true
    
    return btn
  }()
  
  private let pictIv = UIImageView(image: UIImage(named: "picture"))
  
  // MARK: - Setup
  
  override func setupStyles() {
    navigationItem.title = "글쓰기"
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: completeBtn)
    view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    [
      titleTf,
      separatorLine,
      pictsCollectionView,
      contentsTv,
      bottomContainerView
    ].forEach {
      view.addSubview($0)
    }
    
    [
      pictIv,
      currentPictsCountLb,
      pictsCountLb,
      anonymousLabel,
      anonymousBtn
    ].forEach {
      bottomContainerView.addSubview($0)
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
    
    contentsTv.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(pictsCollectionView.snp.bottom).offset(16)
      make.bottom.equalToSuperview()
    }
    
    bottomContainerView.snp.makeConstraints { make in
      make.bottom.leading.trailing.equalToSuperview()
      make.height.equalTo(76)
    }
    
    pictIv.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalToSuperview().inset(12)
    }

    currentPictsCountLb.snp.makeConstraints { make in
      make.leading.equalTo(pictIv.snp.trailing).offset(10)
      make.centerY.equalTo(pictIv)
    }
    
    pictsCountLb.snp.makeConstraints { make in
      make.leading.equalTo(currentPictsCountLb.snp.trailing)
      make.centerY.equalTo(pictIv)
    }
    
    anonymousLabel.snp.makeConstraints { make in
      make.centerY.equalTo(anonymousBtn)
      make.trailing.equalTo(anonymousBtn.snp.leading).offset(-6)
    }
    
    anonymousBtn.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.top.equalToSuperview().inset(12)
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
      withReuseIdentifier: ImageCell.identifier,
      for: indexPath
    ) as? ImageCell else {
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
