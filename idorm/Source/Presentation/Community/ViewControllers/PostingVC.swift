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
import RxSwift
import RxCocoa
import Photos

final class PostingViewController: BaseViewController, View {
  
  // MARK: - UI COMPONENTS
  
  private lazy var photoCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.register(
      PostingPhotoCell.self,
      forCellWithReuseIdentifier: PostingPhotoCell.identifier
    )
    cv.showsHorizontalScrollIndicator = false
    cv.dataSource = self
    cv.delegate = self
    
    return cv
  }()
  
  private lazy var doneButton: UIButton = {
    let button = UIButton()
    var config = UIButton.Configuration.plain()
    var container = AttributeContainer()
    container.font = .idormFont(.bold, size: 16)
    config.attributedTitle = AttributedString("완료", attributes: container)
    
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .disabled:
        button.configuration?.baseForegroundColor = .idorm_gray_300
      case .normal:
        button.configuration?.baseForegroundColor = .idorm_blue
      default:
        break
      }
    }
    
    button.configuration = config
    button.configurationUpdateHandler = handler
    
    return button
  }()
  
  private let titleTextField: UITextField = {
    let tf = UITextField()
    tf.attributedPlaceholder = NSAttributedString(
      string: "제목",
      attributes: [
        .strokeColor: UIColor.idorm_gray_200,
        .font: UIFont.init(name: IdormFont_deprecated.bold.rawValue, size: 20)!
      ]
    )
    tf.font = .init(name: IdormFont_deprecated.bold.rawValue, size: 20)
    tf.textColor = .black
    
    return tf
  }()
  
  private let contentTextView: RSKPlaceholderTextView = {
    let tv = RSKPlaceholderTextView()
    tv.attributedPlaceholder = NSAttributedString(
      string: """
              기숙사에 있는 학우들에게 질문하거나
              함께 이야기를 나누어보세요.
              """,
      attributes: [
        .strokeColor: UIColor.idorm_gray_200,
        .font: UIFont(name: IdormFont_deprecated.medium.rawValue, size: 16)!
      ]
    )
    tv.font = .init(name: IdormFont_deprecated.medium.rawValue, size: 16)
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
  
  private let currentPictsCountLabel: UILabel = {
    let lb = UILabel()
    lb.text = "0"
    lb.font = .idormFont(.medium, size: 12)
    lb.textColor = .black
    
    return lb
  }()
  
  private let pictsCountLb: UILabel = {
    let lb = UILabel()
    lb.text = "/10"
    lb.textColor = .black
    lb.font = .idormFont(.medium, size: 12)
    
    return lb
  }()
  
  private let anonymousLabel: UILabel = {
    let lb = UILabel()
    lb.text = "익명"
    lb.font = .idormFont(.medium, size: 12)
    
    return lb
  }()
  
  private let anonymousButton: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "circle_blue_gray"), for: .selected)
    btn.setImage(UIImage(named: "circle_gray"), for: .normal)
    btn.isSelected = true
    return btn
  }()
  
  private let bottomWhiteView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    
    return view
  }()
  
  private let indicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView()
    indicator.color = .darkGray
    
    return indicator
  }()
  
  private let photoImageView = UIImageView(image: UIImage(named: "picture_medium"))
  
  // MARK: - PROPERTIES
  
  var completion: (() -> Void)?
  
  // MARK: - LIFE CYCLE
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configurePost()
  }
  
  // MARK: - SETUP
  
  private func configurePost() {
    guard let post = self.reactor?.post else { return }
    self.titleTextField.text = post.title
    self.contentTextView.text = post.content
    anonymousButton.isSelected = post.isAnonymous
    self.reactor?.action.onNext(.didChangeTitle(post.title))
    self.reactor?.action.onNext(.didChangeContent(post.content))
    // TODO: isAnonymous 프로퍼티가 Post DTO에서 필요
    /// Label의 "익명"이 들어있다고 실제 익명인지 판단할 수 없음 -> 닉네임이 "~익명~" 일 수도 있기 떄문에
    // TODO: photoCollectionView 설정
  }
  
  override func setupStyles() {
    self.navigationItem.title = "글쓰기"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
    self.view.backgroundColor = .white
    self.doneButton.isEnabled = false
  }
  
  override func setupLayouts() {
    [
      self.titleTextField,
      self.separatorLine,
      self.photoCollectionView,
      self.contentTextView,
      self.bottomContainerView,
      self.bottomWhiteView,
      self.indicator
    ].forEach {
      self.view.addSubview($0)
    }
    
    [
      self.photoImageView,
      self.currentPictsCountLabel,
      self.pictsCountLb,
      self.anonymousLabel,
      self.anonymousButton
    ].forEach {
      self.bottomContainerView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.titleTextField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(30)
    }
    
    self.separatorLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(0.3)
      make.top.equalTo(self.titleTextField.snp.bottom).offset(12)
    }
    
    self.photoCollectionView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(self.separatorLine.snp.bottom).offset(16)
      make.height.equalTo(85)
    }
    
    self.contentTextView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.photoCollectionView.snp.bottom).offset(16)
      make.bottom.equalTo(self.bottomContainerView.snp.top).offset(-16)
    }
    
    self.bottomContainerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
      make.height.equalTo(56)
    }
    
    self.photoImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
    }

    self.currentPictsCountLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.photoImageView.snp.trailing).offset(10)
      make.centerY.equalTo(self.photoImageView)
    }
    
    self.pictsCountLb.snp.makeConstraints { make in
      make.leading.equalTo(currentPictsCountLabel.snp.trailing)
      make.centerY.equalTo(photoImageView)
    }
    
    self.anonymousLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalTo(self.anonymousButton.snp.leading).offset(-6)
    }
    
    self.anonymousButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
    }
    
    self.indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    if DeviceManager.shared.hasNotch() {
      self.bottomWhiteView.snp.makeConstraints { make in
        make.height.equalTo(50)
        make.leading.trailing.bottom.equalToSuperview()
      }
    }
    
    updateConstraints()
  }
  
  // MARK: - Bind
  
  func bind(reactor: PostingViewReactor) {
    
    // MARK: - Action
    
    rx.viewDidLoad
      .map { PostingViewReactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 사진 버튼 클릭
    photoImageView.rx.tapGesture()
      .skip(1)
      .map { _ in PostingViewReactor.Action.didTapPictIv }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 제목 변경
    titleTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .map { PostingViewReactor.Action.didChangeTitle($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 내용 변경
    contentTextView.rx.text
      .orEmpty
      .distinctUntilChanged()
      .map { PostingViewReactor.Action.didChangeContent($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 익명 버튼 이벤트
    anonymousButton.rx.tap
      .withUnretained(self)
      .do { $0.0.anonymousButton.isSelected.toggle() }
      .map { $0.0.anonymousButton.isSelected }
      .map { PostingViewReactor.Action.didTapAnonymousBtn($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 완료 버튼
    doneButton.rx.tap
      .map { PostingViewReactor.Action.didTapCompleteBtn }
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
        $0.0.photoCollectionView.reloadData()
      }
      .disposed(by: disposeBag)
    
    // 현재 사진 갯수
    reactor.state
      .map { $0.currentImages.count }
      .map { String($0) }
      .distinctUntilChanged()
      .bind(to: currentPictsCountLabel.rx.text)
      .disposed(by: disposeBag)
    
    // 완료버튼 활성/비활성
    reactor.state
      .map { $0.isEnabledCompleteBtn }
      .distinctUntilChanged()
      .bind(to: doneButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    // 뒤로가기
    reactor.state
      .map { $0.popVC }
      .filter { $0 }
      .withUnretained(self)
      .bind {
        $0.0.completion?()
        $0.0.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
    
    // 로딩 인디케이터 제어
    reactor.state
      .map { $0.isLoading }
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 화면 인터렉션 제어
    reactor.state
      .map { !$0.isLoading }
      .distinctUntilChanged()
      .bind(to: view.rx.isUserInteractionEnabled)
      .disposed(by: disposeBag)
  }
  
  // MARK: - HELPERS
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
  
  private func checkAuthorization() {
    let galleryVC = GalleryViewController(count: reactor?.currentState.currentImages.count ?? 0)
    
    galleryVC.completion = { [weak self] assets in
      // 선택된 이미지 반응
      let manager = PHImageManager.default()
      var images: [UIImage] = []
      assets.forEach {
        images.append($0.getImageFromPHAsset())
      }
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
      photoCollectionView.isHidden = false
      
      contentTextView.snp.updateConstraints { make in
        make.leading.trailing.equalToSuperview().inset(20)
        make.top.equalTo(photoCollectionView.snp.bottom).offset(16)
        make.bottom.equalTo(bottomContainerView.snp.top).offset(-16)
      }
    } else {
      photoCollectionView.isHidden = true      
      
      contentTextView.snp.updateConstraints { make in
        make.leading.trailing.equalToSuperview().inset(20)
        make.top.equalTo(photoCollectionView.snp.bottom).offset(-84)
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
      withReuseIdentifier: PostingPhotoCell.identifier,
      for: indexPath
    ) as? PostingPhotoCell,
          let reactor = reactor else {
      return UICollectionViewCell()
    }
    
    let image = reactor.currentState.currentImages[indexPath.row].image
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
