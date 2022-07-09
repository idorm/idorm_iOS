//
//  HomeViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/08.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {
    // MARK: - Properties
    let viewModel = HomeListViewModel()
    
    lazy var selectDormButton: UIButton = {
        let button = UIButton(type: .custom)
        button.showsMenuAsPrimaryAction = true
        button.setTitle("인천대 3기숙사", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24.0, weight: .bold)
        button.contentHorizontalAlignment = .center
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
        button.tintColor = .black
        button.menu = UIMenu(title: "기숙사 선택", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [ dorm1Action, dorm2Action, dorm3Action ])
        
        return button
    }()
    
    lazy var dorm1Action: UIAction = {
        let dorm1 = UIAction(title: "인천대 1기숙사") { [weak self] action in
            guard let self = self else { return }
            self.dorm3Action.state = .off
            self.dorm2Action.state = .off
            self.dorm1Action.state = .on
            self.selectDormButton.setTitle("인천대 1기숙사", for: .normal)
        }
        
        return dorm1
    }()
    
    lazy var dorm2Action: UIAction = {
        let dorm2 = UIAction(title: "인천대 2기숙사") { [weak self] action in
            guard let self = self else { return }
            self.dorm1Action.state = .off
            self.dorm3Action.state = .off
            self.dorm2Action.state = .on
            self.selectDormButton.setTitle("인천대 2기숙사", for: .normal)
        }
        
        return dorm2
    }()
    
    lazy var dorm3Action: UIAction = {
        let dorm3 = UIAction(title: "인천대 3기숙사") { [weak self] action in
            guard let self = self else { return }
            self.dorm1Action.state = .off
            self.dorm2Action.state = .off
            self.dorm3Action.state = .on
            self.selectDormButton.setTitle("인천대 3기숙사", for: .normal)
        }
        
        return dorm3
    }()
    
    lazy var bellButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.tintColor = .black
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 24.0), forImageIn: .normal)
        
        return button
    }()
    
    lazy var collectionView: UICollectionView = {
        var config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16.0
        let layout = createLayout()
        layout.configuration = config
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(HomeRoommateCollectionViewCell.self, forCellWithReuseIdentifier: HomeRoommateCollectionViewCell.identifier)
        collectionView.register(HomePopularCollectionViewCell.self, forCellWithReuseIdentifier: HomePopularCollectionViewCell.identifier)
        collectionView.register(HomeCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeCollectionHeaderView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        
        [ selectDormButton, bellButton, collectionView ]
            .forEach { view.addSubview($0) }
        
        selectDormButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.leading.equalToSuperview().inset(24)
        }
        
        bellButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.trailing.equalToSuperview().inset(24)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(selectDormButton.snp.bottom).offset(16)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func createSection(section: Int) -> NSCollectionLayoutSection {
        if section == 0 {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .absolute((UIScreen.main.bounds.width - 60) / 2))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.42))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)
            group.interItemSpacing = NSCollectionLayoutSpacing.fixed(12.0)
            
            let section = NSCollectionLayoutSection(group: group)
            let header = createHeaderLayout()
            section.boundarySupplementaryItems = [ header ]
            
            return section
        } else {
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(134.0), heightDimension: .absolute(134.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(280.0), heightDimension: .absolute(134.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            group.interItemSpacing = NSCollectionLayoutSpacing.fixed(8.0)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)
            section.interGroupSpacing = 8.0
            section.orthogonalScrollingBehavior = .continuous
            let header = createHeaderLayout()
            section.boundarySupplementaryItems = [ header ]
            section.supplementariesFollowContentInsets = false
            
            return section
        }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionNumber, _ -> NSCollectionLayoutSection? in
            switch sectionNumber {
            case 0: return self?.createSection(section: 0)
            default: return self?.createSection(section: 1)
            }
        }
    }
    
    private func createHeaderLayout() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50.0))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        
        return header
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let roommateCell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeRoommateCollectionViewCell.identifier, for: indexPath) as? HomeRoommateCollectionViewCell,
            let popularCell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePopularCollectionViewCell.identifier, for: indexPath) as? HomePopularCollectionViewCell
        else { return UICollectionViewCell() }

        if indexPath.section == 0 {
            roommateCell.configureUI()
            roommateCell.backgroundColor = .blue
            return roommateCell
        } else {
            popularCell.configureUI()
            popularCell.backgroundColor = .blue
            return popularCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeCollectionHeaderView.identifier, for: indexPath) as? HomeCollectionHeaderView else { return UICollectionReusableView() }
        
        if indexPath.section == 0 {
            let title = HomeSection.roommate.rawValue
            header.configureUI(title: title)
            return header
        } else {
            let title = HomeSection.popular.rawValue
            header.configureUI(title: title)
            return header
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.numberOfItemsInSection(section: 0)
        } else {
            return viewModel.numberOfItemsInSection(section: 1)
        }
    }
}
