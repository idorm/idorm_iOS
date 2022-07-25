//
//  OnboardingImageViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/14.
//

import UIKit
import SnapKit

class OnboardingDetailViewController: UIViewController {
  // MARK: - Properties
  lazy var myInfoView: MyInfoView = {
    let view = MyInfoView()
    
    return view
  }()
  
  lazy var floatyBottomView: OnboardingDetailFloatyBottomView = {
    let view = OnboardingDetailFloatyBottomView()
    view.skipButton.addTarget(self, action: #selector(didTapSkipButton), for: .touchUpInside)
    
    return view
  }()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  // MARK: - Selectors
  @objc private func didTapSkipButton() {
    navigationController?.popViewController(animated: true)
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    navigationItem.title = "내 프로필 이미지"
  }
}
