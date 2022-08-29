//
//  ManageMyInfoViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/08/28.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ManageMyInfoViewController: UIViewController {
  // MARK: - Properties
  lazy var tableView: UITableView = {
    let tv = UITableView(frame: .zero, style: .grouped)
    
    return tv
  }()
  
  lazy var profileImage: UIImageView = UIImageView(image: UIImage(named: "myProfileImage(MyPage)"))
  
  let disposeBag = DisposeBag()
  let viewModel = ManageMyInfoViewModel()
  
  // MARK: - LifeCycle
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  func bind() {
    // --------------------------------
    // --------------INPUT-------------
    // --------------------------------
    rx.viewDidLoad
      .bind(to: viewModel.input.viewDidLoad)
      .disposed(by: disposeBag)
    
    rx.viewWillAppear
      .map { _ in Void() }
      .bind(to: viewModel.input.viewWillAppear)
      .disposed(by: disposeBag)
    
    // --------------------------------
    // -------------OUTPUT-------------
    // --------------------------------
    viewModel.output.configureUI
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.configureUI()
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  func configureUI() {
    self.navigationItem.title = "내 정보 관리"
    self.view.backgroundColor = .white
  }
}
