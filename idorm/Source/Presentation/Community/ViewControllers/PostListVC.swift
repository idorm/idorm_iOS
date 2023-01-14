//
//  PostListVC.swift
//  idorm
//
//  Created by 김응철 on 2023/01/11.
//

import UIKit

import SnapKit

final class PostListViewController: BaseViewController {
  
  enum Section: Int, CaseIterable {
    case popular
    case common
  }
  
  // MARK: - Properties
  
  private let floatyBtn: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "ellipse_posting"), for: .normal)
    btn.setImage(UIImage(named: "ellipse_posting_activated"), for: .highlighted)
    
    return btn
  }()
  
  private let dormBtn: UIButton = {
    var container = AttributeContainer()
    container.font = .init(name: MyFonts.bold.rawValue, size: 20)

    var config = UIButton.Configuration.plain()
    config.imagePadding = 16
    config.imagePlacement = .trailing
    config.image = #imageLiteral(resourceName: "downarrow")
    config.attributedTitle = AttributedString("인천대 3기숙사", attributes: container)
    config.baseForegroundColor = .black
    
    let btn = UIButton(configuration: config)
    
    return btn
  }()
  
  private let bellBtn: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "bell"), for: .normal)
    
    return btn
  }()
  
  private lazy var postListCV: UICollectionView = {
    let cv = UICollectionView(frame: .zero, collectionViewLayout: getLayout())
    cv.backgroundColor = .idorm_gray_100
    cv.register(
      PostCell.self,
      forCellWithReuseIdentifier: PostCell.identifier
    )
    cv.register(
      PopularPostCell.self,
      forCellWithReuseIdentifier: PopularPostCell.identifier
    )
    cv.dataSource = self
    cv.delegate = self
    
    return cv
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    view.backgroundColor = .white
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dormBtn)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bellBtn)
  }
  
  override func setupLayouts() {
    [
      postListCV,
      floatyBtn
    ].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    floatyBtn.snp.makeConstraints { make in
      make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
      make.centerX.equalToSuperview()
    }
    
    postListCV.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  // MARK: - Helpers
  
  private func getLayout() -> UICollectionViewCompositionalLayout {
    UICollectionViewCompositionalLayout { section, _ in
      switch section {
      case Section.popular.rawValue:
        return PostUtils.popularPostSection()
      default:
        return PostUtils.postSection()
      }
    }
  }
}

// MARK: - CollectionView Setup

extension PostListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return 10
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return Section.allCases.count
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard
      let postCell = collectionView.dequeueReusableCell(
        withReuseIdentifier: PostCell.identifier,
        for: indexPath
      ) as? PostCell,
      let popularPostCell = collectionView.dequeueReusableCell(
        withReuseIdentifier: PopularPostCell.identifier,
        for: indexPath
      ) as? PopularPostCell else {
      return UICollectionViewCell()
    }
    
    switch indexPath.section {
    case Section.popular.rawValue :
      return popularPostCell
    default:
      return postCell
    }
  }
}
