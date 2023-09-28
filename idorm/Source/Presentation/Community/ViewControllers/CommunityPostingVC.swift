//
//  CommunityPostingViewController.swift
//  idorm
//
//  Created by 김응철 on 2023/01/10.
//

import UIKit

import SnapKit
import RSKPlaceholderTextView
import ReactorKit
import RxSwift
import RxCocoa
import PhotosUI
import RxGesture

final class CommunityPostingViewController: BaseViewController, View {
  
  typealias DataSource = UICollectionViewDiffableDataSource<CommunityPostingSection, CommunityPostingSectionItem>
  typealias Reactor = CommunityPostingViewReactor
  
  // MARK: - UI Components
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.getLayout()
    )
    // Cell
    collectionView.register(
      CommunityPostingTitleCell.self,
      forCellWithReuseIdentifier: CommunityPostingTitleCell.identifier
    )
    collectionView.register(
      CommunityPostingImageCell.self,
      forCellWithReuseIdentifier: CommunityPostingImageCell.identifier
    )
    collectionView.register(
      CommunityPostingContentCell.self,
      forCellWithReuseIdentifier: CommunityPostingContentCell.identifier
    )
    return collectionView
  }()
  
  private let confirmButton: iDormButton = {
    let button = iDormButton("완료")
    button.font = .iDormFont(.bold, size: 16.0)
    button.baseBackgroundColor = .white
    button.contentInset = .zero
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      guard let button = button as? iDormButton else { return }
      button.configuration?.background.backgroundColor = .white
      switch button.state {
      case .disabled: button.baseForegroundColor = .iDormColor(.iDormGray200)
      default: button.baseForegroundColor = .iDormColor(.iDormBlue)
      }
    }
    button.configurationUpdateHandler = handler
    return button
  }()

  private let bottomContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.shadowOpacity = 0.1
    view.layer.shadowRadius = 7.5
    view.layer.shadowOffset = CGSize(width: .zero, height: 3.0)
    return view
  }()
  
  private let imagesCountButton: iDormButton = {
    let button = iDormButton("0/10")
    button.image = .iDormIcon(.photo)?.resize(newSize: 18.0)
    button.imagePadding = 10.0
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .black
    button.contentInset = .zero
    button.font = .iDormFont(.medium, size: 12.0)
    return button
  }()
  
  private let anonymousButton: iDormButton = {
    let button = iDormButton("익명")
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .black
    button.font = .iDormFont(.medium, size: 12.0)
    button.imagePadding = 8.0
    button.imagePlacement = .trailing
    button.contentInset = .zero
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      guard let button = button as? iDormButton else { return }
      switch button.state {
      case .selected: button.image = .iDormIcon(.select)
      default: button.image = .iDormIcon(.deselect)
      }
    }
    button.isSelected = true
    button.configurationUpdateHandler = handler
    return button
  }()
  
  // MARK: - Properties
  
  private lazy var dataSource: DataSource = {
    let dataSource = DataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case .title:
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CommunityPostingTitleCell.identifier,
            for: indexPath
          ) as? CommunityPostingTitleCell else {
            return UICollectionViewCell()
          }
          cell.textFieldHandler = { self.reactor?.action.onNext(.titleTextFieldDidChange($0)) }
          return cell
        case .content:
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CommunityPostingContentCell.identifier,
            for: indexPath
          ) as? CommunityPostingContentCell else {
            return UICollectionViewCell()
          }
          cell.textViewHandler = { self.reactor?.action.onNext(.contentTextViewDidChange($0)) }
          return cell
        case .image(let image):
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CommunityPostingImageCell.identifier,
            for: indexPath
          ) as? CommunityPostingImageCell else {
            return UICollectionViewCell()
          }
          cell.removeButtonHandler = {
            self.reactor?.action.onNext(.removeButtonDidTap(item))
          }
          cell.configure(with: image)
          return cell
        }
      }
    )
    return dataSource
  }()
  
  var completion: (() -> Void)?
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.navigationItem.title = "글쓰기"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.confirmButton)
  }
  
  override func setupLayouts() {
    [
      self.collectionView,
      self.bottomContainerView
    ].forEach {
      self.view.addSubview($0)
    }
    [
      self.imagesCountButton,
      self.anonymousButton
    ].forEach {
      self.bottomContainerView.addSubview($0)
    }
    super.setupLayouts()
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.collectionView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.bottomContainerView.snp.top)
    }
    
    self.bottomContainerView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
      make.height.equalTo(44.0)
    }
    
    self.imagesCountButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(24.0)
    }
    
    self.anonymousButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(24.0)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: CommunityPostingViewReactor) {
    
    // Action
    
    self.rx.viewDidLoad
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.anonymousButton.rx.tap
      .map { Reactor.Action.anonymousButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.imagesCountButton.rx.tap
      .map { Reactor.Action.imagesCountButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.collectionView.rx.tapGesture()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: self.disposeBag)
    
    // State
    
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<CommunityPostingSection, CommunityPostingSectionItem>()
        snapshot.appendSections(sectionData.sections)
        sectionData.items.enumerated().forEach { index, items in
          snapshot.appendItems(items, toSection: sectionData.sections[index])
        }
        DispatchQueue.main.async {
          owner.dataSource.apply(snapshot)
        }
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$presentToImagePickerVC).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, selectionLimit in
        let viewController = iDormPHPickerViewController(
          .multiSelection(selectionLimit: selectionLimit)
        )
        viewController.modalPresentationStyle = .overFullScreen
        viewController.imagesHandler = { owner.reactor?.action.onNext(.imagesDidPick($0)) }
        owner.present(viewController, animated: false)
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isAnonymous }
      .distinctUntilChanged()
      .bind(to: self.anonymousButton.rx.isSelected)
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isEnabledConfirmButton }
      .distinctUntilChanged()
      .bind(to: self.confirmButton.rx.isEnabled)
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.post }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, post in
        owner.imagesCountButton.title = "\(post.imagesData.count)/10"
      }
      .disposed(by: self.disposeBag)
  }
  
  private func checkAuthorization() {
//    let galleryVC = GalleryViewController(count: reactor?.currentState.currentImages.count ?? 0)
//    
//    galleryVC.completion = { [weak self] assets in
//      // 선택된 이미지 반응
//      let manager = PHImageManager.default()
//      var images: [UIImage] = []
//      assets.forEach {
//        images.append($0.getImageFromPHAsset())
//      }
//      self?.reactor?.action.onNext(.didPickedImages(images))
//    }
//    
//    switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
//    case .authorized, .limited:
//      DispatchQueue.main.async {
//        self.navigationController?.pushViewController(galleryVC, animated: true)
//      }
//      
//    case .notDetermined:
//      PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
//        switch status {
//        case .authorized, .limited:
//          DispatchQueue.main.async {
//            self.navigationController?.pushViewController(galleryVC, animated: true)
//          }
//        default:
//          break
//        }
//      }
//      
//    default:
//      presentAuthenticationAlert()
//    }
  }
  
  private func presentAuthenticationAlert() {
    let alert = UIAlertController(title: "알림", message: "모든 사진의 권한을 허용해주세요.", preferredStyle: .alert)
    
    let settingAction = UIAlertAction(title: "설정", style: .default) { _ in
      UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel)
    
    alert.addAction(settingAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: false)
  }
}

// MARK: - Privates

private extension CommunityPostingViewController {
  func getLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { [weak self] index, _ in
      guard let section = self?.dataSource.sectionIdentifier(for: index) else {
        fatalError("❌ CommunityPostingSection을 찾을 수 없습니다!")
      }
      return section.section
    }
  }
}
