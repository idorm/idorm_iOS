import UIKit

import SnapKit
import RSKPlaceholderTextView
import Photos
import RxSwift
import RxCocoa

class PostingViewController: UIViewController {
  // MARK: - Properties
  private var selectedAssets: [PHAsset] = []
  
  lazy var pictureButton: UIButton = {
    let btn = UIButton(type: .custom)
    btn.setImage(UIImage(named: "picture"), for: .normal)
    btn.addTarget(self, action: #selector(didTapPictureButton), for: .touchUpInside)
    
    return btn
  }()
  
  lazy var pictCountLabel: UILabel = {
    let label = UILabel()
    label.text = "0/10"
    label.font = .init(name: MyFonts.medium.rawValue, size: 12)
    label.textColor = .black
    
    return label
  }()
  
  lazy var confirmButton: UIButton = {
    let btn = UIButton(type: .custom)
    btn.setTitle("완료", for: .normal)
    btn.setTitleColor(UIColor.idorm_gray_300, for: .normal)
    btn.titleLabel?.font = .init(name: MyFonts.bold.rawValue, size: 16)
    btn.addTarget(self, action: #selector(didTapPostingButton), for: .touchUpInside)
    
    return btn
  }()
  
  lazy var titleTextField: UITextField = {
    let tf = UITextField()
    let attributedString = NSAttributedString(
      string: "제목",
      attributes: [
        NSAttributedString.Key.font: UIFont.init(name: MyFonts.bold.rawValue, size: 20) ?? 0,
        NSAttributedString.Key.foregroundColor: UIColor.idorm_gray_200
      ])
    tf.attributedPlaceholder = attributedString
    tf.font = .init(name: MyFonts.bold.rawValue, size: 20)
    
    return tf
  }()
  
  lazy var separatorLine: UIView = {
    let view = UIView()
    view.backgroundColor = .idorm_gray_200
    
    return view
  }()
  
  lazy var pictureStack: UIStackView = {
    let pictureStack = UIStackView(arrangedSubviews: [ pictureButton, pictCountLabel ])
    pictureStack.axis = .horizontal
    pictureStack.spacing = 8

    return pictureStack
  }()
  
  lazy var textView: RSKPlaceholderTextView = {
    let textView = RSKPlaceholderTextView()
    textView.placeholderColor = .idorm_gray_200
    textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    let attributedString = NSAttributedString(
      string:
                """
            기숙사에 있는 학우들에게
            질문하거나 함께 이야기를 나누어 보세요.
            """,
      attributes: [NSAttributedString.Key.font: UIFont.init(name: MyFonts.medium.rawValue, size: 16) ?? 0])
    textView.attributedPlaceholder = attributedString
    
    return textView
  }()
  
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 8
    layout.itemSize = CGSize(width: 86, height: 86)
    layout.scrollDirection = .horizontal
    layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(PostingPictureCollectionViewCell.self, forCellWithReuseIdentifier: PostingPictureCollectionViewCell.identifier)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.dataSource = self
    collectionView.delegate = self
    
    return collectionView
  }()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    checkCollectionViewHidden()
    checkAlbumPermission()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    collectionView.reloadData()
  }
  
  // MARK: - Selectors
  @objc private func didTapPostingButton() {
    
  }
  
  @objc private func didTapPictureButton() {
    let imagePickerVC = ImagePickerViewController(count: selectedAssets.count)
    imagePickerVC.delegate = self
    navigationController?.pushViewController(imagePickerVC, animated: true)
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    navigationItem.title = "글 쓰기"
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: confirmButton)
    tabBarController?.tabBar.isHidden = true
    
    [ titleTextField, separatorLine, textView, pictureStack, collectionView ]
      .forEach { view.addSubview($0) }
    
    titleTextField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(28)
      make.top.equalTo(view.safeAreaLayoutGuide).inset(31)
    }
    
    separatorLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(28)
      make.top.equalTo(titleTextField.snp.bottom).offset(12)
      make.height.equalTo(0.3)
    }
    
    pictureStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(22)
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-42)
      make.height.equalTo(24)
    }
    
    textView.snp.makeConstraints { make in
      make.top.equalTo(separatorLine.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(pictureStack.snp.top)
    }
  }
  
  private func checkCollectionViewHidden() {
    collectionView.snp.removeConstraints()
    textView.snp.removeConstraints()

    if selectedAssets.isEmpty {
      textView.snp.makeConstraints { make in
        make.top.equalTo(separatorLine.snp.bottom).offset(16)
        make.leading.trailing.equalToSuperview().inset(24)
        make.bottom.equalTo(pictureStack.snp.top)
      }
    } else {
      collectionView.snp.makeConstraints { make in
        make.top.equalTo(separatorLine.snp.bottom).offset(16)
        make.leading.trailing.equalToSuperview()
        make.height.equalTo(86)
      }

      textView.snp.makeConstraints { make in
        make.top.equalTo(collectionView.snp.bottom).offset(16)
        make.leading.trailing.equalToSuperview().inset(24)
        make.bottom.equalTo(pictureStack.snp.top)
      }
    }
    collectionView.reloadData()
  }
  
  private func checkAlbumPermission() {
    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
      switch status {
      case .authorized:
        print("Album: 권한 허용")
      case .denied:
        print("Album: 권한 거부")
      case .restricted, .notDetermined:
        print("Album: 선택하지 않음")
      default:
        break
      }
    }
  }
}

extension PostingViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostingPictureCollectionViewCell.identifier, for: indexPath) as? PostingPictureCollectionViewCell else { return UICollectionViewCell() }
    cell.configureUI(asset: selectedAssets[indexPath.row])
    cell.delegate = self
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return selectedAssets.count
  }
}

extension PostingViewController: PostingPictureCollectionViewCellDelegate {
  func didTapXmarkbutton(asset: PHAsset) {
    if let index = self.selectedAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
      selectedAssets.remove(at: index)
      checkCollectionViewHidden()
      pictCountLabel.text = "\(selectedAssets.count)/10"
    }
  }
}

extension PostingViewController: ImagePickerViewControllerDelegate {
  func didTapConfirmButton(assets: [PHAsset]) {
    self.selectedAssets.append(contentsOf: assets)
    checkCollectionViewHidden()
    pictCountLabel.text = "\(selectedAssets.count)/10"
  }
}
