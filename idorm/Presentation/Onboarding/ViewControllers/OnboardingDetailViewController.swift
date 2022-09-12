//
//  OnboardingImageViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/14.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class OnboardingDetailViewController: UIViewController {
  // MARK: - Properties
  lazy var myInfoView = MyInfoView(myInfo: myInfo)
  
  lazy var floatyBottomView: OnboardingFloatyBottomView = {
    let floatyBottomView = OnboardingFloatyBottomView()
    floatyBottomView.configureUI(type: .detail)
    
    return floatyBottomView
  }()
  
  lazy var backButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
    button.tintColor = .black
    
    return button
  }()
  
  let myInfo: MyInfo
  let disposeBag = DisposeBag()
  let viewModel = OnboardingDetailViewModel()
  
  // MARK: - LifeCycle
  init(myInfo: MyInfo) {
    self.myInfo = myInfo
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bind()
  }
  
  // MARK: - Selectors
  @objc private func didTapSkipButton() {
    navigationController?.popViewController(animated: true)
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    navigationItem.title = "내 프로필 이미지"
    navigationItem.hidesBackButton = true
    
    [ floatyBottomView, myInfoView ]
      .forEach { view.addSubview($0) }
    
    floatyBottomView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
      make.height.equalTo(76)
    }
    
    myInfoView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.centerY.equalTo(view.safeAreaLayoutGuide).offset(-50)
    }
  }
  
  private func bind() {
    // ---------------------------------
    // ---------------INPUT-------------
    // ---------------------------------
    floatyBottomView.skipButton.rx.tap
      .bind(to: viewModel.input.didTapBackButton)
      .disposed(by: disposeBag)
    
    // ---------------------------------
    // --------------OUTPUT-------------
    // ---------------------------------
    // 뒤로가기
    viewModel.output.popVC
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
  }
}

