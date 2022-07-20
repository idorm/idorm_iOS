//
//  CommunityViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/17.
//

import UIKit
import SnapKit

class CommunityViewController: UIViewController {
  // MARK: - Properties
  lazy var floatyButton: UIButton = {
    let btn = UIButton(type: .custom)
    btn.setImage(UIImage(named: "WriteButton"), for: .normal)
    btn.setImage(UIImage(named: "WriteButtonHover"), for: .highlighted)
    btn.addTarget(self, action: #selector(didTapFloatyButton), for: .touchUpInside)
    
    return btn
  }()
  
  lazy var changeDormButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.imagePadding = 16
    config.imagePlacement = .trailing
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    let button = UIButton(configuration: config)
    let attributedString = returnAttributedString(text: "인천대 3기숙사")
    button.setImage(UIImage(named: "bottomArrowButton"), for: .normal)
    button.setAttributedTitle(attributedString, for: .normal)
    button.setTitleColor(UIColor.black, for: .normal)
    
    return button
  }()
  
  lazy var bellButton: UIButton = {
    let btn = UIButton(type: .custom)
    btn.setImage(UIImage(named: "bell"), for: .normal)
    
    return btn
  }()
  
  lazy var collectionView: UICollectionView = {
    let layout = createLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(CommunityPopularCollectionVIewCell.self, forCellWithReuseIdentifier: CommunityPopularCollectionVIewCell.identifieir)
    collectionView.register(CommunityPostCollectionViewCell.self, forCellWithReuseIdentifier: CommunityPostCollectionViewCell.identifier)
    collectionView.backgroundColor = .init(rgb: 0xF4F2FA)
    collectionView.dataSource = self
    collectionView.delegate = self
    
    return collectionView
  }()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = false
  }
  
  // MARK: - Selectors
  @objc private func didTapFloatyButton() {
    let writingVC = PostingViewController()
    navigationController?.pushViewController(writingVC, animated: true)
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: changeDormButton)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bellButton)
    
    [ floatyButton, collectionView ]
      .forEach { view.addSubview($0) }
    
    floatyButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
    }
    
    collectionView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  private func createLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { [weak self] sectionNumber, _ in
      if sectionNumber == 0 {
        return self?.createPopularSection()
      } else {
        return self?.createPostSection()
      }
    }
  }
  
  private func createPopularSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(138), heightDimension: .absolute(132))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(404), heightDimension: .absolute(132))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
    group.interItemSpacing = NSCollectionLayoutSpacing.fixed(8)
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 8
    section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
    section.orthogonalScrollingBehavior = .continuous
    
    return section
  }
  
  private func createPostSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(136))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(136))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 6
    
    return section
  }
  
  private func returnAttributedString(text: String) -> NSAttributedString {
    let attributedString = NSAttributedString(
      string: text,
      attributes: [
        NSAttributedString.Key.font: UIFont.init(name: Font.bold.rawValue, size: 20) ?? 0,
        NSAttributedString.Key.foregroundColor: UIColor.black
      ]
    )
    
    return attributedString
  }
}

extension CommunityViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let popularCell = collectionView.dequeueReusableCell(withReuseIdentifier: CommunityPopularCollectionVIewCell.identifieir, for: indexPath) as? CommunityPopularCollectionVIewCell,
          let postCell = collectionView.dequeueReusableCell(withReuseIdentifier: CommunityPostCollectionViewCell.identifier, for: indexPath) as? CommunityPostCollectionViewCell
    else { return UICollectionViewCell() }
    
    if indexPath.section == PostType.popular.rawValue {
      popularCell.configureUI()
      return popularCell
    } else {
      postCell.configureUI()
      return postCell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return PostType.allCases.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let communityDetailVC = CommunityDetailViewController()
    navigationController?.pushViewController(communityDetailVC, animated: true)
  }
}
