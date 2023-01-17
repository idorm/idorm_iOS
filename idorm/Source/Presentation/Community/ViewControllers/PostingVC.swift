//
//  PostVC.swift
//  idorm
//
//  Created by 김응철 on 2023/01/10.
//

import UIKit

import SnapKit
import RSKPlaceholderTextView
import ReactorKit
import Photos

final class PostingViewController: BaseViewController, View {
  
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
  
  private let bottomWhiteView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    
    return view
  }()
  
  private let pictIv = UIImageView(image: UIImage(named: "picture_medium"))
  
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
      bottomContainerView,
      bottomWhiteView
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
      make.top.equalTo(view.safeAreaLayoutGuide).inset(30)
    }
    
    separatorLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(0.3)
      make.top.equalTo(titleTf.snp.bottom).offset(12)
    }
    
    pictsCollectionView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(separatorLine.snp.bottom).offset(16)
      make.height.equalTo(85)
    }
    
    contentsTv.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(pictsCollectionView.snp.bottom).offset(16)
      make.bottom.equalTo(bottomContainerView.snp.top).offset(-16)
    }
    
    bottomContainerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
      make.height.equalTo(56)
    }
    
    pictIv.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
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
      make.centerY.equalToSuperview()
      make.trailing.equalTo(anonymousBtn.snp.leading).offset(-6)
    }
    
    anonymousBtn.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
    }
    
    if DeviceManager.shared.hasNotch() {
      bottomWhiteView.snp.makeConstraints { make in
        make.height.equalTo(50)
        make.leading.trailing.bottom.equalToSuperview()
      }
    }
    
    updateConstraints()
  }
  
  // MARK: - Bind
  
  func bind(reactor: PostingViewReactor) {
    
    // MARK: - Action
    
    // 사진 버튼 클릭
    pictIv.rx.tapGesture()
      .skip(1)
      .map { _ in PostingViewReactor.Action.didTapPictIv }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    // 갤러리VC
    reactor.state
      .map { $0.showsGalleryVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { $0.0.checkAuthorization() }
      .disposed(by: disposeBag)
    
    // 현재 사진 목록
    reactor.state
      .map { $0.currentImages }
      .distinctUntilChanged()
      .skip(1)
      .withUnretained(self)
      .observe(on: MainScheduler.asyncInstance)
      .bind {
        $0.0.updateConstraints()
        $0.0.pictsCollectionView.reloadData()
      }
      .disposed(by: disposeBag)
    
    // 현재 사진 갯수
    reactor.state
      .map { $0.currentImages.count }
      .map { String($0) }
      .distinctUntilChanged()
      .bind(to: currentPictsCountLb.rx.text)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
  
  private func checkAuthorization() {
    let galleryVC = GalleryViewController(count: reactor?.currentState.currentImages.count ?? 0)
    
    galleryVC.completion = { [weak self] images in
      // 선택된 이미지 반응
      self?.reactor?.action.onNext(.didPickedImages(images))
    }
    
    switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
    case .authorized, .limited:
      DispatchQueue.main.async {
        self.navigationController?.pushViewController(galleryVC, animated: true)
      }
      
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
        switch status {
        case .authorized, .limited:
          DispatchQueue.main.async {
            self.navigationController?.pushViewController(galleryVC, animated: true)
          }
        default:
          break
        }
      }

    default:
      presentAuthenticationAlert()
    }
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
  
  private func updateConstraints() {
    guard let images = reactor?.currentState.currentImages else { return }
    
    if images.count > 0 {
      pictsCollectionView.isHidden = false
      
      contentsTv.snp.updateConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(pictsCollectionView.snp.bottom).offset(16)
        make.bottom.equalTo(bottomContainerView.snp.top).offset(-16)
      }
    } else {
      pictsCollectionView.isHidden = true
      
      contentsTv.snp.updateConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(pictsCollectionView.snp.bottom).offset(-84)
        make.bottom.equalTo(bottomContainerView.snp.top).offset(-16)
      }
    }
  }
}

// MARK: - CollectionView Setup

extension PostingViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    guard let images = reactor?.currentState.currentImages else { return 0 }
    return images.count
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: ImageCell.identifier,
      for: indexPath
    ) as? ImageCell,
          let reactor = reactor else {
      return UICollectionViewCell()
    }
    
    let image = reactor.currentState.currentImages[indexPath.row]
    cell.setupImage(image)
    
    // 특정 셀 지우기
    cell.deleteCompletion = {
      reactor.action.onNext(.didTapDeleteBtn(indexPath.row))
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
