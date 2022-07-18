//
//  WritingViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/17.
//

import SnapKit
import UIKit
import RSKPlaceholderTextView
import Photos

class WritingViewController: UIViewController {
    // MARK: - Properties
    lazy var pictureButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "picture"), for: .normal)
        btn.addTarget(self, action: #selector(didTapPictureButton), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var pictCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/10"
        label.font = .init(name: Font.medium.rawValue, size: 12)
        label.textColor = .black
        
        return label
    }()
    
    lazy var confirmButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("완료", for: .normal)
        btn.setTitleColor(UIColor.grey_custom, for: .normal)
        btn.titleLabel?.font = .init(name: Font.bold.rawValue, size: 16)
        btn.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var titleTextField: UITextField = {
        let tf = UITextField()
        let attributedString = NSAttributedString(
            string: "제목",
            attributes: [
                NSAttributedString.Key.font: UIFont.init(name: Font.bold.rawValue, size: 20) ?? 0,
                NSAttributedString.Key.foregroundColor: UIColor.bluegrey
            ])
        tf.attributedPlaceholder = attributedString
        tf.font = .init(name: Font.bold.rawValue, size: 20)
        
        return tf
    }()
    
    lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .bluegrey
        
        return view
    }()
    
    lazy var textView: RSKPlaceholderTextView = {
        let textView = RSKPlaceholderTextView()
        textView.placeholderColor = .bluegrey
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let attributedString = NSAttributedString(
            string:
                """
            기숙사에 있는 학우들에게
            질문하거나 함께 이야기를 나누어 보세요.
            """,
            attributes: [NSAttributedString.Key.font: UIFont.init(name: Font.medium.rawValue, size: 16) ?? 0])
        textView.attributedPlaceholder = attributedString
       
        return textView
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout(section: createSection())
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return collectionView
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        checkAlbumPermission()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewWillAppear!")
    }
    
    // MARK: - Selectors
    @objc private func didTapConfirmButton() {
    }
    
    @objc private func didTapPictureButton() {
        let imagePickerVC = ImagePickerViewController()
        navigationController?.pushViewController(imagePickerVC, animated: true)
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "글 쓰기"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: confirmButton)
        tabBarController?.tabBar.isHidden = true
        
        let pictureStack = UIStackView(arrangedSubviews: [ pictureButton, pictCountLabel ])
        pictureStack.axis = .horizontal
        pictureStack.spacing = 8
        
        [ titleTextField, separatorLine, textView, pictureStack ]
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
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(200)
        }
        
        pictureStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(22)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-42)
            make.height.equalTo(24)
        }
    }
    
    private func checkCollectionViewHidden() {
        
    }
    
    private func createSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(80.0), heightDimension: .absolute(134.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(80.0), heightDimension: .absolute(134.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(8.0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)
        section.interGroupSpacing = 8.0
        section.orthogonalScrollingBehavior = .continuous
        
        return section
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
