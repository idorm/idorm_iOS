//
//  MyPostViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum MyPostVCType {
  case post
  case comments
  case recommend
  case likeRoommate
}

class MyPostViewController: UIViewController {
  // MARK: - Properties
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewCompositionalLayout(section: createSection())
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.register(MyCommentsCollectionViewCell.self, forCellWithReuseIdentifier: MyCommentsCollectionViewCell.identifier)
    cv.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
    cv.register(MyLikeRoommateCollectionViewCell.self, forCellWithReuseIdentifier: MyLikeRoommateCollectionViewCell.identifier)
    cv.register(MyPostCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MyPostCollectionHeaderView.identifier)
    cv.backgroundColor = .idorm_gray_100
    cv.dataSource = self
    cv.delegate = self
    
    return cv
  }()
  
  let type: MyPostVCType
  
  // MARK: - LifeCycle
  init(myPostVCType: MyPostVCType) {
    self.type = myPostVCType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .idorm_gray_100
    navigationController?.navigationBar.isHidden = false
    navigationController?.navigationBar.layer.masksToBounds = false
    navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
    navigationController?.navigationBar.layer.shadowOpacity = 0.1
    navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
    
    switch type {
    case .post:
      navigationItem.title = "내가 쓴 글"
    case .comments:
      navigationItem.title = "내가 쓴 댓글"
    case .recommend:
      navigationItem.title = "추천한 글"
    case .likeRoommate:
      navigationItem.title = "좋아요한 룸메"
    }
    
    view.addSubview(collectionView)
    
    collectionView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }
}

extension MyPostViewController {
  /// Post, Recommend
  private func createSection() -> NSCollectionLayoutSection {
    switch type {
    case .post, .recommend:
      let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(136))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(136))
      let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
      
      let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(53))
      let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
      
      let section = NSCollectionLayoutSection(group: group)
      section.boundarySupplementaryItems = [header]
      section.interGroupSpacing = 6
      
      return section
    case .comments:
      let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
      let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
      
      let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(53))
      let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
      
      let section = NSCollectionLayoutSection(group: group)
      section.boundarySupplementaryItems = [header]
      section.interGroupSpacing = 2
      
      return section
    case .likeRoommate:
      let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(532))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(532))
      let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
      
      let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(53))
      let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
      
      let section = NSCollectionLayoutSection(group: group)
      section.boundarySupplementaryItems = [header]
      section.interGroupSpacing = 14
      
      return section
    }
  }
}

extension MyPostViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch type {
    case .recommend, .post:
      guard let postCell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else { return UICollectionViewCell() }
      postCell.configureUI()
      return postCell
    case .comments:
      guard let commentsCell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCommentsCollectionViewCell.identifier, for: indexPath) as? MyCommentsCollectionViewCell else { return UICollectionViewCell() }
      commentsCell.configureUI()
      return commentsCell
    case .likeRoommate:
      guard let likeRoommateCell = collectionView.dequeueReusableCell(withReuseIdentifier: MyLikeRoommateCollectionViewCell.identifier, for: indexPath) as? MyLikeRoommateCollectionViewCell else { return UICollectionViewCell() }
      likeRoommateCell.configureUI()
      return likeRoommateCell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MyPostCollectionHeaderView.identifier, for: indexPath) as? MyPostCollectionHeaderView else { return UICollectionReusableView() }
    header.configureUI()
    return header
  }
}
