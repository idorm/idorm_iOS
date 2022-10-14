//
//  OnboardingImageViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/14.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

final class OnboardingDetailViewController: BaseViewController {
  
  // MARK: - Properties
  
  private lazy var floatyBottomView: OnboardingFloatyBottomView = {
    let floatyBottomView = OnboardingFloatyBottomView()
    floatyBottomView.configureUI(type: .detail)
    
    return floatyBottomView
  }()
  
  private lazy var backButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
    button.tintColor = .black
    
    return button
  }()
  
  private lazy var indicator = UIActivityIndicatorView()
  private lazy var myInfoView = MyInfoView(myInfo: matchingInfo)
  
  private var viewModel: OnboardingDetailViewModel!
  let matchingInfo: MatchingInfo
  
  // MARK: - Init
  
  init(matchingInfo: MatchingInfo) {
    self.matchingInfo = matchingInfo
    self.viewModel = OnboardingDetailViewModel(matchingInfo)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - LifeCycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    floatyBottomView.confirmButton.isUserInteractionEnabled = true
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    [floatyBottomView, myInfoView, indicator]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    floatyBottomView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
      make.height.equalTo(76)
    }
    
    myInfoView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.centerY.equalTo(view.safeAreaLayoutGuide).offset(-50)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(20)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
    navigationItem.title = "내 프로필 이미지"
  }
  
  override func bind() {
    super.bind()
    
    // ---------------------------------
    // ---------------INPUT-------------
    // ---------------------------------
    
    // 뒤로 가기 버튼 이벤트
    floatyBottomView.skipButton.rx.tap
      .bind(to: viewModel.input.didTapBackButton)
      .disposed(by: disposeBag)
    
    // 완료 버튼 이벤트
    floatyBottomView.confirmButton.rx.tap
      .bind(to: viewModel.input.didTapConfirmButton)
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
    
    // 애니메이션 시작
    viewModel.output.startAnimation
      .bind(onNext: { [weak self] in
        self?.indicator.startAnimating()
        self?.view.isUserInteractionEnabled = false
      })
      .disposed(by: disposeBag)
    
    // 애니메이션 종료
    viewModel.output.stopAnimation
      .bind(onNext: { [weak self] in
        self?.indicator.stopAnimating()
        self?.view.isUserInteractionEnabled = true
      })
      .disposed(by: disposeBag)
  }
}

