//
//  ChangeNickNameVC.swift
//  idorm
//
//  Created by 김응철 on 2022/09/04.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ChangeNicknameViewController: UIViewController {
  // MARK: - Properties
  lazy var backgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    
    return view
  }()
  
  lazy var mainLabel: UILabel = {
    let label = UILabel()
    label.textColor = .idorm_gray_400
    label.font = .init(name: Font.regular.rawValue, size: 16)
    label.text = "idorm 프로필 닉네임을 변경해주세요."
    
    return label
  }()
  
  let viewModel = ChangeNicknameViewModel()
  let disposeBag = DisposeBag()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
    configureUI()
  }
  
  // MARK: - Bind
  func bind() {
    // --------------------------------
    // --------------INPUT-------------
    // --------------------------------
    
    // --------------------------------
    // -------------OUTPUT-------------
    // --------------------------------
  }
  
  // MARK: - Helpers
  func configureUI() {
    view.backgroundColor = .idorm_gray_100
    navigationController?.title = "닉네임"
  }
}
